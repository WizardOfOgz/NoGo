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
  end

  it 'passes method calls through to the adapter' do
    adapter.should_receive(:pass_through)
    proxy_adapter.pass_through
  end
end