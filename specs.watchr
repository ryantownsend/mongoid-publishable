watch("spec/spec_helper\.rb") { |md| system("rspec") }
watch("spec/support/.*\.rb") { |md| system("rspec") }
watch("spec/.*_spec\.rb") { |md| system("rspec #{md[0]}") }
watch("lib/(.*)\.rb") { |md| system("rspec spec/#{md[1]}_spec.rb") }

# Ctrl + \
Signal.trap("QUIT") do
  system("rspec")
end

# Ctrl+C
Signal.trap("INT") { abort("\n") }