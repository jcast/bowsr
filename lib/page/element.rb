module Page
  class Element < EventDispatcher
    
    def initialize(hpricot_element)
      @elmt = hpricot_element
    end
    
    def to_s
      @elmt.to_html
    end
    
    def find(element, options=nil)
      #find(:all, :class => "blah")
      #find(:first, :href => "http://google.com")
      #find("some_id")
    end
    
    def tag_for_method(method_name)
      case method_name
      when "links": "a"
      when "paragraphs", "para": "p"
      when "images": "img"
      else
        method_name.singularize
      end
    end
    
    def hash_to_xpath(hash)
      return hash.to_s unless hash.is_a? Hash
      properties = ""
      hash.each_pair do |key, value|
        properties << "[@#{key}='#{value}']"
      end
      return properties
    end
    
    def method_missing(method_name, *args)
      #First see if method can be called on the Hpricot document
      return @elmt.send(method_name.to_sym, *args) if @elmt.responds_to(method_name.to_sym)
    
      #If not Hpricot, let's see if we're trying to find an html element
      tag_name = tag_for_method(method_name)
      properties = hash_to_xpath(args[0])
      properties = "##{properties}" unless %w{# . / [}.index(properties[0])
      results = @elmt.search("//#{tag_name}#{properties}").collect do |r|
        element_class = Element
        element_class = properties if defined?(properties.constantize)
        element_class = arg[0].constantize if arg[0].is_a?(String) && defined?(arg[0].constantize)
        element_class.new(r)
      end
      return results
    end
    
  end
end