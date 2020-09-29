require 'rails_helper'

RSpec.describe 'Projects', type: :request do
  include_context 'API'

  let(:existing_client_name) { 'Some Existing Client' }
  let(:client) { create(:client, name: existing_client_name) }
  let(:project_status_id) { ProjectStatus::New.id }

  describe "GET projects#index" do
    context "success" do
      context 'with full permissions' do
        let!(:project1) { create(:project, client: client) }
        let(:other_client) { create(:client) }
        let!(:project2) { create(:project, client: other_client) }
        let(:api_url) { '/api/v1/projects' }

        it "returns the collection of projects" do
          get api_url_with_full_permissions

          expect(response).to have_http_status(200)
          expect(json_payload['projects'].map { |p|  p['name'] }).to match_array([
            project1.name, project2.name
          ])
        end
      end

      context 'with pagination' do
        let!(:projects) { create_list(:project, 4, client: client) }
        let(:expected_project_names) { Project.order(:created_at).last(2).map(&:name) }
        let(:per_page) { '2' }
        let(:page) { '2' }
        let(:api_url) { "/api/v1/projects?page=#{page}&per_page=#{per_page}" }

        it "returns the collection of projects" do
          get api_url_with_full_permissions

          expect(response).to have_http_status(200)
          expect(json_payload['projects'].map { |p|  p['name'] }).to eq(expected_project_names)
          expect(json_payload['per_page']).to eq per_page
          expect(json_payload['page']).to eq page
        end
      end
    end

    describe 'unauthorized' do
      context 'when the user does not have index permissions' do
        let(:api_url) { '/api/v1/projects' }

        it 'returns an error with 403' do
          get api_url_with_no_permissions
          expect(response).to have_http_status(403)
          expect(json_errors).to eq '403 Forbidden'
        end
      end
    end
  end

  describe "GET /clients/:client_id/projects#show" do
    context "with full permissions" do
      context 'successfully returns all projects, regardless of client' do
        let!(:project1) { create(:project, client: client) }
        let!(:project2) { create(:project, client: client) }
        let(:api_url) { "/api/v1/clients/#{client.id}/projects/#{project1.id}" }

        it "returns the collection of projects" do
          get api_url_with_full_permissions
          expect(response).to have_http_status(200)
          expect(json_payload['projects'].map { |p|  p['name'] }).to match_array([
            project1.name
          ])
          expect(json_payload['projects'].first['client'].keys).to match_array([
            "created_at", "id", "name", "updated_at"
          ])
        end
      end

      context "with read only still returns client on show" do
        let!(:project1) { create(:project, client: client) }
        let!(:project2) { create(:project, client: client) }
        let(:api_url) { "/api/v1/clients/#{client.id}/projects/#{project1.id}" }

        it "returns the collection of projects" do
          get api_url_with_read_only_permissions
          expect(response).to have_http_status(200)
          expect(json_payload['projects'].map { |p|  p['name'] }).to match_array([
            project1.name
          ])
          expect(json_payload['projects'].first['client'].keys).to match_array([
            "created_at", "id", "name", "updated_at"
          ])
        end
      end

    end
  end

  describe "GET /clients/:client_id/projects#index" do
    context 'success' do
      context 'with full permissions' do
        let!(:project) { create(:project, name: 'Project 1', client: client) }
        let(:no_match_client) { create(:client, name: 'No match client') }

        let!(:no_match_project) do
          create(:project, name: 'No match', client: no_match_client)
        end
        let(:api_url) { "/api/v1/clients/#{client.id}/projects" }

        it "returns the collection of projects for that client only" do
          get api_url_with_full_permissions

          expect(response).to have_http_status(200)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq project.name
          expect(json_payload['projects'].first['client']['name']).to eq project.client.name
        end
      end

      context 'with read only permissions' do
        let!(:project) { create(:project, name: 'Project 1', client: client) }
        let(:no_match_client) { create(:client, name: 'No match client') }

        let!(:no_match_project) { create(:project, name: 'No match', client: no_match_client) }
        let(:api_url) { "/api/v1/clients/#{client.id}/projects" }

        it "returns the collection of projects for that client only" do
          get api_url_with_read_only_permissions

          expect(response).to have_http_status(200)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq project.name
          expect(json_payload['projects'].first.keys).not_to include('client')
        end
      end

    end

    context 'with pagination' do
      let!(:projects) { create_list(:project, 4, client: client) }
      let(:expected_project_names) { Project.order(:created_at).last(2).map(&:name) }

      let(:per_page) { '2' }
      let(:page) { '2' }

      let(:api_url) do
        "/api/v1/clients/#{client.id}/projects?page=#{page}&per_page=#{per_page}"
      end

      it "returns the collection of projects" do
        get api_url_with_full_permissions

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
          post api_url_with_full_permissions, params: api_params

          expect(response).to have_http_status(201)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq project_name
        end
      end

      context 'error when client not found' do

        let(:project_name) { 'My new project' }
        let(:api_url) { "/api/v1/clients/#{not_there}/projects" }
        let(:api_params) do
          {
            name: project_name,
            project_status_id: project_status_id
          }
        end
        let(:not_there) { 9999999999 }

        it "returns 404" do
          post api_url_with_full_permissions, params: api_params

          expect(response).to have_http_status(404)
          expect(json_errors).to eq "Couldn't find Client with 'id'=#{not_there}"
        end
      end

      context 'error when validation fails' do
        let(:project_name) { 'My new project' }
        let(:existing_project) do
          create(:project, client: client, name: project_name)
        end
        let(:api_url) { "/api/v1/clients/#{client.id}/projects" }
        let(:api_params) do
          {
            name: existing_project.name,
            project_status_id: project_status_id
          }
        end

        it "returns 422" do
          post api_url_with_full_permissions, params: api_params

          expect(response).to have_http_status(422)
          expect(json_errors).to eq "Validation failed: Name has already been taken"
        end
      end

      context 'unauthorized' do
        let(:api_url) { "/api/v1/clients/#{client.id}/projects" }
        let(:api_params) do
          {
            name: 'My Project',
            project_status_id: project_status_id
          }
        end

        context 'with no permissions' do
          it 'errors with 403' do
            post api_url_with_no_permissions, params: api_params

            expect(response).to have_http_status(403)
            expect(json_errors).to eq "403 Forbidden"
          end
        end

        context 'with read only permissions' do
          it 'errors with 403' do
            post api_url_with_read_only_permissions, params: api_params

            expect(response).to have_http_status(403)
            expect(json_errors).to eq "403 Forbidden"
          end
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
          post api_url_with_full_permissions, params: api_params

          expect(response).to have_http_status(201)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq project_name
          expect(Client.last.name).to eq client_name
        end
      end

      context 'error when client create fails' do
        let(:existing_client) { create(:client, name: 'ACME') }
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
          post api_url_with_full_permissions, params: api_params

          expect(response).to have_http_status(422)
          expect(json_errors).to eq "client: Name has already been taken"
        end
      end

      context 'error when validation fails' do
        let(:project_name) { 'My new project' }
        let(:existing_project) { create(:project, client: client, name: project_name) }
        let(:api_url) { "/api/v1/clients/#{client.id}/projects" }
        let(:api_params) do
          {
            name: existing_project.name,
            project_status_id: project_status_id
          }
        end

        it "returns 422" do
          post api_url_with_full_permissions, params: api_params

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
        let!(:project) { create(:project, client: client) }
        let(:api_url) { "/api/v1/clients/#{client.id}/projects/#{project.id}" }
        let(:api_params) do
          {
            name: updated_project_name,
            project_status_id: ProjectStatus::Done.id,
          }
        end

        it "updates the existing project for the client" do
          put api_url_with_full_permissions, params: api_params

          expect(response).to have_http_status(200)
          expect(json_payload['projects'].count).to eq 1
          expect(json_payload['projects'].first['name']).to eq updated_project_name
          expect(json_payload['projects'].first['project_status']).to eq ProjectStatus::Done.name
        end
      end
    end
  end

  describe "DELETE /clients/:client_id/projects#delete" do
    context "with full permissions" do
      context 'successfully returns all projects, regardless of client' do
        let!(:project1) { create(:project, client: client) }

        let!(:project2) { create(:project, client: client) }
        let(:api_url) { "/api/v1/clients/#{client.id}/projects/#{project1.id}" }

        it "returns the collection of projects" do
          delete api_url_with_full_permissions
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
