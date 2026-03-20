default_seed_url = "http://localhost:#{ENV.fetch("PORT", "3000")}"
seed_url = ENV.fetch("SEED_BASE_URL", default_seed_url)
ci_enabled = ENV.fetch("CI", "false") == "true"
skip_http_seed_flag = ENV.fetch("SKIP_HTTP_SEED", "false") == "true"
force_http_seed_flag = ENV.fetch("FORCE_HTTP_SEED", "false") == "true"
skip_http_seed = !force_http_seed_flag && (Rails.env.test? || Rails.env.production? || ci_enabled || skip_http_seed_flag)

if skip_http_seed
  puts(
    "Pulando seed HTTP " \
    "(RAILS_ENV=#{Rails.env}, CI=#{ci_enabled}, " \
    "SKIP_HTTP_SEED=#{skip_http_seed_flag}, FORCE_HTTP_SEED=#{force_http_seed_flag})."
  )
  if Rails.env.production? && !force_http_seed_flag
    puts "Para executar em produção, use FORCE_HTTP_SEED=true e configure SEED_BASE_URL."
  end
else
  puts "Executando seed HTTP em #{seed_url}"

  success = system({ "SEED_BASE_URL" => seed_url }, "ruby", Rails.root.join("script/http_seed.rb").to_s)
  abort("Falha ao executar seed HTTP. Verifique se o app está online em #{seed_url}.") unless success
end
