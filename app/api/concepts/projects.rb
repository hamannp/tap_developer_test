module Concepts
  class Projects < API
    desc 'Return projects regardless of client scoping.'
    params do
      optional :per_page
      optional :page
    end

    get :projects do
      projects = paginate(Project.all, declared(params))
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
      client = Client.create(declared(params)[:client])

      if client.valid?
        project = client.projects.create!(declared(params).except(:client))
      else
        error!("client: #{client.errors.full_messages.join(", ")}", 422)
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
        client   = Client.find(params[:client_id])
        projects = paginate(client.projects, declared(params))

        present_with_pagination :projects, projects, expose_client: current_user.admin?
      end

      desc 'Return client project with the given id'
      params do
        requires :client_id, type: Integer, desc: 'Client ID.'
        requires :id, type: Integer, desc: 'Project ID.'
      end
      get 'projects/:id' do
        client  = Client.find(params[:client_id])
        project = client.projects.find(params[:id])

        present_with :projects, project, expose_client: current_user.admin?
      end

      desc 'Creates a new project for a given client.'
      params do
        requires :client_id, type: Integer, desc: 'Client ID.'
        requires :name
        requires :project_status_id
      end
      post :projects do
        client  = Client.find(params[:client_id])
        project = client.projects.create!(declared(params))

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
        client  = Client.find(params[:client_id])
        project = client.projects.find(params[:id])
        project.update!(declared(params).slice(:name, :project_status_id))

        present_with :projects, project, expose_client: current_user.admin?
      end

      desc 'Delete client project with the given id'
      params do
        requires :client_id, type: Integer, desc: 'Client ID.'
        requires :id, type: Integer, desc: 'Project ID.'
      end
      delete 'projects/:id' do

        client  = Client.find(params[:client_id])
        project = client.projects.find(params[:id])
        project.destroy!

        present_with :projects, project, expose_client: current_user.admin?
      end
    end
  end
end
