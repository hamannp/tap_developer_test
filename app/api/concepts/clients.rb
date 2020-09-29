module Concepts
  class Clients < API
    desc 'Return clients.'
    params do
      optional :per_page
      optional :page
    end
    get :clients do
      permit!(:clients, :index)

      clients = paginate(Client.list_all, declared(params))
      present_with_pagination(:clients, clients)
    end
  end
end
