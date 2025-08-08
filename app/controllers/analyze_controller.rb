# frozen_string_literal: true

class AnalyzeController < ApplicationController
  def create
    username = params[:username]

    if username.blank?
      flash[:alert] = 'O nome de usuário não pode ficar em branco.'
    else
      ImportUserJob.perform_later(username: username)

      flash[:notice] = "A análise para o usuário '#{username}' foi iniciada em segundo plano."
    end

    redirect_to root_path
  end
end
