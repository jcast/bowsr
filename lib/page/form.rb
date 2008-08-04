#require all form elements here

module Page
  module Form
    
    include Element
    include HttpRequestor
    
    def submit(*options)
      request_type = (options[0].is_a?(String) && options[0]) || self.request_method
      form_values = options.last if options.last.is_a?(Hash)
      # get and override form values
      self.set_values(form_values) if form_values
      dispatch_event("#{request_type}_request", :url => self['action'], :data => self.values)
    end
    
    def request_method
      @request_method || self['method'] || "post"
    end
    
    def set_values(new_form_values)
      #Sets form values
    end
    
    def values
      #Gets form values
    end
    
    def info
      #Gets all form information: elements, action, etc
    end
    
  end
end
