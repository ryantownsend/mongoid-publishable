require "spec_helper"
require "multi_json"
require "mongoid/publishable/unpublished_object"

describe Mongoid::Publishable::UnpublishedObject do
  let(:model) { PublishableObject.new }
  let(:parent_model) do
    ParentPublishableObject.create
  end
  let(:nested_model) do
    parent_model.nested_objects.build
  end

  describe "::deserialize_from_session" do
    it "should initialize with data" do
      subject = Mongoid::Publishable::UnpublishedObject.deserialize_from_session("data")
      expect(subject).to be_kind_of Mongoid::Publishable::UnpublishedObject
    end
  end
  
  describe "::initialize" do
    subject do
      Mongoid::Publishable::UnpublishedObject.new(params)
    end
    let(:params) { Hash.new }
    
    context "with a model" do
      let(:params) do
        { model: model }
      end
      
      it "should not raise an error" do
        expect { subject }.not_to raise_error
      end
    end
    
    context "with data" do
      let(:params) do
        { data: %Q({ class_name: "Item", id: 123 }) }
      end
      
      it "should not raise an error" do
        expect { subject }.not_to raise_error
      end
    end
    
    context "with no model or data" do      
      it "should raise an argument error" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
  
  describe "#serialize_for_session" do
    context "with a model" do
      subject do
        Mongoid::Publishable::UnpublishedObject.new(model: model)
      end
      
      it "should return a string of JSON" do
        json = MultiJson.load(subject.serialize_for_session)
        expect(json["class_name"]).to eq model.class.name
        expect(json["id"].to_s).to eq model.id.to_s
      end
      
      it "should deserialise back into the object" do
        model.save
        data = subject.serialize_for_session
        reloaded_subject = subject.class.deserialize_from_session(data)
        expect(reloaded_subject.source_object).to eq subject.source_object
      end
    end
    
    context "with a nested model" do
      subject do
        Mongoid::Publishable::UnpublishedObject.new(model: nested_model)
      end
      
      it "should return a string of JSON" do
        json = MultiJson.load(subject.serialize_for_session)
        expect(json["class_name"]).to eq nested_model._parent.class.name
        expect(json["id"].to_s).to eq nested_model._parent.id.to_s
        expect(json["embedded"]["id"]).to eq nested_model.id.to_s
        expect(json["embedded"]["association"]).to eq "nested_objects"
        expect(json["embedded"]["embedded"]).to be_nil
      end
      
      it "should deserialise back into the object" do
        nested_model.save
        data = subject.serialize_for_session
        reloaded_subject = subject.class.deserialize_from_session(data)
        expect(reloaded_subject.source_object).to eq subject.source_object
      end
    end
    
    context "with data" do
      subject do
        data = %Q({ "class_name": "Item", "id": "123" })
        Mongoid::Publishable::UnpublishedObject.new(data: data)
      end
      
      it "should return a string of JSON" do
        json = MultiJson.load(subject.serialize_for_session)
        expect(json["class_name"]).to eq "Item"
        expect(json["id"].to_s).to eq "123"
      end
    end
  end
  
  describe "#params" do
    context "with data" do
      subject do
        data = %Q({ "class_name": "Item", "id": "123" })
        Mongoid::Publishable::UnpublishedObject.new(data: data).params
      end
      
      it "should return a string of JSON" do
        expect(subject["class_name"]).to eq "Item"
        expect(subject["id"].to_s).to eq "123"
      end
    end
  end
  
  describe "#respond_to_missing?" do
    subject do
      Mongoid::Publishable::UnpublishedObject.new(model: model)
    end

    it "should return true if the model accepts the method" do
      expect(subject.respond_to_missing?(:id)).to be_true
    end
  end
  
  describe "#method_missing" do
    subject do
      Mongoid::Publishable::UnpublishedObject.new(model: model)
    end
    
    it "should delegate to the model" do
      expect(subject.id).to eq model.id
    end
  end
  
  describe "#source_object" do
    context "with data" do
      subject do
        data = %Q({ "class_name": "PublishableObject", "id": "123" })
        Mongoid::Publishable::UnpublishedObject.new(data: data)
      end
      
      it "should find the model" do
        model = mock("model")
        PublishableObject.should_receive(:find).with("123").and_return(model)
        expect(subject.source_object).to eq model
      end
    end
    
    context "with a model" do
      subject do
        Mongoid::Publishable::UnpublishedObject.new(model: model)
      end
      
      it "should return the model" do
        expect(subject.source_object).to eq model
      end
    end
  end
end