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
      
      module ClassMethods
        # returns the list of callbacks
        def after_publish_callbacks
          @after_publish_callbacks ||= []
        end
        
        # adds a callback to the list
        def after_publish(*args)
          if block_given?
            @after_publish_callbacks ||= []
            @after_publish_callbacks << &block
          elsif args.length == 1 && args[0].kind_of?(Symbol)
            @after_publish_callbacks ||= []
            @after_publish_callbacks << args[0]
          else
            raise ArgumentError, "after_publish only allows a block or a symbol method reference as arguments"
          end
        end
      end
      
      module InstanceMethods
        # allow additional per-instance after_publish callbacks,
        # delegate to the class for defaults too
        def after_publish_callbacks
          (@after_publish_callbacks || []) + self.class.after_publish_callbacks
        end
        
        # process the callbacks
        def process_after_publish_callbacks
          after_publish_callbacks.each do |callback|
            if callback.kind_of?(Symbol)
              send(callback)
            elsif callback.respond_to?(:yield)
              callback.yield(self)
            else
              raise ArgumentError, "Unknown how to handle after_publish callback of type: #{callback.class.name}"
            end
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