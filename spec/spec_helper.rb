require 'spec'
require File.join(File.dirname(__FILE__), "..", "lib", 'bowsr')


module TestObject
  attr_reader :method_called, :args
  
  def method_missing(name, *args)
     @method_called = name
     @args = args
  end
end