class API < Grape::API
  prefix 'api/v1'
  format :json

  User = Struct.new(:id, :name, :permissions) do
    def admin?
      permissions[:admin]
    end
  end

  helpers do
    def permit!(resource, action)
      _permissions = Array.wrap(current_user.permissions[resource])
      return true if _permissions.include?(:all)
      error!('403 Forbidden', 403) unless _permissions.include?(action)
    end

    def current_user
      @current_user ||= begin
                          if params[:token] == ENV['FULL_PERMISSION_TOKEN']
                            User.new(1, 'John Smith', projects: [:all], clients: [:all], admin: true)
                          elsif params[:token] == ENV['NO_PERMISSION_TOKEN']
                            User.new(2, 'Bob Jones', projects: [], clients: [], admin: false)
                          elsif params[:token] == ENV['READ_ONLY_PERMISSION_TOKEN']
                            User.new(3, 'Leroy Jenkins', projects: [:show, :index],
                                     clients: [:show, :index], admin: false)
                          end
                        end
    end

    def authenticate!
      error!('401 Unauthorized', 401) unless current_user
    end

    def paginate(collection, opts)
      Paginator.new(collection, opts).paginate
    end

    def error_messages_for(model)
      model.errors.full_messages.join(", ")
    end

    def present_with_pagination(root, collection, options={})
      present({ page: params[:page] || '1', per_page: params[:per_page] || ENV['MAX_PROJECTS_PER_PAGE'] })
      present_with(root, collection, options)
    end

    def present_with(root, collection, options)
      present root, Array.wrap(collection),
        { with: "API::Entities::#{root.to_s.singularize.capitalize}".constantize}.merge(options)
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
