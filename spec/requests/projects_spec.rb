require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let(:existing_client_name) { 'Some Existing Client' }
  let(:client) { Client.create!(name: existing_client_name) }
  let(:project_status_id) { ProjectStatus::New.id }

  def json_payload
    JSON.parse(response.body || '[]')
  end

  def json_errors
    json_payload['error']
  end

  before do
    Project.destroy_all
    Client.destroy_all
  end

  describe "GET projects#index" do
    context "with full permissions" do
      context 'successfully returns all projects, regardless of client' do
        let!(:project1) do
          Project.create!(name: 'Project 1', client: client,
                          project_status_id: project_status_id)
        end
        let(:other_client) { Client.create!(name: 'Whatever') }

        let!(:project2) do
          Project.create!(name: 'Project 2', client: other_client,
                          project_status_id: project_status_id)
        end

        it "returns the collection of projects" do
          get '/api/v1/projects'
          expect(response).to have_http_status(200)
          expect(json_payload['projects'].map { |p|  p['name'] }).to match_array([
            project1.name, project2.name
          ])
        end
      end

      context 'with pagination' do
        let!(:projects) do
          Project.create!(name: 'Project 1', client: client,
                          project_status_id: ProjectStatus::Done.id)
          sleep 1.1

          Project.create!(name: 'Project 2', client: client,
                          project_status_id: ProjectStatus::Done.id)
          sleep 1.1

          Project.create!(name: 'Project 3', client: client,
                          project_status_id: ProjectStatus::Done.id)

          sleep 1.1
          Project.create!(name: 'Project 4', client: client,
                          project_status_id: ProjectStatus::New.id)
        end

        let(:expected_project_names) { Project.order(:created_at).last(2).map(&:name) }

        let(:per_page) { '2' }
        let(:page) { '2' }

        it "returns the collection of projects" do
          get "/api/v1/projects?page=#{page}&per_page=#{per_page}"

          expect(response).to have_http_status(200)
          expect(json_payload['projects'].map { |p|  p['name'] }).to eq(expected_project_names)
          expect(json_payload['per_page']).to eq per_page
          expect(json_payload['page']).to eq page
        end
      end

    end
  end

  describe "GET /clients/:client_id/projects#show" do
    context "with full permissions" do
      context 'successfully returns all projects, regardless of client' do
        let!(:project1) do
          Project.create!(name: 'Project 1', client: client,
                          project_status_id: project_status_id)
        end

        let!(:project2) do
          Project.create!(name: 'Project 2', client: client,
                          project_status_id: project_status_id)
        end
        let(:api_url) { "/api/v1/clients/#{client.id}/projects/#{project1.id}" }

        it "returns the collection of projects" do
          get api_url
          expect(response).to have_http_status(200)
          expect(json_payload['projects'].map { |p|  p['name'] }).to match_array([
            project1.name
          ])
        end
      end

    end
  end

  describe "GET /clients/:client_id/projects#index" do
    context "with full permissions" do
      context 'success' do
        let!(:project) do
          Project.create!(name: 'Project 1', client: client,
                          project_status_id: project_status_id)
        end

        let(:no_match_client) { Client.create!(name: 'No match client') }

        let!(:no_match_project) do
          Project.create!(name: 'No match', client: no_match_client,
                          project_status_id: project_status_id)
        end
        let(:api_url) do
          "/api/v1/clients/#{client.id}/projects"
        end

        it "returns the collection of projects for that client only" do
          get api_url

          expect(response).to have_http_status(200)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq project.name
        end
      end

    end

    context 'with pagination' do
      let!(:projects) do
        Project.create!(name: 'Project 1', client: client,
                        project_status_id: ProjectStatus::Done.id)
        sleep 1.1

        Project.create!(name: 'Project 2', client: client,
                        project_status_id: ProjectStatus::Done.id)
        sleep 1.1

        Project.create!(name: 'Project 3', client: client,
                        project_status_id: ProjectStatus::Done.id)

        sleep 1.1
        Project.create!(name: 'Project 4', client: client,
                        project_status_id: ProjectStatus::New.id)
      end

      let(:expected_project_names) { Project.order(:created_at).last(2).map(&:name) }

      let(:per_page) { '2' }
      let(:page) { '2' }

      let(:api_url) do
        "/api/v1/clients/#{client.id}/projects?page=#{page}&per_page=#{per_page}"
      end

      it "returns the collection of projects" do
        get api_url

        expect(response).to have_http_status(200)
        expect(json_payload['projects'].map { |p|  p['name'] }).to eq(expected_project_names)
        expect(json_payload['per_page']).to eq per_page
        expect(json_payload['page']).to eq page
      end
    end
  end

  describe "POST /clients/:client_id/projects#create" do
    context "with full permissions" do
      context 'success' do

        let(:project_name) { 'My new project' }
        let(:api_url) { "/api/v1/clients/#{client.id}/projects" }
        let(:api_params) do
          {
            name: project_name,
            project_status_id: project_status_id
          }
        end

        it "creates the new project for the client" do
          post api_url, params: api_params

          expect(response).to have_http_status(201)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq project_name
        end
      end

      context 'error when client not found' do

        let(:project_name) { 'My new project' }
        let(:api_url) { "/api/v1/clients/not_there/projects" }
        let(:api_params) do
          {
            name: project_name,
            project_status_id: project_status_id
          }
        end

        it "returns 404" do
          post api_url, params: api_params

          expect(response).to have_http_status(404)
          expect(json_errors).to eq "Couldn't find Client with 'id'=not_there"
        end
      end

      context 'error when validation fails' do

        let(:project_name) { 'My new project' }
        let(:existing_project) do
          Project.create!(client: client, name: project_name,
                          project_status_id: project_status_id)
        end
        let(:api_url) { "/api/v1/clients/#{client.id}/projects" }
        let(:api_params) do
          {
            name: existing_project.name,
            project_status_id: project_status_id
          }
        end

        it "returns 422" do
          post api_url, params: api_params

          expect(response).to have_http_status(422)
          expect(json_errors).to eq "Validation failed: Name has already been taken"
        end
      end

    end
  end

  describe "POST /projects#create" do
    context "with full permissions" do
      context 'success' do

        let(:client_name) { 'ACME' }
        let(:project_name) { 'My new project' }
        let(:api_url) { "/api/v1/projects" }
        let(:api_params) do
          {
            name: project_name,
            project_status_id: project_status_id,
            client: { name: client_name }
          }
        end

        it "creates the new project for the client" do
          post api_url, params: api_params

          expect(response).to have_http_status(201)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq project_name
          expect(Client.last.name).to eq client_name
        end
      end

      context 'error when client create fails' do

        let(:existing_client) { Client.create!(name: 'ACME') }
        let(:project_name) { 'My new project' }
        let(:api_url) { "/api/v1/projects" }
        let(:api_params) do
          {
            name: project_name,
            client: { name: existing_client.name },
            project_status_id: project_status_id
          }
        end

        it "returns 422" do
          post api_url, params: api_params

          expect(response).to have_http_status(422)
          expect(json_errors).to eq "client: Name has already been taken"
        end
      end

      context 'error when validation fails' do

        let(:project_name) { 'My new project' }
        let(:existing_project) do
          Project.create!(client: client, name: project_name,
                          project_status_id: project_status_id)
        end
        let(:api_url) { "/api/v1/clients/#{client.id}/projects" }
        let(:api_params) do
          {
            name: existing_project.name,
            project_status_id: project_status_id
          }
        end

        it "returns 422" do
          post api_url, params: api_params

          expect(response).to have_http_status(422)
          expect(json_errors).to eq "Validation failed: Name has already been taken"
        end
      end
    end
  end

  describe "PUT /clients/:client_id/projects#update" do
    context "with full permissions" do
      context 'success' do

        let(:updated_project_name) { 'My updated project' }
        let!(:project) do
          Project.create!(name: 'Project', client: client,
                          project_status_id: project_status_id)
        end
        let(:api_url) { "/api/v1/clients/#{client.id}/projects/#{project.id}" }
        let(:api_params) do
          {
            name: updated_project_name,
            project_status_id: ProjectStatus::Done.id,
          }
        end

        it "updates the existing project for the client" do
          put api_url, params: api_params

          expect(response).to have_http_status(200)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq updated_project_name
          expect(json_payload['projects'].first['project_status_id']).to eq ProjectStatus::Done.id
        end
      end
    end
  end

  describe "DELETE /clients/:client_id/projects#delete" do
    context "with full permissions" do
      context 'successfully returns all projects, regardless of client' do
        let!(:project1) do
          Project.create!(name: 'Project 1', client: client,
                          project_status_id: project_status_id)
        end

        let!(:project2) do
          Project.create!(name: 'Project 2', client: client,
                          project_status_id: project_status_id)
        end
        let(:api_url) { "/api/v1/clients/#{client.id}/projects/#{project1.id}" }

        it "returns the collection of projects" do
          delete api_url
          expect(response).to have_http_status(200)
          expect(json_payload['projects'].map { |p|  p['name'] }).to match_array([
            project1.name
          ])
          expect(Project.exists?(project1.id)).to eq false
          expect(Project.exists?(project2.id)).to eq true
        end
      end

    end
  end

end
