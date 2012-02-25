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

    private

    def method_missing(method_name, *args, &block)
      @adapter.send(method_name, *args, &block)
    end
  end
end