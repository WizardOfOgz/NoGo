require 'spec_helper'

describe NoGo::Connection do
  subject { NoGo::Connection }

  describe '::connect!' do
    it 'raise an error if ActiveRecord is not connected to a database' do
      ActiveRecord::Base.stub(:connection).and_raise(ActiveRecord::ConnectionNotEstablished.new)
      expect{subject.connect!}.to raise_error(ActiveRecord::ConnectionNotEstablished)
    end

    context do
      let(:adapter) { ActiveRecord::ConnectionAdapters::AbstractAdapter.new(nil)}
      let(:config) {{:adapter => 'original_adapter'}}
      
      before :each do
        adapter.stub(:connect)
        ActiveRecord::Base.stub(:connection) { adapter }
        ActiveRecord::Base.stub(:connection_pool) { mock(:spec => mock(:config => config)) }
      end

      it 'proxies the current connection adapter' do
        ActiveRecord::Base.should_receive(:establish_connection).
          with(:adapter => :nogo, :target_adapter => adapter)
        subject.connect!
      end

      it 'sets @@proxy_adapter with instance of NoGo::ProxyAdapter generated when establishing connection' do
        subject.connect!
        subject.class_variable_get(:@@proxy_adapter).should == adapter
      end

      it 'sets connection_pool spec config adapter to original (non-proxied) value' do
        config.should_receive(:[]=).with(:adapter, 'original_adapter')
        subject.connect!
      end
    end
  end

  describe '::connected?' do
    it 'returns false if proxy adapter has not been connected' do
      subject.class_variable_set(:@@proxy_adapter, nil)
      subject.connected?.should == false
    end

    it 'returns true if proxy adapter has been connected' do
      subject.class_variable_set(:@@proxy_adapter, mock)
      subject.connected?.should == true
    end    
  end

  describe '::raise_if_not_connected' do
    it 'raises error if proxy adapter is not connected' do
      subject.stub(:connected?) { false }
      expect{subject.send(:raise_if_not_connected)}.to raise_error
    end

    it 'does not raise an error if proxy adapter is connected' do
      subject.stub(:connected?) { true }
      expect{subject.send(:raise_if_not_connected)}.to_not raise_error
    end
  end
end