# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetricsCacheService, type: :service do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:service) { described_class.new(cache: cache) }
  let(:user) { create(:user) }
  let(:post) { create(:post, user: user) }
  let!(:comment) { create(:comment, post: post, body: 'test', state: :approved) }
  let(:metrics) do
    { approved_count: 1, average_length: 4, approval_rate: 1.0, median_length: 4, rejected_count: 0,
      stddev_length: 0.0, }
  end
  let(:group_metrics) do
    { total_users: 1, total_comments: 1, approved_comments: 1, rejected_comments: 0, approval_rate: 1.0,
      average_comment_length: 4, median_comment_length: 4, stddev_comment_length: 0.0, }
  end

  before do
    allow(CommentMetricsService).to receive(:new).and_return(double(as_json: metrics, average_length: 4,
                                                                    median_length: 4, stddev_length: 0.0))
    allow(GroupMetricsService).to receive(:calculate).and_return(group_metrics)
  end

  describe '#fetch_user_metrics' do
    it 'fetches user metrics from cache if present' do
      cache.write(format(MetricsCacheService::CACHE_USER_KEY, user_id: user.id), metrics)
      expect(service.fetch_user_metrics(user)).to eq(metrics)
      expect(CommentMetricsService).not_to receive(:new)
    end

    it 'calculates user metrics if cache miss' do
      expect(CommentMetricsService).to receive(:new).with(user.comments).and_call_original
      expect(service.fetch_user_metrics(user)).to eq(metrics)
    end

    it 'returns empty hash if user is nil' do
      expect(service.fetch_user_metrics(nil)).to eq({})
    end
  end

  describe '#fetch_group_metrics' do
    it 'fetches group metrics from cache if present' do
      cache.write(MetricsCacheService::CACHE_GROUP_KEY, group_metrics)
      expect(service.fetch_group_metrics).to eq(group_metrics)
      expect(GroupMetricsService).not_to receive(:calculate)
    end

    it 'calculates group metrics if cache miss' do
      expect(GroupMetricsService).to receive(:calculate).and_call_original
      allow(CommentMetricsService).to receive(:new).with(Comment.all).and_return(double(as_json: metrics,
                                                                                        average_length: 4, median_length: 4, stddev_length: 0.0))
      expect(service.fetch_group_metrics).to eq(group_metrics)
    end
  end

  describe '#invalidate_user' do
    it 'deletes user cache entry' do
      cache.write(format(MetricsCacheService::CACHE_USER_KEY, user_id: user.id), metrics)
      expect { service.invalidate_user(user) }.to change {
        cache.exist?(format(MetricsCacheService::CACHE_USER_KEY, user_id: user.id))
      }.from(true).to(false)
    end

    it 'does nothing if user is nil' do
      expect { service.invalidate_user(nil) }.not_to raise_error
      expect(cache).not_to receive(:delete)
    end
  end

  describe '#invalidate_group' do
    it 'deletes group cache entry' do
      cache.write(MetricsCacheService::CACHE_GROUP_KEY, group_metrics)
      expect { service.invalidate_group }.to change {
        cache.exist?(MetricsCacheService::CACHE_GROUP_KEY)
      }.from(true).to(false)
    end
  end
end
