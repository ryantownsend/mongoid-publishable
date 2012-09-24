require "spec_helper"

describe Mongoid::Publishable::CallbackCollection do
  let(:callback) { mock("callback") }
  let(:contents) { [callback] }
  subject { Mongoid::Publishable::CallbackCollection.new(contents) }

  describe "#process" do
    it "should call #process on each of it's items" do
      object = mock("instance")
      callback.should_receive(:process).with(object).and_return(true)
      subject.process(object)
    end
  end

end