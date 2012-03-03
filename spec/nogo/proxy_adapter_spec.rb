require 'spec_helper'

describe NoGo::ProxyAdapter do
  let(:adapter) { ActiveRecord::ConnectionAdapters::AbstractAdapter.new(nil)}
  let(:proxy_adapter) { NoGo::ProxyAdapter.new(adapter) }

  before :all do
    NoGo::ProxyAdapter.class_eval do

      # Ugh, rspec mocks freak out if we try to pass calls to
      def is_a?(klass)
        proxied_adapter.is_a?(klass)
      end

      private
      def method_missing_with_test_filter(method_name, *args, &block)
        # RSpec sends messages directly to method_missing when checking an object with mocked methods.  Why?  I don't know, but it 
        # causes an infinite loop for some of ProxyAdapter methods.  This filter prevents that from happening.
        unless %W[warn pass_through method_missing].include?(method_name.to_s)
          method_missing_without_test_filter(method_name, *args, &block)
        end
      end
      alias_method_chain :method_missing, :test_filter
    end
  end

  describe '::new' do
    it 'initializes with adapter argument' do
      expect{ NoGo::ProxyAdapter.new(adapter) }.to_not raise_error
    end

    it 'raises error without adapter argument' do
      expect{ NoGo::ProxyAdapter.new }.to raise_error(ArgumentError)
    end

    it 'raises error when adapter argument is not an instance of AbstractAdapter' do
      expect{ NoGo::ProxyAdapter.new(Object.new) }.to raise_error(ArgumentError)
    end

    it 'initializes @strategy to :raise' do
      NoGo::ProxyAdapter.new(adapter).instance_variable_get(:@strategy).should == :raise
    end
  end

  it 'passes undefined method calls through to the adapter' do
    adapter.should_receive(:method_name).with(:arg)
    proxy_adapter.method_name :arg
  end

  it 'initializes enabled to false' do
    NoGo::ProxyAdapter.new(adapter).enabled.should == false
  end

  describe '#enabled?' do
    context 'enabled set to true' do
      before :each do
        proxy_adapter.enabled = true
      end

      it 'returns true if block_enabled is set to true' do
        proxy_adapter.block_enabled = true
        proxy_adapter.enabled?.should == true
      end

      it 'returns true if block_enabled is set to true' do
        proxy_adapter.block_enabled = false
        proxy_adapter.enabled?.should == true
      end
    end

    context 'enabled set to true' do
      before :each do
        proxy_adapter.enabled = false
      end

      it 'returns true if block_enabled is set to true' do
        proxy_adapter.block_enabled = true
        proxy_adapter.enabled?.should == true
      end

      it 'returns true if block_enabled is set to true' do
        proxy_adapter.block_enabled = false
        proxy_adapter.enabled?.should == false
      end
    end
  end
    
  describe '#proxied_adapter' do
    it 'returns adapter' do
      proxy_adapter.proxied_adapter.should == adapter
    end
  end

  describe '#is_a?' do
    it 'invokes method on proxied adapter' do
      adapter.stub(:is_a?).with(ActiveRecord::ConnectionAdapters::AbstractAdapter) { true }
      adapter.should_receive(:is_a?).with(Class)
      proxy_adapter.is_a?(Class)
    end
  end

  describe '#strategy' do
    NoGo::ProxyAdapter::StrategyOptions.each do |strategy_option|
      it "returns :#{strategy_option}" do
        proxy_adapter.instance_variable_set(:@strategy, strategy_option)
        proxy_adapter.strategy.should == strategy_option
      end
    end
  end

  describe '#strategy=' do
    NoGo::ProxyAdapter::StrategyOptions.each do |strategy_option|
      it "sets :#{strategy_option} strategy" do
        proxy_adapter.strategy = strategy_option
        proxy_adapter.strategy.should == strategy_option
      end
    end

    it 'raises an exception if the strategy option is not valid' do
      expect{ proxy_adapter.strategy = :invalid_option }.to raise_error(ArgumentError)
    end
  end

  describe '#pass_through' do
    it 'uoea' do
      proxy_adapter.should_receive(:bleh).with(:m, :a)
      proxy_adapter.bleh :m, :a
    end

    it 'sends method call and arguments to @adapter' do
      adapter.should_receive(:method_name).with(:arg)
      proxy_adapter.send :pass_through, :method_name, :arg
    end

    context 'when strategy is :warn' do
      before :each do
        proxy_adapter.strategy = :warn
      end

      it 'invokes #warn when enabled' do
        proxy_adapter.enabled = true
        adapter.stub(:method_name)
        proxy_adapter.should_receive(:warn).with(:method_name, :arg)
        proxy_adapter.send :pass_through, :method_name, :arg
      end

      it 'does not invoke #warn when disabled' do
        proxy_adapter.enabled = false
        adapter.stub(:method_name)
        proxy_adapter.should_not_receive(:warn).with(:method_name, :arg)
        proxy_adapter.send :pass_through, :method_name, :arg
      end
    end

    it 'does not invoke #warn when strategy is :pass_through' do
      proxy_adapter.strategy = :pass_through
      adapter.stub(:method_name)
      proxy_adapter.should_not_receive(:warn).with(:method_name, :arg)
      proxy_adapter.send :pass_through, :method_name, :arg
    end
  end

  describe '#raise_or_pass_through' do
    context 'when strategy is set to :raise' do
      before :each do
        proxy_adapter.strategy = :raise
      end

      it 'raises an exception when enabled' do
        proxy_adapter.enabled = true
        expect{ proxy_adapter.send :raise_or_pass_through, :method_name, :arg }.to raise_error
      end

      it 'does not raise an exception when disabled' do
        proxy_adapter.enabled = false
        adapter.stub(:method_name)
        expect{ proxy_adapter.send :raise_or_pass_through, :method_name, :arg }.to_not raise_error
      end
    end

    context 'when strategy is set to :warn' do
      before :each do
        proxy_adapter.strategy = :warn
      end

      it 'passes method call through to the adapter' do
        proxy_adapter.should_receive(:pass_through).with(:method_name, :arg)
        proxy_adapter.send :raise_or_pass_through, :method_name, :arg
      end
    end

    context 'when strategy is set to :pass_through' do
      before :each do
        proxy_adapter.strategy = :pass_through
      end

      it 'passes method call through to the adapter' do
        proxy_adapter.should_receive(:pass_through).with(:method_name, :arg)
        proxy_adapter.send :raise_or_pass_through, :method_name, :arg
      end
    end
  end

  # Overridden methods -------------------------------------------------------

  describe '#execute' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:execute, 'SELECT COUNT(*) FROM tables;', 'name')
      proxy_adapter.execute('SELECT COUNT(*) FROM tables;', 'name')
    end

    it 'invokes #pass_through if SQL is BEGIN' do
      proxy_adapter.should_receive(:pass_through).with(:execute, 'BEGIN', 'name')
      proxy_adapter.execute('BEGIN', 'name')
    end

    it 'invokes #pass_through if SQL is ROLLBACK' do
      proxy_adapter.should_receive(:pass_through).with(:execute, 'ROLLBACK', 'name')
      proxy_adapter.execute('ROLLBACK', 'name')
    end

    it 'invokes #pass_through if SQL is SAVEPOINT' do
      proxy_adapter.should_receive(:pass_through).with(:execute, 'SAVEPOINT', 'name')
      proxy_adapter.execute('SAVEPOINT', 'name')
    end
  end

  describe '#insert' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(
        :insert, 'SQL', 'name', 'pk', 'id_value', 'sequence_name', ['bind']
      )
      proxy_adapter.insert('SQL', 'name', 'pk', 'id_value', 'sequence_name', ['bind'])
    end
  end

  describe '#update' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:update, 'SQL', 'name', [])
      proxy_adapter.send(:update, 'SQL', 'name', [])
    end
  end

  describe '#delete' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:delete, 'SQL', 'name', [])
      proxy_adapter.send(:delete, 'SQL', 'name', [])
    end
  end

  describe '#select_rows' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:select_rows, 'SQL', 'name')
      proxy_adapter.select_rows('SQL', 'name')
    end
  end

  describe '#select' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:select, 'SQL', 'name')
      proxy_adapter.send(:select, 'SQL', 'name')
    end
  end

  describe '#select_all' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:select_all, 'SQL', 'name', [])
      proxy_adapter.send(:select_all, 'SQL', 'name', [])
    end
  end

  describe '#select_one' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:select_one, 'SQL', 'name')
      proxy_adapter.send(:select_one, 'SQL', 'name')
    end
  end

  describe '#select_value' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:select_value, 'SQL', 'name')
      proxy_adapter.send(:select_value, 'SQL', 'name')
    end
  end

  describe '#select_values' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:select_values, 'SQL', 'name')
      proxy_adapter.send(:select_values, 'SQL', 'name')
    end
  end

  describe '#exec_query' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:exec_query, 'SQL', 'name', [])
      proxy_adapter.send(:exec_query, 'SQL', 'name', [])
    end
  end

  describe '#exec_insert' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:exec_insert, 'SQL', 'name', [])
      proxy_adapter.send(:exec_insert, 'SQL', 'name', [])
    end
  end

  describe '#exec_delete' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:exec_delete, 'SQL', 'name', [])
      proxy_adapter.send(:exec_delete, 'SQL', 'name', [])
    end
  end

  describe '#exec_update' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:exec_update, 'SQL', 'name', [])
      proxy_adapter.send(:exec_update, 'SQL', 'name', [])
    end
  end

  describe '#insert_sql' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:'insert_sql', 'SQL', 'name', 'pk', 'id_value', 'sequence_name', ['bind'])
      proxy_adapter.send(:'insert_sql', 'SQL', 'name', 'pk', 'id_value', 'sequence_name', ['bind'])
    end
  end

  describe '#delete_sql' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:'delete_sql', 'SQL', 'name')
      proxy_adapter.send(:'delete_sql', 'SQL', 'name')
    end
  end

  describe '#update_sql' do
    it 'invokes #raise_or_pass_through' do
      proxy_adapter.should_receive(:raise_or_pass_through).with(:'update_sql', 'SQL', 'name')
      proxy_adapter.send(:'update_sql', 'SQL', 'name')
    end
  end

  # --------------------------------------------------------------------------
end
