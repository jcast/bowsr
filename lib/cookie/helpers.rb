module Cookie
  module CookieArray
    def to_raw
      self.collect{|cookie| cookie.to_s }.join("; ")
    end
  end
end
