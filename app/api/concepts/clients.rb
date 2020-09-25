module Concepts
  class Clients < API
    desc 'Return clients.'
    get :clients do
      { ping: params[:pong] || 'clients' }
    end
  end
end
