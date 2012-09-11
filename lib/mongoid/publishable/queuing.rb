module Mongoid
  module Publishable
    module Queuing
      def self.included(base)
        base.class_eval do
          before_filter :deserialize_publishing_queue
          after_filter  :serialize_publishing_queue
          attr_reader   :publishing_queue
        end
        base.send(:include, InstanceMethods)
      end
      
      module InstanceMethods
        protected
        def deserialize_publishing_queue
          @publishing_queue = Queue.load(session[:publishing_queue])
        end
        
        def serialize_publishing_queue
          session[:publishing_queue] = @publishing_queue.dump
        end
      end
    end
  end
end
