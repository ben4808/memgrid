Memgrid::Application.routes.draw do
  root to: 'home#index'

  get '/login', to: 'login#index'
  post '/login/login', to: 'login#login'
  post '/login/register', to: 'login#register'
  get '/logout', to: 'login#logout'

  get '/browse', to: 'browse#index'
  post '/browse/records', to: 'browse#records', as: 'records'
  get '/browse/favorites', to: 'browse#favorites', as: 'favorites'
  get '/browse/your', to: 'browse#your', as: 'your'
  get '/browse/user/:user', to: 'browse#user', as: 'user'
  get '/browse/search/:keyword', to: 'browse#search', as: 'search'
  post '/browse/new', to: 'browse#new'
  get '/browse/edit_list/:id', to: 'browse#edit_list', as: 'edit_list'
  post '/browse/edit/:id', to: 'browse#edit', as: 'edit_list_s'
  get '/browse/delete/:id', to: 'browse#delete', as: 'delete_list'
  get '/browse/vote/:id/:dir', to: 'browse#vote', as: 'list_vote'

  get '/list/:id', to: 'list#index', as: 'list'
  get '/list/:id/vote/:did', to: 'list#vote', as: 'def_vote'
  post '/list/:id/new', to: 'list#new'
  post '/list/:id/new_multiple' , to: 'list#new_multiple'
  post '/list/:id/edit/:wid', to: 'list#edit'
  get '/list/:id/delete/:wid', to: 'list#delete'
  get '/full_def/:id', to: 'list#full_def'

  get '/quiz/:id', to: 'quiz#normal'
  get '/quiz/:id/reverse', to: 'quiz#reverse'
  post '/quiz/:qid/submit', to: 'quiz#submit'
  post '/quiz/:qid/next', to: 'quiz#next'

  get '/dump_words', to: 'dump_words#index'
  get '/load_words', to: 'load_words#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
