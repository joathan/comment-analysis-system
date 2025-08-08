# Sistema de Análise de Comentários

Este projeto é uma aplicação Ruby on Rails projetada para importar dados de usuários da API JSONPlaceholder, analisar os comentários com base em um conjunto de palavras-chave e calcular métricas estatísticas sobre os resultados.

## Arquitetura

A arquitetura do sistema é baseada nos princípios do Rails, priorizando a separação de responsabilidades para garantir um código limpo, coeso e de fácil manutenção.

* **Models (`app/models`):** Representam os dados da aplicação e a lógica de negócio associada a eles (validações, associações, máquina de estados com AASM).

* **Controllers (`app/controllers`):** Responsáveis por receber as requisições (seja da interface web ou da API), interagir com os serviços e jobs, e retornar uma resposta (HTML ou JSON). São mantidos "magros" (thin), delegando a lógica de negócio.

* **Services (`app/services`):** Contêm a lógica de negócio principal e orquestram as operações complexas. Por exemplo, `ImportUserService` gerencia a importação de um usuário, e `CommentProcessingService` executa os passos para analisar um comentário.

* **Jobs (`app/jobs`):** Utilizam o Active Job para executar tarefas demoradas de forma assíncrona (em segundo plano), como a importação de dados e o reprocessamento de comentários. Isso evita que a interface do usuário ou a API fiquem bloqueadas.

* **Adapters (`app/adapters`):** Isolam o sistema de dependências externas (APIs de terceiros). O `JsonPlaceholderAdapter` e o `LibreTranslateAdapter` são responsáveis exclusivamente pela comunicação com suas respectivas APIs, traduzindo as requisições e respostas.

## Decisões de Design

* **Processamento Assíncrono:** A importação e análise de usuários é uma operação que pode levar tempo. A utilização de **Jobs** (com Sidekiq/Redis) foi uma decisão crucial para garantir que a API responda imediatamente (`202 Accepted`) e que a interface do usuário não trave. Um endpoint de progresso (`/api/v1/progress/:job_id`) foi criado para monitorar o status dessas tarefas.

* **Pattern Adapter:** Para desacoplar o sistema de serviços externos, foi implementado o **Adapter Pattern**. `TranslationService` não conhece os detalhes da API LibreTranslate; ele apenas se comunica com o `LibreTranslateAdapter`. Isso permite que a API de tradução seja trocada no futuro (ex: para a do Google) com impacto mínimo, alterando apenas o adapter.

* **Cache de Métricas e Keywords:** Operações de cálculo de métricas e a busca de palavras-chave podem ser custosas. O `Rails.cache` é utilizado para armazenar esses resultados (`MetricsCacheService` e `Keyword.cached_terms`), melhorando drasticamente a performance em requisições subsequentes. O cache é invalidado de forma inteligente sempre que os dados subjacentes são alterados.

* **Reprocessamento em Lotes:** A alteração de uma palavra-chave dispara o reprocessamento de todos os comentários. Para evitar a sobrecarga do sistema de filas com milhares de jobs simultâneos, o `ReprocessAllCommentsJob` utiliza `find_in_batches` para processar os usuários em lotes, garantindo a escalabilidade da solução.

* **Idempotência e Flexibilidade nos Jobs:** O `ProcessCommentJob` foi projetado com um parâmetro `force: true`. Em seu fluxo normal, ele ignora comentários já processados (otimização). No fluxo de reprocessamento, o `force` é ativado para garantir que todos os comentários sejam reavaliados, tornando a lógica explícita e flexível.

## Fórmulas Estatísticas

As métricas são calculadas sobre o comprimento (número de caracteres) dos comentários.

* **Média (Mean):** A soma dos comprimentos de todos os comentários dividida pelo número total de comentários.

  * Fórmula: `μ = (Σ xi) / n`

* **Mediana (Median):** O valor central em uma lista ordenada de comprimentos. Se a lista tiver um número par de elementos, é a média dos dois valores centrais. A mediana é útil por ser menos sensível a valores extremos (outliers).

* **Desvio Padrão Amostral (Sample Standard Deviation):** Mede a dispersão dos comprimentos dos comentários em relação à média. A fórmula utiliza `n-1` no denominador (Correção de Bessel), que é a prática padrão para estimar o desvio padrão de uma população inteira com base em uma amostra de dados, fornecendo um resultado mais preciso.

  * Fórmula: `σ = √[ Σ(xi - μ)² / (n - 1) ]`

## Collection de Endpoints da API

A seguir, a documentação dos endpoints da API para testes.

### 1. Iniciar Análise de um Usuário

Inicia o processo de importação e análise para um `username` específico.

* **Método:** `POST`

* **Endpoint:** `/api/v1/analyze`

* **Headers:**

  * `Content-Type: application/json`

* **Body (raw, JSON):**

    ```json
    {
      "username": "Bret"
    }
    ```

* **Resposta de Sucesso (202 Accepted):**

    ```json
    {
      "job_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "status": "queued"
    }
    ```

### 2. Verificar Progresso da Análise

Verifica o status de um job que está em andamento.

