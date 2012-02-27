module ActiveRecord
  class Base
    def self.nogo_connection(config)
      proxy_adapter = NoGo::ProxyAdapter.new(config[:target_adapter])
      proxy_adapter.proxied_adapter.send :connect
      proxy_adapter
    end
  end
end
