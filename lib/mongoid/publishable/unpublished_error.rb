module Mongoid
  module Publishable
    class UnpublishedError < StandardError
      attr_accessor :model
    end
  end
end
