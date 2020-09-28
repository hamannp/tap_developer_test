require 'rails_helper'

describe Paginator do

  let(:client) { Client.create!(name: 'Existing') }
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

  before(:all) do
    Project.destroy_all
    Client.destroy_all
  end

  context 'with no per_page or page params passed' do
    let(:expected_projects) { Array.wrap(Project.first) }

    before do
      @original_per_page = ENV['MAX_PROJECTS_PER_PAGE']
      ENV['MAX_PROJECTS_PER_PAGE'] = '1'
    end

    after { ENV['MAX_PROJECTS_PER_PAGE'] = @original_per_page }

    it 'returns the first page with the set limit' do
      expect(Paginator.new(Project.all).paginate).to eq(expected_projects)
    end
  end

  context 'with per_page and page params' do
    let(:expected_projects) { Project.order(:created_at).last(2) }
    let(:params) do
      {per_page: '2', page: '2'}
    end

    it 'applies the requested limit and offset' do
      expect(Paginator.new(Project.all, params).paginate).to eq(expected_projects)
    end
  end

end
