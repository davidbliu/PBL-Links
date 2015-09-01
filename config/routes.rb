Portal::Application.routes.draw do

  # get "/auth/google_oauth2/callback", to: "sessions#sign_onto_google"



  # get "/pull_google_events", to: "events#pull_google_events"
  root 'go#home'
  get '/:key', to:'go#redirect_key'

 
end
