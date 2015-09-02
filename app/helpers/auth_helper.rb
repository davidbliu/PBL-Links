module AuthHelper
	def current_email
	    cookies[:remember_token]
	  end
end