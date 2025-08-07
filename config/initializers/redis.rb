# frozen_string_literal: true

RedisStore.client.ping
Rails.logger.info('[Redis] conexão estabelecida com sucesso.')
