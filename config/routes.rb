Rails.application.routes.draw do
  resources :chart

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/', to: redirect('/chart')
end
