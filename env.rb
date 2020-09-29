ENV['MAX_INPUT_LENGTH'] ||= '100'
ENV['MAX_PROJECTS_PER_PAGE'] ||= '1000'

# TODO: these should really be in a test helper. Adding here for convenience.
ENV['FULL_PERMISSION_TOKEN'] ||= 'some_valid_token'
ENV['NO_PERMISSION_TOKEN'] ||= 'no_permission_token'
ENV['READ_ONLY_PERMISSION_TOKEN'] ||= 'read_only_permission_token'
