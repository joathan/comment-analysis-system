# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Keyword flow (keywords)", type: :integration do
  let(:user)   { User.create!(username: "joao", name: "João", email: "joao@example.com", external_id: 10) }
  let(:post)   { user.posts.create!(title: "Exemplo", body: "Corpo", external_id: 1) }
  let(:body1)  { "Ruby is powerful and Rails is productive" }
  let(:body2)  { "Python is great, but Ruby is also excellent" }

  before do
    Rails.cache.clear
  end

  it "reprocesses comments from all users when changing keywords and recalculates metrics correctly" do
    Keyword.create!(term: "Ruby")
    Keyword.create!(term: "Rails")

    comment1 = post.comments.create!(external_id: 1, body: body1, state: :new, name: "João",  email: "joao@email.com")
    comment2 = post.comments.create!(external_id: 2, body: body2, state: :new, name: "Maria", email: "maria@email.com")

    ProcessCommentJob.perform_now(comment1.id)
    ProcessCommentJob.perform_now(comment2.id)
    comment1.reload; comment2.reload

    expect(comment1).to be_approved
    expect(comment2).to be_rejected

    expect(ReprocessAllCommentsJob).to receive(:perform_later).at_least(:once)
    Keyword.create!(term: "Python")

    ReprocessUserJob.perform_now(user_id: user.id)

    ProcessCommentJob.perform_now(comment1.id)
    ProcessCommentJob.perform_now(comment2.id)
    comment1.reload; comment2.reload

    expect(comment2).to be_approved

    metrics = MetricsCacheService.new.fetch_user_metrics(user)
    expect(metrics[:approved_count]).to eq(2)
    expect(metrics[:rejected_count]).to eq(0)
    expect(metrics[:approval_rate]).to eq(1.0)

    Keyword.find_by!(term: "Ruby").destroy
    ReprocessUserJob.perform_now(user_id: user.id)
    ProcessCommentJob.perform_now(comment1.id)
    ProcessCommentJob.perform_now(comment2.id)
    comment1.reload; comment2.reload

    expect(comment1).to be_rejected
    expect(comment2).to be_rejected

    metrics = MetricsCacheService.new.fetch_user_metrics(user)
    expect(metrics[:approved_count]).to eq(0)
    expect(metrics[:rejected_count]).to eq(2)
    expect(metrics[:approval_rate]).to eq(0.0)
  end
end
