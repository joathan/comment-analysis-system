# generate_api_data.rb

require 'faker'
require 'json'
require './lib/faker/comment'
require 'i18n'
I18n.load_path += Dir[File.expand_path('../config/locales/**/*.yml', __dir__)]
I18n.reload!
I18n.locale = :en

puts 'Gerando dados para a API falsa...'

users = []
posts = []
comments = []
post_id_counter = 1

# Helper para sortear o tipo de comentário e gerar com o Faker
def generate_comment_body_and_sentiment
  sentiment = %i[positive negative neutral].sample
  body = Faker::Comment.send(sentiment)
  [body, sentiment.to_s]
end

# --- Gera 10 Usuários ---
10.times do |i|
  user_id = i + 1
  users << {
    id: user_id,
    name: Faker::Name.name,
    username: Faker::Internet.username(specifier: 5..8),
    email: Faker::Internet.email,
  }

  # --- Gera de 5 a 10 Posts para cada Usuário ---
  rand(5..10).times do
    posts << {
      id: post_id_counter,
      userId: user_id,
      title: Faker::Lorem.sentence(word_count: 3, supplemental: true, random_words_to_add: 4).capitalize,
      body: Faker::Lorem.paragraph(sentence_count: 3, supplemental: true, random_sentences_to_add: 4),
    }

    # --- Gera de 2 a 8 Comentários para cada Post ---
    rand(2..8).times do
      comment_body, sentiment = generate_comment_body_and_sentiment

      comments << {
        postId: post_id_counter,
        id: comments.size + 1,
        name: Faker::Name.name,
        email: Faker::Internet.email,
        body: comment_body,
        sentiment: sentiment, # novo campo para análise posterior
      }
    end

    post_id_counter += 1
  end
end

# Cria o hash final para o db.json
db_data = {
  users: users,
  posts: posts,
  comments: comments,
}

# Salva o arquivo JSON
File.write('./docker/json-server/db.json', JSON.pretty_generate(db_data))

puts '---------------------------------------------------------'
puts "✅ Arquivo 'db.json' gerado com sucesso!"
puts "- #{users.size} usuários"
puts "- #{posts.size} posts"
puts "- #{comments.size} comentários"
puts 'Agora você pode rodar: json-server --watch db.json'
puts '---------------------------------------------------------'
