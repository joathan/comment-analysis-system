# frozen_string_literal: true

# Força o Rails.logger a sempre exibir todos os níveis
Rails.logger = ActiveSupport::Logger.new(STDOUT)
Rails.logger.level = Logger::DEBUG
Rails.logger.formatter = Logger::Formatter.new

# Garante que todos os loggers internos usem o Rails.logger
ActiveRecord::Base.logger = Rails.logger
ActionController::Base.logger = Rails.logger
ActionView::Base.logger = Rails.logger
ActiveJob::Base.logger = Rails.logger
