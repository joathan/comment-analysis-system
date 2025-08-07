# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupMetricsService do
  before(:each) do
    Comment.delete_all
    Post.delete_all
    User.delete_all
  end

  let!(:users) { create_list(:user, 3) }
  let!(:posts) { users.map { |u| create(:post, user: u) } }

  let!(:approved_comments) do
    posts.map { |post| create(:comment, post: post, state: :approved, body: 'approved') }
  end
  let!(:rejected_comments) do
    posts.map { |post| create(:comment, post: post, state: :rejected, body: 'rejected') }
  end
  let!(:pending_comments) do
    posts.map { |post| create(:comment, post: post, state: :new, body: 'pending') }
  end

  describe '.calculate' do
    subject(:metrics) { described_class.calculate }

    it 'returns the correct total users' do
      expect(metrics[:total_users]).to eq(3)
    end

    it 'returns the correct total comments' do
      expect(metrics[:total_comments]).to eq(9)
    end

    it 'returns the correct approved and rejected comments' do
      expect(metrics[:approved_comments]).to eq(3)
      expect(metrics[:rejected_comments]).to eq(3)
    end

    it 'returns the correct approval rate' do
      expect(metrics[:approval_rate]).to eq(3.0 / 9)
    end

    it 'returns the average comment length' do
      lengths = Comment.all.map { |c| c.body.length }

      expected_average = Statistics.mean(lengths)
      expect(metrics[:average_comment_length]).to eq(expected_average)
    end

    it 'returns the median comment length' do
      lengths = Comment.all.map { |c| c.body.length }

      expected_median = Statistics.median(lengths)
      expect(metrics[:median_comment_length]).to eq(expected_median)
    end

    it 'returns the stddev comment length' do
      lengths = Comment.all.map { |c| c.body.length }

      expected_stddev = Statistics.standard_deviation(lengths)
      expect(metrics[:stddev_comment_length]).to eq(expected_stddev)
    end

    context 'when there are no comments' do
      before { Comment.delete_all }

      it 'returns 0 for metrics based on comments' do
        metrics = described_class.calculate

        expect(metrics[:total_comments]).to eq(0)
        expect(metrics[:approved_comments]).to eq(0)
        expect(metrics[:rejected_comments]).to eq(0)
        expect(metrics[:approval_rate]).to eq(0.0)
        expect(metrics[:average_comment_length]).to eq(0.0)
        expect(metrics[:median_comment_length]).to eq(0.0)
        expect(metrics[:stddev_comment_length]).to eq(0.0)
      end
    end
  end
end
