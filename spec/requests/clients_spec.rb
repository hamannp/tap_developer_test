require 'rails_helper'

RSpec.describe 'Clients', type: :request do
  include_context 'API'

  # TODO make pagination shared_example

  let(:existing_client_name) { 'Some Existing Client' }
  let(:client) { create(:client, name: existing_client_name) }

  describe "GET clients#index" do
    context "success" do
      context 'with full permissions' do
        let!(:client1) { create(:client) }
        let!(:client2) { create(:client) }
        let(:api_url) { '/api/v1/clients' }

        it "returns the collection of clients" do
         get api_url_with_full_permissions

          expect(response).to have_http_status(200)
          expect(json_payload['clients'].map { |c|  c['name'] }).to match_array([
            client1.name, client2.name
          ])
        end
      end

      context 'with pagination' do
        let!(:clients) { create_list(:client, 4) }
        let(:expected_client_names) { Client.order(:created_at).last(2).map(&:name) }
        let(:per_page) { '2' }
        let(:page) { '2' }
        let(:api_url) { "/api/v1/clients?page=#{page}&per_page=#{per_page}" }

        it "returns the collection" do
          get api_url_with_full_permissions

          expect(response).to have_http_status(200)
          expect(json_payload['clients'].map { |p|  p['name'] }).to eq(expected_client_names)
          expect(json_payload['per_page']).to eq per_page
          expect(json_payload['page']).to eq page
        end
      end
    end

    describe 'unauthorized' do
      context 'when the user does not have index permissions' do
        let(:api_url) { '/api/v1/clients' }

        it 'returns an error with 403' do
          get api_url_with_no_permissions
          expect(response).to have_http_status(403)
          expect(json_errors).to eq '403 Forbidden'
        end
      end
    end
  end

end
