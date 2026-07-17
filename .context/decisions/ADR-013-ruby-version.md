# ADR-013 — Versão do Ruby

## Status
Aceito

## Contexto
`ecosystem.md` e `tech_stack` indicavam "Ruby 4.x.x (ou versão estável compatível)".
No bootstrap (Fase 0), Ruby 4.x não é uma versão estável adequada para produção com Rails 8,
enquanto Ruby 3.4.x é a linha estável recomendada e totalmente suportada.

## Decisão
Fixar **Ruby 3.4.8** para o projeto, versionado em `.tool-versions` e `.ruby-version`,
usado tanto no ambiente local quanto na imagem Docker de desenvolvimento.

## Consequências
- Compatibilidade garantida com Rails 8 e o ecossistema de gems atual.
- A menção a "Ruby 4.x" em `ecosystem.md` fica coberta pela cláusula "ou versão estável compatível".
- Atualização de versão passa a ser uma decisão explícita (novo ADR ou revisão deste).
