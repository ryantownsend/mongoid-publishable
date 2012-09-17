class CallbackableObject
  def self.after_save(*args); end
  include Mongoid::Publishable::Callbacks
end