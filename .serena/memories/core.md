# room-booking — Core

Aplicação **Ruby on Rails 8** para gerenciamento de reservas de salas de reunião.
Projeto de **estudo** (arquitetura, boas práticas, desenvolvimento orientado por IA).

## Estado atual (IMPORTANTE)
**Fase 0 (Bootstrap) concluída.** O esqueleto Rails 8 existe e roda via Docker:
- App gerada com `rails new` (PostgreSQL, importmap+Hotwire, tailwindcss-rails).
- Ruby 3.4.8 (`.tool-versions`/`.ruby-version`). Gems nativas do Rails 8 (Solid Queue/Cache/Cable, Kamal, Propshaft).
- Docker Compose (`compose.yaml` + `Dockerfile.dev`): serviços `web` (roda como UID 1000), `db` (postgres:16), `mailpit`. Gems num volume `bundle_data`.
- Testes: RSpec + FactoryBot + Faker + Shoulda + SimpleCov (`spec/`, cobertura em `/coverage`, gitignored).
- Qualidade: RuboCop (rails-omakase, 0 offenses — sem `.rubocop_todo.yml`), Brakeman (0 alertas), Bullet.
- i18n default `pt-BR`; timezone `America/Sao_Paulo` (AR em UTC).
- Diretórios de camadas criados em `app/` (services/policies/queries/presenters/serializers/forms/validators/components) com `.keep`.
- **Ainda não há domínio** (User/Room/Reservation), migrations ou regras de negócio — isso começa na Fase 1.

Rodar: `docker compose up -d` → `docker compose run --rm web bin/rails db:prepare`.
Testes: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec` (o `web` define
RAILS_ENV=development, então passe `-e RAILS_ENV=test` para specs).
Nota: para instalar gems novas, rode bundle como root: `docker compose run --rm --user root web bundle install`.

## Planos
- `.claude/plans/room-booking-roadmap.plan.md` — roadmap macro (Fases 0–8).
- `.claude/plans/phase-0-bootstrap.plan.md` — plano executável da Fase 0 (concluído).

## Mapa de fontes
- `.context/ecosystem.md` — visão geral e Definition of Done. **Fonte primária de requisitos.**
- `.context/ARCHITECTURE.md` — padrões arquiteturais e estrutura de `app/`.
- `.context/domain.md` — entidades (User, Room, Reservation) e regras de negócio.
- `.context/decisions/ADR-001..012` — decisões arquiteturais.

## Domínio (alvo — ainda não implementado)
- **User**: name, email, password_digest, role.
- **Room**: name, capacity, description, available.
- **Reservation**: room, user, starts_at, ends_at, purpose, status.

## Invariantes de negócio (ADR + domain.md)
- Não permitir reservas sobrepostas na mesma sala.
- Não permitir reservas no passado.
- `ends_at` deve ser maior que `starts_at`.
- Apenas o criador ou um admin pode cancelar uma reserva.
- Registrar auditoria de criação, edição e cancelamento de reservas.

## Memórias relacionadas
`mem:tech_stack`, `mem:conventions`, `mem:suggested_commands`, `mem:task_completion`.
