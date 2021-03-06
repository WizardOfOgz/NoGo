module NoGo
  class ProxyAdapter  
    # Valid values for <tt>@strategy</tt> and arguments when setting <tt>strategy</tt>
    StrategyOptions = [:raise, :warn, :pass_through].freeze

    ErrorMessageForRaiseStrategy = <<-EOM.freeze
      Access to the database adapter is currently restricted (strategy set to :raise).
      Set strategy to :pass_through or :warn to allow database access.  See NoGo::Connection#strategy=.
    EOM

    # Most methods calls should simply be passed on to the proxied adapter.  By undefining most methods we can use 
    # <tt>method_missing</tt> to accomplish this.
    instance_methods.each do |method_name| 
      undef_method method_name unless method_name =~ /^__|^send$|^object_id$|^extend|^tap|^instance_variable_set|^instance_variable_get/ 
    end

    attr_accessor :enabled

    # Include overriden AbstractAdapter methods
    include NoGo::AbstractMethodOverrides

    # Initializes an instance and sets the proxied adapter and default strategy.  An exception is raised if the argument to <tt>adapter</tt> is 
    # not an instance of <tt>ActiveRecord::ConnectionAdapters::AbstractAdapter</tt>.
    def initialize(adapter)
      raise ArgumentError.new(
        "Expected an instance of ActiveRecord::ConnectionAdapters::AbstractAdapter, but received #{adapter.class.name}"
      ) unless adapter.is_a?(ActiveRecord::ConnectionAdapters::AbstractAdapter)

      @adapter = adapter
      @strategy = :raise
      self.enabled = false
      @enabled_state_stack = []
    end

    # Pops the last value from <tt>enabled_state_stack</tt> and assigns it to <tt>enabled</tt>.
    def pop_enabled_state
      self.enabled = @enabled_state_stack.pop || false
    end

    # Pushes the current value of <tt>enabled</tt> onto <tt>enabled_state_stack</tt>.
    def push_enabled_state
      @enabled_state_stack.push(enabled)
    end

    # Returns the adapter which is being proxied by the current object.
    def proxied_adapter
      @adapter
    end

    # Returns the current strategy assigned to this adapter, which can any of the <tt>StrategyOptions</tt>.
    def strategy
      @strategy
    end

    # Sets the current strategy for this adapter.  Raises an <tt>ArgumentErrer</tt> if <tt>strategy_option</tt> is not
    # a value from <tt>StrategyOptions</tt>
    def strategy=(strategy_option)
      raise ArgumentError.new(
        "Expected strategy to be set to one of [#{StrategyOptions.map{|opt| ":#{opt}"}.join(', ')}], but received #{strategy_option}"
      ) unless StrategyOptions.include?(strategy_option.to_sym)

      @strategy = strategy_option
    end

    private

    # Pass through any undefined instance method calls.
    def method_missing(method_name, *args, &block)  # :doc:
      pass_through(method_name, *args, &block)
    end

    # Passes a method call to the proxied adapter.
    # If the strategy is set to <tt>:warn</tt> then <tt>#warn</tt> will be invoked.
    def pass_through(method_name, *args, &block) # :doc: 
      warn(method_name, *args, &block) if enabled && @strategy == :warn
      proxied_adapter.send(method_name, *args, &block)
    end

    # Raises an error if the current strategy is <tt>:raise</tt> and otherwise defers the method call to <tt>#pass_through</tt>.
    def raise_or_pass_through(method_name, *args, &block) # :doc:
      raise ErrorMessageForRaiseStrategy if enabled && @strategy == :raise
      pass_through(method_name, *args, &block)
    end

    # Placeholder for <tt>#warn</tt> method.  This is probably a place to trigger hooks once they are supported
    def warn(method_name, *args, &block) # :doc:
      puts "\nDatabase adapter accessed from: " + Kernel.caller[0..12].join("\n")
    end
  end
end
