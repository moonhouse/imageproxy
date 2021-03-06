require 'base64'
require "#{File.dirname(__FILE__)}/../lib/imageproxy"

describe Imageproxy::Options do
  describe "parsing path" do
    context "a simple URL" do
      subject { Imageproxy::Options.new "/process/color/blue/size/medium", {} }
      its(:command) { should == "process" }
      its(:color) { should == "blue" }
      its(:size) { should == "medium" }
    end

    context "source" do
      context "when double-escaped" do
        subject { Imageproxy::Options.new "/process/source/http%253A%252F%252Fexample.com%252Fdog.jpg", {} }
        it("should unescape") { subject.source.should == "http://example.com/dog.jpg" }
      end

      context "when escaped" do
        subject { Imageproxy::Options.new "/process/source/http%3A%2F%2Fexample.com%2Fdog.jpg", {} }
        it("should unescape") { subject.source.should == "http://example.com/dog.jpg" }
      end

      context "when not escaped" do
        subject { Imageproxy::Options.new "/process/source/foo", {} }
        it("should not unescape") { subject.source.should == "foo" }
      end

      context "when parameter is named 'src'" do
        subject { Imageproxy::Options.new "/process/src/foo", {} }
        it("should rename to 'source'") { subject.source.should == "foo" }
      end
    end

    context "signature" do
      context "when escaped with + signs" do
        subject { Imageproxy::Options.new "/process/source/foo/signature/foo+bar", {} }
        it("should keep the + sign") { subject.signature.should == "foo+bar" }
      end
    end
  end

  describe "adding query params" do
    subject { Imageproxy::Options.new "/convert/source/foo", { "resize" => "20x20" } }
    it("should add query params") { subject.resize.should == "20x20" }
    it("should keep params from path") { subject.source.should == "foo" }
  end

  describe "obfuscation" do
    it "should allow the query string to be encoded in base64" do
      encoded = CGI.escape(Base64.encode64("resize=20x20&source=http://example.com/dog.jpg"))
      options = Imageproxy::Options.new "/convert", "_" => encoded
      options.resize.should == "20x20"
      options.source.should == "http://example.com/dog.jpg"
    end

    it "should allow the path to be encoded in base64" do
      encoded = CGI.escape(Base64.encode64("resize/20x20/source/http%3A%2F%2Fexample.com%2Fdog.jpg"))
      options = Imageproxy::Options.new "/convert/-/#{encoded}", {}
      options.resize.should == "20x20"
      options.source.should == "http://example.com/dog.jpg"
    end
  end

  describe "quality" do
    it "should be set to 0 if it's less than 0" do
      Imageproxy::Options.new("/convert", "quality" => "-39").quality.should == "0"
    end

    it "should be set to 100 if it's > 100" do
      Imageproxy::Options.new("/convert", "quality" => "293").quality.should == "100"
    end
    
    it "should not change if it's >= 0 <= 100" do
      Imageproxy::Options.new("/convert", "quality" => "59").quality.should == "59"
    end
  end
end
