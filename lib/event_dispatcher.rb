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
    options[:dispatcher] ||= self
    @registration[event_name].each do |event|
      event[:object].send(event[:method], options)
      if event[:object].is_a?(EventDispatcher) && (event[:bubbles] || options[:bubbles])
        bubble_options = options.dup
        bubble_options[:dispatcher] = self
        event[:object].send(:dispatch_event, event_name, bubble_options)
      end
    end
  end
  
end