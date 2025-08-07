# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentMetricsService do
  let!(:approved_comment1) { create(:comment, body: 'foo bar', state: :approved) }
  let!(:approved_comment2) { create(:comment, body: 'baz buzz word', state: :approved) }
  let!(:rejected_comment)  { create(:comment, body: 'nope', state: :rejected) }
  let!(:pending_comment)   { create(:comment, body: 'waiting...', state: :new) }
  let(:comments) { Comment.all }
  let(:metrics)  { described_class.new(comments) }

  describe '#approved_count' do
    it 'returns the number of approved comments' do
      expect(metrics.approved_count).to eq(2)
    end
  end

  describe '#rejected_count' do
    it 'returns the number of rejected comments' do
      expect(metrics.rejected_count).to eq(1)
    end
  end

  describe '#approval_rate' do
    it 'returns the correct approval rate' do
      expect(metrics.approval_rate).to eq(2.0 / 4)
    end

    it 'returns 0.0 if there are no comments' do
      empty_metrics = described_class.new(Comment.none)
      expect(empty_metrics.approval_rate).to eq(0.0)
    end
  end

  describe 'text metrics' do
    it '#average_length returns the mean length of comment bodies' do
      expect(metrics.average_length).to eq(Statistics.mean([7, 13, 4, 10]))
    end

    it '#median_length returns the median length' do
      expect(metrics.median_length).to eq(Statistics.median([4, 7, 10, 13]))
    end

    it '#stddev_length returns the sample standard deviation' do
      expect(metrics.stddev_length).to be_within(0.01).of(Statistics.standard_deviation([7, 13, 4, 10]))
    end
  end

  context 'when comments is an array' do
    let(:comments) { Comment.all.to_a }

    it 'works with plain Ruby arrays as well' do
      expect(metrics.approved_count).to eq(2)
      expect(metrics.rejected_count).to eq(1)
      expect(metrics.average_length).to eq(Statistics.mean([7, 13, 4, 10]))
    end
  end

  describe 'quando um comentário não tem corpo' do
    it 'não explode se algum comentário não tem body' do
      comment = create(:comment, body: nil)
      metrics = described_class.new(Comment.all)
      expect { metrics.average_length }.not_to raise_error
    end
  end
end