* **Método:** `GET`

* **Endpoint:** `/api/v1/progress/:job_id`

  * *Substitua `:job_id` pelo ID retornado no endpoint anterior.*

* **Exemplo de URL:** `/api/v1/progress/a1b2c3d4-e5f6-7890-1234-567890abcdef`

* **Respostas Possíveis (200 OK):**

  * **Em andamento:**

      ```json
      {
        "job_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
        "status": "processing"
      }
      ```

  * **Concluído:**

      ```json
      {
        "job_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
        "status": "done"
      }
      ```

### 3. Obter Métricas de Análise

Retorna as métricas calculadas para um usuário específico e para o grupo.

* **Método:** `GET`

* **Endpoint:** `/api/v1/analyze/:username`

  * *Substitua `:username` pelo nome de usuário analisado.*

* **Exemplo de URL:** `/api/v1/analyze/Bret`

* **Resposta de Sucesso (200 OK):**

    ```json
    {
      "user": {
        "username": "Bret",
        "metrics": {
          "approved_count": 25,
          "rejected_count": 25,
          "approval_rate": 0.5,
          "average_length": 145.5,
          "median_length": 148.0,
          "stddev_length": 28.7
        }
      },
      "group": {
        "metrics": {
          "total_users": 10,
          "total_comments": 500,
          "approved_comments": 250,
          "rejected_comments": 250,
          "approval_rate": 0.5,
          "average_comment_length": 150.2,
          "median_comment_length": 151.0,
          "stddev_comment_length": 30.1
        }
      }
    }
    ```

* **Resposta de Erro (404 Not Found):**

    ```json
    {
      "error": "User not found"
    }
    ```

## Escopo do Projeto vs. Funcionalidades Adicionais

Esta seção detalha as funcionalidades que foram parte dos requisitos originais do projeto e aquelas que foram implementadas como melhorias para aumentar a robustez, escalabilidade e experiência de uso do sistema.

### Funcionalidades do Escopo (Requisitos Iniciais)

* **API para Análise:** Endpoint `POST /api/v1/analyze` para iniciar a análise de um usuário.
* **Pipeline de Importação:** Importação de dados de usuário, posts e comentários da API JSONPlaceholder.
* **Máquina de Estados:** Classificação de comentários usando uma máquina de estados (`new` → `processing` → `approved`/`rejected`).
* **Lógica de Classificação:** Tradução do comentário para PT-BR e aprovação baseada na contagem de palavras-chave (>=2).
* **Cálculo de Métricas:** Cálculo de média, mediana e desvio padrão sobre o comprimento dos comentários.
* **Agrupamento de Métricas:** Apresentação das métricas tanto por usuário individual quanto para o grupo de todos os usuários.
* **API de Métricas:** Endpoint `GET /api/v1/analyze/:username` para retornar os dados calculados em JSON.
* **Gerenciamento de Palavras-chave:** Funcionalidade para criar, alterar e remover as palavras-chave que guiam a análise.
* **Reprocessamento Automático:** Gatilho para reanalisar todos os comentários sempre que a lista de palavras-chave é modificada.
* **Endpoint de Progresso:** API `GET /api/v1/progress/:job_id` para monitorar o status de jobs em segundo plano.
* **Uso de Cache:** Aplicação de cache para otimizar o recálculo de métricas.

### Melhorias

* **Arquitetura com Adapters e Services:** A formalização da arquitetura com o **Pattern Adapter** (`LibreTranslateAdapter`) e **Service Objects** (`TranslationService`, `CommentProcessingService`) foi uma decisão de design para garantir baixo acoplamento e alta manutenibilidade, facilitando futuras trocas de serviços externos.
* **Escalabilidade no Reprocessamento:** O `ReprocessAllCommentsJob` foi otimizado para usar `find_in_batches`, prevenindo a sobrecarga do sistema de filas ao lidar com um grande volume de usuários.
* **Otimização de Performance com Cache de Keywords:** A lista de palavras-chave é cacheada (`Keyword.cached_terms`) para evitar múltiplas consultas ao banco de dados durante o processamento em massa, otimizando significativamente a performance.
* **Flexibilidade nos Jobs (`force: true`):** A introdução do parâmetro `force` no `ProcessCommentJob` foi uma solução de design para gerenciar de forma explícita e robusta a diferença entre o processamento inicial e a reanálise forçada de comentários.

### Funcionalidades Adicionais (Extras)

As seguintes funcionalidades foram adicionadas para aprimorar o projeto, indo além do escopo original:

* **Interface Web Completa:** Uma interface administrativa web foi construída do zero usando DaisyUI/TailwindCSS, permitindo:
  * Visualizar todas as métricas em um dashboard.
  * Gerenciar palavras-chave através de formulários.
  * Iniciar a análise de um usuário diretamente pela UI.
  * Listar todos os posts e comentários com seus respectivos status.
* **Feedback de Progresso em Tempo Real:** Implementação de JavaScript para fazer polling no endpoint de progresso e exibir o status da análise em tempo real na interface, com notificações que se transformam e desaparecem automaticamente.
