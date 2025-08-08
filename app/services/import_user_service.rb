# frozen_string_literal: true

class ImportUserService
  def initialize(username:)
    @username = username
  end

  def call
    user = find_or_create_user

    return unless user

    import_posts(user)
    import_comments(user)
  end

  private

  def find_or_create_user
    data = JsonPlaceholderAdapter.fetch_user(@username)

    unless data
      Rails.logger.warn("[ImportUserService] Nenhum dado retornado para o username #{@username.inspect}")
      return nil
    end

    User.find_or_create_by!(external_id: data['id']) do |user|
      user.username = data['username']
      user.name = data['name']
      user.email = data['email']
    end
  end

  def import_posts(user)
    posts_data = JsonPlaceholderAdapter.fetch_user_posts(user.external_id)
    posts_data.each do |post_data|
      Post.find_or_create_by!(external_id: post_data['id']) do |post|
        post.user = user
        post.title = post_data['title']
        post.body = post_data['body']
      end
    rescue StandardError => e
      Rails.logger.error("[ImportUserService] Falha ao criar post #{post_data["id"]}: #{e.message}")
      next
    end
  end

  def import_comments(user)
    user.posts.find_each do |post|
      comments_data = JsonPlaceholderAdapter.fetch_post_comments(post.external_id)
      comments_data.each do |comment_data|
        next if Comment.exists?(external_id: comment_data['id'])

        comment = post.comments.create!(
          external_id: comment_data['id'],
          name: comment_data['name'],
          email: comment_data['email'],
          body: comment_data['body']
        )

        ProcessCommentJob.perform_later(comment.id)
      rescue StandardError => e
        Rails.logger.error("[ImportUserService] Falha ao criar comentário para o post #{post.external_id}: #{e.message}")
        next
      end
    end
  end
end
