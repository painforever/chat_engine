Chat::Engine.routes.draw do
  resources :patients do
    resources :chats
  end
end
