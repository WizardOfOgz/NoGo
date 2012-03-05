if defined?(ActiveRecord::Import)
  ActiveRecord::Import.module_eval do
    class << self # Lulz, I tried `module << self` which didn't work.
      # Catch case where adapter is set to <tt>:nogo</tt>.  Activerecord-import hijacks 
      # AR::Base#establish_connection, so there was no clean way to avoid having it attempt
      # to require its own nogo adatper, which fails.
      def require_adapter_with_nogo(adapter)
        require_adapter_without_nogo(adapter) unless adapter==:nogo
      end
      alias_method_chain :require_adapter, :nogo
    end
  end
end