require 'spec_helper'

describe NoGo::ProxyAdapter do
  describe '::new' do
    it 'initializes with adapter argument' do
      expect{ NoGo::ProxyAdapter.new(ActiveRecord::ConnectionAdapters::AbstractAdapter.new(mock)) }.to_not raise_error
    end

    it 'raises error without adapter argument' do
      expect{ NoGo::ProxyAdapter.new }.to raise_error(ArgumentError)
    end

    it 'raises error when adapter argument is not an instance of AbstractAdapter' do
      expect{ NoGo::ProxyAdapter.new(Object.new) }.to raise_error(ArgumentError)
    end
  end

end