module Concepts
  class Projects < API
    desc 'Return projects regardless of client scoping.'
    params do
      optional :per_page
      optional :page
    end
    get :projects do
      permit!(:projects, :index)

      projects = paginate(Project.list_all, declared(params))
      present_with_pagination :projects, projects, expose_client: current_user.admin?
    end

    desc 'Creates a new client while adding a project.'
    params do
      requires :client, type: Hash do
        requires :name
      end
      requires :name
      requires :project_status_id
    end
    post :projects do
      permit!(:clients, :create)
      permit!(:projects, :create)

      client = Client.make(declared(params)[:client])

      if client.valid?
        project = client.make_project!(declared(params).except(:client))
      else
        error!("client: #{error_messages_for(client)}", 422)
      end

      present_with :projects, project, expose_client: true
    end

    resources '/clients/:client_id/' do
      desc 'Return projects for a given client.'
      params do
        optional :per_page
        optional :page
      end
      get :projects do
        permit!(:clients, :show)
        permit!(:projects, :index)

        client   = Client.fetch_by_id!(params[:client_id])
        projects = paginate(client.list_projects, declared(params))

        present_with_pagination :projects, projects, expose_client: current_user.admin?
      end

      desc 'Return client project with the given id'
      params do
        requires :client_id, type: Integer, desc: 'Client ID.'
        requires :id, type: Integer, desc: 'Project ID.'
      end
      get 'projects/:id' do
        permit!(:clients, :show)
        permit!(:projects, :show)

        client  = Client.fetch_by_id!(params[:client_id])
        project = client.fetch_project!(params[:id])

        present_with :projects, project, expose_client: true
      end

      desc 'Creates a new project for a given client.'
      params do
        requires :client_id, type: Integer, desc: 'Client ID.'
        requires :name
        requires :project_status_id
      end
      post :projects do
        permit!(:clients, :show)
        permit!(:projects, :create)

        client  = Client.fetch_by_id!(params[:client_id])
        project = client.make_project!(declared(params))

        present_with :projects, project, expose_client: current_user.admin?
      end

      desc 'Updates an existing project for a given client.'
      params do
        requires :client_id, type: Integer, desc: 'Client ID.'
        requires :id, type: Integer, desc: 'Project ID.'

        optional :name
        optional :project_status_id, type: Integer, desc: 'Status ID.'
      end
      put 'projects/:id' do
        permit!(:clients, :show)
        permit!(:projects, :update)

        client  = Client.fetch_by_id!(params[:client_id])
        project = client.fetch_project!(params[:id])
        project.update!(declared(params).slice(:name, :project_status_id))

        present_with :projects, project, expose_client: current_user.admin?
      end

      desc 'Delete client project with the given id'
      params do
        requires :client_id, type: Integer, desc: 'Client ID.'
        requires :id, type: Integer, desc: 'Project ID.'
      end
      delete 'projects/:id' do
        permit!(:clients, :show)
        permit!(:projects, :delete)

        client  = Client.fetch_by_id!(params[:client_id])
        project = client.fetch_project!(params[:id])
        project.destroy!

        present_with :projects, project, expose_client: current_user.admin?
      end
    end
  end
end
