module Page
  module Link
    
    include Element
    include HttpRequestor
    
    def follow(request_type=nil)
      request_type ||= self.request_method
      dispatch_event("#{request_type}_request", :url => self['href'])
    end
    
  end
end