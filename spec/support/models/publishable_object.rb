require "mongoid/publishable"

class PublishableObject
  include Mongoid::Document
  include Mongoid::Publishable

  belongs_to :user, class_name: "Publisher"
end