require File.dirname(__FILE__) + "/spec_helper"
include Cookies

describe CookieJar do

  before(:each) do
    cookie_str = "myCookie=a=1&b=2; path=/; domain=bob.com;"
    cookie_str = cookie_str + "; cookie2=blarg; path=blarg.com/; domain=weirdthings.com"
    cookie_str = cookie_str + "; cookie3=foo, path=foo.com/, domain=bob.weirdthings.com"
    @cookies = Cookie.parse(cookie_str)
    @jar = CookieJar.new
    @cookies.each{|c| @jar.store(c) }
  end

  it "should store cookies only" do
    begin
      @jar.store("string is invalid type")
      raise "never got invalid argument error"
    rescue ArgumentError
      true.should == true
    end
  end

  it "should store cookies by domain" do
    @cookies.each do |c|
      @jar.instance_eval("@store")[c.properties["domain"]].index(c).should_not be_nil
    end
  end

  it "should retrieve cookies by domain" do
    arr = @jar.grab("bob")
    arr.length.should == 0
    arr = @jar.grab("bob.com")
    arr.length.should == 1
    arr[0].name.should == "myCookie"
  end

  it "should ignore subdomains when not specified" do
    arr = @jar.grab("weirdthings.com")
    arr.length.should == 1
    arr[0].name.should == "cookie2"
  end

  it "should include subdomains when specified" do
    arr = @jar.grab("bob.weirdthings.com")
    arr.length.should == 2
    arr[0].name.should == "cookie3"
    arr[1].name.should == "cookie2"
  end

end