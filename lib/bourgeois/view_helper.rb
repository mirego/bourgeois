module Bourgeois
  module ViewHelper
    # Wrap a resource or a collection into its related presenter
    #
    # @example
    #   present User.new(name: 'Remi') do |user|
    #     puts user.inspect # => #<UserPresenter object=#<User name="Remi>>
    #     puts user.name # => Remi
    #   end
    def present(object, klass = nil, &blk)
      return if object.nil?
      return object.map { |o| present(o, klass, &blk) } if object.respond_to?(:to_a) && !object.is_a?(Struct)

      if object.is_a?(Bourgeois::Presenter)
        presenter = object
      else
        klass ||= ViewHelper.presenter_class(object)
      end

      presenter ||= klass.new(object, self)
      yield presenter if block_given?

      presenter
    end

    def self.presenter_class(object)
      klass_name = "#{object.class}Presenter"
      klass_name.constantize
    rescue ::NameError
      raise UnknownPresenter, klass_name
    end
  end
end
