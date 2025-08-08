# frozen_string_literal: true

class AnalyzeController < ApplicationController
  def create
    username = params[:username]

    if username.blank?
      flash[:alert] = 'O nome de usuário não pode ficar em branco.'
    else
      job = ImportUserJob.perform_later(username: username)

      flash[:notice] = "A análise para o usuário '#{username}' foi iniciada."
      flash[:job_id] = job.job_id
    end

    redirect_to root_path
  end
end
