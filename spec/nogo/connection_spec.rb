require 'spec_helper'

describe NoGo::Connection do
  subject { NoGo::Connection }

  describe '::connect!' do
    it 'raise an error if ActiveRecord is not connected to a database' do
      ActiveRecord::Base.stub(:connection).and_raise(ActiveRecord::ConnectionNotEstablished.new)
      expect{subject.connect!}.to raise_error(ActiveRecord::ConnectionNotEstablished)
    end

    context do
      let(:dummy_connection) {mock}
      before :each do
        ActiveRecord::Base.stub(:connection) { dummy_connection }
        ActiveRecord::Base.stub(:establish_connection).
          with(:adapter => :nogo, :target_adapter => dummy_connection)
      end

      it 'proxies the current connection adapter' do
        ActiveRecord::Base.should_receive(:establish_connection).
          with(:adapter => :nogo, :target_adapter => dummy_connection)
        subject.connect!
        subject.class_variable_get(:@@proxy_adapter).should == dummy_connection
      end

      it 'sets the current proxy adapter' do
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