module Bourgeois
  module Presenter
    extend ActiveSupport::Concern

    def initialize(object, view = nil)
      @object = object
      @view = view
    end

    # Catch unknown method calls and delegate them to @object
    def method_missing(method, *args, &blk)
      if @object.respond_to?(method)
        @object.send method, *args, &blk
      else
        super
      end
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

  private

    # Return the view from where the presenter was created
    def view
      @view
    end

    # Return the original delegated object
    def object
      @object
    end

    module ClassMethods
      # ActionView::Helpers::FormBuilder needs this
      def model_name
        klass.model_name
      end

      # ActionView::Helpers::FormBuilder needs this too
      def human_attribute_name(*args)
        klass.human_attribute_name(*args)
      end

      # Declare a new block helper method
      #
      # @example
      #   class UserPresenter
      #     include Bourgeois::Presenter
      #
      #     helper :with_profile, if: -> { profile.present? }
      #   end
      #
      #   presenter = UserPresenter.new(User.new(profile: 'Foo'))
      #   presenter.with_profile do
      #     puts 'User has a profile:'
      #     puts presenter.profile
      #   end
      def helper(name, opts = {})
        define_method(name) do |&block|
          execute = true

          if opts[:if]
            execute = execute && self.instance_exec(&opts[:if])
          end

          if opts[:unless]
            execute = execute && !self.instance_exec(&opts[:unless])
          end

          block.call if execute
        end
      end

    private

      # Return the original object class based on the presenter class name
      # We would be able to use `@object.class` but we need this in class methods
      def klass
        @klass ||= self.name.split(/Presenter$/).first.constantize
      end
    end
  end
end
