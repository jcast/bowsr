require File.dirname(__FILE__) + "/spec_helper"
include Cookies

describe Cookie do

  def parse_time(time_str)
    m = time_str.strip.match /^\w{3},\s(\d{2})\-(\w{3})\-(\d{4})\s(\d{2}):(\d{2}):(\d{2})/i
    return nil unless m && m[6]
    Time.gm(m[3], m[2], m[1], m[4], m[5], m[6])
  end


  before(:each) do
    @raw_cookie = "myCookie=a=1&b=2; comment=this is a comment; path=/; expires=Fri, 01-Jan-2016 00:00:00; secure; httponly; version=1.0; domain=bob.com; max-age=300"
    @raw_partial_cookie = "cookie2=blarg; path=blarg.com/; domain=weirdthings.com"
    @raw_ms_cookie = "cookie3=foo, path=foo.com/, domain=weirdthings.com, expires=Sun, 27-Jul-2008 00:00:00"
  end

  it "should parse all valid elements of a cookie" do
    cookies = Cookie.parse(@raw_cookie)
    cookies.length.should == 1
    cookie = cookies[0]
    cookie.name.should == "myCookie"
    cookie.content.should == "a=1&b=2"
    cookie.properties["expires"].class.should == Time
    cookie.properties["expires"].should == parse_time("Fri, 01-Jan-2016 00:00:00")
    cookie.properties["comment"].should == "this is a comment"
    cookie.properties["max-age"].class.should == Time
    cookie.properties["max-age"].should == Time.at(Time.now.to_i + 300)
    cookie.properties["domain"].should == "bob.com"
    cookie.properties["secure"].should == true
    cookie.properties["httponly"].should == true
    cookie.properties["version"].should == "1.0"
  end

  it "should parse stripped down cookies" do
    cookie = Cookie.parse(@raw_partial_cookie)[0]
    cookie.name.should == "cookie2"
    cookie.content.should == "blarg"
    cookie.properties["path"].should == "blarg.com/"
    cookie.properties["domain"].should == "weirdthings.com"
    cookie.properties["expires"].should be_nil
    cookie.properties["comment"].should be_nil
    cookie.properties["max-age"].should be_nil
    cookie.properties["secure"].should be_nil
    cookie.properties["httponly"].should be_nil
    cookie.properties["version"].should be_nil
  end

  it "should be able to parse a ms (poorly formatted) csv cookie" do
    cookie = Cookie.parse(@raw_ms_cookie)[0]
    cookie.name.should == "cookie3"
    cookie.content.should == "foo"
    cookie.properties["path"].should == "foo.com/"
    cookie.properties["domain"].should == "weirdthings.com"
  end

  it "should parse multiple cookies" do
    cookies = Cookie.parse( "#{@raw_cookie}, #{@raw_ms_cookie}; #{@raw_partial_cookie}" )
    cookies.length.should == 3
    cookies[0].name.should == "myCookie"
    cookies[1].name.should == "cookie3"
    cookies[2].name.should == "cookie2"
    cookies[0].properties.each_pair do |k,v|
      v.should_not be_nil
    end
  end

  it "should correctly return expiration test" do
    cookie = Cookie.parse(@raw_ms_cookie)[0]
    cookie.expired?.should == true
    cookie = Cookie.parse(@raw_cookie)[0]
    cookie.expired?.should == false
    cookie = Cookie.parse(@raw_partial_cookie)[0]
    cookie.expired?.should == false
  end

  it "should correctly convert back to raw string" do
    string = Cookie.parse(@raw_cookie)[0].to_s
    string.index("myCookie=a=1&b=2;").should == 0
    string.index("; comment=this is a comment").should > 0
    string.index("; path=/").should > 0
    string.index("; expires=Fri, 01-Jan-2016 00:00:00").should > 0
    string.index("; secure").should > 0
    string.index("; httponly").should > 0
    string.index("; version=1.0").should > 0
    string.index("; domain=bob.com").should > 0
    string.index("; max-age=300").should > 0
  end

end