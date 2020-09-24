class Client < ApplicationRecord
  has_many :projects

  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: ENV['MAX_INPUT_LENGTH'].to_i }
end
