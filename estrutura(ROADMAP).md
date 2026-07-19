# Roadmap de Desenvolvimento Frontend: Talles Engenharia de Software e Projetos

Este documento define o checklist detalhado para o desenvolvimento frontend da plataforma **Talles Engenharia de Software e Projetos**, utilizando a arquitetura do kit **Kasy** (Flutter, Riverpod, Slang i18n e GoRouter).

---

## 🎨 Fase 1: Identidade Visual e Configurações Globais (Rebranding & Setup)
*Alinhamento inicial do Kasy Design System para a identidade da Talles Engenharia.*

- [ ] **Configuração de Cores & Tema (`lib/core/theme/colors.dart`)**
  - [ ] Adaptar a paleta de cores primária para refletir engenharia e tecnologia (ex: tons de azul escuro tecnológico, cinza chumbo e detalhes em azul claro/ciano metálico como cor de destaque).
  - [ ] Ajustar tons de superfícies claras/escuras (`surface`, `surfaceSecondary`, `background`, `backgroundSecondary`).
- [ ] **Configuração Tipográfica (`lib/core/theme/type_scale.dart` e `texts.dart`)**
  - [ ] Validar e ajustar os pesos da fonte Poppins no ramp de visualização mobile, tablet e desktop.
  - [ ] Configurar os estilos semânticos (`pageTitle`, `sectionTitle`, `cardTitle`, `caption`) para garantir hierarquia limpa.
- [ ] **Atualização de Assets (`assets/branding/`)**
  - [ ] Substituir logotipos de demonstração pelos oficiais da Talles Engenharia (`logo-light.png`, `logo-dark.png`).
  - [ ] Gerar os ícones de launcher (`app-icon.png`) e favicon (`favicon.png`) para a plataforma web/mobile.
- [ ] **Estruturação de Idiomas / i18n (`lib/i18n/pt.i18n.json` e `en.i18n.json`)**
  - [ ] Adicionar namespace `talles_landing` para textos da Landing Page pública.
  - [ ] Adicionar namespace `talles_portal` para textos do painel restrito (administração, programadores, clientes e pendentes).
  - [ ] Executar o comando de compilação do Slang: `dart run slang` para atualizar `translations.g.dart`.

---

## 🌐 Fase 2: Landing Page Pública (Acesso Livre)
*Implementação do portal de entrada responsivo, contendo navegação em abas/seções de livre acesso.*

- [ ] **Estrutura de Rotas Públicas (`lib/router.dart` e `lib/core/bottom_menu/bottom_router.dart`)**
  - [ ] Definir `/` (Home/Landing Page) e suas sub-seções ou páginas de detalhe públicas.
  - [ ] Garantir suporte a links amigáveis e restauráveis (web URL routing).
- [ ] **Landing Page / Home Pública (`lib/features/home/`)**
  - [ ] Hero Section chamativa com proposta de valor da Talles Engenharia, vídeo/imagem abstrata ao fundo e botão de ação (CTA) para o portal do cliente.
  - [ ] Integrar micro-animações nas transições de seção.
- [ ] **Módulo de Projetos (Portfólio de Engenharia & Software)**
  - [ ] Grid de cards responsivos com imagens dos projetos realizados (usando `KasyCard` e `KasyNetworkImage`).
  - [ ] Filtro por categoria (ex: Engenharia Civil, Software Customizado, Consultoria de Projetos).
  - [ ] Tela de detalhe do projeto (página ou bottom sheet/diálogo dependendo da tela).
- [ ] **Módulo de Clientes (Parceiros e Depoimentos)**
  - [ ] Carrossel ou grade de logotipos de clientes parceiros.
  - [ ] Seção de depoimentos e histórias de sucesso (testemunhos reais de clientes).
- [ ] **Módulo de Notícias / Blog**
  - [ ] Feed de novidades e artigos sobre engenharia, arquitetura de software e gestão de projetos.
  - [ ] Visualização de artigo individual com suporte a layout de leitura focado (`kKasyContentMaxWidth` de 600px).
