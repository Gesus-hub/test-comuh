#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "faraday"
require "set"

BASE_URL = ENV.fetch("SEED_BASE_URL", "http://localhost:3000")
TOTAL_MESSAGES = 1000
REACTION_TYPES = %w[like love insightful].freeze
MAIN_POST_RATIO = 0.7
REACTION_RATIO = 0.8
TOTAL_USERS = 50
TOTAL_IPS = 20
DEFAULT_COMMUNITIES = 5
MIN_COMMUNITIES = 3
MAX_COMMUNITIES = 5

MAIN_POST_COUNT = (TOTAL_MESSAGES * MAIN_POST_RATIO).to_i
COMMENT_COUNT = TOTAL_MESSAGES - MAIN_POST_COUNT
REACTION_MESSAGE_COUNT = (TOTAL_MESSAGES * REACTION_RATIO).to_i

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
  (1..TOTAL_USERS).map { |index| format("user_%03d", index) }
end

def ip_pool
  (1..TOTAL_IPS).map { |index| "192.168.1.#{index}" }
end

def community_count
  raw = ENV.fetch("SEED_COMMUNITIES", DEFAULT_COMMUNITIES).to_i
  return DEFAULT_COMMUNITIES if raw <= 0

  [ [ raw, MIN_COMMUNITIES ].max, MAX_COMMUNITIES ].min
end

def pick_from(pool, index)
  pool[index % pool.size]
end

def post_content(index)
  mood = index.even? ? "ótimo" : "ruim"
  "Post principal ##{index} para discussão da comunidade, clima #{mood}"
end

def comment_content(index)
  mood = index.even? ? "ótimo" : "ruim"
  "Comentário ##{index} com opinião #{mood}"
end

def log_progress(prefix, index, total)
  return unless (index % 100).zero? || index == total

  puts "#{prefix} progress: #{index}/#{total}"
end

http = client
users = username_pool
ips = ip_pool
used_usernames = Set.new
used_ips = Set.new

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

1.upto(MAIN_POST_COUNT) do |index|
  community = pick_from(communities, index - 1)
  username = pick_from(users, index - 1)
  ip = pick_from(ips, index - 1)

  message = post_json(
    http,
    "/api/v1/messages",
    {
      username: username,
      community_id: community["id"],
      content: post_content(index),
      user_ip: ip
    }
  )

  all_message_ids << message["id"]
  community_main_posts[community["id"]] << message["id"]
  used_usernames << username
  used_ips << ip
  log_progress("Posts", index, MAIN_POST_COUNT)
end

1.upto(COMMENT_COUNT) do |index|
  community = pick_from(communities, index - 1)
  parent_message_id = pick_from(community_main_posts[community["id"]], index - 1)
  absolute_index = MAIN_POST_COUNT + index
  username = pick_from(users, absolute_index - 1)
  ip = pick_from(ips, absolute_index - 1)

  message = post_json(
    http,
    "/api/v1/messages",
    {
      username: username,
      community_id: community["id"],
      content: comment_content(index),
      user_ip: ip,
      parent_message_id: parent_message_id
    }
  )

  all_message_ids << message["id"]
  used_usernames << username
  used_ips << ip
  log_progress("Comentários", index, COMMENT_COUNT)
end

all_message_ids.first(REACTION_MESSAGE_COUNT).each_with_index do |message_id, index|
  reaction_type = pick_from(REACTION_TYPES, index)
  username = pick_from(users, index)

  post_json(
    http,
    "/api/v1/reactions",
    {
      message_id: message_id,
      reaction_type: reaction_type,
      username: username
    }
  )

  log_progress("Reações", index + 1, REACTION_MESSAGE_COUNT)
end

puts "HTTP seed finalizado com sucesso!"
puts "Comunidades: #{communities.size}"
puts "Usuários disponíveis: #{users.size}"
puts "Usuários usados: #{used_usernames.size}"
puts "IPs disponíveis: #{ips.size}"
puts "IPs usados: #{used_ips.size}"
puts "Mensagens: #{all_message_ids.size}"
puts "Posts principais: #{MAIN_POST_COUNT}"
puts "Comentários: #{COMMENT_COUNT}"
puts "Mensagens com reação: #{REACTION_MESSAGE_COUNT}"
