class Project < ApplicationRecord
  belongs_to :client

  validates :client, presence: true
  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: ENV["MAX_INPUT_LENGTH"].to_i }
end
