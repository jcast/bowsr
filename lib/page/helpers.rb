module Page

  module HttpRequestor

    def request_method
      self['method'] || "get"
    end

    def request_method=(value)
      self['method'] = value
    end

  end

end