- [ ] **Módulo de Contato**
  - [ ] Formulário de captação de leads (`KasyTextField` variantes `primary` ou `flat`, `KasyTextArea`).
  - [ ] Botão de envio integrado com feedback visual de carregamento (`KasyButton(loading: ...)`).
  - [ ] Informações físicas: endereço com integração de link para mapa, e-mail direto, telefone e botão rápido de WhatsApp.
- [ ] **Módulo de Aulas (Conteúdo Educacional Livre)**
  - [ ] Área de visualização de aulas/palestras ministradas pela equipe Talles Engenharia.
  - [ ] Grid de vídeos didáticos (incorporados ou via players de vídeo integrados).

---

## 🔑 Fase 3: Autenticação, Perfis de Usuário, Fluxo de Aprovação & Guarda de Rotas
*Gerenciamento de acessos, cadastro livre com fluxo de aprovação obrigatório por parte do Administrador.*

- [ ] **Modelagem de Perfis e Status de Usuário (`lib/features/authentication/`)**
  - [ ] Criar enum `UserRole` para papéis do sistema: `none` (não definido), `client` (cliente), `programmer` (programador) e `admin` (administrador).
  - [ ] Criar enum `UserApprovalStatus` para controle do cadastro: `pending` (pendente aprovação) e `approved` (aprovado).
  - [ ] Integrar esses campos no modelo de usuário autenticado.
- [ ] **UI de Autenticação (`lib/features/authentication/ui/`)**
  - [ ] Cadastro livre no `signup_page.dart`: qualquer usuário pode se registrar com e-mail/senha. Por padrão, novas contas são criadas com `status: pending` e `role: none`.
  - [ ] Customizar a tela de login (`signin_page.dart`) com a marca Talles Engenharia.
- [ ] **Tela de Espera / Pendente de Aprovação (`pending_approval_page.dart`)**
  - [ ] Interface informativa exibida para usuários recém-cadastrados ou que estão com `status: pending`.
  - [ ] Mensagem explicando que o administrador precisa aprovar e atribuir o cargo antes que o acesso seja liberado.
  - [ ] Botão de logout rápido (`KasyButton`) caso queiram entrar com outra conta.
- [ ] **Configuração do Guard de Rotas baseado em Role (`lib/router.dart` - `_authRedirect`)**
  - [ ] Configurar lógica condicional de redirecionamento:
    * Se não logado ➔ Redireciona para `/signin`.
    * Se logado mas com status `pending` ➔ Redireciona obrigatoriamente para `/pending-approval` (bloqueia o resto do app).
    * Se logado e aprovado (`approved`):
      * Cargo **Admin** ➔ Redireciona para o portal geral `/admin`.
      * Cargo **Programador** ➔ Redireciona para o portal do desenvolvedor `/programmer`.
      * Cargo **Cliente** ➔ Redireciona para o painel do cliente `/client`.

---

## 💼 Fase 4: Portal Multicargos (Ambiente Fechado)
*Desenvolvimento das interfaces específicas para cada um dos 3 painéis de acesso.*

### 🖥️ A. Painel do Administrador (Visão Geral & Gestão Geral de Projetos)
*Acesso completo de controle sobre todos os recursos do sistema.*

- [ ] **Dashboard Consolidado (Geral)**
  - [ ] Métricas gerais em cards iluminados (`KasySpotlightCard`): faturamento mensal, total de projetos ativos, total de programadores alocados e pendências de clientes.
- [ ] **Tela de Aprovação e Gestão de Usuários (Cadastros Pendentes)**
  - [ ] **Listagem de Pendentes**: Lista de usuários com `status: pending` exibindo avatar e nome.
  - [ ] **Atribuição de Papel**: Componente de seleção (`KasyDropDown`) para o Admin selecionar o papel do usuário (`Cliente`, `Programador` ou `Admin`).
  - [ ] **Ação de Aprovação**: Botão de aprovação (`KasyButton`) que muda o status para `approved` e salva o papel selecionado no banco (de forma simulada).
  - [ ] **Confirmação**: Diálogo de confirmação (`showKasyConfirmDialog`) antes de salvar as alterações.
