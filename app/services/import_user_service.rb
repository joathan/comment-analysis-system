# frozen_string_literal: true

class ImportUserService
  def initialize(username)
    @username = username
    @logger = Rails.logger
  end

  def call
    user = find_or_create_user
    import_posts_and_comments(user)
    # TODO: Se necessário, adicionar jobs para processar comentários ou recalcular métricas
    # RecalculateGroupMetricsJob.perform_later
  end

  private

  def find_or_create_user
    User.find_or_create_by!(username: @username)
  rescue ActiveRecord::RecordInvalid => e
    @logger.error("[ImportUserService] Falha ao criar usuário: #{e.message}")
    raise
  end

  def import_posts_and_comments(user)
    posts = JsonPlaceholderAdapter.fetch_user_posts(user.id)
    posts.each do |post_attrs|
      post = user.posts.find_or_create_by!(
        title: post_attrs['title'],
        body: post_attrs['body']
      )
      import_comments_for_post(post)
    rescue StandardError => e
      @logger.error("[ImportUserService] Falha no post #{post_attrs["id"]}: #{e.message}")
    end
  end

  def import_comments_for_post(post)
    comments = JsonPlaceholderAdapter.fetch_post_comments(post.id)
    comments.each do |comment_attrs|
      comment = post.comments.find_or_create_by!(
        name: comment_attrs['name'],
        email: comment_attrs['email'],
        body: comment_attrs['body']
      )

      ProcessCommentJob.perform_later(comment.id)
    rescue StandardError => e
      @logger.error("[ImportUserService] Falha no comentário do post #{post.id}: #{e.message}")
    end
  end
end
