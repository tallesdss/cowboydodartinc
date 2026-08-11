# Plano de Implementação de Backend (Firebase)

## 0. PREBACK (Ajustes Finais de Front-end)
*Antes de conectar o Firebase, é essencial finalizar as pendências do front-end (Fase 3 do Roadmap) para garantir que a interface esteja madura para lidar com dados assíncronos e latência de rede:*
- [x] **Skeletons / Loading States:** Implementar indicadores de carregamento visuais (Skeletons) nas listas e ao abrir o leitor de PDF (preparando para a latência real de internet).
- [x] **Refinamento Responsivo (Mobile/Tablet):** Ajustar o layout da grade de PDFs, o menu lateral (Drawer no mobile, Sidebar fixa no desktop) e o leitor de PDF para telas menores.
- [x] **Integração de Dark Mode:** Revisar e garantir a aplicação correta dos tokens do Kasy Design System para suportar leitura confortável no tema escuro.

## 1. Planejamento e Arquitetura
- [x] Definir a stack tecnológica do backend exclusivamente como **Firebase** (Firestore, Firebase Auth, Firebase Storage, Cloud Functions).
- [x] Mapear as entidades do modelo de dados para o modelo NoSQL do Firestore (Coleções e Subcoleções).
- [x] Definir regras de segurança (Firebase Security Rules) baseadas estritamente em 2 perfis: **Administrador** e **Cliente**.
  - **Administrador:** Acesso total (CRUD) a todas as coleções (usuários, categorias, PDFs, comentários). Possui acesso a dados analíticos do Dashboard.
  - **Cliente:** Pode explorar, ler e baixar PDFs, avaliar/comentar, e enviar seus próprios PDFs. Só pode gerenciar/excluir o seu próprio conteúdo e perfil.

## 2. Modelagem do Banco de Dados (Firestore NoSQL)
- [x] Criar o projeto no Firebase Console.
- [x] Criar a coleção `users` (id do documento = UID do Auth, nome, email, perfil [ENUM: admin, cliente], avatar_url, bio, criado_em).
- [x] Criar a coleção `categories` (id gerado, nome, descricao, icone_cor, criado_em).
- [x] Criar a coleção `pdfs` (id gerado, titulo, descricao, autor_id, arquivo_url, thumbnail_url, categoryIds [array], tags [array], criado_em).
- [x] Criar a coleção `comments` (id gerado, pdf_id, usuario_id, texto, nota, criado_em).
- [x] Criar a coleção `bookmarks` (id gerado, pdf_id, usuario_id, criado_em).

## 3. Autenticação e Autorização (Firebase Auth)
- [x] Configurar o Firebase Auth (Login por E-mail/Senha).
- [x] Implementar a separação dos dois papéis usando **Custom Claims** no token do Firebase Auth (ou, alternativamente, checando o campo `perfil` no documento da coleção `users`).
- [x] Configurar as **Firestore Security Rules**:
  - **Para Clientes:**
    - [x] Permitir `read` nas coleções `pdfs` e `categories` para qualquer usuário autenticado.
    - [x] Permitir `create` de novos `pdfs` forçando que o campo `autor_id` seja o `request.auth.uid`.
    - [x] Permitir `update` e `delete` de PDFs, Comentários e Dados Pessoais EXCLUSIVAMENTE se `request.auth.uid == resource.data.autor_id` (ou `usuario_id`).
  - **Para Administradores:**
    - [x] Permitir `read`, `create`, `update`, `delete` globalmente (bypass nas regras baseadas no *claim* de admin).
    - [x] Permitir gestão total sobre a coleção `categories` (criar e excluir categorias oficiais).

## 4. Configuração de Armazenamento (Firebase Storage)
- [x] Criar as pastas (paths) no Firebase Storage: `/pdfs`, `/avatars` e `/thumbnails`.
- [x] Configurar as **Firebase Storage Rules**:
  - [x] **Leitura:** Permitida para todos os usuários autenticados.
  - [x] **Escrita (Cliente):** Pode fazer upload, e só pode deletar arquivos localizados no caminho contendo o seu próprio UID (ex: `/pdfs/{uid}/{filename}`).
  - [x] **Escrita (Admin):** Pode gerenciar, excluir ou mover qualquer arquivo de qualquer usuário.

