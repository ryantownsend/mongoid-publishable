module Mongoid
  module Publishable
    class CallbackCollection < Array
      def process(object)
        each do |callback|
          callback.process(object)
        end
      end
    end
  end
end