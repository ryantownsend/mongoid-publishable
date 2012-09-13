require "simplecov"
SimpleCov.start

require "mongoid"

lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

models = File.expand_path("../support/models", __FILE__)
$LOAD_PATH.unshift(models) unless $LOAD_PATH.include?(models)

Dir[File.join(File.dirname(__FILE__), "support/*.rb")].each { |f| require f }