class Paginator

  def initialize(relation, opts={})
    @relation = relation
    @page     = opts[:page].to_i || 1
    @per_page = (opts[:per_page] || default_per_page).to_i

    if @per_page > default_per_page
      @per_page = default_per_page
    end
  end

  def paginate
    relation.order(:created_at).limit(per_page).offset(per_page * (page - 1))
  end

  private

  def default_per_page
    ENV['MAX_PROJECTS_PER_PAGE'].to_i
  end

  attr_reader :page, :per_page, :relation
end
