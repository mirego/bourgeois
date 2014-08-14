module Bourgeois
  module ViewHelper
    def present(object, klass = nil, &blk)
      Bourgeois::Presenter.present(object, klass, self, &blk)
    end
  end
end
