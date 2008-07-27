module Page
  class Link < Element
    
    def follow
      dispatch_event("follow_link", :data => href)
    end
    
  end
end