# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Keyword flow (keywords)", type: :integration do
  let(:user)   { User.create!(username: "joao", name: "João", email: "joao@example.com", external_id: 10) }
  let(:post)   { user.posts.create!(title: "Exemplo", body: "Corpo", external_id: 1) }
  let(:body1)  { "Ruby é poderoso e Rails é produtivo" }
  let(:body2)  { "Python é ótimo, mas Ruby também é excelente" }

  before do
    Rails.cache.clear
    redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
    redis.flushdb
  end

  it "reprocesses comments for all users when keywords are changed" do
    keyword1 = Keyword.create!(term: "Ruby")
    keyword2 = Keyword.create!(term: "Rails")

    comment1 = post.comments.create!(
      external_id: 1, body: body1, translated_body: body1, state: :new, name: "João", email: "joao@email.com"
    )
    comment2 = post.comments.create!(
      external_id: 2, body: body2, translated_body: body2, state: :new, name: "Maria", email: "maria@email.com"
    )

    ProcessCommentJob.perform_now(comment1.id)
    ProcessCommentJob.perform_now(comment2.id)

    comment1.reload
    comment2.reload

    expect(comment1).to be_approved
    expect(comment2).to be_rejected

    expect(ReprocessAllCommentsJob).to receive(:perform_later).at_least(:once)
    keyword3 = Keyword.create!(term: "Python")
    
    ReprocessUserJob.perform_now(user_id: user.id)

    comment1.reload
    comment2.reload

    expect(comment2).to be_approved

    metrics = MetricsCacheService.new.fetch_user_metrics(user)
    expect(metrics[:approved_count]).to eq(2)
    expect(metrics[:rejected_count]).to eq(0)

    keyword1.destroy
    ReprocessUserJob.perform_now(user_id: user.id)

    comment1.reload
    comment2.reload
    
    expect(comment1).to be_rejected
    expect(comment2).to be_rejected

    metrics = MetricsCacheService.new.fetch_user_metrics(user)
    expect(metrics[:approved_count]).to eq(0)
    expect(metrics[:rejected_count]).to eq(2)
  end
end