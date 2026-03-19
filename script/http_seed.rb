#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "faraday"

BASE_URL = ENV.fetch("SEED_BASE_URL", "http://localhost:3000")
TOTAL_MESSAGES = 1000
REACTION_TYPES = %w[like love insightful].freeze

def client
  Faraday.new(url: BASE_URL) do |faraday|
    faraday.request :json
    faraday.adapter Faraday.default_adapter
  end
end

def post_json(http, path, payload)
  response = http.post(path) do |request|
    request.headers["Content-Type"] = "application/json"
    request.headers["Accept"] = "application/json"
    request.body = payload.to_json
  end

  body = response.body.to_s
  parsed = body.empty? ? {} : JSON.parse(body)
  return parsed if response.status.between?(200, 299)

  raise "HTTP #{response.status} #{path}: #{parsed["error"] || body}"
end

def username_pool
  (1..50).map { |index| format("user_%03d", index) }
end

def ip_pool
  (1..20).map { |index| "192.168.1.#{index}" }
end

def message_content(index, parent_message_id)
  mood = index.even? ? "ótimo" : "ruim"
  if parent_message_id
    "Comentário ##{index} com opinião #{mood}"
  else
    "Post principal ##{index} para discussão da comunidade, clima #{mood}"
  end
end

http = client
users = username_pool
ips = ip_pool

community_count = rand(3..5)
seed_tag = Time.now.to_i
communities = community_count.times.map do |index|
  post_json(
    http,
    "/api/v1/communities",
    {
      name: "Comunidade #{index + 1} - #{seed_tag}",
      description: "Descrição da comunidade #{index + 1}"
    }
  )
end

community_main_posts = Hash.new { |hash, key| hash[key] = [] }
all_message_ids = []

TOTAL_MESSAGES.times do |index|
  community = communities.sample
  create_comment = rand < 0.3 && community_main_posts[community["id"]].any?
  parent_message_id = create_comment ? community_main_posts[community["id"]].sample : nil

  message = post_json(
    http,
    "/api/v1/messages",
    {
      username: users.sample,
      community_id: community["id"],
      content: message_content(index + 1, parent_message_id),
      user_ip: ips.sample,
      parent_message_id: parent_message_id
    }
  )

  all_message_ids << message["id"]
  community_main_posts[community["id"]] << message["id"] if parent_message_id.nil?

  next unless rand < 0.8

  REACTION_TYPES.sample(rand(1..3)).each do |reaction_type|
    begin
      post_json(
        http,
        "/api/v1/reactions",
        {
          message_id: message["id"],
          reaction_type: reaction_type,
          username: users.sample
        }
      )
    rescue StandardError
    end
  end

  puts "Seed progress: #{index + 1}/#{TOTAL_MESSAGES}" if ((index + 1) % 100).zero?
end

puts "HTTP seed finalizado com sucesso!"
puts "Comunidades: #{communities.size}"
puts "Usuários: #{users.size}"
puts "Mensagens: #{all_message_ids.size}"
