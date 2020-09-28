class API < Grape::API
  prefix 'api/v1'
  format :json

  User = Struct.new(:id, :name) do
    def admin?
      true
    end
  end

  helpers do
    def current_user
      @current_user ||= User.new(1, 'John Smith')
    end

    def authenticate!
      error!('401 Unauthorized', 401) unless current_user
    end

    def paginate(collection, opts)
      Paginator.new(collection, opts).paginate
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |error|
    error!(error, 404)
  end

  rescue_from ActiveRecord::RecordInvalid do |error|
    error!(error, 422)
  end

  before do
    authenticate!
  end

  mount Concepts::Projects
  mount Concepts::Clients

end
