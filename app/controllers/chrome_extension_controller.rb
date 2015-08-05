class ChromeExtensionController < ApplicationController


	def resolve_chrome_email
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

		chrome_email = params[:chrome_email]
		chrome_members = ChromeMember.where(chrome_email: chrome_email)
		if member_email_hash.keys.include?(chrome_email)
			render json: chrome_email, status:200 
		elsif chrome_members.length > 0
			render json: chrome_members[0].member_email, status:200
		else
			render json: chrome_email, status: 200
		end
	end

	def get_tracking_event
		# member email, link id, key, time
	end

	def tracker
		render 'tracker', layout: false
	end

	def my_bundles
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		email = params[:email]
		render json: ParseGoLinkBundle.my_bundles(email).to_a, status:200
	end

	def get_bundle_keys
		name = params[:name]
		bundle = ParseGoLinkBundle.where(name: name).to_a[0]
		render json: bundle.keys, status: 200
	end

	def create_bundle
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

		name = params[:name]
		urls = params[:urls].split(',')
		titles = params[:titles].split(',')
		original_urls = urls.clone
		email = params[:email]


		data = cached_golinks.select{|x| urls.include?(x.url)}.map{|x| [x.key, x.url]}
		existing_keys = data.select{|x| x[0]}
		existing_urls = data.select{|x| x[1]}

		keys = Array.new
		data.each do |datum|
			keys << datum[0]
			idx = urls.index(datum[1])
			urls.delete(idx)
			titles.delete(idx)
		end
		new_golinks = Array.new
		urls.each_with_index do |url, i|
			key = titles[i]
			keys << key
			new_golinks << ParseGoLink.new(key:key, member_email:email, url: url, type:'bundle',description: 'auto generated for bundle ' + name, tags:['bundle', 'autogenerated'])
		end
		ParseGoLink.save_all(new_golinks)
		existing_bundles = ParseGoLinkBundle.limit(10000).where(name: name)
		ParseGoLinkBundle.destroy_all(existing_bundles)

		if name == nil or name == ''
			render json: '<h3>That bundle name was invalid</h3>', status:200
		else
			ParseGoLinkBundle.create(name: name, keys: keys, urls: original_urls, groups:[member_email_hash[email].name])
			Thread.new{
				puts 'caching permissions on bundles'
				ParseGoLinkBundle.cache_permissions
				puts 'finished caching bundle permissions'
			}
			render json: '<h3>Your bundle '+name+' was created</h3>', status:200
		end
	end


	def most_used_links
		email = params[:email]
		clicks = ParseGoLinkClick.limit(100000).where(member_email:email).sort_by{|x| x.time}.reverse[0..25]
		@keys = Set.new(clicks.map{|x| x.key})
		# @golinks = cached_golinks.select{|x| keys.include?(x.key)}


		# @golinks = cached_golinks[0..10]
		render 'most_used_links', layout: false
	end


	def create_go_link

		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

		key = params[:key]
		url = params[:url]
		description = params[:description]
		tags = nil
		# directory = params[:directory] != "" ? params[:directory] : '/PBL'
		# tags = params[:tags].split(',')
		# override = (key.include?(':') and key.split(':')[-1] == 'override') ? true : false
		# if override
		# 	key = key.split(':')[0]
		# end
		""" save the new link dont check for errors"""
		golink = ParseGoLink.new(key: key, url: url, description: description, tags: ['new_xtension'], directory: '/tags')
		if params[:email] and params[:email] != ""
			golink.member_email = params[:email]
		end
		golink.save
		clear_go_cache
		render json: "<h3>Successfully created link</h3><ul class = 'list-group'><li class = 'list-group-item lookup-match'>pbl.link/"+golink.key+"</li></ul><button class = 'btn btn-danger undo-btn' id = "+golink.id+">Undo</button>", :status=>200, :content_type=>'text/html'
	end

	def undo_create
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

		id = params[:id]

		# override = (key.include?(':') and key.split(':')[-1] == 'override') ? true : false
		# if override
		# 	key = key.split(':')[0]
		# end

		ParseGoLink.destroy_all(ParseGoLink.where(id: id).to_a)
		# clear_go_cache
		render json: "<h3>Your golink has been removed</h3>", :status => 200
	end

	def lookup_url
		url = params[:url]
		@matches = go_link_key_hash.values.select{|x| x.is_url_match(url)}
		puts 'this is matches'
		puts @matches

		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		if @matches.length == 0 
			render json: "<h4>This URL is not in PBL Links yet</h4>", :status=>200, :content_type=>'text/html'
		else
			# render json: match_string, :status=>200, :content_type=>'text/html'
			render 'lookup_url.html.erb', :layout=>false
		end
	end


	def create_directory
		directory = params[:directory] 
		if ParseGoLink.create_directory(directory)
			clear_go_cache
			response.headers['Access-Control-Allow-Origin'] = '*'
			response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
			response.headers['Access-Control-Request-Method'] = '*'
			response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
			render json: "<h3>Successfully created " + directory + "</h3>", :status=>200, :content_type=>'text/html'
		else
			render json: "Error creating directory", :status=>500, :content_type=>'text/html'
		end
	end

	def directories_dropdown
		@golinks = go_link_key_hash.values
		@directory_hash = ParseGoLink.directory_hash(@golinks) #.dir_hash
		@directories = @directory_hash.keys.sort
		@one_ply = ParseGoLink.one_ply(@directories)
		@directory_tree = ParseGoLink.n_ply_tree(@directories)
		@all_directories = ParseGoLink.all_directories(@golinks)
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		render 'directories_dropdown', layout: false
	end

	def search
		search_term = params[:search_term]
		key_hash = go_link_key_hash
		golinks = ParseGoLink.search(search_term)
		results = golinks.map{|x| x.key}

		# log this search event
		search_email = params[:email] ? params[:email] : nil
		search_event = ParseGoLinkSearch.create(member_email: search_email, search_term: search_term, results: results, type: 'chrome', time: Time.now)

		# results = Array.new
		# keys.each do |key|
		# 	results << key_hash[key]
		# end
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		render json: golinks, :status=>200
	end

	def favorite_links
		email = params[:email]
		existing_keys = go_link_key_hash.keys
		@favorite_links = (go_link_favorite_hash.keys.include?(email) ? Set.new(go_link_favorite_hash[email].select{|x| existing_keys.include?(x)}) : Array.new)
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		render 'favorite_links', layout: false
	end

	def chrome_sync
		@current_member = current_member
	end

end