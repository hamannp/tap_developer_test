module Entities
  class Project < Grape::Entity
    format_with(:iso_timestamp) { |dt| dt.iso8601 }

    expose :name
    expose :id
    expose :project_status do |instance, _|
      instance.project_status.name
    end

    expose :client, using: API::Entities::Client, if: lambda { |_, opts| opts[:expose_client] }

    with_options(format_with: :iso_timestamp) do
      expose :created_at
      expose :updated_at
    end
  end
end
