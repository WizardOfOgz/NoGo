module NoGo
  class ProxyAdapter
    instance_methods.each do |m| 
      undef_method m unless m =~ /^__|^send$|^object_id$|^extend|^tap/ 
    end

    def initialize(adapter)
      raise ArgumentError.new(
        "Expected an instance of ActiveRecord::ConnectionAdapters::AbstractAdapter, but received #{adapter.class.name}"
      ) unless adapter.is_a?(ActiveRecord::ConnectionAdapters::AbstractAdapter)
      
      @adapter = adapter
    end
  end
end