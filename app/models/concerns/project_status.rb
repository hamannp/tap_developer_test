module ProjectStatus
  extend ActiveSupport::Concern

  New        = StaticValue.new(1, 'New')
  InProgress = StaticValue.new(2, 'In Progress')
  Delayed    = StaticValue.new(3, 'Delayed')
  Done       = StaticValue.new(4, 'Done')

  Collection = constants.map { |status| const_get(status) }
  All        = Collection.map(&:id)

  included do
    validates :project_status_id, presence: true,
                                  inclusion: { in: ProjectStatus::All, allow_nil: true}
  end

  def project_status
    ProjectStatus::Collection.detect do |status|
      status.id == project_status_id
    end
  end
end
