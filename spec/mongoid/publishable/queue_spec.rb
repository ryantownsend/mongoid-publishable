require "spec_helper"
require "mongoid/publishable/queue"

describe Mongoid::Publishable::Queue do

  describe "the class" do
    subject do
      Mongoid::Publishable::Queue
    end
    
    describe "::load" do
      context "given session data" do
        it "should create an unpublished object for each line" do
          data = %Q({ class_name: "Item", id: 123 }\n{ class_name: "Item", id: 123 })
          expect(subject.load(data).size).to eq 2
        end
      end
      
      context "given no session data" do
        it "should return an empty queue" do
          expect(subject.load.size).to eq 0
        end
      end
    end
  end
  
  describe "an instance of the queue" do
    let(:items) { [] }
    
    subject do
      Mongoid::Publishable::Queue.new(items)
    end

    describe "#publish_via" do
      let(:item) do
        mock("unpublished_item").tap do |item|
          item.stub(:publish_via!).and_return(true)
        end
      end
      let(:items) { [item] }

      context "when all contents are published" do
        before(:each) do
          item.stub(:published?).and_return(true)
        end
        
        it "should empty the queue" do
          expect(subject.size).to eq 1
          subject.publish_via(mock("user"))
          expect(subject.size).to eq 0
        end
      end
      
      context "when one of the items cannot be published" do
        before(:each) do
          item.stub(:published?).and_return(false)
        end
        
        it "should leave one item in the queue" do
          expect(subject.size).to eq 1
          subject.publish_via(mock("user"))
          expect(subject.size).to eq 1
        end
      end
    end
    
    describe "#dump" do
      let(:item) do
        mock("unpublished_item", serialize_for_session: "123")
      end
      let(:items) { [item, item] }

      it "should serialize each object and join into a multi-line string" do
        expect(subject.dump).to eq "123\n123"
      end
    end
    
    describe "#push" do
      context "when given a single item" do
        it "the number of objects should be incremented by 1" do
          count = subject.size
          subject.push(mock("model"))
          expect(subject.size).to eq count + 1
        end
      end
      
      context "when given 2 items" do
        it "the number of objects should be incremented by 2" do
          count = subject.size
          subject.push(mock("model"), mock("model"))
          expect(subject.size).to eq count + 2
        end
      end
      
      context "when given no items" do
        it "the number of objects should not change" do
          count = subject.size
          subject.push
          expect(subject.size).to eq count
        end
      end
    end

  end # instance

end