- [ ] **Módulo de Gestão de Clientes e Programadores Aprovados**
  - [ ] Listagem e busca de perfis de clientes e de programadores associados aos projetos.
  - [ ] Modal de cadastro de novos clientes ou atribuição de programador a um projeto.
- [ ] **Gestão Global de Projetos**
  - [ ] Criação de novos projetos com definição de escopo, prazo inicial, orçamento e contratos.
  - [ ] Painel para vincular clientes e programadores específicos a cada projeto.
- [ ] **Aprovação de Demandas e Contratos**
  - [ ] Fluxo para visualizar demandas enviadas por clientes, definir prioridade oficial e delegar para um programador específico.
  - [ ] Gerenciamento financeiro global (faturamento e recebíveis de todos os contratos).

---

### 💻 B. Painel do Programador (Desenvolvedores Integrados)
*Foco na execução do escopo técnico, movimentação de tarefas e entregas.*

- [ ] **Dashboard do Programador**
  - [ ] Lista de projetos em que está alocado e lista de tarefas/demandas urgentes sob sua responsabilidade.
- [ ] **Quadro de Tarefas Integrado (Kanban do Projeto)**
  - [ ] Reaproveitamento completo do `KanbanPage` (`lib/features/kanban/ui/kanban_page.dart`) para o programador:
    * Mover tarefas entre as colunas ("A Fazer", "Desenvolvimento", "Revisão/QA", "Concluído").
    * Drag and drop de tarefas adaptado para toques (mobile/tablet) e ponteiro (web/desktop).
- [ ] **Entrega de Demandas e Upload Técnico**
  - [ ] Fluxo de upload de arquivos de entrega (builds, manuais, zip com código, relatórios) diretamente na tarefa ou na biblioteca do projeto.
  - [ ] Campo de comentários na tarefa para notificar o cliente ou pedir esclarecimentos.

---

### 👤 C. Painel do Cliente (Acompanhamento & Solicitações)
*Ambiente do cliente focado em visualizar o andamento, baixar arquivos entregues e abrir demandas.*

- [ ] **Dashboard do Cliente**
  - [ ] Visão resumida do andamento atual do projeto com barra de progresso visual (`KasyProgressBar`).
- [ ] **Módulo de Arquivos e Uploads (Biblioteca de PDFs)**
  - [ ] Histórico de arquivos enviados pela Talles Engenharia (relatórios, PDFs de plantas, manuais, executáveis).
  - [ ] Área de upload onde o próprio cliente pode anexar arquivos de briefing, documentos de contrato assinados ou referências visuais.
- [ ] **Acompanhamento do Andamento (Kanban & Timeline)**
  - [ ] Visualização simplificada da Timeline do projeto (etapas macro).
  - [ ] Visualização em modo leitura do quadro Kanban para acompanhar as tarefas que a equipe técnica está desenvolvendo em tempo real (sem permissão de arrastar ou alterar tarefas internas criadas pela engenharia).
- [ ] **Abertura de Demandas (Colocar Demandas)**
  - [ ] Interface para o cliente cadastrar novas demandas ou solicitações de alteração no projeto.
  - [ ] Formulário modal (`KasyBottomSheet` ou `KasyDialog`) utilizando:
    * `KasyTextField` para o título da solicitação.
    * `KasyTextArea` para descrição da demanda.
    * `KasySelectableChip` para o cliente apontar a urgência estimada.
    * `KasyDatePicker` para sugerir a data de necessidade.
    * Anexo de arquivos técnicos à demanda.
