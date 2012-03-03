require 'rspec'

module NoGo
  module RSpec
    class DSL
      NogoBeforeAllBlock = Proc.new do
        NoGo::Connection.push_enabled_state
        NoGo::Connection.enabled = true
      end.freeze
      NogoAfterAllBlock = Proc.new do
        NoGo::Connection.pop_enabled_state
      end.freeze

      def self.nogo_example_group(*args, &example_group_block)
        ::RSpec::Core::ExampleGroup.describe(*args) do
          before(:all, &NoGo::RSpec::DSL::NogoBeforeAllBlock)
          after(:all, &NoGo::RSpec::DSL::NogoAfterAllBlock)
          instance_eval(&example_group_block)
        end
      end
    end
  end
end

# Adds DSL method to RSpec ExampleGroup instances
RSpec::Core::DSL.module_eval do
  def nogo(*args, &example_group_block)
    NoGo::RSpec::DSL.nogo_example_group(*args, &example_group_block).register
  end
end
