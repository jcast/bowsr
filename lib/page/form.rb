module Page
  class Form < Element
    
    def submit(form_values=nil)
      # get and override form values
      dispatch_event("form_submit", :data => form_input)
    end
    
    def info
      @elmt.search("//input")
      @elmt.search("//select")
      @elmt.search("//textarea")
    end
    
  end
end