source 'https://rubygems.org'

# Specify your gem's dependencies in mongoid_publishable.gemspec
gemspec

case RUBY_PLATFORM
when /darwin/
  gem "rb-fsevent", require: false
when /linux/
  gem "rb-inotify", require: false
end