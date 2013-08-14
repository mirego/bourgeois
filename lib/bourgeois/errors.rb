module Bourgeois
  class UnknownPresenter < StandardError
    def initialize(klass)
      @klass = klass
    end

    def to_s
      "unknown presenter class #{@klass}"
    end
  end
end
