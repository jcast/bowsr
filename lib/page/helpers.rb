module Page
  
  module HttpRequestor
    
    alias_method :old_method_missing, :method_missing
    
    def request_method
      @request_method || "get"
    end
    
    def request_method=(value)
      @request_method = value
    end
    
    def method_missing(name, *args)
      name_arr = name.to_s.split("_")
      if ["post", "get", "put", "delete"].index(name_arr.last.downcase) && name_arr.length > 1
        request_method = name_arr.last.downcase
      end
      
      return old_method_missing(name, *args)
    end
    
  end
  
end