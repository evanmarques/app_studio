# PC Studio App (Flutter Edition)

## 1. Visão Geral e Objetivo do Projeto

O **PC Studio App** é uma plataforma multiplataforma (Android, iOS, Web) desenvolvida em Flutter, projetada para conectar estúdios e artistas de tatuagem com clientes. O aplicativo serve como um diretório profissional, permitindo que artistas divulguem seus trabalhos e alcancem novos clientes, enquanto oferece aos usuários finais uma ferramenta para descobrir, contatar e agendar sessões com esses profissionais.

A decisão de usar Flutter foi uma evolução estratégica do projeto para garantir uma base de código única e escalável, visando a publicação nas lojas da Apple (iOS) e Google (Android), além de uma versão web acessível.

## 2. Estratégia de Monetização

O projeto utilizará um modelo de negócio "Freemium", gerando receita através de duas frentes principais:

* **Anúncios para Usuários Finais:** Os clientes que utilizam o aplicativo para buscar artistas o farão gratuitamente, mas visualizarão anúncios (AdMob) em telas estratégicas.

* **Planos de Assinatura para Artistas/Estúdios:** Os profissionais terão diferentes níveis de planos, cada um liberando mais funcionalidades:
    * **Plano Free:** Um "cartão de visita" digital, permitindo o cadastro básico do estúdio apenas com informações de contato.
    * **Plano Básico:** Inclui os benefícios do Free, mais a opção de adicionar uma foto de perfil e os links para redes sociais (Instagram, WhatsApp, Facebook).
    * **Plano Avançado:** Inclui tudo do Básico, mais a capacidade de fazer upload de um portfólio de até 10 imagens e acesso completo ao sistema de gerenciamento de agenda.
    * **Plano Premium:** Inclui todos os benefícios anteriores, com adicionais futuros como gestão de estoque de produtos e vendas.

## 3. Arquitetura e Tecnologias (Pilha Tecnológica)

* [cite_start]**Framework:** Flutter [cite: 6]
* [cite_start]**Linguagem:** Dart [cite: 6]
* [cite_start]**IDE (Ambiente de Desenvolvimento):** Visual Studio Code [cite: 9]
* **Backend como Serviço (BaaS):** Google Firebase
    * **Autenticação:** Firebase Authentication (E-mail/Senha, Google Sign-In).
    * **Banco de Dados:** Cloud Firestore (NoSQL).
    * **Armazenamento de Arquivos:** Cloud Storage (para imagens de perfil e portfólios).
    * **Funções de Servidor:** Cloud Functions (para futuras notificações).

## 4. Roadmap do Projeto

### Versão 1.0 (Lançamento e MVP)

* **Fase 1: Fundação do Projeto (CONCLUÍDO)**
    * [✓] Configuração do ambiente de desenvolvimento Flutter (SDK, VS Code).
    * [✓] Criação e estruturação do novo repositório Git.
    * [✓] Conexão do projeto Flutter com o backend no Firebase.

* **Fase 2: UI Base e Navegação (CONCLUÍDO)**
    * [✓] Criação da estrutura de navegação principal com `BottomNavigationBar`.
    * [✓] Desenvolvimento das telas estáticas (placeholders) para Início, Artistas, Agenda e Perfil.

* **Fase 3: Autenticação de Utilizadores (CONCLUÍDO)**
    * [✓] Implementação da tela de "Splash" (AuthGate) para verificar o status de login.
    * [✓] Desenvolvimento do fluxo completo de autenticação com E-mail/Senha.
    * [✓] Implementação do fluxo de "Login com Google".
    * [✓] Criação da coleção `users` no Firestore.

* **Fase 4: Perfis e Gerenciamento do Artista (EM ANDAMENTO)**
    * [✓] Lógica na tela de Perfil para exibir botões de "Cadastrar Estúdio" ou "Gerenciar Perfil".
    * [✓] Desenvolvimento do fluxo de cadastro de estúdio (seleção de plano, formulário, upload de imagem).
    * [✓] Implementação da tela de gerenciamento de portfólio (adicionar/remover fotos).
    * [ ] Desenvolvimento da tela "Editar Perfil" para artistas.

* **Fase 5: Funcionalidades Centrais (PRÓXIMO PASSO)**
    * [✓] Exibição das listas de artistas com dados do Firestore.
    * [✓] Implementação da tela de detalhes do artista.
    * [ ] Implementação do visualizador de imagens em tela cheia na Home.
    * [ ] Desenvolvimento completo do sistema de agendamento (lado do artista e do cliente).

### Versão 2.0 (Recursos Avançados e Premium)

* **Autenticação Social Adicional:** Implementar login com Facebook e Instagram.
* **Gestão de Estoque:** Implementar a funcionalidade do plano Premium.
* **Teste de Tatuagem com Realidade Aumentada (AR/IA):** Desenvolver o recurso inovador.



----

# PC Studio App (Flutter Edition)

## 1. Visão Geral e Objetivo do Projeto

O **PC Studio App** é uma plataforma multiplataforma (Android, iOS, Web) desenvolvida em Flutter, projetada para conectar estúdios e artistas de tatuagem com clientes. O aplicativo serve como um diretório profissional, permitindo que artistas divulguem seus trabalhos e alcancem novos clientes, enquanto oferece aos usuários finais uma ferramenta para descobrir, contatar e agendar sessões com esses profissionais.

## 2. Estratégia de Monetização

