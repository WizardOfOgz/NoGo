module NoGo
  class ProxyAdapter
    StrategyOptions = [:raise, :warn, :pass_through]

    instance_methods.each do |method_name| 
      undef_method method_name unless method_name =~ /^__|^send$|^object_id$|^extend|^tap|^instance_variable_set|^instance_variable_get/ 
    end

    def initialize(adapter)
      raise ArgumentError.new(
        "Expected an instance of ActiveRecord::ConnectionAdapters::AbstractAdapter, but received #{adapter.class.name}"
      ) unless adapter.is_a?(ActiveRecord::ConnectionAdapters::AbstractAdapter)

      @adapter = adapter
      @strategy = :raise
    end

    def strategy
      @strategy
    end

    def strategy=(strategy_option)
      raise ArgumentError.new(
        "Expected strategy to be set to one of [:raise, :warn, :pass_through], but received #{strategy_option}"
      ) unless StrategyOptions.include?(strategy_option.to_sym)

      @strategy = strategy_option
    end

    private

    def method_missing(method_name, *args, &block)
      @adapter.send(method_name, *args, &block)
    end
  end
end

  # def execute_with_db_safe(sql, name = nil)
  #   return if sql.match /BEGIN|ROLLBACK|SAVEPOINT/
  #   puts "---> EXECUTE: #{sql}"
  #   raise_or_noop
  # end
  
  # def insert_with_db_safe(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
  #   puts "---> INSERT: #{sql.to_sql}"
  #   raise_or_noop
  # end

  # def select_rows_with_db_safe(sql, name = nil)
  #   raise_or_noop []
  # end

  # protected
  
  # def raise_or_noop(noop_return_value = nil)
  #   DBSafe.enabled ? raise(EXCEPTION_MESSAGE) : noop_return_value
  # end
  
  # def select_with_db_safe(sql, name = nil, binds = [])
  #   raise_or_noop []
  # end



  # def execute(sql, name = nil)
  #   raise_or_noop
  # end
  
  # def insert(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
  #   raise_or_noop
  # end if Rails::VERSION::MAJOR == 1

  # def select_rows(sql, name = nil)
  #   raise_or_noop []
  # end
  
  # def rename_table(table_name, new_name)
  #   raise_or_noop
  # end
  
  # def change_column(table_name, column_name, type, options = {})
  #   raise_or_noop
  # end
  
  # def change_column_default(table_name, column_name, default)
  #   raise_or_noop
  # end

  # def rename_column(table_name, column_name, new_column_name)
  #   raise_or_noop
  # end
  
  # def tables
  #   @cached_columns.keys
  # end

  # protected
  
  # def raise_or_noop(noop_return_value = nil)
  #   @strategy == :raise ? raise(EXCEPTION_MESSAGE) : noop_return_value
  # end
  
  # def select(sql, name = nil)
  #   raise_or_noop []
  # end