## 5. Lógica de Servidor (Firebase Cloud Functions)
- [x] Inicializar o ambiente Node.js/TypeScript para Firebase Functions.
- [x] Criar Cloud Functions globais (Acessíveis a todos):
  - [x] Função para busca avançada (caso necessário integrar com Algolia, ou realizar agregações).
  - [x] Triggers (gatilhos `onWrite`, `onCreate`) para atualizar dados desnormalizados (ex: calcular a avaliação média de um PDF e salvar no documento do PDF ao receber um novo `comment`).
- [x] Criar Cloud Functions restritas de **Administrador**:
  - [x] Atribuir Custom Claims (ex: promover um usuário a Admin).
  - [x] Obter métricas globais para o Dashboard (total de PDFs, downloads totais, ranking de uploaders) usando agregações ou contadores distribuídos no Firestore.
  - [x] Excluir fisicamente usuários no Firebase Auth.

## 6. Integração com o Front-end (Substituição de Mocks)
- [x] Adicionar as dependências (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions`) no `pubspec.yaml`.
- [x] **Desacoplar Mocks:** Substituir sistematicamente toda a camada de `api` mockada (`mock_..._api.dart`) por repositórios reais conectados ao Firebase. Toda geração de dados falsos locais na interface deve ser trocada por chamadas de rede.
- [x] Refatorar a interface para checar os Custom Claims do Firebase e exibir o menu de "Dashboard" e "Categorias" apenas se o usuário for *admin*.
- [x] Integrar a tela de envio de PDFs para realizar o upload via pacote `firebase_storage`, obter a URL final, e depois salvar o documento no Firestore.
- [x] Adaptar a UI do Kasy para reagir aos _streams_ do Firestore (realtime updates, se desejado).

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

## 9. Plano de Migração Técnica: Supabase ➔ Firebase no Código
- [x] **Ajuste de Dependências (`pubspec.yaml`):**
  - [x] Remover `supabase_flutter`.
  - [x] Garantir/Adicionar `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` e `cloud_functions`.
- [x] **Alterações na Inicialização (`lib/main.dart`):**
  - [x] Remover a inicialização do Supabase (`await Supabase.initialize(...)`).
  - [x] Garantir que o Firebase esteja inicializado corretamente para todas as plataformas.
- [x] **Migração da API de Autenticação (`lib/features/authentication/api/authentication_api.dart`):**
  - [x] Criar a classe `FirebaseAuthenticationApi` implementando `AuthenticationApi`.
  - [x] Substituir o provider `authenticationApiProvider` para injetar `FirebaseAuthenticationApi` com `FirebaseAuth.instance`.
  - [x] Implementar os métodos usando `FirebaseAuth` (`signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `signOut`, etc.).
  - [x] Tratar e mapear as exceções do Firebase Auth para que a UI continue exibindo erros amigáveis.
- [x] **Migração das APIs de Dados para Firestore/Firebase Storage:**
  - [x] **User API (`lib/core/data/api/user_api.dart`):** Substituir chamadas a `_client.from('users')` por consultas à coleção `'users'` no Firestore.
  - [x] **Storage API (`lib/core/data/api/storage_api.dart`):** Substituir envios e leituras de arquivos do Supabase Storage pelo Firebase Storage.
  - [x] **Stripe Backend API (`lib/features/subscriptions/api/stripe_backend_api.dart`):** Mudar invocação de Supabase Edge Functions para Firebase Cloud Functions.
- [x] **Atualização de Variáveis de Ambiente (`.env` e `app_env.dart`):**
  - [x] Remover chaves exclusivas do Supabase (`BACKEND_URL` e `SUPABASE_TOKEN`).
  - [x] Configurar e gerar os arquivos `firebase_options_dev.dart` (e prod) via FlutterFire CLI para não depender de chaves cruas no `.env`.

