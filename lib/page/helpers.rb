module Page
  
  module HttpRequestor
    
    def request_method
      @request_method || "get"
    end
    
    def request_method=(value)
      @request_method = value
    end
    
  end
  
end