require 'rails_helper'

describe Paginator do

  let(:client) { Client.create!(name: 'Existing') }
  let!(:projects) do
    create_list(:project, 4, client: client)
  end

  context 'with no per_page or page params passed' do
    before do
      @original_per_page = ENV['MAX_PROJECTS_PER_PAGE']
      ENV['MAX_PROJECTS_PER_PAGE'] = '1'
    end

    after { ENV['MAX_PROJECTS_PER_PAGE'] = @original_per_page }

    let(:expected_projects) { Array.wrap(Project.first) }

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
