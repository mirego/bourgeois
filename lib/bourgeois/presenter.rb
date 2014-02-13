module Bourgeois
  class Presenter < ::SimpleDelegator
    # Return the original delegated object
    attr_reader :object

    def initialize(object, view = nil)
      @view = view
      super(@object = object)
    end

    # Return a String representation of the presenter + the original object
    def inspect
      "#<#{self.class} object=#{@object.inspect}>"
    end

    # We need to explicitely define this method because it's not
    # catched by the delegator
    def kind_of?(mod)
      @object.kind_of?(mod)
    end

    # ActionView::Helpers::FormBuilder needs this
    def self.model_name
      klass.model_name
    end

    # ActionView::Helpers::FormBuilder needs this too
    def self.human_attribute_name(*args)
      klass.human_attribute_name(*args)
    end

    # Declare a new block helper method
    #
    # @example
    #   class UserPresenter < Bourgeois::Presenter
    #     helper :with_profile, if: -> { profile.present? }
    #   end
    #
    #   presenter = UserPresenter.new(User.new(profile: 'Foo'))
    #   presenter.with_profile do
    #     puts 'User has a profile:'
    #     puts presenter.profile
    #   end
    def self.helper(name, opts = {})
      define_method(name) do |&block|
        execute_helper(block, opts)
      end
    end

  private

    # Return the view from where the presenter was created
    attr_reader :view

    # Return the original object class based on the presenter class name
    # We would be able to use `@object.class` but we need this in class methods
    def self.klass
      @klass ||= name.split(/Presenter$/).first.constantize
    end

    # Execute a helper block if it matches conditions
    def execute_helper(block, opts)
      if_condition = execute_helper_condition(opts[:if])
      unless_condition = !execute_helper_condition(opts[:unless], false)

      block.call if if_condition && unless_condition
    end

    # Execute a block within the context of the instance and return
    # the result. Return a default value if the passed block is blank
    def execute_helper_condition(block, default = true)
      if block.blank?
        default
      else
        instance_exec(&block)
      end
    end
  end
end
