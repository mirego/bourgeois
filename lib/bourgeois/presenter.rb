module Bourgeois
  class Presenter < ::SimpleDelegator
    def initialize(object, view)
      @view = view
      super(@object = object)
    end

    def inspect
      "#<#{self.class} object=#{@object.inspect}>"
    end

    def kind_of?(mod)
      @object.kind_of?(mod)
    end

    def self.model_name
      klass.model_name
    end

    def self.human_attribute_name(*args)
      klass.human_attribute_name(*args)
    end

  private

    def view
      @view
    end

    def self.klass
      @klass ||= self.name.split(/Presenter$/).first.constantize
    end
  end
end
