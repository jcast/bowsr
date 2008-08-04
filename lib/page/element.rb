require "hpricot"
require "active_support"

require "#{File.dirname(__FILE__)}/../event_dispatcher"
require "#{File.dirname(__FILE__)}/tag_library"


module Page
  module Element
    
    include EventDispatcher
    include TagLibrary
    
    #find(:any, :class => "blah")
    #find(:form, :name => "foo")
    #find("some_id")
    def find(element, options=nil)
      options ||= {}
      if element.is_a?(String)
        options.merge!({:id => element})
        element = :any
      end
      
      tag_query = query_for(element)
      properties = xpath_for(options)
      properties = "##{properties}" unless properties.empty? || ["#",".","/","[","*"].index(properties[0,1])
      
      results = self.search("#{tag_query}#{properties}").collect do |r|
        r.extend(module_for(tag_query, r.to_html))
      end
      return results
    end
    
    def method_missing(method_name, *args)
      #See if we're trying to find an html element
      #puts method_name
      return find(method_name, args[0])
    end
    
  end
end


require "#{File.dirname(__FILE__)}/helpers"
require "#{File.dirname(__FILE__)}/link"
require "#{File.dirname(__FILE__)}/form"