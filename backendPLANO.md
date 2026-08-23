# Plano de Ação Passo a Passo: Configuração do Backend e Funções no Firebase

Este guia transforma o planejamento em etapas sequenciais e acionáveis para a construção e integração do backend usando exclusivamente o Firebase.

## Etapa 1: Preparação e Inicialização do Projeto
**Objetivo:** Ter o ambiente do Firebase conectado ao projeto Flutter.
- [x] **Criar os Projetos no Firebase Console:** Projeto `cowboydodartinc-r162vk` já criado.
- [x] **Configuração via FlutterFire CLI:** O projeto já foi conectado (`firebase_options.dart` gerado).
- [x] **Ajuste de Dependências (`pubspec.yaml`):** Dependências base garantidas e antigas removidas.
- [x] **Inicialização no `main.dart`:** O `Firebase.initializeApp()` já está configurado.

## Etapa 2: Autenticação (Firebase Auth)
**Objetivo:** Permitir login e controle de papéis (Admin vs Cliente).
- [x] **Ativar Métodos de Login:** Ação manual necessária (Ativar E-mail/Senha no console do Firebase).
- [x] **Implementar `FirebaseAuthenticationApi`:** Já implementado utilizando `FirebaseAuth.instance` e injetado via Riverpod.
- [x] **Definir Perfis (Custom Claims vs Coleção):** Já definido via o campo `role` na coleção `users` do Firestore.

## Etapa 3: Modelagem e Segurança do Banco de Dados (Firestore)
**Objetivo:** Estruturar as tabelas (coleções) e proteger quem pode ler/escrever.
- [x] **Criar Coleções Base (Modelagem):**
  - `users`: id (UID), nome, email, perfil, avatar_url.
  - `categories`: id, nome, descricao, icone_cor.
  - `pdfs`: id, titulo, descricao, autor_id, arquivo_url, categoryIds, tags.
  - `comments`: id, pdf_id, usuario_id, texto, nota.
  - `bookmarks`: id, pdf_id, usuario_id.
- [x] **Aplicar Firebase Security Rules (Firestore):**
  - **Admins:** Acesso total leitura e escrita (bypass global).
  - **Clientes:** Leitura pública em `pdfs` e `categories`; Escrita/Edição em `pdfs`, `comments` e `users` apenas se `request.auth.uid == resource.data.autor_id`. Impedir clientes de gerenciar categorias oficiais.

## Etapa 4: Armazenamento de Arquivos (Firebase Storage)
**Objetivo:** Permitir o upload seguro de PDFs e Avatares.
- [x] **Configurar as Pastas no Storage:** Padronizar caminhos: `/pdfs/{uid}/`, `/avatars/{uid}/`.
- [x] **Aplicar Firebase Storage Rules:**
  - **Leitura:** Permitida para todos.
  - **Escrita (Cliente):** Somente no seu próprio diretório, validando pelo UID no caminho.
  - **Escrita (Admin):** Acesso global de deleção e modificação.
- [x] **Implementar o Upload no App:** Integrar pacote `firebase_storage` nas lógicas de envio (repositório), obtendo o link final antes de salvar no Firestore.

## Etapa 5: Lógica de Servidor (Firebase Cloud Functions)
**Objetivo:** Automatizar regras de negócio e ações privilegiadas.
- [x] **Inicializar o Ambiente Functions:** Rodar `firebase init functions` na raiz do projeto (TypeScript/Node).
- [x] **Criar Funções de Triggers (Automação):** `onWrite`/`onCreate` em `comments` para recalcular a nota média de um PDF automaticamente.
- [x] **Criar Funções Restritas (Acesso Admin):** Promover usuário a Admin, obter métricas pesadas do Dashboard, deletar conta permanentemente (GDPR).
- [ ] **Deploy das Funções:** Rodar `firebase deploy --only functions`.

 Etapa 6:## Integração Final e Remoção Completa de Mocks
**Objetivo:** Conectar o Flutter integralmente aos novos serviços e limpar arquivos falsos.
- [ ] **REMOVER TODOS OS DADOS MOCKADOS:** É expressamente necessário excluir ou limpar completamente qualquer código de geração de dados falsos locais e arquivos de mock da interface (ex: `mock_..._api.dart`), substituindo 100% pelas chamadas que trazem dados reais do Firebase Firestore.
- [ ] **Ajustar UI para Dados Reais e Streams:** Atualizar as listagens para consumir os dados provindos do backend real, usando paginação e reatividade onde necessário.
- [ ] **Proteção de Rotas e Telas no App:** Limitar exibição dos itens "Dashboard" e gestão de categorias apenas para contas reais mapeadas como Admin no banco.

## Etapa 7: Validação e Deploy
**Objetivo:** Testar a segurança e lançar.
- [ ] **Teste e Validação de Fluxos:** Testar ciclo do Cliente e do Admin. Validar segurança garantindo `Permission Denied` em casos proibidos.
- [ ] **Popular Dados Iniciais (Seeding):** Executar um script Node.js para criar as primeiras categorias e a 1ª conta Admin no ambiente de produção.
- [ ] **Deploy Final de Regras:** Rodar `firebase deploy --only firestore:rules,storage`.
- [ ] **Monitoramento:** Verificar as requisições no painel Firebase e monitorar a latência real.

