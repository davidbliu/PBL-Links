class ElasticsearchGoLink < ActiveRecord::Base
	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks
	ElasticsearchGoLink.__elasticsearch__.client = Elasticsearch::Client.new host: ENV['ELASTICSEARCH_HOST']

	def to_parse
		GoLink.new(parse_id: self.parse_id, key: self.key, description: self.description, email: self.email,
			permissions: self.permissions, url: self.url, type: self.type)
	end
end
