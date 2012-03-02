require_relative '../nogo'
require_relative 'rspec/dsl'


# class DBSafe
#   @@enabled = false
#   def self.enabled
#     !!@@enabled
#   end
#   def self.enabled=(value)
#     @@enabled = value
#   end

#   def self.with_unit_test
#     original_enabled_value = @@enabled
#     @@enabled = true
#     yield if block_given?
#     @@enabled = original_enabled_value
#   end
# end
# module DBSafeContext
#   extend RSpec::Core::SharedContext
#   before(:all) do
#         original_enabled_value = DBSafe.enabled
#         DBSafe.enabled = true
#         puts "DB safe: #{DBSafe.enabled}"
#   end
#   after(:all) do
#         DBSafe.enabled = original_enabled_value
#         puts "Exit: #{DBSafe.enabled}"    
#   end
# end
# RSpec::Example::ExampleGroupMethods.module_eval do
#     def db_safe(*args,&block)
#       describe do
#         include DBSafeContext
#         instance_eval(&block)
#       end
#     end
# end