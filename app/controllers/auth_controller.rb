class AuthController < ApplicationController
	def info
		
	end

	def google_callback
		result = Hash.new
		authentication_info = request.env["omniauth.auth"]
		cookies[:access_token] = authentication_info["credentials"]["token"]
		cookies[:refresh_token] = authentication_info["credentials"]["refresh_token"]
		cookies[:remember_token] = authentication_info['info']['email']
		redirect_to '/'
	end

	def logout
		cookies[:remember_token] = nil
		redirect_to '/'
	    # redirect_to "https://accounts.google.com/logout"
	end

	def login
	end

	def not_signed_in
	end

end