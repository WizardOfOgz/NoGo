module NoGo
  class Connection
    @@proxy_adapter = nil

    # Proxy an existing connection.  Raises an exception if no database
    # connection has been established.
    def self.connect!
      ActiveRecord::Base.establish_connection :adapter => :nogo, :target_adapter => ActiveRecord::Base.connection
      @@proxy_adapter = ActiveRecord::Base.connection
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