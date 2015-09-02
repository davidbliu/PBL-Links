Portal::Application.routes.draw do

  root 'go#home'
  get '/:key', to:'go#redirect_key'
  get '/go/add', to:'go#add'
  get '/go/add_link',to:'go#add_link'
  get '/go/already_created', to:'go#already_created'
  get '/go/search', to:'go#search'

  get "/auth/logout", to: "auth#logout"
  get "/auth/google_oauth2/callback", to: "auth#google_callback"

  get '/auth/info', to:'auth#info'
 
end
