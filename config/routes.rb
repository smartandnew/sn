Rails.application.routes.draw do

  root to: 'home#index'
  #admin controller
  get 'admin/index'
  get 'admin/confirm_first_product_deliverd'
  post 'admin/admin_login'
  post 'admin/create'
  post 'admin/search_users_by_username'
  post '/admin/update_slider_images'
  post '/admin/search_admins_by_username'
  patch 'admin/reset_password'
  match '/admin_login', :to => 'admin#login', :via => 'get'
  match '/admin_signup', :to => 'admin#new', :via => 'get'
  match '/admin_signout', :to => 'admin#destroy', :via => 'get'
  match '/admin_index', :to => 'admin#index', :via => 'get'
  match '/admin/search_users', :to => 'admin#search_users', :via => 'get'
  match '/admin/reset_user_password', :to => 'admin#reset_user_password', :via => 'get'
  match '/admin_store_categories', :to => 'store#store_categories', :via => 'get'
  match '/admin_store_sub_categories', :to => 'store#sub_categories', :via => 'get'
  match '/admin_store_products', :to => 'store#products', :via => 'get'
  match '/admin_store_selected_product', :to => 'store#product', :via => 'get'
  match '/admin/choose_action', :to => 'admin#user_actions', :via => 'get'
  match '/admin/user_expenses', :to => 'admin#user_expenses', :via => 'get'
  match '/users_first_products', :to=> 'admin#users_first_products', :via => 'get'
  patch '/admin/generate_code'
  match '/admin/codes', :to => 'admin#codes', :via => 'get'
  match '/slider_images', :to => 'admin#slider_images', :via => 'get'
  match '/calculations', :to => 'admin#calculations', :via => 'get'
  patch '/admin/update_calculations'
  match '/admin_actions', :to => 'admin#admin_actions', :via => 'get'
  match '/search_admins', :to => 'admin#search_admins', :via => 'get'
  match '/edit_info', :to => 'admin#edit_info', :via => 'get'
  match '/update_sub_admin', :to => 'admin#update_sub_admin', :via => 'get'
  match '/update_super_admin', :to => 'admin#update_super_admin', :via => 'get'
  patch '/admin/update_sub_admin_info'
  patch '/admin/update_super_admin_info'
  patch '/admin/reset_super_admin_password'
  patch '/admin/reset_sub_admin_password'
  match '/all_sub_admins', :to => 'admin#all_sub_admins', :via => 'get'
  match '/view_sub_admin', :to => 'admin#view_sub_admin', :via => 'post'
  match '/admin/view_searched_user', :to => 'admin#view_searched_user', :via => 'post'
  match '/admin/edit_searched_user', :to => 'admin#edit_searched_user', :via => 'post'
  post 'admin/update_searched_user_info'
  match '/admin/update_governorates', :to => 'user#update_governorates', :via => 'get'
  match '/admin/update_regions', :to => 'user#update_regions', :via => 'get'

  match '/products_orders',:to=>'admin#confirm_products_order', :via => 'get'
  get 'admin/confirm_products_order_deliverd'

  #application controller

  match '/store_categories' , :to => 'application#store_categories', :via => 'get'
  match '/store_products', :to => 'application#products', :via => 'get'
  match '/store_selected_product', :to => 'application#product', :via => 'get'
  match '/store_sub_categories', :to => 'application#store_sub_categories', :via => 'get'

  #home controller
  get 'home/index'

  #place controller
  post 'place/create_country'
  post 'place/create_governorate'
  post 'place/create_region'
  match '/place', :to => 'place#index', :via => 'get'
  match '/add_country', :to => 'place#add_country', :via => 'get'
  match '/add_governorate', :to => 'place#add_governorate', :via => 'get'
  match '/add_region', :to => 'place#add_region', :via => 'get'
  get 'place/index'
  get 'place/add_country'
  get 'place/add_governorate'
  get 'place/add_region'
  get 'store/index'
  patch 'place/update_region'
  match '/countries', :to => 'place#countries', :via => 'get'
  match '/governorates', :to => 'place#governorates', :via => 'get'
  match '/regions', :to => 'place#regions', :via => 'get'
  match '/selected_region', :to => 'place#region', :via => 'get'
  patch 'place/update_country'
  patch 'place/update_governorate'
  match '/place/update_governorates', :to => 'user#update_governorates', :via => 'get'
  match '/place/update_regions', :to => 'user#update_regions', :via => 'get'

  #product_order
  match '/add_product_order', :to => 'product_order#add_product_order', :via => 'get'
  match '/add_product_order', :to => 'product_order#add_product_order_old_customer', :via => 'get'
  post 'product_order/create_product_order'
  post 'product_order/create_product_order_old_customer'
  match '/add_product_order', :to => 'product_order#add_product_order', :via => 'get'
  post 'product_order/create_product_order'
  match '/empty_cart', :to => 'product_order#empty_cart', :via => 'post'
  post 'product_order/empty_cart'
  match '/add_to_cart', :to => 'product_order#add_to_cart', :via => 'post'
  post 'product_order/add_to_cart'
  match '/remove_product_from_cart', :to => 'product_order#remove_product_from_cart', :via => 'get'
  get 'product_order/remove_product_from_cart'

  #profile controller
  get 'profile/index'
  match '/profile', :to => 'profile#index', :via => 'get'
  match '/user_order', :to => 'profile#product_credit_order', :via => 'get'
  match '/generate_code', :to => 'profile#generate_code', :via => 'post'
  post 'profile/generate_code'
  match '/get_left', :to => 'profile#get_left', :via => 'get'
  match '/get_parent', :to => 'profile#get_parent', :via => 'get'
  match '/get_right', :to => 'profile#get_right', :via => 'get'
  get 'profile/get_left'
  get 'profile/get_parent'
  get 'profile/get_right'

  #session controller
  get 'session/new'
  post 'session/create'
  match '/signin', :to => 'session#new', :via => 'get'
  match '/signout', :to => 'session#destroy', :via => 'get'

  #store controller
  get 'store/add_category'
  get 'store/add_sub_category'
  get 'store/add_product'
  post 'store/create_category'
  post 'store/create_sub_category'
  post 'store/create_product'
  match '/store', :to => 'store#index', :via => 'get'
  match '/add_category', :to => 'store#add_category', :via => 'get'
  match '/add_sub_category', :to => 'store#add_sub_category', :via => 'get'
  match '/add_product', :to => 'store#add_product', :via => 'get'
  patch 'store/update_product'
  patch 'store/update_category_name'
  patch 'store/update_sub_category_name'
  match '/store/all_products', :to => 'store#all_products', :via => 'get'

  #user controller
  get 'user/show'
  get 'user/new'
  get 'user/edit_info'
  get 'user/index'
  get 'user/change_password'
  get 'user/show'
  post 'user/create'
  match '/create', :to=>'user#create',:via=>'post'
  match '/verify_email_create', :to=>'user#verify_email_create',:via=>'post'
  post 'user/index'
  patch 'user/update_user_info'
  patch 'user/update_password'
  match '/signUp', :to => 'user#sign_up', :via => 'get'
  match '/edit_profile', :to => 'user#edit_info', :via => 'get'
  match '/change_password', :to => 'user#change_password', :via => 'get'
  match '/verify_email', :to => 'user#verify_email_create', :via => 'post'
  match '/verify_email', :to => 'user#verify_email', :via => 'get'
  match '/forgetPassword', :to => 'user#forget_password', :via => 'get'
  match '/send_new_password', :to => 'user#send_new_password', :via => 'post'
  match '/expenses', :to => 'user#expenses', :via => 'get'
  match '/first_product', :to => 'user#first_product', :via => 'get'
  get '/user/select_first_product'
  match '/update_governorates', :to => 'user#update_governorates', :via => 'get'
  match '/update_regions', :to => 'user#update_regions', :via => 'get'
  match '/user/update_governorates', :to => 'user#update_governorates', :via => 'get'
  match '/user/update_regions', :to => 'user#update_regions', :via => 'get'
  # match "*path" => redirect("/404"), :via => [:get, :post]

  #static pages
  get '/about_us',:to => 'home#about_us', :via => 'get'
  get '/contact_us',:to => 'home#contact_us', :via => 'get'
  get '/delivery_information',:to => 'home#delivery_information', :via => 'get'
  get '/terms_conditions',:to => 'home#terms_conditions', :via => 'get'
  get '/privacy_policy',:to => 'home#privacy_policy', :via => 'get'

  #get 'user/update_cities', as: 'update_cities'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'regions/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :regions

  # Example resource route with options:
  #   resources :regions do
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
  #   resources :regions do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :regions do
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
  #     # Directs /admin/regions/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :regions
  #   end
  #unless Rails.application.config.consider_all_requests_local

  match '*not_found', to: 'errors#error_404', via: :all

#end
end