O projeto utilizará um modelo de negócio "Freemium", gerando receita através de duas frentes principais:

* **Anúncios para Utilizadores Finais e Artistas Free:** Os clientes que utilizam o aplicativo para buscar artistas, bem como os artistas no plano gratuito, visualizarão anúncios em telas estratégicas.
* **Planos de Assinatura para Artistas/Estúdios:** Os profissionais terão diferentes níveis de planos, cada um liberando mais funcionalidades.

## 3. Arquitetura e Tecnologias (Pilha Tecnológica)

* **Framework:** Flutter
* **Linguagem:** Dart
* **IDE (Ambiente de Desenvolvimento):** Visual Studio Code
* **Backend como Serviço (BaaS):** Google Firebase
    * **Autenticação:** Firebase Authentication (E-mail/Senha, Google Sign-In).
    * **Banco de Dados:** Cloud Firestore (NoSQL).
    * **Armazenamento de Arquivos:** Cloud Storage (para imagens de perfil e portfólios).
    * **Notificações:** Firebase Cloud Messaging (FCM).

## 4. Roadmap do Projeto

### Versão 1.0 (MVP Funcional) - CONCLUÍDO

* **Fase 1: Fundação do Projeto:** Configuração do ambiente, criação do repositório e conexão com o Firebase.
* **Fase 2: UI Base e Navegação:** Estrutura de navegação principal com `BottomNavigationBar` e telas estáticas.
* **Fase 3: Autenticação de Utilizadores:** Fluxos completos de E-mail/Senha e Login com Google.
* **Fase 4: Perfis e Gestão de Artista (v1):** Fluxo de registo de estúdio, gestão de portfólio e definição de disponibilidade (dias e horas).
* **Fase 5: Sistema de Agendamento (v1):**
    * Cliente pode visualizar disponibilidade (calendário e horários).
    * Cliente pode solicitar um agendamento.
    * Artista pode visualizar, aprovar ou recusar solicitações pendentes.
    * Cliente pode visualizar os seus agendamentos confirmados.

---

### Versão 1.1 (Melhorias de Qualidade de Vida e UX) - EM ANDAMENTO

* **Gestão de Agendamentos (Lado do Cliente):**
    * [ ] Implementar funcionalidade para o cliente cancelar um agendamento, com um campo para justificar o motivo.
* **Notificações para o Artista:**
    * [ ] Exibir um popup ou um indicador visual na tela Home do artista quando existirem agendamentos pendentes.
* **Melhorias na Gestão do Artista:**
    * [ ] Tornar a gestão de disponibilidade mais interativa (ex: calendário visual em vez de checkboxes).
    * [ ] Permitir que artistas de planos pagos definam a duração de uma sessão (ex: 1 hora, 2 horas).
* **Melhorias na Experiência do Cliente:**
    * [ ] Permitir que o cliente selecione múltiplos horários consecutivos (para sessões mais longas).
    * [ ] Adicionar um popup na Home do cliente para lembretes de agendamentos próximos.
    * [ ] Tornar a tela de Perfil do utilizador mais rica (sugestões em aberto).

### Versão 2.0 (Monetização e Funcionalidades Avançadas) - A FAZER

* **Implementação de Anúncios:**
    * [ ] Integrar o Google AdMob para exibir anúncios para utilizadores e artistas do plano "Free".
* **Login Social Adicional:**
    * [ ] Implementar o Login com Facebook.
* **Funcionalidades Premium:**
    * [ ] Gestão de Estoque e Vendas de produtos.
    * [ ] Recurso de Teste de Tatuagem com Realidade Aumentada (AR).

    --- Nova atualização:

    ## 4. Roadmap do Projeto

### Versão 1.0 (MVP Funcional) - CONCLUÍDO

* **Fase 1: Fundação do Projeto**
* **Fase 2: UI Base e Navegação**
* **Fase 3: Autenticação de Utilizadores**
* **Fase 4: Perfis e Gestão de Artista (v1)**
* **Fase 5: Sistema de Agendamento (v1)**

---

### Versão 1.1 (Melhorias de Qualidade de Vida e UX) - EM ANDAMENTO

* **Sistema de Agendamento Avançado (v2):**
    * [ ] **Lado do Artista:** Permitir que o artista defina durações de sessão personalizadas com base no **tipo** e **tamanho** da tatuagem.
    * [ ] **Lado do Cliente:** Criar um fluxo onde o cliente primeiro seleciona o tipo/tamanho da tatuagem antes de ver o calendário com os horários correspondentes.
    * [ ] Permitir que o cliente selecione múltiplos horários consecutivos para sessões longas.
* **Gestão de Agendamentos (Lado do Cliente):**
    * [✓] Implementar funcionalidade para o cliente cancelar um agendamento.
* **Notificações para o Artista:**
    * [✓] Exibir um alerta visual na tela Home do artista sobre agendamentos pendentes.
* **Melhorias na Gestão do Artista:**
    * [ ] Tornar a gestão de disponibilidade mais interativa.

### Versão 2.0 (Monetização e Funcionalidades Futuras) - A FAZER

* **Implementação de Anúncios:**
    * [ ] Integrar o Google AdMob para utilizadores e artistas "Free".
* **Login Social Adicional:**
    * [ ] Implementar o Login com Facebook.
* **Melhorias na Experiência do Cliente:**
    * [ ] Adicionar um popup na Home do cliente para lembretes de agendamentos.
    * [ ] Tornar a tela de Perfil do utilizador mais rica.