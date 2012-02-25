require 'spec_helper'

describe NoGo::ProxyAdapter do
  it 'initializes' do
    expect{ NoGo::ProxyAdapter.new }.to_not raise_error
  end
end