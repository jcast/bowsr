require "hpricot"
require "active_support"

require "#{File.dirname(__FILE__)}/../event_dispatcher"

module Page
  class Element < EventDispatcher
    
    def initialize(init_element)
      raise(ArgumentError, "expected type String or Hpricot, got #{init_element.class}") unless init_element.is_a?(String) || init_element.class.include?(Hpricot::Container::Trav)
      @elmt = init_element.is_a?(String) ? Hpricot(init_element) : init_element
    end
    
    def to_s
      @elmt.to_html
    end
    
    def ==(value)
      @elmt == value.instance_variable_get("@elmt")
    end

    def <=>(value)
      @elmt <=> value.instance_variable_get("@elmt")
    end
    
    #find(:any, :class => "blah")
    #find(:form, :name => "foo")
    #find("some_id")
    def find(element, options=nil)
      options ||= {}
      if element.is_a?(String)
        options.merge!({:id => element})
        element = "*"
      end
      element = element.to_s unless element.is_a?(String) && element.is_a?(Symbol)
      element = "*" if element == "any"
      
      tag_name = tag_for_method(element)
      properties = hash_to_xpath(options)
      properties = "##{properties}" unless ["#",".","/","[","*"].index(properties[0,1]) || properties.empty?
      results = @elmt.search("#{tag_name}#{properties}").collect do |r|
        element_class = Element
        if element == "*"
          tag_name = r.to_html.match(/^<([^\s\\>]+)[>\s]*/)[1]
          tag_name = "link" if tag_name == "a"
        end
        element_class = Page.const_get(tag_name.camelize) if tag_name && Page.const_defined?(tag_name.camelize)
        element_class = Page.const_get(element.to_s.singularize.camelize) if element != "*" && Page.const_defined?(element.to_s.singularize.camelize)
        element_class.new(r)
      end
      return results
    end
    
    def tag_for_method(method_name)
      case method_name.to_s
      when "links", "link": "a"
      when "paragraphs", "paragraph", "para": "p"
      when "images", "image": "img"
      else
        method_name.to_s.singularize
      end
    end
    
    def hash_to_xpath(hash)
      operator = "="
      return hash.to_s unless hash.is_a? Hash
      properties = ""
      hash.each_pair do |key, value|
        op = operator
        op = value[0,2] if ["<=",">=","!="].index(value[0,2])
        op = value[0,1] if ["<",">"].index(value[0,1])
        properties << "[@#{key}#{op}'#{value}']"
      end
      return properties
    end
    
    def method_missing(method_name, *args)
      #First see if method can be called on the Hpricot element
      return @elmt.send(method_name, *args) if @elmt.respond_to?(method_name)
      
      #If not Hpricot, let's see if we're trying to find an html element
      return find(method_name, args[0])
    end
    
  end
end
