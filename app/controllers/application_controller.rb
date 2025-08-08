class ApplicationController < ActionController::Base
  def healthcheck
    render json: { status: 'ok' }, status: :ok
  end
end
