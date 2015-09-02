class GoController < ApplicationController
	def home
		redirect_to 'https://dl.dropboxusercontent.com/u/20405942/PBL%20pages/cs70links.html'
	end
	def add
	end

	def redirect_key
		golinks = GoLink.where(key: params[:key]).to_a
		if golinks.length > 0
			redirect_to golinks[0].url
		else
			redirect_to 'https://dl.dropboxusercontent.com/u/20405942/PBL%20pages/cs70links.html'
		end
	end

	def quick_add
		@url = params[:url]
		@key = params[:key]
		golink = GoLink.create(url:@url, key: @key, email:current_email)
		redirect_to '/finished_adding?id='+golink.id
	end

	def finished_adding
		
	end
end