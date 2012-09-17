require "spec_helper"
require "mongoid/publishable/callback"

describe Mongoid::Publishable::Callback do
  subject { Mongoid::Publishable::Callback }

  describe "#initialize" do
    it "should accept a block" do
      callback = subject.new do |object|
        puts "Done something"
      end
      expect(callback).to respond_to :process
    end
    
    it "should accept a symbol" do
      callback = subject.new(:method_name)
      expect(callback).to respond_to :process
    end
    
    it "should not accept two arguments" do
      expect {
        subject.new(:one, :two)
      }.to raise_error(ArgumentError)
    end
  end
  
  describe "#process" do
    let(:object) { mock("instance", test: "123") }
    
    context "when given a method name" do
      it "should call the method on the given object" do
        callback = subject.new(:test)
        expect(callback.process(object)).to eq "123"
      end
    end
    
    context "when given a block" do
      it "should yield the block with the given object" do
        callback = subject.new do |object|
          object.test
        end
        expect(callback.process(object)).to eq "123"
      end
    end
  end
end