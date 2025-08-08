# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentMetricsService do
  let!(:approved_comment1) { create(:comment, body: 'foo bar', state: :approved) }
  let!(:approved_comment2) { create(:comment, body: 'baz buzz word', state: :approved) }
  let!(:rejected_comment)  { create(:comment, body: 'nope', state: :rejected) }
  let!(:pending_comment)   { create(:comment, body: 'waiting...', state: :new) }
  let(:metrics) { described_class.new(Comment.all) }

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
    let(:metrics)  { described_class.new(comments) }

    it 'works with plain Ruby arrays as well' do
      expect(metrics.approved_count).to eq(2)
      expect(metrics.rejected_count).to eq(1)
      expect(metrics.average_length).to eq(Statistics.mean([7, 13, 4, 10]))
    end

    it 'as_json works with plain arrays' do
      expected = {
        approved_count: 2,
        rejected_count: 1,
        approval_rate: 2.0 / 4,
        average_length: Statistics.mean([7, 13, 4, 10]),
        median_length: Statistics.median([4, 7, 10, 13]),
        stddev_length: Statistics.standard_deviation([7, 13, 4, 10]),
      }

      expect(metrics.as_json).to eq(expected)
    end
  end

  describe '#as_json' do
    it 'returns all calculated metrics as a hash' do
      expected = {
        approved_count: 2,
        rejected_count: 1,
        approval_rate: 2.0 / 4,
        average_length: Statistics.mean([7, 13, 4, 10]),
        median_length: Statistics.median([4, 7, 10, 13]),
        stddev_length: Statistics.standard_deviation([7, 13, 4, 10]),
      }

      expect(metrics.as_json).to eq(expected)
    end
  end

  describe 'when a comment has no body' do
    it 'does not explode if a comment has no body' do
      Comment.delete_all

      create(:comment, body: 'foo bar', state: :approved)
      create(:comment, body: 'baz buzz word', state: :approved)
      create(:comment, body: 'nope', state: :rejected)
      create(:comment, body: 'waiting...', state: :new)
      c = create(:comment)
      c.update_column(:body, nil)

      metrics = described_class.new(Comment.all)

      expect { metrics.average_length }.not_to raise_error
      expect(metrics.average_length).to eq(Statistics.mean([7, 13, 4, 10, 0]))
    end
  end
end
