class Object
  # returns an async wrapper around this object
  def async
    AsyncProxy::ObjectProxy.new(self)
  end 

  # ensures we are dealing with the "real" synchronous object
  def sync
    self # a no-op in Object, will be redefine in async proxies classes
  end
end