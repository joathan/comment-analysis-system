# frozen_string_literal: true

class ImportUserService
  def initialize(username:)
    @username = username
  end

  def call
    user = find_or_create_user
    import_posts(user)
    ReprocessUserJob.perform_later(user_id: user.id)
  end

  private

  def find_or_create_user
    data = JsonPlaceholderAdapter.fetch_user(@username)
    User.find_or_create_by!(external_id: data['id']) do |user|
      user.username = data['username']
      user.name = data['name']
      user.email = data['email']
    end
  end

  def import_posts(user)
    JsonPlaceholderAdapter.fetch_user_posts(user.external_id).each do |post_data|
      post = Post.find_or_create_by!(external_id: post_data['id']) do |p|
        p.user = user
        p.title = post_data['title']
        p.body = post_data['body']
      end

      import_comments(post)
    end
  end

  def import_comments(post)
    JsonPlaceholderAdapter.fetch_post_comments(post.external_id).each do |comment_data|
      Comment.find_or_create_by!(external_id: comment_data['id']) do |c|
        c.post = post
        c.email = comment_data['email']
        c.body = comment_data['body']
      end
    end
  end
end
