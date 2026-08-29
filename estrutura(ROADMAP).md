# Especificação do Sistema — Biblioteca Digital

## 1. Visão Geral

Sistema web para gerenciamento de uma biblioteca digital de PDFs, organizados por categorias, com controle de acesso por perfil de usuário (Desenvolvedor e Cliente) onde cada usuário possui seu próprio perfil, pode postar PDFs, comentar, ler, baixar e navegar pelos perfis dos demais usuários.

**Status:** Fase 1 e Fase 2 concluídas (Recursos de Comunidade, Perfis e Exploração por Temas).
**Próximo Passo:** Fases futuras a definir conforme evolução do projeto.

---

## 2. Perfis de Usuário

### 2.1 Administrador / Desenvolvedor
> **Decisão:** Admin e Desenvolvedor possuem as mesmas permissões (visão unificada). Ambos os papéis existem para fins de organização/nomenclatura, mas têm acesso total às mesmas funcionalidades.

- Define e gerencia os papéis (roles) dos usuários — quem é Admin, Desenvolvedor ou Cliente
- Cadastra, edita e remove usuários de qualquer perfil
- Cadastra, edita e remove categorias oficiais do sistema
- Faz upload, edição e remoção de qualquer PDF
- Acesso a configurações gerais do sistema
- Pode comentar/avaliar PDFs (assim como qualquer perfil)

### 2.2 Cliente / Usuário Comum
- Visualiza categorias e PDFs disponíveis
- Pode buscar/filtrar PDFs por categoria, título, tags ou temas
- Realiza download e/ou visualização online dos PDFs
- Pode comentar/avaliar PDFs
- **Faz upload de seus próprios PDFs** (associando a uma categoria e adicionando tags)
- Gerencia o próprio perfil (dados pessoais, avatar, e visualiza a lista de PDFs que ele mesmo enviou)
- **Navega e visita perfis** de outros usuários para ver os PDFs postados por eles

### 2.3 Hierarquia de Permissões (resumo)

| Ação | Admin / Desenvolvedor | Cliente |
|---|---|---|
| Definir papéis/roles de usuários | ✅ | ❌ |
| Gerenciar usuários (criar/editar/bloquear) | ✅ | ❌ |
| Gerenciar categorias oficiais | ✅ | ❌ |
| Upload/edição de PDFs próprios | ✅ | ✅ |
| Remover/editar PDFs de terceiros | ✅ | ❌ |
| Visualizar/baixar PDFs | ✅ | ✅ |
| Comentar/avaliar PDFs | ✅ | ✅ |
| Visualizar e navegar por perfis alheios | ✅ | ✅ |

## 3. Navegação e Fluxo

### 3.1 Login
- Tela de login usando backend Supabase/Firebase via MCP
- Após autenticar, navega para a **Home autenticada**

### 3.2 Seletor de Perfil (troca simples)
- Um seletor simples (ex: dropdown ou botão "trocar perfil") permite alternar entre Admin/Desenvolvedor e Cliente sem precisar deslogar
- A troca de perfil atualiza dinamicamente o menu lateral e as páginas disponíveis

### 3.3 Menu Lateral (Sidebar)
- Menu lateral fixo na Home autenticada, com itens de navegação que mudam conforme o perfil ativo:

| Perfil | Itens do menu lateral (sugestão) |
|---|---|
| Admin / Desenvolvedor | Biblioteca, Explorar Temas, Cadastrar PDF, Categorias (gerenciar), Perfis (Navegar), Usuários (gerenciar), Meu Perfil |
| Cliente | Biblioteca, Explorar Temas, Enviar PDF, Perfis (Navegar), Meus Favoritos, Meu Perfil |

---

## 4. Módulos e Funcionalidades Detalhadas

### 4.1 Funcionalidades Existentes (Fase 1)
- [x] Cadastro de categorias — conectado ao backend via MCP
- [x] Listagem de PDFs vinculados a uma ou mais categorias
- [x] Metadados do PDF integrados: título, descrição, autor, data de publicação, tags, thumbnail (capa)
- [x] Listagem de PDFs por categoria
- [x] Busca por nome/tag/categoria (filtro com suporte do backend)
- [x] Botão de marcação (favoritar/salvar PDF) — usuário marca PDFs de interesse para acesso rápido depois
- [x] Funções de biblioteca online: leitura/visualização do PDF direto no navegador (sem precisar baixar), navegação por páginas, zoom
- [x] Download do PDF
- [x] Tela de upload integrada ao backend via MCP (Admin/Desenvolvedor e Cliente)
- [x] Comentários e avaliações (nota/estrelas) por PDF — todos os perfis podem comentar/avaliar

### 4.2 Recursos Faltantes para Upgrade (Fase 2)

#### A. Upload de PDF por Qualquer Usuário (Clientes)
- Permitir que clientes enviem PDFs diretamente do botão "Enviar PDF" ou da tela "Meu Perfil".
- Os PDFs enviados por um cliente ficam associados ao seu nome de usuário como autor/criador.

#### B. Navegação de Perfis ("Explorar Criadores")
- Tela que lista todos os usuários/criadores cadastrados no backend.
- Permite clicar em qualquer usuário para acessar seu perfil público e ver todos os PDFs enviados por ele.

