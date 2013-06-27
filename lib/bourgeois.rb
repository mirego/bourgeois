require 'bourgeois/version'

require 'delegate'
require 'active_model'
require 'action_view'

require 'bourgeois/presenter'
require 'bourgeois/view_helper'

module Bourgeois
end

require 'bourgeois/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3
