require 'spec_helper'
require 'active_record/connection_adapters/nogo_adapter'

describe ActiveRecord::Base do
  describe '::nogo_connection' do
    let(:adapter) { mock }
    let(:nogo_adapter) { mock(:proxied_adapter => adapter) }

    before :each do
      NoGo::ProxyAdapter.stub(:new).with(adapter).and_return(nogo_adapter)
    end

    it 'returns new NoGo::ProxyAdapter instance' do
      adapter.stub(:connect)
      ActiveRecord::Base.nogo_connection({:target_adapter => adapter}).should == nogo_adapter
    end

    it 'reconnects the adapter' do
      adapter.should_receive(:connect)
      ActiveRecord::Base.nogo_connection({:target_adapter => adapter})
    end
  end

end