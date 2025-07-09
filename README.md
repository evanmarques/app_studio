# PC Studio App (Flutter Edition)

## 1. Visão Geral e Objetivo do Projeto

O **PC Studio App** é uma plataforma multiplataforma (Android, iOS, Web) desenvolvida em Flutter, projetada para conectar estúdios e artistas de tatuagem com clientes. O aplicativo serve como um diretório profissional, permitindo que artistas divulguem seus trabalhos e alcancem novos clientes, enquanto oferece aos usuários finais uma ferramenta para descobrir, contatar e agendar sessões com esses profissionais.

## 2. Estratégia de Monetização

O projeto utilizará um modelo de negócio "Freemium", gerando receita através de duas frentes principais:

* **Anúncios:** Utilizadores finais e artistas no plano "Free" visualizarão anúncios (Google AdMob) em telas estratégicas.
* **Planos de Assinatura para Artistas/Estúdios:** Os profissionais terão diferentes níveis de planos, cada um liberando mais funcionalidades.

## 3. Arquitetura e Tecnologias

* **Framework:** Flutter
* **Linguagem:** Dart
* **IDE:** Visual Studio Code
* **Backend como Serviço (BaaS):** Google Firebase
    * **Autenticação:** Firebase Authentication (E-mail/Senha, Google Sign-In).
    * **Banco de Dados:** Cloud Firestore (NoSQL).
    * **Armazenamento de Arquivos:** Cloud Storage (Imagens de perfil e portfólios).
    * **Notificações:** Firebase Cloud Messaging (FCM).
* **Principais Pacotes:**
    * `google_mobile_ads` para anúncios.
    * `table_calendar` para o sistema de agendamento.
    * `font_awesome_flutter` para ícones sociais.
    * `image_picker` e `url_launcher`.

## 4. Roadmap do Projeto

### Funcionalidades Implementadas (Versão Atual)

#### Autenticação
* [✓] Fluxo completo de Registo e Login com E-mail/Senha.
* [✓] Fluxo completo de Login com Google.
* [✓] Gestão de estado de autenticação com `AuthGate`.
* [✓] Criação de documentos de utilizador no Firestore no primeiro login/registo.
* [✓] Captura e atualização de token FCM para notificações futuras.

#### Artistas e Perfis
* [✓] Artistas podem registar o seu estúdio através de um fluxo de seleção de planos.
* [✓] Artistas podem gerir o seu portfólio de imagens (adicionar/ver).
* [✓] Artistas podem gerir a sua disponibilidade geral (dias da semana, hora de início/fim).
* [✓] **Gestão de Serviços:** Artistas podem criar um menu de serviços, cada um com estilo, tamanho e duração em horas específica.
* [✓] A tela de detalhes do artista exibe todas as suas informações, portfólio e links sociais.

#### Clientes e Agendamento
* [✓] Clientes podem visualizar a lista de artistas e os seus perfis detalhados.
* [✓] **Sistema de Agendamento Avançado:**
    * O cliente primeiro seleciona o serviço desejado.
    * O calendário exibe apenas os dias de trabalho do artista.
    * Os horários disponíveis são gerados em blocos com a duração correta do serviço escolhido.
    * O cliente pode selecionar múltiplos blocos de horário consecutivos para sessões longas.
    * O agendamento é salvo no Firestore com o status "pending".
* [✓] **Visualização e Cancelamento:** O cliente pode ver a sua lista de agendamentos e cancelar os que estão confirmados.
* [✓] **Favoritos:** O cliente pode marcar artistas como favoritos na tela de detalhes.

#### Gestão e UX
* [✓] **Agenda do Artista:** A aba "Agenda" serve como um painel de controlo para o artista, com separadores para agendamentos "Pendentes", "Confirmados" e "Histórico". O artista pode aprovar ou recusar solicitações.
* [✓] **Notificação na Home:** A tela de início do artista exibe um alerta visual clicável para o notificar de solicitações pendentes.
* [✓] **Carrossel de Estilos:** A tela de início apresenta os estilos num carrossel moderno e de tamanho controlado.
* [✓] **Visualizador de Imagens:** As imagens do portfólio e do carrossel de estilos podem ser abertas em tela cheia com zoom.
* [✓] **Monetização (Base):** O SDK de anúncios está integrado e um banner é exibido condicionalmente na tela de início.

---

### Próximos Passos (Roadmap Futuro)

* **Monetização (Expansão):**
    * [ ] Implementar a exibição de anúncios em outras telas para utilizadores e artistas "Free" (ex: Tela de Artistas, Detalhes do Artista).
* **Melhorias na Experiência do Cliente:**
    * [ ] Exibir a lista de "Artistas Favoritos" na tela de Perfil do utilizador.
    * [ ] Adicionar um alerta na Home do cliente para lembretes de agendamentos próximos.
* **Melhorias na Gestão do Artista:**
    * [ ] Tornar a gestão de disponibilidade no painel mais interativa (ex: um calendário visual).
* **Autenticação Social Adicional:**
    * [ ] Implementar o Login com Facebook (quando a conta do programador estiver pronta).
* **Funcionalidades Premium:**
    * [ ] Desenvolver a gestão de estoque e vendas de produtos.
    * [ ] Investigar e desenvolver o recurso de teste de tatuagem com Realidade Aumentada (AR).