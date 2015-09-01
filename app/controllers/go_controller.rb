class GoController < ApplicationController
	def home
		redirect_to 'http://pbl.link/cs70-links'
	end
	def redirect_key
		golinks = GoLink.where(key: params[:key]).to_a
		if golinks.length > 0
			redirect_to golinks[0].url
		else
			redirect_to 'http://pbl.link/cs70-links'
		end
	end
end