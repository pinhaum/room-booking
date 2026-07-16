# Definition of Done (ecosystem.md)

Uma tarefa só está concluída quando:

1. Código implementado.
2. Testes passando — `bundle exec rspec`.
3. RuboCop sem erros — `bundle exec rubocop`.
4. Brakeman sem alertas críticos — `bundle exec brakeman`.
5. Documentação atualizada (README/ADRs conforme necessário).
6. Sem TODOs pendentes.

## Prioridade de testes (ADR-008)
1. Services  2. Models  3. Requests  4. Policies  5. Jobs

Cobertura acompanhada via SimpleCov. Bullet ativo em dev/test para detectar N+1.
