require 'rails_helper'

describe Project do
  let(:client) { create(:client, name: 'Existing') }
  let(:existing_project) do
    create(:project, name: 'Existing', client: client)
  end

  it 'is valid with a unique name, a valid status, and an existing client' do
    project = Project.new(name: 'Unique Project', client: client,
                          project_status_id: ProjectStatus::Done.id)

    expect(project).to be_valid
  end

  it 'is invalid when client is blank or does not exist' do
    project = Project.new(name: 'whatever', client: nil)
    project.valid?

    expect(project.errors[:client]).to match_array(["can't be blank", "must exist"])
  end

  describe '#name' do
    it 'is invalid when name is blank' do
      project = Project.new(name: '')
      project.valid?

      expect(project.errors[:name]).to match_array(["can't be blank"])
    end

    it 'is invalid when a client with the same name already exists' do
      project = Project.new(name: existing_project.name)
      project.valid?

      expect(project.errors[:name]).to match_array(["has already been taken"])
    end

    it 'is invalid when name is too long' do
      name   = 'X' * (ENV['MAX_INPUT_LENGTH'].to_i + 1)
      project = Project.new(name: name)
      project.valid?

      expect(project.errors[:name]).to match_array([
        "is too long (maximum is #{ENV['MAX_INPUT_LENGTH']} characters)"
      ])
    end
  end
end
