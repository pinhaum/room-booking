# room-booking — Core

Aplicação **Ruby on Rails 8** para gerenciamento de reservas de salas de reunião.
Projeto de **estudo** (arquitetura, boas práticas, desenvolvimento orientado por IA).

## Estado atual (IMPORTANTE)
**Fases 0 (Bootstrap), 1 (Autenticação) e 2 (Autorização) concluídas.**

Fase 0: app Rails 8 (PostgreSQL, importmap+Hotwire, tailwindcss-rails/Propshaft), Docker Compose
(`web` roda como UID 1000 e compila Tailwind no boot; `db` postgres:16; `mailpit`; gems no volume
`bundle_data`), RSpec/FactoryBot/Faker/Shoulda/SimpleCov, RuboCop (rails-omakase), Brakeman,
Bullet, i18n `pt-BR`, timezone `America/Sao_Paulo`, camadas em `app/`.

Fase 1: `User` (`has_secure_password`, enum `role` member/admin, e-mail normalizado/único),
service `UserAuthenticator`, concern `Authentication` + `Current`, `SessionsController`
(`/login`, `/logout`), `HomeController` (root, requer auth), views ERB, i18n `auth.*`,
seed admin (`admin@example.com` / `password123`).

Fase 2: autorização por Policies próprias (ADR-006, **não RBAC puro** — papel + ownership).
`ApplicationPolicy` (deny-by-default, helpers `admin?`/`owner?`, `Scope`), concern `Authorization`
(`authorize`/`policy`/`policy_scope` + `rescue_from Authorization::NotAuthorized` → 403; HTML render
plain 403, JSON head :forbidden), i18n `authorization.not_authorized`. Policies concretas
(`RoomPolicy`, `ReservationPolicy`) subclassificam `ApplicationPolicy` nas Fases 3–4.

**29 specs verdes, rubocop/brakeman limpos.**

### Armadilhas do ambiente (operacionais, NÃO ADR)
- Container `web` defasado: após instalar gem nova, `docker compose up -d --force-recreate web`.
- `down -v` apaga o volume `bundle_data` (gems) → reinstalar depois.
- Gem nova: `docker compose run --rm --user root web bundle install`.
- Deprecação pendente: trocar `:unprocessable_entity` por `:unprocessable_content` (Rack).

## Comandos essenciais
- Subir: `docker compose up -d` → `docker compose run --rm web bin/rails db:prepare`
- Testes: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec` (passar `-e RAILS_ENV=test`).
- Migrar/seed: `docker compose run --rm web bin/rails db:migrate|db:seed`.

## Planos e decisões
- `.claude/plans/`: roadmap + `phase-0`..`phase-2` (0–2 concluídas).
- `.context/decisions/ADR-001..014`. Notáveis: ADR-006 (autorização = papel+ownership, policies próprias),
  ADR-013 (Ruby 3.4.8), ADR-014 (assets sem Node).
- Requisitos: `.context/ecosystem.md`, `ARCHITECTURE.md`, `domain.md`.

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
