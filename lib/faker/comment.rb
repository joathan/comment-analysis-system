# frozen_string_literal: true

require 'faker'

module Faker
  class Comment < Base
    class << self
      def positive
        fetch('comment.positive')
      end

      def negative
        fetch('comment.negative')
      end

      def neutral
        fetch('comment.neutral')
      end

      def random
        send(%i[positive negative neutral].sample)
      end
    end
  end
end
