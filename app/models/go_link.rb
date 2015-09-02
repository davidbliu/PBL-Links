class GoLink < ParseResource::Base
	fields :key, :url, :description, :type, :email, :permissions, :parse_id
	def self.import
		puts 'importing go links'
		GoLink.limit(100000).all.each do |golink|
			print '.'
			egl = ElasticsearchGoLink.where(key: golink.key, parse_id: golink.id).first_or_create
			egl.url = golink.url
			egl.description = golink.description
			egl.email = golink.email
			egl.permissions = golink.permissions
			egl.golink_type = golink.type
			egl.save
		end
		ElasticsearchGoLink.import
	end

	def self.search(search_term)
		results = ElasticsearchGoLink.search(query: {multi_match: {query: search_term, fields: ['key^3', 'golink_type^2', 'description', 'fulltext', 'url', 'email'], fuzziness:1}}, :size=>100).results
		golinks = Array.new
		results.each do |result|
			data =  result._source
			golinks << GoLink.new(parse_id: data['parse_id'], key: data['key'], description: data['description'], 
				url: data['url'], email: data['email'], permissions: data['permissions'], type: data['golink_type'])
		end
		return golinks
	end

end