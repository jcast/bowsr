require "net/http"
require "net/https"
require "uri"
require "cgi"
require "hpricot"

require "#{File.dirname(__FILE__)}/cookies/cookie"
require "#{File.dirname(__FILE__)}/cookies/cookie_jar"
require "#{File.dirname(__FILE__)}/page/document"


class URI::Generic
  def request_uri
    self.to_s
  end
end

# TODO: request additional resources: css, img, js, etc...
# TODO: Benchmarking: request time, itemized load times, etc...
class WebSession
  
  attr_reader :response
  attr_accessor :follow_redirects
  
  def initialize(url)
    @http = nil
    @url = URI.parse(url)
    @response = nil
    @headers = {}
    @cookies = Cookie::CookieJar.new
    @follow_redirects = true
    # TODO: @page will give access to the loaded html for general page
    # information (without needing to view source) and on-the-fly browsing:
    # web_session.page.forms["Login"].submit
    # web_session.page.links["somelink"].follow
    http(url)
  end
  
  def post(urlstr, data=nil, head=headers)
    url = URI.parse(urlstr)
    head['Content-Type'] = 'application/x-www-form-urlencoded' if data
    data = convert_to_uri_data(data)
    #puts "DATA: #{data}"
    #puts "CALLED: #{url.request_uri}"
    http_response = http(urlstr).post(@url.request_uri, data, head)
    return process_response(http_response)
  end
  
  def get(urlstr, head=headers)
    url = URI.parse(urlstr)
    http_response = http(urlstr).get(@url.request_uri, head)
    return process_response(http_response)
  end
  
  def http(new_url=nil)
    return @http unless new_url
    
    url = new_url.is_a?(URI) ? new_url : URI.parse(new_url.to_s)
    old_uri = @url.dup
    @url = @url.merge(url)
    
    if @http.nil? || old_uri.host != @url.host || old_uri.scheme != @url.scheme || old_uri.port != @url.port
      @http = Net::HTTP.new(@url.host, @url.port)
      @http.use_ssl = (@url.scheme == 'https')
      puts "HOST: #{@url.scheme}://#{@url.host}:#{@url.port}"
    end  
    set_headers({'Cookie' => @cookies.grab(@url.host).to_raw})
    puts "CALLING: #{@url.to_s}"
    puts "WITH COOKIE: #{@cookies.grab(@url.host).to_raw}"
    return @http
  end
  
  def cookie
    return response['get-cookie'] if response
  end
  
  def location
    return response['location'] if response && response['location']
    return @url.to_s
  end
  
  def headers
    @headers.merge!({'Referer' => location.to_s})
  end

  def set_headers(hash)
    @headers.merge!(hash)
  end
  
  def get_form_data_for(form_id, overrides={})
    overrides = {} unless overrides
    return unless response && response.body
    
    doc = Hpricot(response.body.strip)
    doc = doc.children.last if doc.children.length > 1 #prevents loading multiple html pages
    form_action = doc.at("##{form_id}")['action']
    form_data = {}
    #TODO: get form data from elements other than only input
    (doc/"##{form_id}//input").each do |i|
      form_data[i.attributes['name']] = overrides[i.attributes['name']] || i.attributes['value']
    end
    return form_action, form_data
  end
  
  protected
  
  def process_response(http_response)
    store_cookies(http_response['set-cookie'])
    if http_response['location'] && follow_redirects
      puts "REDIRECT"
      http_response = self.get(http_response['location'], headers)
    end
    @response = http_response
    @url = URI.parse(location)
    http_response
  end
  
  def store_cookies(cookie_string)
    return if cookie_string.nil? || cookie_string.empty?
    
    puts "COOKIE: #{cookie_string}"
    Cookie::Cookie.parse(cookie_string).each{|c| @cookies.store(c) }
  end
  
  def convert_to_uri_data(hash)
    return hash.to_s unless hash.is_a?(Hash)
    param = []
    hash.each_pair{|k, v| param << "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }
    param.join("&")
  end
  
end