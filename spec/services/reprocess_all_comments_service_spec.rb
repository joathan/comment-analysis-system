# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReprocessAllCommentsService, type: :service do
  let!(:approved_comment) { create(:comment, :approved) }
  let!(:rejected_comment) { create(:comment, :rejected) }
  let!(:new_comment) { create(:comment) }

  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  it 'reactivates approved and rejected comments and queues them for processing' do
    expect {
      described_class.new.call
    }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(2)

    expect(approved_comment.reload).to be_processing
    expect(rejected_comment.reload).to be_processing
    expect(new_comment.reload).to be_new
  end
end