- [ ] **Módulo Financeiro & Contratos**
  - [ ] Visualização do status de faturamento do projeto (parcelas pagas, vencendo e recibos).
  - [ ] Aceite eletrônico de termos e novos contratos de projetos.

---

## ⚙️ Fase 5: Estado & Lógica do Frontend (Riverpod Providers & Mock Data)
*Controle de estado reativo segmentado por Role.*

- [ ] **Provider de Gerenciamento de Usuários (`userApprovalProvider`)**
  - [ ] StateNotifier para carregar usuários pendentes, atualizar seu cargo e efetivar aprovação/rejeição.
- [ ] **Adaptação do `kanbanProvider` para Múltiplas Roles**
  - [ ] Implementar lógicas condicionais no Notifier:
    * Clientes: Apenas leitura e criação de novas demandas (que entram na primeira coluna "A Fazer").
    * Programadores: Escrita completa (mover tarefas entre colunas e comentar).
    * Admins: Gestão completa (criar colunas, arquivar tarefas, reordenar).
- [ ] **Novos Providers de Gerenciamento**
  - [ ] `adminProjectsProvider`: Gerencia a lista global de projetos e alocação de usuários para o Admin.
  - [ ] `clientFilesProvider`: Controla o upload e a listagem de arquivos técnicos do projeto do cliente.
  - [ ] `clientFinancialProvider`: Controla parcelas e notas fiscais.

---

## 🛠️ Guia de Reaproveitamento de Componentes Kasy
*Componentes já presentes no projeto a serem obrigatoriamente utilizados para evitar reescrita:*

| Requisito / UI | Componente Kasy Existente | Caminho do Componente |
| :--- | :--- | :--- |
| **Páginas de Layout** | `KasyScreen` / `KasyAppBar` | `lib/components/kasy_screen.dart` |
| **Grid / Container de Itens** | `KasyCard` | `lib/components/kasy_card.dart` |
| **Destaque do Dashboard (Admin)**| `KasySpotlightCard` | `lib/components/kasy_spotlight_card.dart` |
| **Modais (Formulários/Uploads)**| `KasyBottomSheet` (mobile) / `KasyDialog` (desktop) | `lib/components/kasy_bottom_sheet.dart` / `kasy_dialog.dart` |
| **Envio de Arquivos / Ações** | `KasyButton` (com estados de `loading`) | `lib/components/kasy_button.dart` |
| **Campos de Formulário** | `KasyTextField` / `KasyTextArea` | `lib/components/kasy_text_field.dart` / `kasy_text_area.dart` |
| **Seleção de Cargo / Filtros** | `KasyDropDown` | `lib/components/kasy_drop_down.dart` |
| **Seleção de Prioridade** | `KasySelectableChip` | `lib/components/kasy_selectable_chip.dart` |
| **Seleção de Prazos** | `KasyDatePicker` | `lib/components/kasy_date_picker.dart` |
| **Carregamento de Upload** | `KasyProgressCircle` | `lib/components/kasy_progress_circle.dart` |
| **Progresso do Projeto** | `KasyProgressBar` | `lib/components/kasy_progress_bar.dart` |
| **Status (Faturas, Prazos)** | `KasyStatusTag` | `lib/components/kasy_status_tag.dart` |
| **Histórico de Demandas** | `KasyAccordion` | `lib/components/kasy_accordion.dart` |
| **Board de Andamento** | `KanbanPage` (reaproveitado) | `lib/features/kanban/ui/kanban_page.dart` |

---

## 🔎 Fase 6: Qualidade de Código & Verificação (QA)
- [ ] **Responsividade Multidispositivo**
  - [ ] Validar comportamento em telas Mobile (`small`), Tablet (`medium`) e Desktop (`large`/`xlarge`).
- [ ] **Validação de Primitivas de Design**
  - [ ] Executar o analisador de boas práticas visuais: `dart run tool/design_check.dart`.
- [ ] **Análise Estática do Flutter**
  - [ ] Rodar `flutter analyze` e garantir **zero warnings/errors** no console.
