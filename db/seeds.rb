seed_url = ENV.fetch("SEED_BASE_URL", "http://localhost:3000")
puts "Executando seed HTTP em #{seed_url}"

success = system({ "SEED_BASE_URL" => seed_url }, "ruby", Rails.root.join("script/http_seed.rb").to_s)
abort("Falha ao executar seed HTTP. Verifique se o app está online em #{seed_url}.") unless success
