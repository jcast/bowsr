require "cgi"
require "#{File.dirname(__FILE__)}/helpers"
require "#{File.dirname(__FILE__)}/cookie"

module Cookies
  # TODO: cleanup expired cookies
  class CookieJar

    def initialize
      @store = {}
    end

    def store(cookie)
      raise(ArgumentError, "expected type Cookie, got #{cookie.class}") unless cookie.is_a? Cookie
      @store[cookie.domain] = [] unless @store[cookie.domain].is_a? Array
      @store[cookie.domain] << cookie
      #puts "STORE COOKIE: #{cookie.domain} - #{cookie.name}"
    end

    # Returns an array of cookies
    # Accepts queries of the following form:
    #   :domain
    #   { :domain => :cookie_name }
    #   { :domain => [:cookie1, :cookie2...], :domain2 => :cookie3 }
    def grab(query)
      cookie_array = []
      if !query.is_a? Hash
        query.each do |domain, cookie_names|
          cookie_array << if cookie_names.is_a?(Array)
            cookies_matching_domain(domain).select{|c| cookie_names.index(c.name) }
          else
            cookies_matching_domain(domain)
          end
        end
        cookie_array.flatten!
      else
        cookie_array = cookies_matching_domain(query)
      end
      #puts "INSPECT:" + cookie_array.inspect
      cookie_array.compact.select{|c| !c.expired? }.extend(CookieArray)
    end

    private

    def cookies_matching_domain(request_domain)
      @store.select{|k,v| request_domain.to_s =~ /#{k}$/ }.collect{|arr| arr[1] }
    end

  end
end
