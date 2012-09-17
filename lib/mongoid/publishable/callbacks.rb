require "mongoid/publishable/callback"
require "mongoid/publishable/callback_collection"

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
          @after_publish_callbacks ||= CallbackCollection.new
        end
        
        # adds a callback to the list
        def after_publish(*args, &block)
          Callback.new(*args, &block).tap do |callback|
            after_publish_callbacks << callback
          end
        end
      end
      
      module InstanceMethods        
        # process the callbacks
        def process_after_publish_callbacks
          self.class.after_publish_callbacks.process(self)
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