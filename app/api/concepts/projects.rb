module Concepts
  class Projects < API
    desc 'Return projects regardless of client scoping.'
    params do
      optional :per_page
      optional :page
    end

    get :projects do
      #TODO add page and per_page
      { projects: paginate(Project.all, declared(params)) }
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

      { projects: Array.wrap(project) }
    end

    resources '/clients/:client_id/' do
      desc 'Return projects for a given client.'
      get :projects do

        client = Client.find(params[:client_id])

        #TODO paginate add page and per_page
        { projects: client.projects }
      end

      desc 'Return client project with the given id'
      params do
        requires :client_id, type: Integer, desc: 'Client ID.'
        requires :id, type: Integer, desc: 'Project ID.'
      end
      get 'projects/:id' do

        client  = Client.find(params[:client_id])
        project = client.projects.find(params[:id])

        { projects: Array.wrap(project) }
      end

      desc 'Creates a new project for a given client.'
      params do
        requires :client_id
        requires :name
        requires :project_status_id
      end
      post :projects do
        client  = Client.find(params[:client_id])
        project = client.projects.create!(declared(params))

        { projects: Array.wrap(project) }
      end

      desc 'Updates an existing project for a given client.'
      params do
        requires :client_id
        requires :id, type: Integer, desc: 'Project ID.'

        optional :name
        optional :project_status_id
      end
      put 'projects/:id' do
        client  = Client.find(params[:client_id])
        project = client.projects.find(params[:id])
        project.update_attributes!(declared(params).slice(:name, :project_status_id))

        { projects: Array.wrap(project) }
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

        { projects: Array.wrap(project) }
      end
    end
  end
end
