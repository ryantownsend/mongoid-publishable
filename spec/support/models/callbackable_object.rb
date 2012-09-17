require "mongoid/publishable/callbacks"

class CallbackableObject
  include Mongoid::Document
  include Mongoid::Publishable::Callbacks
end