require "mongoid/publishable/unpublished_object"

module Mongoid
  module Publishable
    class Queue < Array

      # loads the queue from the session
      def self.load(session = nil)
        # create a new queue
        queue = new
        # if there was no existing queue, return new
        return queue unless session
        # create our contents
        contents = session.split("\n").map do |data|
          UnpublishedObject.deserialize_from_session(data)
        end
        # add into the queue
        queue.replace(contents)
      end
      
      # publishes all the objects on the queue to this user
      def publish_via(publisher)
        remaining = delete_if do |model|
          model.publish_via!(publisher)
          model.published?
        end
        # replaces the contents with the remaining models
        replace(remaining)
      end
      
      # creates a string containing the data of the queue
      def dump
        map do |model|
          model.serialize_for_session
        end.join("\n")
      end
      
      # adds a new object to the queue
      def push(*models)
        # map each item to an unpublished object
        models = Array(models).map do |model|
          UnpublishedObject.new(model: model)
        end
        # add them to the array
        super(*models)
      end
      alias_method :<<, :push

    end
  end
end
