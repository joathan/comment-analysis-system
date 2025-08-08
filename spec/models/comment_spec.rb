# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:post) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'state machine (AASM)' do
    let(:comment) { create(:comment) }

    it 'starts with the new state' do
      expect(comment.state).to eq('new')
    end

    describe '#process' do
      it 'transitions from :new to :processing' do
        expect { comment.process! }.to change { comment.state }.from('new').to('processing')
      end

      it 'transitions from :approved to :processing' do
        comment.update(state: :approved)
        expect { comment.process! }.to change { comment.state }.from('approved').to('processing')
      end

      it 'transitions from :rejected to :processing' do
        comment.update(state: :rejected)
        expect { comment.process! }.to change { comment.state }.from('rejected').to('processing')
      end
    end

    describe '#approve' do
      before { comment.process! }

      it 'transitions from :processing to :approved' do
        expect { comment.approve! }.to change { comment.state }.from('processing').to('approved')
      end

      it 'does not transition from :new' do
        comment.update(state: :new)
        expect { comment.approve! }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe '#reject' do
      before { comment.process! }

      it 'transitions from :processing to :rejected' do
        expect { comment.reject! }.to change { comment.state }.from('processing').to('rejected')
      end

      it 'does not transition from :new' do
        comment.update(state: :new)
        expect { comment.reject! }.to raise_error(AASM::InvalidTransition)
      end
    end
  end
end
