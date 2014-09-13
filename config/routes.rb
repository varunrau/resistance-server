Resistance::Application.routes.draw do

  get "user/index"
  get "user/show"
  root to: "api/game#index"
  devise_scope :api_user do
    namespace :api do
      #TODO Add versioning namespace
      resources :sessions, only: [:create, :destroy]
    end
  end
  namespace :api, defaults: { format: 'json' } do
    resources :game, only: [:index, :show, :create] do
      post 'join'
      post 'submit_team'
      post 'team_vote'
      post 'mission_vote'
      post 'lady_of_the_lake'
    end
    devise_for :users, controllers: { sessions: "api/sessions",
                                 registrations: "api/registrations"}
  end
end
