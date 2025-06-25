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

* **Fase 3: Autenticação de Usuários (PRÓXIMO PASSO)**
    * [ ] Implementação da tela de "Splash" para verificar o status de login.
    * [ ] Desenvolvimento do fluxo completo de autenticação com E-mail/Senha.
    * [ ] Implementação do fluxo de "Login com Google".
    * [ ] Criação da coleção `users` no Firestore.

* **Fase 4: Perfis e Gerenciamento do Artista**
    * [ ] Lógica na tela de Perfil para exibir botões de "Cadastrar Estúdio" ou "Gerenciar Perfil".
    * [ ] Desenvolvimento do fluxo de cadastro de estúdio (seleção de plano, formulário, upload de imagem).
    * [ ] Desenvolvimento da tela "Editar Perfil" para artistas.
    * [ ] Implementação da tela de gerenciamento de portfólio (adicionar/remover fotos).

* **Fase 5: Funcionalidades Centrais**
    * [ ] Exibição das listas de estilos e artistas com dados do Firestore.
    * [ ] Implementação da tela de detalhes do artista.
    * [ ] Desenvolvimento completo do sistema de agendamento (lado do artista e do cliente).

### Versão 2.0 (Recursos Avançados e Premium)

* **Gestão de Estoque:** Implementar a funcionalidade do plano Premium para que os estúdios possam gerenciar produtos (pomadas, vestuário, etc.).
* **Teste de Tatuagem com Realidade Aumentada (AR/IA):** Desenvolver o recurso inovador que permite aos usuários visualizar uma tatuagem em seu corpo usando a câmera do celular, como um "decalque digital".