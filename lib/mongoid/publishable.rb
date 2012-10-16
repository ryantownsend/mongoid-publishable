require "mongoid"
require "mongoid/publishable/queuing"
require "mongoid/publishable/callbacks"
require "mongoid/publishable/unpublished_error"

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

      # gets/sets the foreign key of the publisher to be stored
      def publisher_foreign_key(name = nil)
        @publisher_foreign_key = name if name
        @publisher_foreign_key || :id
      end
      
      # gets/sets custom publishing conditions
      def publishing_conditions(&block)
        if block_given?
          @publishing_conditions = block
        else
          @publishing_conditions
        end
      end
    end

    module InstanceMethods
      # saves to the db, and publishes if possible
      def persist_and_publish(publisher = nil)
        publish_via(publisher) && save
      end

      # saves to the db, and publishes if possible
      # raises an UnpublishedError if unable to publish
      def persist_and_publish!(publisher = nil)
        # attempt save / publish
        persist_and_publish(publisher)
        # if it was saved to the DB
        if persisted?
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
        # ensure this isn't published and we have a publisher
        if !published? && publisher
          # load the publisher's foreign key
          value = publisher.send(publisher_foreign_key)
          # update this instance with the key
          self.send("#{publisher_column}=", value)
          # if this now counts as published
          if pre_published?
            # mark as just published
            run_after_publish_callbacks
          end
          # always return true
          true
        end
      end

      # publishes this instance using the id provided
      # and persists the publishing
      def publish_via!(publisher)
        publish_via(publisher) && save
      end
      
      # returns boolean of whether this instance has been published
      # regardless of whether it's been persisted yet
      def pre_published?
        has_publisher_id? && meets_custom_publishing_conditions?
      end

      # returns boolean of whether this instance has been published
      def published?
        persisted? && pre_published?
      end

      # returns whether this instance needs publishing (persisted, not published)
      def requires_publishing?
        persisted? && !pre_published?
      end
      
      # returns whether or not the publisher is present
      def has_publisher_id?
        !!send(publisher_column)
      end
      
      # returns true if there are no conditions, or the resulting yield is true
      def meets_custom_publishing_conditions?
        publishing_conditions.nil? || publishing_conditions.yield(self)
      end
      
      # returns a block with custom publishing conditions
      def publishing_conditions
        self.class.publishing_conditions
      end

      # raises an UnpublishedError containing this object as a reference
      def raise_unpublished_error
        raise UnpublishedError.new.tap { |e| e.model = self }, "Unable to publish this #{self.class.name}"
      end

    end
  end
end
