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
      flash[:notice] = 'Keyword criada. O reprocessamento de todos os comentários foi iniciado em segundo plano.'
      redirect_to keywords_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @keyword.update(keyword_params)
      flash[:notice] = 'Keyword atualizada. O reprocessamento de todos os comentários foi iniciado em segundo plano.'

      redirect_to keywords_path
    else
      render :edit
    end
  end

  def destroy
    @keyword.destroy
    flash[:notice] = 'Keyword removida. O reprocessamento de todos os comentários foi iniciado em segundo plano.'

    redirect_to keywords_path
  end

  private

  def set_keyword
    @keyword = Keyword.find(params[:id])
  end

  def keyword_params
    params.require(:keyword).permit(:term)
  end
end
