class ParseGoLink < ParseResource::Base
	fields :key, :url, :description, :tags, :member_id, :old_id, :type, :directory, :old_member_id
	
	def short_url(len = 50)
		if url.length > len
			return url.first(len) + "..."
		else
			return url
		end
	end


	def dir
		if self.directory and self.directory.include?('/')
			return self.directory
		end
		return '/'
	end

	def dir_array
		dir_a = self.dir.split("/").select{|x| x != ""}
		dir_a.insert(0, "/")
		return dir_a
	end

	def self.dir_hash
		ParseGoLink.all.index_by(&:dir)
	end

	def self.get_dirs
		ParseGoLink.all.uniq{|x| x.dir}.map{|x| x.dir}
	end

	def self.get_subdirs(dir, all_dirs)
		all_dirs.select{|x| x.start_with?(dir)}.select{|x| x!=dir}
	end

	def get_type_image
		type = self.resolve_type
		# if not self.type or self.type == nil
		# 	return '/assets/pbl-logo.png'
		# end
		prefix = '/assets/'
		image_hash = Hash.new
		image_hash['document'] = 'gdoc-icon.png'
		image_hash['spreadsheets'] = 'gsheet-icon.png'
		image_hash['facebook'] = 'facebook-icon.png'
		image_hash['trello'] = 'trello-logo.png'
		image_hash['youtube'] = 'youtube-logo.png'
		image_hash['box'] = 'box-icon.png'
		image_hash['piazza'] = 'piazza-icon.png'
		image_hash['flickr'] = 'flickr-logo.png'
		image_hash['git'] = 'git-icon.png'
		image_hash['other'] = 'pbl-logo.png'
		image_hash['drive'] = 'drive-logo.png'
		image_hash['instagram'] = 'instagram-logo.png'
		return prefix + image_hash[type]
	end

	def resolve_type
		type = 'other'
		url = self.url
		if url.include?('docs.google.com/document')
			type = 'document'
		elsif url.include?('docs.google.com/spreadsheets')
			type = 'spreadsheets'
		elsif url.include?('trello.com')
			type = 'trello'
		elsif url.include?('flickr.com')
			type = 'flickr'
		elsif url.include?('box.com')
			type = 'box'
		elsif url.include?('youtube.com')
			type = 'youtube'
		elsif url.include?('facebook.com')
			type = 'facebook'
		elsif url.include?('github.com')
			type = 'git'
		elsif url.include?('piazza.com')
			type = 'piazza'
		elsif url.include?('drive.google.com')
			type = 'drive'
		elsif url.include?('instagram')
			type = 'instagram'
		end
		return type
	end

	def updated_at_string
	    Date.parse(self.updated_at).strftime("%b %e, %Y")
  	end

	def self.hash
		# hash = Rails.cache.read('go_link_hash')
		# if hash != nil
		# 	return hash
		# end

		hash = ParseGoLink.all.index_by(&:id)
		Rails.cache.write('go_link_hash', hash)
		return hash
	end

	def self.key_hash
		l_hash = self.hash
		l_hash.values.index_by(&:key)
	end


	""" elasticsearch methods"""
	def self.import
		# create GoLink Objects
		GoLink.destroy_all
		puts 'requesting text hash...'
		parse_text_hash = ParseElasticsearchData.all.index_by(&:go_link_id)
		parse_text_hash_keys = parse_text_hash.keys
		puts 'received text hash!'
		ParseGoLink.limit(10000).all.each do |pgl|
			puts pgl.key
			gl = GoLink.new
			gl.key = pgl.key
			gl.url = pgl.url
			gl.description = pgl.description
			gl.member_id = pgl.member_id
			gl.parse_id = pgl.id
			if parse_text_hash_keys.include?(pgl.id)
				gl.text = parse_text_hash[pgl.id].text
			else
				gl.text = ''
			end
			gl.save
		end
		GoLink.import
		puts 'imported into elasticsearch index'
	end

	def self.search(search_term)
		GoLink.search(search_term)
	end
	
	""" catalogue methods DEPRECATED""" 
	def self.catalogue_by_resource_type
		types = Array.new
		types_keyword = Array.new

		types << 'Google Drive'
		types_keyword << 'drive.google.com'

		types << 'Google Docs'
		types_keyword << 'docs.google.com'

		types << 'Piazza'
		types_keyword << 'piazza.com'

		types << 'PBL Portal'
		types_keyword << '.berkeley-pbl.com'

		types << 'Google Forms'
		types_keyword << '/viewform'

		# types << 'other'
		# types_keyword << ''
		# set up result hash
		result = Hash.new
		types.each do |type|
			result[type] = Array.new
		end
		result['other'] = Array.new
		# populate result hash with list of links for each type
		link_hash = self.hash
		link_hash.keys.each do |id|
			url = link_hash[id].url
			matches = 0
			types.each_with_index do |type, index|
				if url.include?(types_keyword[index])
					result[type] << id
					matches = matches + 1
				end
			end
			if matches == 0
				result['other'] << id
			end
		end
		# remove empty partitions
		empty_partitions = Array.new
		result.keys.each do |partition|
			if result[partition].length < 1
				empty_partitions << partition
			end
		end
		empty_partitions.each do |partition|
			result.delete(partition)
		end
		return result
	end

	def self.catalogue_by_fix
		result = Hash.new
		link_hash = self.hash
		link_hash.keys.each do |id|
			key = link_hash[id].key
			chunks = key.split('-')
			chunks.each do |chunk|
				if not result.keys.include?(chunk)
					result[chunk] = Array.new
				end
				result[chunk] << id
			end
		end
		puts 'this is the resul'
		puts result
		return result
	end

	""" migration methods""" 
	def self.migrate_type
		golinks = ParseGoLink.all.to_a
		to_save = Array.new
		golinks.each do |golink|
			type = 'other'
			url = golink.url
			if url.include?('docs.google.com/document')
				type = 'document'
			elsif url.include?('docs.google.com/spreadsheets')
				type = 'spreadsheets'
			elsif url.include?('trello.com')
				type = 'trello'
			elsif url.include?('flickr.com')
				type = 'flickr'
			elsif url.include?('box.com')
				type = 'box'
			elsif url.include?('youtube.com')
				type = 'youtube'
			elsif url.include?('facebook.com')
				type = 'facebook'
			elsif url.include?('github.com')
				type = 'git'
			elsif url.include?('piazza.com')
				type = 'piazza'
			elsif url.include?('drive.google.com')
				type = 'drive'
			elsif url.include?('instagram')
				type = 'instagram'
			end
			puts url + " : " + type
			golink.type = type
			to_save << golink
		end
		ParseGoLink.save_all(to_save)
	end

	def self.migrate_member_id
		puts 'not implemented yet'
	end
	def self.migrate_directory
		golinks = ParseGoLink.all.to_a
		save_array = Array.new
		golinks.each do |golink|
			golink.directory = '/'
			save_array << golink
		end
		ParseGoLink.save_all(save_array)
	end
end
