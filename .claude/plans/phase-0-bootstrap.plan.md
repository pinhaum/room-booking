# Plan: Fase 0 — Fundação / Bootstrap

**Source Roadmap**: `.claude/plans/room-booking-roadmap.plan.md`
**Selected Milestone**: Fase 0 — Fundação / Bootstrap
**Complexity**: Medium

## Summary
Criar o esqueleto Rails 8 (PostgreSQL, importmap+Hotwire, tailwindcss-rails) dentro do
repositório atual **sem sobrescrever** `.gitignore`/`.tool-versions`, subir tudo via Docker
Compose (`web` + `db` + `mailpit`), instalar a suíte RSpec e o ferramental de qualidade
(RuboCop incremental, Brakeman, Bullet), fixar i18n em `pt-BR` e deixar um smoke test verde.
Nenhuma regra de domínio nesta fase — apenas fundação verificável.

## Decisões-chave (fiéis aos ADRs)
- **Native-first (ADR-012):** importmap para JS + `tailwindcss-rails` para CSS → sem Node/`node_modules`.
- **Ruby 3.4.8** local via `.tool-versions` (asdf/mise) para rodar `rails new`; runtime da app roda em container.
- **RuboCop incremental:** base `rubocop-rails-omakase` + `.rubocop_todo.yml` gerado (não travar o bootstrap).
- **Preservar** `.gitignore` e `.tool-versions` já versionados (`rails new --skip-git`).

## Patterns to Mirror
| Category | Source | Pattern |
|---|---|---|
| Arquitetura | ADR-001 / `ARCHITECTURE.md` | MVC + Service Objects; diretórios de camadas em `app/` |
| Testes | ADR-008 / `ecosystem.md` | RSpec; prioridade Services→Models→Requests→Policies→Jobs |
| Dependências | ADR-012 | Preferir recursos nativos do Rails; gem só com valor claro |
| Idioma | `mem:conventions` | Código/commits em inglês; mensagens de usuário em pt-BR (I18n) |

## Files to Change
| File | Action | Why |
|---|---|---|
| `Gemfile` / `Gemfile.lock` | CREATE | App Rails 8 + gems de teste/qualidade |
| `config/`, `app/`, `bin/`, `db/`, `public/` | CREATE | Scaffold do `rails new` |
| `.tool-versions` | KEEP | Já fixa ruby 3.4.8 |
| `.gitignore` | KEEP | Já Rails-aware; não sobrescrever |
| `README.md` | UPDATE | Substituir placeholder por instruções de setup |
| `compose.yaml` | CREATE | Serviços dev: web + db (Postgres) + mailpit |
| `Dockerfile.dev` | CREATE | Imagem de desenvolvimento (Ruby 3.4.8) |
| `.env.example` | CREATE | Variáveis (DATABASE_URL, etc.); `.env` fica no gitignore |
| `config/database.yml` | UPDATE | Apontar para serviço `db` via env |
| `config/application.rb` | UPDATE | `config.i18n.default_locale = :"pt-BR"`, `config.time_zone` |
| `config/locales/pt-BR.yml` | CREATE | Mensagens base em pt-BR |
| `spec/` + `.rspec` + `spec/rails_helper.rb` | CREATE | Setup RSpec/FactoryBot/Shoulda/SimpleCov |
| `.rubocop.yml` + `.rubocop_todo.yml` | CREATE | Base omakase + backlog incremental |
| `app/{services,policies,queries,presenters,serializers,forms,validators,components}/.keep` | CREATE | Diretórios de camadas (ADR-001) |

## Tasks

### Task 1: Gerar o esqueleto Rails 8 preservando arquivos versionados
- **Action**:
  ```bash
  ruby -v   # confirmar 3.4.8 (asdf/mise via .tool-versions)
  gem install rails -v '~> 8.0'
  rails new . --database=postgresql --css=tailwind --skip-git --skip-test --force
  ```
  `--skip-git` preserva `.gitignore`; `--skip-test` remove Minitest (usaremos RSpec);
  `--force` aceita sobrescrever só o `README.md` placeholder. Importmap é o default (JS nativo).
- **Mirror**: ADR-012 (native-first: importmap + tailwindcss-rails).
- **Validate**: `test -f Gemfile && test -f config/application.rb && bin/rails -v`

### Task 2: Criar diretórios de camadas da arquitetura
- **Action**: criar `app/services app/policies app/queries app/presenters app/serializers app/forms app/validators app/components` com um `.keep` em cada (Rails já cria `mailers` e `jobs`).
- **Mirror**: `ARCHITECTURE.md` / ADR-001.
- **Validate**: `bin/rails zeitwerk:check` (autoload sem erros).

