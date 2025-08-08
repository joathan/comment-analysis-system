# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.includes(:comments).order(:title)
  end
end
