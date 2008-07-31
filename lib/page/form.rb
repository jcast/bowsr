module Page
  class Form < Element
    
    #include HttpRequestor
    
    def submit(form_values=nil)
      # get and override form values
      self.set(form_values) if form_values
      dispatch_event("#{self.request_method}_request", :url => self['action'], :data => self.values)
    end
    
    def request_method
      @request_method || self['method'] || "post"
    end
    
    def set(new_form_values)
      
    end
    
    def values
    end
    
    def info
      @elmt.search("input,select,textarea")
    end
    
    def radio_buttons
      @elmt.search("input[@type='radio']")
    end
    
    def textareas
      @elmt.search("textarea")
    end
    
    def checkboxes
      @elmt.search("input[@type='checkbox']")
    end
    
    def passwords
      @elmt.search("input[@type='password']")
    end
    
    def file_fields
      @elmt.search("input[@type='file']")
    end
    
    def text_fields
      @elmt.search("input[@type='text']")
    end
    
    def hidden_fields
      @elmt.search("input[@type='hidden']")
    end
    
    def reset_buttons
      @elmt.search("input[@type='reset']")
    end
    
    def submit_buttons
      @elmt.search("input[@type='submit']")
    end
    
    def buttons
      @elmt.search("input[@type='button']")
    end
    
    def image_buttons
      @elmt.search("input[@type='image']")
    end
    
    def selects
      @elmt.search("select")
    end
    
  end
end
