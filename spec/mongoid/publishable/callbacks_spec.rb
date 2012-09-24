require "spec_helper"

describe Mongoid::Publishable::Callbacks do

  context "a class that's included Mongoid::Publishable::Callbacks" do

    subject do
      CallbackableObject
    end
    
    before(:each) do
      [CallbackableObject, CallbackableSubobject].each do |klass|
        klass.after_publish_callbacks.replace []
      end
    end
    
    describe "::after_publish_callbacks" do
      it "should return an object that responds to #process" do
        expect(subject.after_publish_callbacks).to respond_to :process
      end
    end
  
    describe "::after_publish" do
      it "should increment the callbacks by 1" do
        expect(subject.after_publish_callbacks.size).to eq 0
        subject.after_publish(:method_name)
        expect(subject.after_publish_callbacks.size).to eq 1
      end
  
      it "should accept a block" do
        callback = subject.after_publish do |object|
          puts "Done something"
        end
        expect(callback).to respond_to :process
      end
    
      it "should accept a symbol" do
        callback = subject.after_publish(:method_name)
        expect(callback).to respond_to :process
      end
      
      it "should be inherited by any sub-classes" do
        expect(CallbackableSubobject.after_publish_callbacks.size).to eq 0
        CallbackableObject.after_publish(:method_name)
        expect(CallbackableSubobject.after_publish_callbacks.size).to eq 1
      end
    end

  end # class
  
  context "a sub-class of a class that's included Mongoid::Publishable::Callbacks" do
    
    before(:each) do
      [CallbackableObject, CallbackableSubobject].each do |klass|
        klass.after_publish_callbacks.replace []
      end
    end
    
    describe "defining a callback" do
      it "should not be defined on the parent class" do
        expect(CallbackableObject.after_publish_callbacks.size).to eq 0
        CallbackableSubobject.after_publish(:method_name)
        expect(CallbackableObject.after_publish_callbacks.size).to eq 0
      end
    end

  end
  
  context "an instance of a class that's included Mongoid::Publishable::Callbacks" do

    subject do
      CallbackableObject.new
    end

    describe "#process_after_publish_callbacks" do
      it "should process the callbacks" do
        collection = subject.class.after_publish_callbacks
        collection.should_receive(:process).with(subject).and_return(true)
        expect(subject.process_after_publish_callbacks).to be_true
      end
    end
    
    describe "#run_after_publish_callbacks?" do
      context "by default" do
        it "should return false" do
          expect(subject.run_after_publish_callbacks?).to be_false
        end
      end
      
      context "after calling #run_after_publish_callbacks" do
        it "should return true" do
          subject.run_after_publish_callbacks
          expect(subject.run_after_publish_callbacks?).to be_true
        end
      end
    end

  end # instance

end