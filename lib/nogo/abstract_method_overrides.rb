module NoGo
  # Contains overrides for methods which are defined in ActiveRecord::ConnectionAdapters::AbstractAdapter and are 
  # ovenrridden here as a way to hook into ActiveRecord before requests access the database connection.
  module AbstractMethodOverrides

    def execute(sql, name = nil)
      if sql.match /BEGIN|ROLLBACK|SAVEPOINT/ # TODO: There should be a better way to avoid transactions *
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
  end
end