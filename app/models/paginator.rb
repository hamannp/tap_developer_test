class Paginator
  MAX_PER_PAGE = 1000

  def initialize(collection, opts)
    @collection = collection
    @page       = (opts[:page] || 1).to_i
    @per_page   = (opts[:per_page] || 100).to_i

    if @per_page > MAX_PER_PAGE
      @per_page = MAX_PER_PAGE
    end
  end

  def paginate
    collection.order(:created_at).limit(per_page).offset(per_page * (page - 1))
  end

  private

  attr_reader :page, :per_page, :collection
end
