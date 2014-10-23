require File.dirname(__FILE__) + "/spec_helper"


describe EventDispatcher do

  before(:each) do
    @dispatcher = Object.new.extend(EventDispatcher)
    @test_object = Object.new.extend(TestObject)
  end

  it "should properly register a callback" do
    @dispatcher.register_callback("load_event", @test_object)
    event = @dispatcher.instance_eval("@registration")["load_event"][0]
    event.class.should == Hash
    event[:object].should == @test_object
    event[:method].should == :on_load_event
    event[:bubbles].should be_nil
  end

  it "should call default callback with correct arguments" do
    @dispatcher.register_callback("load_event", @test_object)
    @dispatcher.dispatch_event("load_event")
    @test_object.method_called.should == :on_load_event
    @test_object.args[0][:dispatcher].should == @dispatcher
  end

  it "should call appropriate callback when specified" do
    @dispatcher.register_callback("load_event", @test_object, :method_name => "do_something")
    @dispatcher.dispatch_event("load_event")
    @test_object.method_called.should == :do_something
  end

  it "should bubble events up event dispatchers when specified on event" do
    @higher_dispatcher = Object.new.extend(EventDispatcher).extend(TestObject)
    @higher_dispatcher.register_callback("load_event", @test_object)
    @dispatcher.register_callback("load_event", @higher_dispatcher, :bubbles => true)
    @dispatcher.dispatch_event("load_event")
    @higher_dispatcher.method_called.should == :on_load_event
    @higher_dispatcher.args[0][:dispatcher].should == @dispatcher
    @test_object.method_called.should == :on_load_event
    @test_object.args[0][:dispatcher].should == @dispatcher
  end

  it "should bubble events up event dispatchers when specified on dispatch call" do
    @higher_dispatcher = Object.new.extend(EventDispatcher).extend(TestObject)
    @higher_dispatcher.register_callback("load_event", @test_object)
    @dispatcher.register_callback("load_event", @higher_dispatcher)
    @dispatcher.dispatch_event("load_event", :bubbles => true)
    @higher_dispatcher.method_called.should == :on_load_event
    @higher_dispatcher.args[0][:dispatcher].should == @dispatcher
    @test_object.method_called.should == :on_load_event
    @test_object.args[0][:dispatcher].should == @dispatcher
  end

end