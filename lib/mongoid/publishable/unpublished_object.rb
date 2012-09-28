require "mongoid/nested_serialization"

module Mongoid
  module Publishable
    class UnpublishedObject
      def self.deserialize_from_session(data)
        new(data: data)
      end
      
      def initialize(options = {})
        if options[:model]
          @source_object = options[:model]
        elsif options[:data]
          @serialized_data = options[:data]
        else
          raise ArgumentError, "No :model or :data provided"
        end
      end
      
      # returns the data needed for object retrieval
      def serialize_for_session
        @serialized_data ||= serialize_object_for_session
      end
      
      # returns the retrieved object
      def source_object
        @source_object ||= load_source_object_from_params
      end
      
      # delegation to the source object
      def respond_to_missing?(method, include_private = false)
        source_object.respond_to?(method) || super
      end
      
      # delegation to the source object
      def method_missing(method, *args, &block)
        if respond_to_missing?(method)
          source_object.send(method, *args, &block)
        else
          super
        end
      end
      
      private
      def load_source_object_from_params
        Mongoid::NestedSerialization::Finder.find(@serialized_data)
      end
      
      def serialize_object_for_session
        Mongoid::NestedSerialization::Serializer.new(source_object).to_json
      end
    end
  end
end
