# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportUserService do
  let(:username) { Faker::Internet.unique.username }
  let(:service) { described_class.new(username) }

  let(:fake_posts) do
    [
      { 'id' => 1, 'title' => 'Post Title', 'body' => 'Post Body' },
    ]
  end

  let(:fake_comments) do
    [
      { 'id' => 10, 'name' => 'Name', 'email' => 'email@example.com', 'body' => 'Comment Body' },
    ]
  end

  before do
    allow(JsonPlaceholderAdapter).to receive(:fetch_user_posts).and_return(fake_posts)
    allow(JsonPlaceholderAdapter).to receive(:fetch_post_comments).and_return(fake_comments)
  end

  context 'when everything goes normally' do
    it 'creates the user, their posts, and comments' do
      expect { service.call }
        .to change(User, :count).by(1)
        .and change(Post, :count).by(1)
        .and change(Comment, :count).by(1)

      user = User.find_by(username: username)
      expect(user).to be_present
      expect(user.posts.count).to eq(1)
      expect(user.posts.first.comments.count).to eq(1)
    end
  end

  context 'when the user already exists' do
    let!(:user) { create(:user, username: username) }

    it 'does not create a duplicate user, but imports posts/comments' do
      expect do
        service.call
      end.to change(Post, :count).by(1)
                                 .and change(Comment, :count).by(1)

      expect(User.where(username: username).count).to eq(1)
      expect(user.reload.posts.count).to eq(1)
    end
  end

  context 'when there is an error creating the user' do
    before do
      allow(User).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordInvalid.new(User.new))
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the error and propagates the exception' do
      expect(Rails.logger).to receive(:error).with(/Falha ao criar usuário/)
      expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'when there is an error creating a post' do
    before do
      allow_any_instance_of(User).to receive_message_chain(:posts, :find_or_create_by!).and_raise(StandardError,
                                                                                                  'Post error')
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the post error and continues' do
      expect(Rails.logger).to receive(:error).at_least(:once)
                                             .with(a_string_matching(/\[ImportUserService\] Falha no post \d+: Post error/))
      expect { service.call }.not_to raise_error
    end
  end

  context 'when there is an error creating a comment' do
    before do
      allow_any_instance_of(Post).to receive_message_chain(:comments, :find_or_create_by!).and_raise(StandardError,
                                                                                                     'Comment error')
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the comment error and continues' do
      expect(Rails.logger).to receive(:error).at_least(:once)
                                             .with(a_string_matching(/\[ImportUserService\] Falha no comentário do post \d+: Comment error/))
      expect { service.call }.not_to raise_error
    end
  end
end
