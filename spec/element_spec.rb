require File.dirname(__FILE__) + "/spec_helper"
include Page

describe Element do
  
  before :each do
    @html = File.read(File.dirname(__FILE__) + "/fixtures/igoogle_render.html")
    @doc = Hpricot(@html)
    @elmt = @doc.extend(Element)
  end
  
  it "should parse the page on the fly" do
    @elmt.links.length.should == 114
    @elmt.links[0].is_a?(Link).should == true
    @elmt.forms.length.should == 10
    @elmt.forms[0].is_a?(Form).should == true
  end
  
  it "should be able to find tags based on method name" do
    @elmt.inputs.length.should == 45
    @elmt.a.length.should == @elmt.links.length
    @elmt.p.length.should == @elmt.paragraphs.length
    @elmt.any(:class => "gb3").length.should == 1
  end
  
  it "should find elements by attribute value" do
    @elmt.links(:href => "http://www.google.com/intl/en/options/").length.should == 2
    @elmt.links(:class => "gb3", :href => "http://www.google.com/intl/en/options/").length.should == 1
    link = @elmt.links(:href => "http://www.google.com/intl/en/options/")[0]
    link['href'].should == "http://www.google.com/intl/en/options/"
  end
  
  it "should default to finding elements by id" do
    @elmt.forms("sfrm").should == @elmt.forms(:id => "sfrm")
    @elmt.forms("sfrm").should == @elmt.find("sfrm")
  end
  
end