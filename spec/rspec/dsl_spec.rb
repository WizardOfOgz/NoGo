require 'spec_helper'
require_relative '../../lib/nogo/rspec'

describe NoGo::RSpec::DSL do
  describe '::nogo_example_group' do
    it 'returns an rspec example group' do
      dummy_example_group = mock
      block = Proc.new {}
      RSpec::Core::ExampleGroup.stub(:subclass).and_return(dummy_example_group)
      NoGo::RSpec::DSL.nogo_example_group(&block).should == dummy_example_group
    end

    context 'executed' do
      it 'invokes nogo before all block' do
        dummy = mock
        dummy.should_receive(:execute)
        block = Proc.new { dummy.execute }
        NoGo::RSpec::DSL.stub(:NogoBeforeAllBlock).and_return(block)
        NoGo::RSpec::DSL.nogo_example_group{ it{ :example_to_trigger_callbacks }}.run mock.as_null_object
      end

      it 'invokes nogo after all block' do
        dummy = mock
        dummy.should_receive(:execute)
        block = Proc.new { dummy.execute }
        NoGo::RSpec::DSL.stub(:NogoAfterAllBlock).and_return(block)
        NoGo::RSpec::DSL.nogo_example_group{ it{ :example_to_trigger_callbacks}}.run mock.as_null_object
      end

      it 'invokes instance eval with example group block' do
        dummy = mock
        dummy.should_receive(:execute)
        block = Proc.new { dummy.execute }
        NoGo::RSpec::DSL.nogo_example_group(&block).run mock.as_null_object
      end
    end
  end
end

describe 'nogo' do
  it 'registers a nogo example group' do
    dummy_example_group = mock
    dummy_example_group.should_receive(:register)
    NoGo::RSpec::DSL.stub(:nogo_example_group).and_return(dummy_example_group)
    nogo{}
  end
end
