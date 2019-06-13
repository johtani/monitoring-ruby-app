Rails.application.routes.draw do
  get 'trouble/message'
  get 'trouble/zerodivide'
  get 'trouble/soslow'
  root 'questions#index'
  get 'about/about'
  get 'questions/:id/vote' => 'questions#vote', as: 'question_vote'
  resources :questions
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
