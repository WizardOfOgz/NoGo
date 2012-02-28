# Adds a connection method so that ActiveRecord recognizes the proxy adapter
module ActiveRecord
  class Base
    # returns an instance of <tt>NoGo::ProxyAdapter</tt> which proxies the adapter instance specified by <tt>config[:target_adapter]</tt>.  This method will 
    # also attempt to reconnect the proxied adapter.
    def self.nogo_connection(config)
      proxy_adapter = NoGo::ProxyAdapter.new(config[:target_adapter])
      proxy_adapter.proxied_adapter.send :connect # TODO: It would be nice if we could detect whether the adapter was connected before, but for now just attempt to reconnect it. ActiveRecord disconnects the adapter before calling <tt>::nogo_connection</tt> *
      proxy_adapter
    end
  end
end
