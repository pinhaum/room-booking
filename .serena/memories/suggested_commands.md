# Comandos sugeridos

> O projeto ainda não foi inicializado (sem Gemfile/binstubs). Os comandos abaixo são o
> fluxo esperado assim que o app Rails 8 existir. Confirme que os arquivos existem antes de rodar.

## Dev
- `bin/dev` — sobe a aplicação (Rails + assets/Tailwind, via Procfile.dev)
- `bin/rails server` — servidor Rails
- `docker compose up` — ambiente completo (app, PostgreSQL, Mailpit)

## Banco
- `bin/rails db:create db:migrate`
- `bin/rails db:seed`

## Testes / Qualidade
- `bundle exec rspec` — suíte de testes (RSpec)
- `bundle exec rspec path/to/_spec.rb` — arquivo específico
- `bundle exec rubocop` / `bundle exec rubocop -A` — lint / autocorreção
- `bundle exec brakeman` — análise de segurança

## Sistema (Linux)
Utilitários padrão (`git`, `ls`, `grep`, `find`) comportam-se como unix padrão — sem
particularidades relevantes nesta máquina.

## Nota de ferramentas
Há um hook GateGuard que exige, antes do **primeiro** comando Bash da sessão, declarar
(1) o pedido do usuário e (2) o que o comando produz. Contornável com
`ECC_GATEGUARD=off` ou `ECC_DISABLED_HOOKS=pre:bash:gateguard-fact-force`.
