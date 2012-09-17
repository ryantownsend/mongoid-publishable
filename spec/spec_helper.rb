require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "mongoid"

lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }