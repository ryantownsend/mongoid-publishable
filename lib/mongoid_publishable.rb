require "mongoid/publishable/version"

module Mongoid
  module Publishable
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.send :include, Callbacks
      base.class_eval do
        # allow overwriting of the columns on an instance level
        attr_writer :publisher_column, :publisher_foreign_key
      end
    end
    
    module ClassMethods
      # gets/sets the column that stores the user_id
      def publisher_column(name = nil)
        @publisher_column = name if name
        @publisher_column || :user_id
      end
      
      def publisher_foreign_key(name = nil)
        @publisher_foreign_key = name if name
        @publisher_foreign_key || :id
      end
    end
    
    module InstanceMethods
      # saves to the db, and publishes if possible
      def persist_and_publish(publisher)
        publish_via(publisher) && save
      end
      
      # saves to the db, and publishes if possible
      # raises an UnpublishedError if unable to publish
      def persist_and_publish!(publisher)
        # attempt save / publish
        persist_and_publish(publisher)
        # if it was saved to the DB
        if peristed?
          # return true if published, raise exception if not
          published? || raise_unpublished_error
        # if the save failed
        else
          # return false to allow traditional validation
          false
        end
      end
      
      # delegate publisher column, allow overriding
      def publisher_column
        @publisher_column || self.class.publisher_column
      end
      
      # delegate foreign key, allow overriding
      def publisher_foreign_key
        @publisher_foreign_key || self.class.publisher_foreign_key
      end
      
      # publishes this instance using the id provided
      def publish_via(publisher)
        # ensure this isn't published
        unless published?
          # load the publisher's foreign key
          value = publisher.send(publisher_foreign_key)
          # update this instance with the key
          self.send("#{publisher_column}=", value)
          # mark as just published
          run_after_publish_callbacks
        end
      end
      
      # publishes this instance using the id provided
      # and persists the publishing
      def publish_via!(publisher)
        publish_via(publisher) && save
      end
      
      # returns boolean of whether this instance has been published
      def published?
        persisted? && send(publisher_column)
      end
      
      # returns whether this instance needs publishing (persisted, not published)
      def requires_publishing?
        persisted? && !send(publisher_column)
      end
      
      # raises an UnpublishedError containing this object as a reference
      def raise_unpublished_error
        raise UnpublishedError.new.tap { |e| e.model = self }, "Unable to publish this #{self.class.name}"
      end

    end
  end
end
