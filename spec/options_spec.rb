require "#{File.dirname(__FILE__)}/../imageproxy"

describe "parsing" do
  context "a simple URL" do
    subject { Options.new "/color/blue/size/medium" }
    its(:color) { should == "blue" }
    its(:size) { should == "medium" }
  end

  context "source" do
    context "when escaped" do
      subject { Options.new "/source/http%3A%2F%2Fexample.com%2Fdog.jpg" }
      it("should unescape") { subject.source.should == "http://example.com/dog.jpg" }
    end

    context "when not escaped" do
      subject { Options.new "/source/foo" }
      it("should not unescape") { subject.source.should == "foo" }
    end
  end
end