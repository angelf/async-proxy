module AsyncProxy
  
  # a specialization of ObjectProxy to be used when the wraped value is dependent on another
  # async proxy and a computation (a block)
  #
  # will be automatically created by calling a method or +when_ready+ in any async object 
  #
  # the user should not directly create objects of this class
  
  class ComputedProxy < ObjectProxy
    
    attr_reader :callable
    attr_reader :proc
    
    def initialize(callable, proc)
      @callable  = callable
      @proc      = proc
      @callbacks = []
    end
    
    def ready?
      @ready
    end
    
    def async
      self
    end
    
    def sync
      wait_for_computation
      @result
    end

    def launch_computation
      @thread = Thread.new do
        @result = @proc.call(@callable.sync)
        @ready = true
        run_callbacks
      end
    end

    def wait_for_computation
      callable.sync # ensures the callable has finished and run its callbacks
      @thread.join if !@done
    end
    
    private
      def run_callbacks
        @callbacks.each { |block| block.call @result }
      end
  end
end