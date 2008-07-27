class EventDispatcher
  
  def initialize
    @registration = {}
  end
  
  def register_callback(event_name, object, options=nil)
    options ||= {}
    options[:method_name] ||= "on_#{event_name}" unless options[:method_name]
    @registration[event_name] = [] unless @registration[event_name]
    @registration[event_name] << {:object => object, :method => options[:method_name].to_sym, :bubbles => options[:bubbles]}
  end
  
  def dispatch_event(event_name, options=nil)
    options ||= {}
    @registration[event_name].each do |event|
      if event[:object].is_a?(EventDispatcher) && (event[:bubbles] || options[:bubbles])
        options[:dispatcher] = self
        event[:object].send(:dispatch_event, event_name, options)
      else
        options[:dispatcher] ||= self
        event[:object].send(event[:method], options)
      end
    end
  end
  
end