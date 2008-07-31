module Page
  class Link < Element
    
    #include HttpRequestor
    
    def follow
      dispatch_event("#{self.request_method}_request", :url => self['href'])
    end
    
  end
end