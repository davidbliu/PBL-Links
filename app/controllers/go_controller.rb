class GoController < ApplicationController

	before_filter :authorize, :only => [:add_link, :add]

	def authorize
		if not current_email or current_email == ''
			render 'auth/not_signed_in'
		end
	end

	def search
		q = params[:q]
		@golinks = GoLink.all
	end

	def home
		@golinks = GoLink.limit(10000).all.to_a
		# redirect_to 'https://dl.dropboxusercontent.com/u/20405942/PBL%20pages/cs70links.html'
	end
	def add
	end

	def add_link
		key = params[:key]
		url = params[:url]
		description = params[:description]
		golinks = GoLink.where(key:key).to_a
		if golinks.length > 0
			@golink = golinks[0]
			render 'already_created'
		else
			@golink = GoLink.create(key:key, url:url, description:description, type: 'instructor')
			render 'successfully_added'
		end
	end

	def already_created
	end

	def redirect_key
		golinks = GoLink.where(key: params[:key]).to_a
		if golinks.length > 0
			redirect_to golinks[0].url
		else
			redirect_to '/'
			# redirect_to 'https://dl.dropboxusercontent.com/u/20405942/PBL%20pages/cs70links.html'
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