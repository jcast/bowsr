require "#{File.dirname(__FILE__)}/element"

module Page
  class Document < Element
    
    def initialize(raw_html)
      @elmt = Hpricot(raw_html)
    end
    
  end
end