class Object
  # returns an async wrapper around this object
  def async
    AsyncProxy::ObjectProxy.new(self)
  end 

  # ensures we are dealing with the "real" synchronous object
  def sync(options = {})
    self # a no-op in Object, will be redefined in async proxies classes
  end
end