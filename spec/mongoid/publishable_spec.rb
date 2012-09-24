require "spec_helper"

describe Mongoid::Publishable do
  let(:user) { mock("user", id: 123) }
  
  describe "a class that includes the module" do
    subject { PublishableObject }
    
    before(:each) do
      @publisher_column = subject.publisher_column
      @publisher_foreign_key = subject.publisher_foreign_key
    end
    
    after(:each) do
      subject.publisher_column @publisher_column
      subject.publisher_foreign_key @publisher_foreign_key
    end
    
    it "should include Mongoid::Publishable::Callbacks" do
      expect(subject.included_modules).to include Mongoid::Publishable::Callbacks
    end
    
    describe "::publisher_column" do
      it "should return :user_id by default" do
        expect(subject.publisher_column).to eq :user_id
      end
      
      it "should be overridable" do
        subject.publisher_column :author_id
        expect(subject.publisher_column).to eq :author_id
        subject.publisher_column :user_id
      end
    end
  
    describe "::publisher_foreign_key" do
      it "should return :id by default" do
        expect(subject.publisher_foreign_key).to eq :id
      end
      
      it "should be overridable" do
        subject.publisher_foreign_key :username
        expect(subject.publisher_foreign_key).to eq :username
        subject.publisher_column :user_id
      end
    end
  end
  
  describe "an instance of a class that includes the module" do
    subject { PublishableObject.new }
    
    describe "#publisher_column" do
      it "should return :user_id by default" do
        expect(subject.publisher_column).to eq :user_id
      end
    end
    
    describe "#publisher_column=" do
      it "should be override #publisher_column" do
        subject.publisher_column = :author_id
        expect(subject.publisher_column).to eq :author_id
      end
    end
    
    describe "#publisher_foreign_key" do
      it "should return :id by default" do
        expect(subject.publisher_foreign_key).to eq :id
      end
    end

    describe "#publisher_foreign_key=" do
      it "should be override #publisher_foreign_key" do
        subject.publisher_foreign_key = :username
        expect(subject.publisher_foreign_key).to eq :username
      end
    end

    describe "#persist_and_publish" do
      context "when persisted" do
        before(:each) do
          subject.stub(:save).and_return(true)
        end
        
        context "without a publisher" do
          it "should return false" do
            expect(subject.persist_and_publish).to be_false
          end
        end
        
        context "with a publisher" do
          it "should return true" do
            expect(subject.persist_and_publish(user)).to be_true
          end
        end
      end
      
      context "when not persisted" do
        before(:each) do
          subject.stub(:save).and_return(false)
        end
        
        it "should return false" do
          expect(subject.persist_and_publish(user)).to be_false
        end
        
        it "should still update the publisher" do
          subject.persist_and_publish(user)
          expect(subject.user_id).to eq user.id
        end
      end
    end

    describe "#persist_and_publish!" do
      context "when persisted" do
        before(:each) do
          subject.stub(:persisted?).and_return(true)
          subject.stub(:save).and_return(true)
        end
        
        context "but not published" do
          it "should raise an exception" do
            expect {
              subject.persist_and_publish!(nil)
            }.to raise_error(Mongoid::Publishable::UnpublishedError)
          end
        end
        
        context "and published" do
          it "should return true" do
            expect(subject.persist_and_publish!(user)).to be_true
          end
        end
      end
      
      context "when it fails validation" do
        before(:each) do
          subject.stub(:save).and_return(false)
        end
        
        it "should return false" do
          expect(subject.persist_and_publish!(user)).to be_false
        end
      end
    end

    describe "#publish_via" do
      it "should set the publisher on the object" do
        subject.publish_via(user)
        expect(subject.user_id).to eq user.id
      end
    end

    describe "#publish_via!" do
      it "should set the publisher on the object and persist" do
        subject.should_receive(:save).and_return(true)
        expect(subject.publish_via!(user)).to be_true
        expect(subject.user_id).to eq user.id
      end
    end

    describe "#published?" do
      context "when not persisted" do
        it "should return false" do
          expect(subject.published?).to be_false
        end
      end
      
      context "when persisted" do
        before(:each) do
          subject.stub(:persisted?).and_return(true)
        end
        
        context "without a publisher" do
          it "should return false" do
            expect(subject.published?).to be_false
          end
        end
        
        context "with a publisher" do
          it "should return true" do
            subject.publish_via(user)
            expect(subject.published?).to be_true
          end
        end
      end
    end

    describe "#requires_publishing?" do
      context "when persisted" do
        before(:each) do
          subject.stub(:persisted?).and_return(true)
        end
        
        context "and the publisher is set" do
          it "should return false" do
            subject.publish_via(user)
            expect(subject.requires_publishing?).to be_false
          end
        end
        
        context "and the publisher is not set" do
          it "should return true" do
            expect(subject.requires_publishing?).to be_true
          end
        end
      end
      
      context "when not persisted" do
        it "should return false" do
          expect(subject.requires_publishing?).to be_false
        end
      end
    end
  end
end