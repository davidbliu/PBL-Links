Portal::Application.routes.draw do

  root 'go#home'
  get '/:key', to:'go#redirect_key'
  get '/go/add', to:'go#add'

  get "/auth/logout", to: "auth#logout"
  get "/auth/google_oauth2/callback", to: "auth#google_callback"

 
end
