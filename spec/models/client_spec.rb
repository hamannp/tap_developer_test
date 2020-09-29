require 'rails_helper'

describe Client do
  # TODO: make shared example for use in Project and future models.

  describe '#name' do
    let(:existing_client) { create(:client, name: 'Existing') }

    it 'is invalid when name is blank' do
      client = Client.new(name: '')
      client.valid?

      expect(client.errors[:name]).to match_array(["can't be blank"])
    end

    it 'is valid with unique name' do
      client = Client.new(name: 'Unique Client')
      client.valid?

      expect(client.errors[:name]).to be_empty
    end

    it 'is invalid when a client with the same name already exists' do
      client = Client.new(name: existing_client.name)
      client.valid?

      expect(client.errors[:name]).to match_array(["has already been taken"])
    end

    it 'is invalid when name is too long' do
      name   = 'X' * (ENV['MAX_INPUT_LENGTH'].to_i + 1)
      client = Client.new(name: name)
      client.valid?

      expect(client.errors[:name]).to match_array([
        "is too long (maximum is #{ENV['MAX_INPUT_LENGTH']} characters)"
      ])
    end
  end
end