#### C. Tela de Perfil Público / Detalhe do Uploader
- Exibe o nome do usuário, avatar com inicial, estatísticas (quantidade de PDFs publicados, total de avaliações recebidas nos PDFs) e uma grade de PDFs publicados por ele.

#### D. Explorar PDFs por Temas (Aba Explorar Aprimorada)
- Visualização por categorias (Temas) em formato de carrossel ou tags rápidas.
- Seleção de temas para filtrar dinamicamente a busca.
- Busca unificada por Título, Tag, Categoria e Autor.

#### E. Tela "Meu Perfil"
- Página dedicada ao usuário logado, exibindo suas informações, avatar personalizável (simulado), estatísticas próprias e uma seção gerenciável com os PDFs que ele mesmo enviou (com opção de editar metadados ou excluir).

### 4.3 Estrutura de Dados (sugestão inicial)

```
Categoria
- id
- nome
- descricao
- criado_em

PDF
- id
- titulo
- descricao
- categoryIds [] (suporta múltiplas categorias/temas)
- autor (nome do uploader)
- arquivo_url
- thumbnail_url
- tags []
- criado_em
- criado_por (usuario_id)

Comentario
- id
- pdf_id
- usuario_id
- texto
- nota (1 a 5, opcional)
- criado_em

Marcacao (favorito)
- id
- pdf_id
- usuario_id
- criado_em

Usuario
- id
- nome
- email
- senha_hash
- perfil (enum: admin | desenvolvedor | cliente)
- avatar_url (opcional)
- bio (opcional)
- criado_em
```

---

## 5. Requisitos Técnicos

**Escopo:** projeto full-stack, com backend real integrado via MCP. Todos os dados (categorias, PDFs, usuários) serão persistidos no backend.

| Item | Decisão |
|---|---|
| Front-end | **Flutter Web** |
| Back-end | Integrado via MCP (Supabase/Firebase) |
| Banco de dados | Real (Postgres via Supabase ou Firestore via Firebase) |
| Armazenamento de arquivos (PDFs) | Storage do provedor de backend |
| Autenticação | Real via backend |
| Persistência de dados | Sim — dados reais persistidos no banco de dados do backend |

---

## 6. Roadmap Atualizado

**Fase 1 (Concluída):**
- [x] Biblioteca de PDFs com categorias básicas
- [x] Login conectado ao backend + Home autenticada
- [x] Menu lateral dinâmico por perfil (Admin vs Cliente)
- [x] Seletor de troca de perfil rápido
- [x] Comentários/avaliações iniciais em PDFs
- [x] Visualização direta de PDF no leitor simulado
- [x] Seção "Meus PDFs" na página de início (com os PDFs enviados pelos clientes)
- [x] Botão "Enviar PDF" na página de início que leva à tela de cadastro de PDF

**Fase 2 (Concluída):**
- [x] **Upload universal**: Permitir que o perfil Cliente/Usuário Comum também envie PDFs (associando ao seu perfil de uploader).
- [x] **Navegação de perfis**: Criar página para listar todos os usuários ativos/uploaders e permitir navegar por perfis.
- [x] **Perfis públicos de usuários**: Página do uploader visitado mostrando estatísticas (PDFs enviados, curtidas/avaliações) e a grade de PDFs publicados por ele.
- [x] **Exploração avançada por temas**: Refinar a aba "Explorar" com filtros visuais por temas (categorias) e tags de interesse.
- [x] **Meu Perfil**: Implementar a aba "Meu Perfil" do usuário logado atual, com listagem exclusiva de seus PDFs enviados e estatísticas.
- [x] **Persistência estendida**: Garantir persistência completa no backend para novos uploads, comentários e favoritos.

**Fase 3 (Faltante - Aperfeiçoamentos e Área Admin):**
- [x] **Painel de Dashboard (Admin)**: Tela de estatísticas gerais (total de PDFs, acessos, downloads e ranking de uploaders).
- [x] **Gerenciamento de Usuários (Admin)**: Tabela com bloqueio/desbloqueio e atribuição de papel (admin/user).
- [x] **Gerenciamento de Categorias (Admin)**: Interface (CRUD) para que o Admin crie, edite cor/ícone e remova categorias oficiais.
- [x] **Edição de Perfil Avançada**: Tela de configurações para o usuário alterar bio, e-mail e preferências (com persistência no mock).
- [x] **Central de Notificações**: Dropdown/Modal no cabeçalho alertando sobre novos comentários nos próprios PDFs ou novas avaliações.
- [x] **Busca Global Avançada**: Componente de barra de pesquisa na AppBar (Header) pesquisando simultaneamente em Autores, PDFs e Temas.
- [ ] **Widgets de Feedback Refinados**: Implementar componentes de Loading States (Skeletons) ao carregar PDFs e listas.
- [ ] **Refinamento Responsivo Mobile/Tablet**: Adaptar componentes como a grade de PDFs, barra lateral (Drawer vs Sidebar fixa) e leitor de PDF para telas menores.
- [ ] **Integração de Dark Mode**: Revisão dos tokens do Kasy Design System nas novas páginas para garantir legibilidade no tema escuro.

**Fases futuras:**
- A definir conforme novas necessidades.

---
