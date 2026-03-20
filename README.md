# Plataforma de Comunidades (Backend + Frontend)

Aplicação Rails 8.1 com API REST + interface web (HAML + Stimulus + Turbo) para gestão de comunidades, mensagens, comentários, reações e analytics de IP suspeito.

URL de teste (Render): https://test-comuh.onrender.com/communities

## Stack

- Ruby `3.4.7`
- Rails `8.1.2`
- PostgreSQL
- HAML + Bootstrap + Hotwire (Turbo + Stimulus)
- RSpec + SimpleCov
- RuboCop
- Faraday (integração HTTP + seed via API)

## Funcionalidades Entregues

### API

- `POST /api/v1/message` e `POST /api/v1/messages`
  - Cria mensagem/comentário
  - Cria usuário automaticamente se não existir
  - Calcula `ai_sentiment_score` automaticamente
- `POST /api/v1/reactions`
  - Reação por tipo com proteção de concorrência via índice único no banco
  - Retorna contadores agregados
- `GET /api/v1/communities/:id/messages/top`
  - Ranking por engajamento:
    - `engagement = (reaction_count * 1.5) + (reply_count * 1.0)`
  - `limit` default `10`, máximo `50`
- `GET /api/v1/analytics/suspicious_ips`
  - Detecta IP usado por múltiplos usuários (`min_users`, default `3`)

### Web

- `/communities`
  - Lista comunidades com quantidade de mensagens
- `/communities/:id`
  - Timeline com últimas 50 mensagens
  - Criação de mensagem sem reload (Stimulus + API)
  - Reações sem reload (Stimulus + API)
  - Indicador visual de sentimento
- `/messages/:id`
  - Thread da mensagem
  - Comentários com hierarquia visual
  - Criação de comentário sem reload

### IA / Sentimento

- Integração com OpenAI Responses API quando `OPENAI_API_KEY` está definida.
- Fallback local de sentimento (heurístico) quando sem chave.
- Resultado normalizado entre `-1.0` e `1.0`.

## Pré-requisitos

- Ruby `3.4.7`
- Bundler
- PostgreSQL local **ou** Docker

## Setup Rápido (Docker + `./comuh`)

1. Configurar variáveis:

```bash
cp .env.example .env
```

2. Subir aplicação + banco:

```bash
./comuh up -d
```

3. Rodar migrações:

```bash
./comuh db:migrate
```

4. (Opcional) Popular dados do desafio:

```bash
./comuh db:seed
```

Abra: `http://localhost:3000/communities`

## Seed via HTTP (requisito do desafio)

O script gera:

- 3-5 comunidades (`SEED_COMMUNITIES`, default: 5)
- 50 usuários
- 1000 mensagens com distribuição exata:
  - 700 posts principais
  - 300 comentários/respostas
- 20 IPs únicos garantidos
- 800 mensagens com reação (80% exato)

Com app rodando:

```bash
./comuh seed:http
```

Atalho equivalente:

```bash
./comuh db:seed
```

## Testes e Cobertura

```bash
./comuh rspec
```

Cobertura mínima configurada no SimpleCov: `70%`.

## Lint

```bash
./comuh rubocop
```

## Comandos Úteis (`./comuh`)

- `./comuh up -d` - sobe os containers
- `./comuh down` - derruba os containers
- `./comuh logs` - acompanha logs
- `./comuh db:prepare` - prepara banco (`default` e `test`)
- `./comuh db:migrate` - migra banco (`default` e `test`)
- `./comuh db:seed` - roda seed HTTP do projeto
- `./comuh rspec` - roda os testes em `RAILS_ENV=test`
- `./comuh rubocop` - roda lint
- `./comuh rubocop:fix` - auto-corrige lint quando possível
- `./comuh console` - abre `rails console` no container
- `./comuh sh` - shell no container

## Endpoints (resumo)

### `POST /api/v1/messages`

Request:

```json
{
  "username": "john_doe",
  "community_id": 1,
  "content": "Conteúdo da mensagem",
  "user_ip": "192.168.1.1",
  "parent_message_id": null
}
```

### `POST /api/v1/reactions`

Request:

```json
{
  "message_id": 1,
  "user_id": 1,
  "reaction_type": "like"
}
```

Também aceita `username` no lugar de `user_id` para a interface web.

### `GET /api/v1/communities/:id/messages/top?limit=10`

### `GET /api/v1/analytics/suspicious_ips?min_users=3`

## Decisões Técnicas

- Índices e constraints no banco para performance e consistência.
- Unicidade de reação garantida por índice único (`message_id`, `user_id`, `reaction_type`).
- API desenhada para ser consumida tanto por clientes externos quanto pela UI Stimulus.
- Seed via HTTP reutiliza os próprios endpoints (sem inserção direta no banco).

## Checklist de Entrega - Vinicius G

### Repositório & Código

- [ ] Código no GitHub (público): [URL DO REPO]
- [x] README com instruções completas
- [x] `.env.example` com variáveis de ambiente
- [x] Linter/formatter configurado
- [x] Código limpo e organizado

### Stack Utilizada

- [x] Backend: Ruby on Rails
- [x] Frontend: Rails (HAML + Stimulus + Turbo)
- [x] Banco de dados: PostgreSQL
- [x] Testes: RSpec

### Deploy

- [x] URL da aplicação: https://test-comuh.onrender.com/communities
- [x] Docker funcionando
- [ ] Seeds executados (dados visíveis em ambiente publicado)

### Funcionalidades - API

- [x] `POST /api/v1/messages` (criar mensagem + sentiment)
- [x] `POST /api/v1/reactions` (com proteção de concorrência)
- [x] `GET /api/v1/communities/:id/messages/top`
- [x] `GET /api/v1/analytics/suspicious_ips`
- [x] Tratamento de erros apropriado
- [x] Validações implementadas

### Funcionalidades - Frontend

- [x] Listagem de comunidades
- [x] Timeline de mensagens
- [x] Criar mensagem (sem reload)
- [x] Reagir a mensagens (sem reload)
- [x] Ver thread de comentários
- [x] Responsivo (mobile + desktop)

### Testes

- [x] Cobertura mínima de 70%
- [x] Testes passando
- [x] Como rodar documentado

### Documentação

- [x] Setup local documentado
- [x] Decisões técnicas explicadas
- [x] Como rodar seeds
- [x] Endpoints documentados
- [ ] Screenshot ou GIF da interface (opcional)
