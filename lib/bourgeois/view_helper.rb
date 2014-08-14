module Bourgeois
  module ViewHelper
    def present(object, klass = nil, &blk)
      Bourgeois::Presenter.present(object, klass, &blk)
    end
  end
end
