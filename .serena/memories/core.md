# room-booking — Core

Aplicação **Ruby on Rails 8** para gerenciamento de reservas de salas de reunião.
Projeto de **estudo** (arquitetura, boas práticas, desenvolvimento orientado por IA).

## Estado atual (IMPORTANTE)
**Fase 0 (Bootstrap) e Fase 1 (Autenticação) concluídas.**

Fase 0: app Rails 8 (PostgreSQL, importmap+Hotwire, tailwindcss-rails/Propshaft), Docker Compose
(`web` roda como UID 1000 e compila o Tailwind no boot; `db` postgres:16; `mailpit`; gems no
volume `bundle_data`), RSpec/FactoryBot/Faker/Shoulda/SimpleCov, RuboCop (rails-omakase),
Brakeman, Bullet, i18n default `pt-BR`, timezone `America/Sao_Paulo`, camadas em `app/`.

Fase 1: `User` (`has_secure_password`, enum `role` member/admin, e-mail normalizado/único),
service `UserAuthenticator` (retorna User ou levanta `InvalidCredentials`, compare dummy p/ timing),
concern `Authentication` + `Current`, `SessionsController` (`/login` GET/POST, `/logout` DELETE),
`HomeController` (root, requer auth), views ERB com Tailwind, i18n `auth.*`, seed admin
(`admin@example.com` / `password123`). 21 specs verdes, rubocop/brakeman limpos.

Tailwind: `app/assets/tailwind/application.css` (`@import "tailwindcss"`) → build em
`app/assets/builds/tailwind.css` (gitignored). O layout usa `stylesheet_link_tag :app`, que no
Rails 8.1 serve todos os stylesheets (application + tailwind). O `web` builda no boot; para
rebuild ao vivo: `bin/rails tailwindcss:watch`. `bin/dev`/`Procfile.dev` existem mas não são
usados no compose (foreman não instalado).

### Armadilhas do ambiente (NÃO são ADR — são operacionais)
- **Container `web` defasado:** `docker compose up -d web` NÃO reinicia sem mudança de config;
  após instalar gem nova use `docker compose up -d --force-recreate web` (senão `LoadError`).
- **`down -v` apaga o volume `bundle_data`** (gems) junto com o banco → reinstalar gems depois.
- **Gem nova:** `docker compose run --rm --user root web bundle install` (root, por causa do volume).
- **Deprecação:** trocar `:unprocessable_entity` por `:unprocessable_content` (Rack) — pendente.

## Comandos essenciais
- Subir: `docker compose up -d` → `docker compose run --rm web bin/rails db:prepare`
- Testes: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec` (passar `-e RAILS_ENV=test`).
- Migrar/seed: `docker compose run --rm web bin/rails db:migrate|db:seed`.

## Planos e decisões
- `.claude/plans/`: `room-booking-roadmap.plan.md`, `phase-0-bootstrap.plan.md`, `phase-1-authentication.plan.md`.
- `.context/decisions/ADR-001..014` (novos: ADR-013 Ruby 3.4.8, ADR-014 assets sem Node).
- Requisitos: `.context/ecosystem.md`, `.context/ARCHITECTURE.md`, `.context/domain.md`.

## Domínio
- **User**: name, email, password_digest, role. (implementado)
- **Room**: name, capacity, description, available. (Fase 3)
- **Reservation**: room, user, starts_at, ends_at, purpose, status. (Fase 4)

## Invariantes de negócio (ADR + domain.md)
- Não permitir reservas sobrepostas na mesma sala.
- Não permitir reservas no passado.
- `ends_at` deve ser maior que `starts_at`.
- Apenas o criador ou um admin pode cancelar uma reserva.
- Registrar auditoria de criação, edição e cancelamento de reservas.

## Memórias relacionadas
`mem:tech_stack`, `mem:conventions`, `mem:suggested_commands`, `mem:task_completion`.
