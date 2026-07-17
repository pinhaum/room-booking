# ADR-014 — Pipeline de assets sem Node

## Status
Aceito

## Contexto
O front-end usa Turbo, Stimulus e TailwindCSS (ver `ecosystem.md`). Existem duas abordagens:
empacotadores baseados em Node (esbuild/cssbundling, com `node_modules`) ou as soluções
nativas do Rails 8. O ADR-012 orienta priorizar recursos nativos do Rails.

## Decisão
Servir JavaScript via **importmap-rails** (sem transpilação/bundler) e CSS via
**tailwindcss-rails** (binário standalone, sem Node). Sem `node_modules` no projeto.
Propshaft como asset pipeline.

## Consequências
- Sem dependência de Node/npm no ambiente de desenvolvimento e na imagem Docker.
- Menos passos de build; setup mais simples e alinhado ao ADR-012.
- Limitação: bibliotecas JS que exijam bundler/transpilação não são suportadas diretamente;
  caso surja essa necessidade, reavaliar em novo ADR (migrar para jsbundling/esbuild).
