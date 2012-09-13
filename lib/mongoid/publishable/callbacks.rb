module Mongoid
  module Publishable

    module Callbacks
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
        base.class_eval do
          # handle after_publish callbacks
          after_save :process_after_publish_callbacks, if: :run_after_publish_callbacks?
        end
      end
      
      class CallbackStorage < Array; end
      
      class Callback
        def initialize(*args)
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
            object.call(@method)
          end
        end
      end
      
      module ClassMethods
        # returns the list of callbacks
        def after_publish_callbacks
          @after_publish_callbacks ||= CallbackStorage.new
        end
        
        # adds a callback to the list
        def after_publish(*args)
          after_publish_callbacks << Callback.new(*args)
        end
      end
      
      module InstanceMethods        
        # process the callbacks
        def process_after_publish_callbacks
          self.class.after_publish_callbacks.each do |callback|
            callback.process(self)
          end
        end
    
        # set to run the callbacks after save
        def run_after_publish_callbacks
          @run_after_publish_callbacks = true
        end
    
        # returns whether the object has just been published
        def run_after_publish_callbacks?
          !!@run_after_publish_callbacks
        end
      end
    end

  end
end