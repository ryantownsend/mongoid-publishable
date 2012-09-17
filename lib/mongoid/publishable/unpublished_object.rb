require "multi_json"

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
      
      def serialize_for_session
        @serialized_data ||= serialize_object_for_session
      end
      
      def params
        MultiJson.load(@serialized_data)
      end
      
      def respond_to_missing?(method, include_private = false)
        source_object.respond_to?(method) || super
      end
      
      def method_missing(method, *args, &block)
        if respond_to_missing?(method)
          source_object.send(method, *args, &block)
        else
          super
        end
      end
      
      def source_object
        @source_object ||= load_source_object_from_params
      end
      
      private
      def load_source_object_from_params
        data = params
        # load the top level object
        object = data["class_name"].constantize.find(data["id"])
        # if we have embedded stuff
        while data["embedded"]
          # work on the next level down
          data = data["embedded"]
          # find the nested object
          object = object.send(data["association"]).find(data["id"])
        end
        # once at the bottom, return the object
        object
      end
      
      def serialize_object_for_session
        # start at the bottom
        object = source_object
        result = nil
        # work the way up the embeds
        while object.embedded?
          # select the relation for the parent object
          parent_relation = relations.select do |k,v|
            v.macro == :embedded_in && v.class_name == object._parent.class.name
          end.values.first
          # wrap the the result
          result = {
            embedded: {
              association: parent_relation.inverse_of,
              embedded: result && result[:embedded],
              id: object.id
            }
          }
          # now act on the parent
          object = object._parent
        end
        # when at the top level, store the class/id/result
        result = { class_name: object.class.name, id: object.id, embedded: result && result[:embedded] }
        # convert the result to JSON
        MultiJson.dump(result)
      end
    end
  end
end
