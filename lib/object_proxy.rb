module AsyncProxy
  
  # a wrapper around an object that will intercept all method calls and run them asynchronously  
  class ObjectProxy
    def initialize(object)
      @object    = object
      @callbacks = []
    end
    
    def sync
      @object
    end
    
    def async
      self
    end
    
    def to_s
      sync.to_s
    end
    
    def each
      sync.each{yield}
    end
    
    # calling +map+ on a proxy will run the block in parallel for each element
    # of the Enumerable
    #
    # async_array.map(&block).each {
    #   # starts processing the first element even if the other ones are not ready yet
    # }
    def map(&block)
      when_ready do |enum|
        enum.map do |item|
          AsyncProxy::ResultProxy.new(item, block)
        end
      end
    end
    
    def ready?
      true
    end
    
    # runs the block with the computation's result as the first argument
    # as soon as the value is available
    #
    # returns an async proxy object, that can be used exactly to recover the block's return
    # value or chain more computations    
    def when_ready(&block)
      result_proxy = AsyncProxy::ComputedProxy.new(self, block)
      register_callback {result_proxy.launch_computation}
      result_proxy
    end

    # called with a block, runs it as soon the computation's result is available.
    # The return value of the block is discarded: use +when_ready+ if you are interested in the
    # block's return value
    def register_callback(&proc)
      if ready?
        proc.call(sync)
      else
        @callbacks << proc
      end
    end

    private  
      def method_missing(symbol, *args)
        when_ready do |obj|
          obj.send(symbol, *args)
        end
      end
  end
end