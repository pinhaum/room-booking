# Meeting Room Booking

Aplicação **Ruby on Rails 8** para gerenciamento de reservas de salas de reunião.
Projeto de estudo (arquitetura em camadas, boas práticas, desenvolvimento orientado com IA).

## Stack

Ruby 3.4.8 · Rails 8 · PostgreSQL · Solid Queue/Cache · Hotwire (Turbo + Stimulus) ·
TailwindCSS · RSpec · RuboCop · Docker Compose · Mailpit.

## Requisitos

- Docker + Docker Compose

## Setup (desenvolvimento)

```bash
# subir banco, app e mailpit
docker compose up -d

# criar/preparar o banco de desenvolvimento
docker compose run --rm web bin/rails db:prepare
```

- App: http://localhost:3000
- Health check: http://localhost:3000/up
- Mailpit (e-mails de dev): http://localhost:8025

## Testes e qualidade

```bash
docker compose run --rm web bundle exec rspec      # testes
docker compose run --rm web bundle exec rubocop    # estilo
docker compose run --rm web bundle exec brakeman   # segurança
```

## Arquitetura

MVC + Service Objects. Camadas em `app/` (`services/`, `policies/`, `queries/`,
`presenters/`, `serializers/`, `forms/`, `validators/`, `components/`).
Decisões registradas em `.context/decisions/` (ADRs). Planos em `.claude/plans/`.
