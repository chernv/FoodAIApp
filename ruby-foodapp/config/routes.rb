Rails.application.routes.draw do
  post :login, to: 'auth#login'
  post :signup, to: 'auth#signup'
  post '/:provider',      to: 'auth#authenticate'
  # post '/twitter',        to: 'auth#twitter'
  post '/google',		  to: 'auth#google'
  # post '/twitter_step_2', to: 'auth#twitter_step_2'

  get    '/me', 						to: 'api#show'
  put    '/me', 						to: 'api#update'
  get    '/me/food_images', 			to: 'api#index_img', :defaults => { :format => 'json' }
  post   '/me/food_images', 			to: 'api#create_img', :defaults => { :format => 'json' }
  get    '/me/food_images/new', 		to: 'api#new_img'
  get    '/me/food_images/:id/edit', 	to: 'api#edit_img', :defaults => { :format => 'json' }
  get    '/me/food_images/:id', 		to: 'api#show_img', :defaults => { :format => 'json' }
  patch  '/me/food_images/:id', 		to: 'api#update_img'
  put 	 '/me/food_images/:id', 		to: 'api#update_img'
  delete '/me/food_images', 			to: 'api#destroy_img'
  post   '/me/process',					to: 'api#process_image'
  # resources :users do
  # 	resources :food_images
  # end
end
