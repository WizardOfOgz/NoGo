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

    def proxied_adapter
      @adapter
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

    # Overridden methods ----------------------------------------------------------------

    def execute(sql, name = nil)
      if sql.match /BEGIN|ROLLBACK|SAVEPOINT/
        pass_through(:execute, sql, name)
      else
        raise_or_pass_through(:execute, sql, name)
      end      
    end

    def insert(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
      raise_or_pass_through(:insert, sql, name, pk, id_value, sequence_name, binds)
    end

    def update(sql, name = nil, binds = [])
      raise_or_pass_through(:update, sql, name, binds)
    end

    def delete(sql, name = nil, binds = [])
      raise_or_pass_through(:delete, sql, name, binds)
    end

    def select_rows(sql, name = nil)
      raise_or_pass_through(:select_rows, sql, name)
    end

    def select(sql, name = nil)
      raise_or_pass_through(:select, sql, name)
    end

    def select_all(sql, name = nil, binds = [])
      raise_or_pass_through(:select_all, sql, name, binds)
    end

    def select_one(sql, name = nil)
      raise_or_pass_through(:select_one, sql, name)
    end

    def select_value(sql, name = nil)
      raise_or_pass_through(:select_value, sql, name)
    end

    def select_values(sql, name = nil)
      raise_or_pass_through(:select_values, sql, name)
    end

    def exec_query(sql, name = nil, binds = [])
      raise_or_pass_through(:exec_query, sql, name, binds)
    end

    def exec_insert(sql, name = nil, binds = [])
      raise_or_pass_through(:exec_insert, sql, name, binds)
    end

    def exec_delete(sql, name = nil, binds = [])
      raise_or_pass_through(:exec_delete, sql, name, binds)
    end

    def exec_update(sql, name = nil, binds = [])
      raise_or_pass_through(:exec_update, sql, name, binds)
    end

    def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
      raise_or_pass_through(:insert_sql, sql, name, pk, id_value, sequence_name, binds)
    end

    def update_sql(sql, name = nil)
      raise_or_pass_through(:update_sql, sql, name)
    end

    def delete_sql(sql, name = nil)
      raise_or_pass_through(:delete_sql, sql, name)
    end

    # -----------------------------------------------------------------------------------

    private

    def method_missing(method_name, *args, &block)
      pass_through(method_name, *args, &block)
    end

    def pass_through(method_name, *args, &block)
      warn(method_name, *args, &block) if @strategy == :warn
      proxied_adapter.send(method_name, *args, &block)
    end

    def raise_or_pass_through(method_name, *args, &block)
      raise 'Database connection is prohibited' if @strategy == :raise
      pass_through(method_name, *args, &block)
    end

    def warn(method_name, *args, &block)
    end
  end
end
