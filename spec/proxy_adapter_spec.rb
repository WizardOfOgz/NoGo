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

  it 'passes method calls through to the adapter' do
    adapter.should_receive(:pass_through)
    proxy_adapter.pass_through
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

  describe '#raise_or_pass_through' do
    context 'strategy is :raise' do
      before :each do
        # proxy_adapter.strategy = :raise
      end

      it 'raises an exception in ' do
      end
    end
  end
end