FactoryBot.define do
  factory :client do
    sequence(:name) { |n| "Client #{n}" }
  end

  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    project_status_id { ProjectStatus::New.id }

    client
  end
end
