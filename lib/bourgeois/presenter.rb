module Bourgeois
  class Presenter < ::SimpleDelegator
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

  private

    # Return the view from where the presenter was created
    def view
      @view
    end

    # Return the original delegated object
    def object
      @object
    end

    # Return the original object class based on the presenter class name
    # We would be able to use `@object.class` but we need this in class methods
    def self.klass
      @klass ||= self.name.split(/Presenter$/).first.constantize
    end
  end
end
