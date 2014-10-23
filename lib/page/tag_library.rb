module Page
  module TagLibrary

    @@library = {
            :any            => "*",
            :links          => "a",
            :paragraphs     => "p",
            :images         => "img",
            :inputs         => "input,textarea,button,select",
            :radios         => "input[@type='radio']",
            :checkboxes     => "input[@type='checkbox']",
            :passwords      => "input[@type='password']",
            :file_fields    => "input[@type='file']",
            :text_fields    => "input[@type='text']",
            :hidden_fields  => "input[@type='hidden']",
            :reset_buttons  => "input[@type='reset']",
            :submit_buttons => "input[@type='submit']",
            :image_buttons  => "input[@type='image']"
          }

    def query_for(key)
      return @@library[key.to_sym] || key.to_s.singularize
    end

    def module_for(query, html=nil)
      return unless query
      key = @@library.index(query) || query.singularize
      mod = Page.const_get(key.to_s.singularize.camelize) if (key && Page.const_defined?(key.to_s.singularize.camelize))
      mod = module_for(match(/^<([^\s\\>]+)[>\s]*/)[1]) if html && !mod
      mod ||= Element
      return mod
    end

    def xpath_for(hash)
      operator = "="
      return hash.to_s unless hash.is_a? Hash
      properties = ""
      hash.each_pair do |key, value|
        op = operator
        op = value[0,2] if ["<=",">=","!=","^=","$=","*="].index(value[0,2])
        op = value[0,1] if ["<",">"].index(value[0,1])
        properties << "[@#{key}#{op}'#{value}']"
      end
      return properties
    end

  end
end