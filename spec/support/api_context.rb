RSpec.shared_context "API", shared_context: :metadata do |args|
  def json_payload
    JSON.parse(response.body || '[]')
  end

  def json_errors
    json_payload['error']
  end

  def api_url_with_full_permissions
    api_url_with_permissions(ENV['FULL_PERMISSION_TOKEN'])
  end

  def api_url_with_no_permissions
    api_url_with_permissions(ENV['NO_PERMISSION_TOKEN'])
  end

  def api_url_with_read_only_permissions
    api_url_with_permissions(ENV['READ_ONLY_PERMISSION_TOKEN'])
  end

  def api_url_with_permissions(token)
    separator = api_url =~ /\?/ ? '&' : '?'
    "#{api_url}#{separator}token=#{token}"
  end
end
