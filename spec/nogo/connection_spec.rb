require 'spec_helper'

describe NoGo::Connection do
  subject { NoGo::Connection }
  let(:proxy_adapter) { mock.as_null_object }
  before :each do
    subject.class_variable_set(:@@proxy_adapter, proxy_adapter)
  end

  describe '::proxy_adapter' do
    let(:proxy_adapter) {mock}

    before :each do
      subject.class_variable_set(:@@proxy_adapter, proxy_adapter)
    end

    it 'raises error if proxy adapter is not connected' do
      subject.class_variable_set(:@@proxy_adapter, nil)
      expect{subject.proxy_adapter}.to raise_error
    end

    it 'does not raise an error if proxy adapter is connected' do
      subject.class_variable_set(:@@proxy_adapter, proxy_adapter)
      expect{subject.proxy_adapter}.to_not raise_error
    end

    it 'returns proxy adapter if connected' do
      subject.class_variable_set(:@@proxy_adapter, proxy_adapter)
      subject.proxy_adapter.should == proxy_adapter
    end
  end

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
      subject.connected?.should == true
    end    
  end

  describe '::enabled=' do
    it 'invokes #enabled= with argument on proxy adapter' do
      argument = mock
      proxy_adapter.should_receive(:enabled=).with(argument)
      subject.enabled = argument
    end
  end

  describe '::strategy=' do
    it 'calls #strategy= on the proxy adapter' do
      proxy_adapter.should_receive(:strategy=).with(:pass_through)
      subject.strategy = :pass_through
    end
  end

  describe '::pop_enabled_state' do
    it 'invokes #pop_enabled_state on the proxy adapter' do
      proxy_adapter.should_receive(:pop_enabled_state)
      subject.pop_enabled_state
    end
  end

  describe '::push_enabled_state' do
    it 'invokes #push_enabled_state on the proxy adapter' do
      proxy_adapter.should_receive(:push_enabled_state)
      subject.push_enabled_state
    end
  end
end