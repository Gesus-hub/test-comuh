namespace :seed do
  desc "Popula o banco via chamadas HTTP aos endpoints da API"
  task http: :environment do
    seed_url = ENV.fetch("SEED_BASE_URL", "http://localhost:3000")
    puts "Executando seed HTTP em #{seed_url}"

    success = system({ "SEED_BASE_URL" => seed_url }, "ruby", Rails.root.join("script/http_seed.rb").to_s)
    abort("Falha ao executar script/http_seed.rb") unless success
  end
end
