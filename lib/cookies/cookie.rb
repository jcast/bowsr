module Cookies
  class Cookie
  
    STANDARD_ATTR = ["comment","domain","expires","max-age","path","version","secure","httponly"]
    COOKIE_REGEXP = /[^=\s;,]+=[^;,]*[;,]?\s*((((path|version|max-age|comment|domain)=[^;,]*)|(expires=[a-zA-Z]+,[-\w\s:]+)|(secure|httponly))[;,]?\s*)*/i
  
    attr_accessor :name, :content, :properties
  
    def initialize(name, content_val, properties={})
      @name = name
      @content = content_val
      @properties = {}
      properties.each do |k,v|
        next unless v
        k = k.to_s.downcase
        v = parse_time(v) if k == "expires" && !v.is_a?(Time)
        v = Time.at(Time.now.to_i + v.to_i) if k == "max-age"
        @properties[k] = v
      end
    end
  
    def expired?
      expires = @properties['expires']
      max_age = @properties['max-age']
      return expires < Time.now if expires
      return max_age < Time.now if max_age
      false
    end
  
    def secure?
      @properties['secure'] || false
    end
  
    def secure=(val)
      @properties['secure'] = val
    end
  
    def to_s
      string_arr = ["#{@name}=#{@content}"]
      @properties.each do |k,v|
        v = time_to_gmt(v) if k == "expires"
        v = v.to_i - Time.now.to_i if k == "max-age"
        (string_arr << k) and next if v == true
        string_arr << "#{k}=#{v}" if v
      end
      string_arr.join("; ")
    end
  
    alias_method :raw, :to_s
  
  
    def self.parse(cookie_string)
      cookie_list = []
      while cookie_string.match(COOKIE_REGEXP) do
        s_cookie = cookie_string.match(COOKIE_REGEXP)[0]
        cookie_string = cookie_string[s_cookie.length..-1]
      
        cookie_attr = {}
        STANDARD_ATTR.each do |att_name|
          att_name.downcase!
          cookie_attr[att_name] = if att_name == "expires"
            match = s_cookie.match(/expires=([a-z]+,[\-0-9a-z\s:]+)[;,]?/i)
            parse_time( match[1] ) if match
          elsif ["secure","httponly"].index(att_name)
            s_cookie.match(/[\s;,]#{att_name}/i) != nil
          else
            match = s_cookie.match(/#{att_name}=([^;,]+)[;,]?/i)
            match && match[1]
          end
        end
      
        cookie_name = s_cookie.split("=")[0]
        cookie_value = s_cookie.split(/[;,]/)[0][(cookie_name.length+1)..-1]
        cookie_list << Cookie.new(cookie_name, cookie_value, cookie_attr)
      end
      cookie_list
    end
  
  
    private
  
    def parse_time(time_str)
      self.class.parse_time(time_str)
    end
  
    def self.parse_time(time_str)
      m = time_str.strip.match /^\w{3},\s(\d{2})\-(\w{3})\-(\d{4})\s(\d{2}):(\d{2}):(\d{2})/i
      return nil unless m && m[6]
      Time.gm(m[3], m[2], m[1], m[4], m[5], m[6])
    end
  
    def time_to_gmt(time)
      time.strftime("%a, %d-%b-%Y %H:%M:%S GMT")
    end
  
    def method_missing(method, *args)
      return @properties[method.to_s] if @properties[method.to_s]
    end
  
  end
end