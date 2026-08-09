# Plano de Implementação de Backend (Firebase)

## 0. PREBACK (Ajustes Finais de Front-end)
*Antes de conectar o Firebase, é essencial finalizar as pendências do front-end (Fase 3 do Roadmap) para garantir que a interface esteja madura para lidar com dados assíncronos e latência de rede:*
- [ ] **Skeletons / Loading States:** Implementar indicadores de carregamento visuais (Skeletons) nas listas e ao abrir o leitor de PDF (preparando para a latência real de internet).
- [ ] **Refinamento Responsivo (Mobile/Tablet):** Ajustar o layout da grade de PDFs, o menu lateral (Drawer no mobile, Sidebar fixa no desktop) e o leitor de PDF para telas menores.
- [ ] **Integração de Dark Mode:** Revisar e garantir a aplicação correta dos tokens do Kasy Design System para suportar leitura confortável no tema escuro.

## 1. Planejamento e Arquitetura
- [ ] Definir a stack tecnológica do backend exclusivamente como **Firebase** (Firestore, Firebase Auth, Firebase Storage, Cloud Functions).
- [ ] Mapear as entidades do modelo de dados para o modelo NoSQL do Firestore (Coleções e Subcoleções).
- [ ] Definir regras de segurança (Firebase Security Rules) baseadas estritamente em 2 perfis: **Administrador** e **Cliente**.
  - **Administrador:** Acesso total (CRUD) a todas as coleções (usuários, categorias, PDFs, comentários). Possui acesso a dados analíticos do Dashboard.
  - **Cliente:** Pode explorar, ler e baixar PDFs, avaliar/comentar, e enviar seus próprios PDFs. Só pode gerenciar/excluir o seu próprio conteúdo e perfil.

## 2. Modelagem do Banco de Dados (Firestore NoSQL)
- [ ] Criar o projeto no Firebase Console.
- [ ] Criar a coleção `users` (id do documento = UID do Auth, nome, email, perfil [ENUM: admin, cliente], avatar_url, bio, criado_em).
- [ ] Criar a coleção `categories` (id gerado, nome, descricao, icone_cor, criado_em).
- [ ] Criar a coleção `pdfs` (id gerado, titulo, descricao, autor_id, arquivo_url, thumbnail_url, categoryIds [array], tags [array], criado_em).
- [ ] Criar a coleção `comments` (id gerado, pdf_id, usuario_id, texto, nota, criado_em).
- [ ] Criar a coleção `bookmarks` (id gerado, pdf_id, usuario_id, criado_em).

## 3. Autenticação e Autorização (Firebase Auth)
- [ ] Configurar o Firebase Auth (Login por E-mail/Senha).
- [ ] Implementar a separação dos dois papéis usando **Custom Claims** no token do Firebase Auth (ou, alternativamente, checando o campo `perfil` no documento da coleção `users`).
- [ ] Configurar as **Firestore Security Rules**:
  - **Para Clientes:**
    - [ ] Permitir `read` nas coleções `pdfs` e `categories` para qualquer usuário autenticado.
    - [ ] Permitir `create` de novos `pdfs` forçando que o campo `autor_id` seja o `request.auth.uid`.
    - [ ] Permitir `update` e `delete` de PDFs, Comentários e Dados Pessoais EXCLUSIVAMENTE se `request.auth.uid == resource.data.autor_id` (ou `usuario_id`).
  - **Para Administradores:**
    - [ ] Permitir `read`, `create`, `update`, `delete` globalmente (bypass nas regras baseadas no *claim* de admin).
    - [ ] Permitir gestão total sobre a coleção `categories` (criar e excluir categorias oficiais).

## 4. Configuração de Armazenamento (Firebase Storage)
- [ ] Criar as pastas (paths) no Firebase Storage: `/pdfs`, `/avatars` e `/thumbnails`.
- [ ] Configurar as **Firebase Storage Rules**:
  - [ ] **Leitura:** Permitida para todos os usuários autenticados.
  - [ ] **Escrita (Cliente):** Pode fazer upload, e só pode deletar arquivos localizados no caminho contendo o seu próprio UID (ex: `/pdfs/{uid}/{filename}`).
  - [ ] **Escrita (Admin):** Pode gerenciar, excluir ou mover qualquer arquivo de qualquer usuário.

## 5. Lógica de Servidor (Firebase Cloud Functions)
- [ ] Inicializar o ambiente Node.js/TypeScript para Firebase Functions.
- [ ] Criar Cloud Functions globais (Acessíveis a todos):
  - [ ] Função para busca avançada (caso necessário integrar com Algolia, ou realizar agregações).
  - [ ] Triggers (gatilhos `onWrite`, `onCreate`) para atualizar dados desnormalizados (ex: calcular a avaliação média de um PDF e salvar no documento do PDF ao receber um novo `comment`).
- [ ] Criar Cloud Functions restritas de **Administrador**:
  - [ ] Atribuir Custom Claims (ex: promover um usuário a Admin).
  - [ ] Obter métricas globais para o Dashboard (total de PDFs, downloads totais, ranking de uploaders) usando agregações ou contadores distribuídos no Firestore.
  - [ ] Excluir fisicamente usuários no Firebase Auth.

## 6. Integração com o Front-end (Substituição de Mocks)
- [ ] Adicionar as dependências (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions`) no `pubspec.yaml`.
- [ ] **Desacoplar Mocks:** Substituir sistematicamente toda a camada de `api` mockada (`mock_..._api.dart`) por repositórios reais conectados ao Firebase. Toda geração de dados falsos locais na interface deve ser trocada por chamadas de rede.
- [ ] Refatorar a interface para checar os Custom Claims do Firebase e exibir o menu de "Dashboard" e "Categorias" apenas se o usuário for *admin*.
- [ ] Integrar a tela de envio de PDFs para realizar o upload via pacote `firebase_storage`, obter a URL final, e depois salvar o documento no Firestore.
- [ ] Adaptar a UI do Kasy para reagir aos _streams_ do Firestore (realtime updates, se desejado).

## 7. Validação, Testes e Segurança
- [ ] Fluxo Cliente: Testar o Auth, upload de arquivo (Storage) + criação de documento (Firestore), edição de seus dados, e comentar.
- [ ] Fluxo Admin: Testar promoção via function, deleção de um PDF de terceiro, e CRUD de categorias.
- [ ] Validação das Security Rules usando o *Firebase Emulator Suite*:
  - [ ] Tentar gravar uma categoria oficial como Cliente (deve falhar - Permission Denied).
  - [ ] Tentar excluir um PDF alheio logado como Cliente (deve falhar - Permission Denied).
- [ ] Testar cursores de paginação (`startAfterDocument`) no Firestore para garantir performance em listas grandes.

## 8. Deploy e Migração Final
- [ ] Criar dois projetos no Firebase (um para Staging/Testes e outro para Production).
- [ ] **Geração de Dados de Exemplo (Seeding):** Criar e rodar um script Node.js (com Firebase Admin SDK) para popular o banco em Produção/Staging com dados de exemplo reais (Categorias iniciais, alguns PDFs públicos de demonstração, comentários de teste e a 1ª conta de Administrador). Isso garantirá que o sistema não fique vazio e possa ser visto e analisado imediatamente.
- [ ] Remover permanentemente todo o código dos Mock Repositories e arquivos JSON locais do projeto Flutter.
- [ ] Configurar CI/CD ou Deploy via Firebase Hosting e Firebase CLI.
- [ ] Lançamento oficial e monitoramento via Firebase Crashlytics / Analytics.
