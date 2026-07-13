# Meeting Room Booking — Guia de Desenvolvimento

## Objetivo

Desenvolver uma aplicação Ruby on Rails para gerenciamento de reservas de salas, com foco em aprendizado de arquitetura, boas práticas e desenvolvimento orientado por IA.

## Objetivos de aprendizado

- Ruby on Rails moderno
- Active Record
- Services
- Policies
- Active Job
- Action Mailer
- API REST
- RSpec
- Docker
- Arquitetura limpa

# Stack

## Linguagem

- Ruby 4.x.x (ou versão estável compatível)

## Framework

- Rails 8

## Banco

- PostgreSQL

## Cache

- Solid Cache

## Background Jobs

- Solid Queue

## Autenticação

- has_secure_password (fase inicial)
- Evolução futura: Devise

## Autorização

- Policies próprias
- Evolução futura: Pundit

## Front-end

- ERB
- Turbo
- Stimulus
- TailwindCSS

## API

- REST
- JSON
- Prefixo `/api/v1`

## Testes

- RSpec
- FactoryBot
- Faker
- Shoulda Matchers
- SimpleCov

## Qualidade

- RuboCop
- Brakeman
- Bullet

## Upload

- Active Storage

## Paginação

- Pagy

## Internacionalização

- I18n

## Containerização

- Docker + Docker Compose

## Email

- Mailpit

# API

## Recursos

- /login
- /logout
- /rooms
- /reservations

Utilizar respostas JSON e códigos HTTP corretos.

# Estratégia de testes

Prioridade:

1. Services
2. Models
3. Requests
4. Policies
5. Jobs

# ADRs

Registrar decisões para:

- Arquitetura
- Autenticação
- Services
- API
- Banco
- Autorização
- Jobs
- Testes
- Tratamento de erros
- Auditoria

# Definition of Done

- Código implementado
- Testes passando
- RuboCop sem erros
- Brakeman sem alertas críticos
- Documentação atualizada
- Sem TODOs pendentes
