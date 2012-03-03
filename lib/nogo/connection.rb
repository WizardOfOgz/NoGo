module NoGo
  class Connection
    @@proxy_adapter = nil

    # Proxy an existing connection.  Raises an exception if no database
    # connection has been established.
    def self.connect!
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

    private

    def self.raise_if_not_connected
      raise 'Proxy adapter is not connected.  Please run NoGo::Connection.connect! to first establish a connection.' unless connected?
    end
  end
end