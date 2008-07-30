require File.dirname(__FILE__) + "/spec_helper"
include Page

describe Element do
  
  before :each do
    @html = File.read(File.dirname(__FILE__) + "/fixtures/igoogle_render.html")
    @doc = Hpricot(@html)
    @elmt = Element.new(@html)
  end
  
  it "should only initialize with an hpricot element or a string" do
    Element.new(@html).class.should == Element
    Element.new(@doc).class.should == Element
    Element.new(@doc.children[1]).class.should == Element
    lambda{Element.new(1234)}.should raise_error(ArgumentError)
  end
  
  it "should parse the page on the fly" do
    @elmt.links.length.should == 114
    @elmt.links[0].class.should == Link
    @elmt.forms.length.should == 10
    @elmt.forms[0].class.should == Form
  end
  
  it "should be able to find tags based on method name" do
    @elmt.inputs.length.should == 37
    @elmt.a.length.should == @elmt.links.length
    @elmt.p.length.should == @elmt.paragraphs.length
    @elmt.any(:class => "gb3").length.should == 1
  end
  
  it "should find elements by attribute value" do
    @elmt.links(:href => "http://www.google.com/intl/en/options/").length.should == 2
    @elmt.links(:class => "gb3", :href => "http://www.google.com/intl/en/options/").length.should == 1
  end
  
  it "should default to finding elements by id" do
    @elmt.forms("sfrm").should == @elmt.forms(:id => "sfrm")
    @elmt.forms("sfrm").should == @elmt.find("sfrm")
  end
  
  it "should reroute undefined methods to Hpricot element" do
    @elmt.instance_variable_get("@elmt").should_receive(:search).with("#sfrm")
    @elmt.search("#sfrm")
  end
  
end