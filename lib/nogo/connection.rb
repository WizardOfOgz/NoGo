module NoGo
  class Connection
    @@proxy_adapter = nil

    # Returns proxy adapter if connected, otherwise raises an error
    def self.proxy_adapter
      @@proxy_adapter || raise('Proxy adapter is not connected.  Please run NoGo::Connection.connect! to first establish a connection.')
    end

    # Proxy an existing connection.  Raises an exception if no database
    # connection has been established.
    def self.connect!
      # TODO: Abstract away ORM-specific code *
      original_adapter = ActiveRecord::Base.connection_pool.spec.config[:adapter]
      ActiveRecord::Base.establish_connection :adapter => :nogo, :target_adapter => ActiveRecord::Base.connection
      @@proxy_adapter = ActiveRecord::Base.connection

      # After establishing connection the connection pool config adapter will be set to <tt>:nogo</tt> which
      # may cause problems with gems such as activerecord-import which rely on that value to be set to a
      # standard ActiveRecord database adapter.  Fortunately we can easily change the config setting back to
      # its original value.
      ActiveRecord::Base.connection_pool.spec.config[:adapter] = original_adapter 
    end

    # Returns true or false to indicate whether a proxy adapter has been connected.
    def self.connected?
      !!@@proxy_adapter
    end

    def self.enabled=(value)
      proxy_adapter.enabled = value
    end

    def self.pop_enabled_state
      proxy_adapter.pop_enabled_state
    end

    def self.push_enabled_state
      proxy_adapter.push_enabled_state
    end

    def self.strategy=(strategy)
      proxy_adapter.strategy = strategy
    end
  end
end