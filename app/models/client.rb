class Client < ApplicationRecord
  has_many :projects

  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: ENV['MAX_INPUT_LENGTH'].to_i }

  def self.fetch_by_id!(id)
    find(id)
  end

  def self.list_all
    all
  end

  def self.make(params)
    create(params)
  end

  def list_projects
    projects
  end

  def fetch_project!(project_id)
    projects.find(project_id)
  end

  def make_project!(params)
    projects.create!(params)
  end
end
