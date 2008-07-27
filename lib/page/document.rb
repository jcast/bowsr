require "hpricot"
require "active_support"

require "document"
require "form"
require "link"

module Page
  class Document < Element
    
    def initialize(raw_html)
      @elmt = Hpricot(raw_html)
    end
    
  end
end