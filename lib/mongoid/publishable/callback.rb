module Mongoid
  module Publishable
    class Callback
      def initialize(*args, &block)
        if block_given?
          @method = block
        elsif args.length == 1 && args[0].kind_of?(Symbol)
          @method = args[0]
        else
          raise ArgumentError, "after_publish only allows a block or a symbol method reference as arguments"
        end
      end
      
      def process(object)
        if @method.respond_to?(:yield)
          @method.yield(object)
        else
          object.send(@method)
        end
      end
    end
  end
end