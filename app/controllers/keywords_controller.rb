# frozen_string_literal: true

class KeywordsController < ApplicationController
  before_action :set_keyword, only: %i[show edit update destroy]

  def index
    @keywords = Keyword.order(:term)
  end

  def show; end

  def new
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)
    if @keyword.save
      redirect_to @keyword, notice: 'Keyword criada com sucesso.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @keyword.update(keyword_params)
      redirect_to @keyword, notice: 'Keyword atualizada com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @keyword.destroy
    redirect_to keywords_path, notice: 'Keyword removida com sucesso.'
  end

  private

  def set_keyword
    @keyword = Keyword.find(params[:id])
  end

  def keyword_params
    params.require(:keyword).permit(:term)
  end
end
