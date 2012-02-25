require 'spec_helper'

describe NoGo::ProxyAdapter do
  let(:adapter) { ActiveRecord::ConnectionAdapters::AbstractAdapter.new(mock) }
  let(:proxy_adapter) { NoGo::ProxyAdapter.new(adapter) }

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
    it 'sends method call and arguments to @adapter' do
      adapter.should_receive(:method_name).with(:arg)
      proxy_adapter.send :pass_through, :method_name, :arg
    end
  end

  describe '#raise_or_pass_through' do
    it 'raises an exception when strategy is set to :raise' do
      proxy_adapter.strategy = :raise
      expect{ proxy_adapter.send :raise_or_pass_through, :method_name, :arg }.to raise_error
    end

    context 'when strategy is set to :warn' do
      before :each do
        proxy_adapter.strategy = :warn
      end

      it 'invokes #warn' do
        adapter.stub(:method_name)
        proxy_adapter.should_receive(:warn).with(:method_name, :arg)
        proxy_adapter.send :raise_or_pass_through, :method_name, :arg
      end

      it 'passes method call through to the adapter' do
        proxy_adapter.should_receive(:pass_through).with(:method_name, :arg)
        proxy_adapter.stub(:warn)
        proxy_adapter.send :raise_or_pass_through, :method_name, :arg
      end
    end

    context 'when strategy is set to :pass_through' do
      before :each do
        proxy_adapter.strategy = :pass_through
      end

      it 'does not invoke #warn' do
        adapter.stub(:method_name)
        proxy_adapter.should_not_receive(:warn).with(:method_name, :arg)
        proxy_adapter.send :raise_or_pass_through, :method_name, :arg
      end

      it 'passes method call through to the adapter' do
        proxy_adapter.should_receive(:pass_through).with(:method_name, :arg)
        proxy_adapter.send :raise_or_pass_through, :method_name, :arg
      end
    end
  end
end