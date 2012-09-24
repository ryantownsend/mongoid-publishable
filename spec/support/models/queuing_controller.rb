class QueuingController
  def self.before_filter(*args); end
  def self.after_filter(*args); end
  def session; @session ||= {}; end
  include Mongoid::Publishable::Queuing
end