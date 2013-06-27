module Bourgeois
  module ViewHelper
    # Wrap a resource or a collection into its related delegator
    #
    # @example
    #   present User.new(name: 'Remi') do |user|
    #     puts user.inspect # => #<UserPresenter object=#<User name="Remi>>
    #     puts user.name # => Remi
    #   end
    def present(object, klass = nil, &blk)
      return object.map { |o| present(o, klass, &blk) } if object.respond_to?(:to_a)

      klass ||= "#{object.class}Presenter".constantize
      presenter = klass.new(object, self)
      yield presenter if block_given?

      presenter
    end
  end
end
