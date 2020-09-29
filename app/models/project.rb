class Project < ApplicationRecord

  include ProjectStatus

  belongs_to :client

  validates :client, presence: true
  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: ENV["MAX_INPUT_LENGTH"].to_i }
  def self.list_all
    all
  end
end