### Task 3: Dockerizar o ambiente de desenvolvimento
- **Action**: criar `Dockerfile.dev` (base `ruby:3.4.8`), `compose.yaml` com serviços:
  - `web`: build de `Dockerfile.dev`, monta o código, `bin/rails server -b 0.0.0.0`;
  - `db`: `postgres:16`, volume nomeado, credenciais via env;
  - `mailpit`: `axllent/mailpit`, portas SMTP 1025 / UI 8025.
  Ajustar `config/database.yml` para ler `DATABASE_URL`/host `db`; criar `.env.example`.
- **Mirror**: restrição do usuário "Docker Compose padronizado desde o início".
- **Validate**: `docker compose up -d db && docker compose run --rm web bin/rails db:prepare`

### Task 4: Instalar e configurar RSpec + ferramentas de teste
- **Action**: adicionar ao `Gemfile` (grupos `:development, :test`): `rspec-rails`, `factory_bot_rails`,
  `faker`, `shoulda-matchers`, `simplecov` (require: false). Rodar `bin/rails generate rspec:install`.
  Configurar `rails_helper.rb`: SimpleCov no topo, Shoulda Matchers, FactoryBot syntax methods.
- **Mirror**: ADR-008 (RSpec; ordem de prioridade dos specs).
- **Validate**: criar `spec/smoke_spec.rb` trivial → `bundle exec rspec` verde.

### Task 5: Ferramental de qualidade (RuboCop incremental, Brakeman, Bullet)
- **Action**: `.rubocop.yml` herdando `rubocop-rails-omakase`; gerar `.rubocop_todo.yml`
  com `bundle exec rubocop --auto-gen-config`. Brakeman já vem no Rails 8. Adicionar `bullet`
  (grupo dev) e habilitar em `config/environments/development.rb`.
- **Mirror**: restrição do usuário "RuboCop ajustado incrementalmente".
- **Validate**: `bundle exec rubocop` (0 offenses fora do todo) e `bundle exec brakeman -q` sem crítico.

### Task 6: i18n pt-BR e timezone
- **Action**: `config.i18n.default_locale = :"pt-BR"`, `config.i18n.available_locales`,
  `config.time_zone`; criar `config/locales/pt-BR.yml` base.
- **Mirror**: `mem:conventions` (mensagens de usuário em pt-BR).
- **Validate**: `bin/rails runner 'raise unless I18n.default_locale == :"pt-BR"'`

### Task 7: README de setup e portão final
- **Action**: substituir o README placeholder por instruções (`docker compose up`, `db:prepare`, `rspec`).
- **Validate**: rodar o bloco de validação abaixo por inteiro.

## Validation
```bash
# App e autoload
bin/rails -v
bin/rails zeitwerk:check

# Banco (via container)
docker compose up -d db
docker compose run --rm web bin/rails db:prepare

# App sobe
docker compose up -d web && curl -fsS http://localhost:3000/up   # health check do Rails 8

# Qualidade
bundle exec rspec
bundle exec rubocop
bundle exec brakeman -q
```

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| `rails new` sobrescrever `.gitignore` | Média | `--skip-git` preserva; conferir `git diff` após gerar |
| Ruby 3.4.8 indisponível localmente para `rails new` | Média | `asdf install` / `mise install`; alternativa: rodar `rails new` num container `ruby:3.4.8` |
| Solid Queue/Cache exigindo config extra no Rails 8 | Média | Validar `db:prepare` (cria os schemas solid) já na Fase 0 |
| Conflito de porta (3000/5432/8025) | Baixa | Mapear portas no `compose.yaml`; documentar no README |
| RuboCop omakase gerando muitas offenses | Média | `.rubocop_todo.yml` isola o legado; corrigir incrementalmente |

## Acceptance
- [ ] `rails new` gerado sem sobrescrever `.gitignore`/`.tool-versions`
- [ ] `docker compose up` sobe web + db + mailpit; `/up` responde 200
- [ ] `bundle exec rspec` verde (smoke test)
- [ ] `rubocop` limpo (fora do todo) e `brakeman` sem alerta crítico
- [ ] i18n default `pt-BR` e diretórios de camadas presentes
- [ ] Commit convencional: `chore(setup): bootstrap rails 8 app with docker, rspec and tooling`

---

## Geração dos próximos planos (Fases 1–8)
Cada fase seguinte terá seu próprio arquivo `.claude/plans/phase-N-<slug>.plan.md`, no mesmo
formato executável (Tasks com Action/Mirror/Validate + Validation + Risks + Acceptance).
Recomendação: **gerar o plano de cada fase logo antes de executá-la**, para ancorar nas
convenções que já existirão no código (não planejar tudo no vazio). Sequência sugerida de
invocações:

1. `phase-1-authentication.plan.md` (após Fase 0 mergeada)
2. `phase-2-authorization.plan.md`
3. `phase-3-rooms.plan.md`
4. `phase-4-reservations.plan.md`  ← núcleo; maior detalhamento de invariantes
5. `phase-5-api-v1.plan.md`
6. `phase-6-audit.plan.md`
7. `phase-7-jobs-mailer.plan.md`
8. `phase-8-frontend.plan.md`
