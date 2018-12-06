Chat::Engine.routes.draw do
  resources :patients do
    resources :chats
  end

  resources :chats do
    collection do
      get 'load_messages'
    end
  end
end
