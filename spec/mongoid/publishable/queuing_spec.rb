require "spec_helper"

describe Mongoid::Publishable::Queuing do
  subject do
    QueuingController.new
  end
  
  describe "#deserialize_publishing_queue" do
    it "should make the queue accessible via #publishing_queue" do
      subject.send(:deserialize_publishing_queue)
      expect(subject.publishing_queue).to respond_to :<<
    end
  end
  
  describe "#serialize_publishing_queue" do
    it "should dump the data data to the session" do
      data = { :one => "two" }
      subject.send(:deserialize_publishing_queue)
      subject.publishing_queue.should_receive(:dump).and_return(data)
      subject.send(:serialize_publishing_queue)
      expect(subject.session[:publishing_queue]).to eq data
    end
  end
end