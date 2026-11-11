# Checklist das principais funcionalidades

Use este checklist para acompanhar a implementação e validar os fluxos essenciais da biblioteca digital.

## 1. Acesso e conta

- [ ] Criar conta e entrar com os métodos de autenticação habilitados.
- [ ] Recuperar a senha e apresentar mensagens claras para sucesso e erro.
- [ ] Encerrar a sessão e impedir acesso a páginas autenticadas após o logout.
- [ ] Carregar o perfil e as permissões do usuário a partir do backend.
- [ ] Restringir páginas e ações conforme o papel do usuário (Admin/Desenvolvedor ou Cliente).

## 2. Biblioteca de PDFs

- [ ] Listar PDFs e categorias com dados persistidos no backend.
- [ ] Buscar PDFs por título, autor, categoria, tema ou tag.
- [ ] Filtrar resultados por categoria/tema e apresentar estados de carregamento, vazio e erro.
- [ ] Abrir os detalhes de um PDF, incluindo descrição, autor, tags e avaliações.
- [ ] Ler o PDF no aplicativo e permitir navegação entre páginas e zoom.
- [ ] Baixar o arquivo e informar quando o download não puder ser concluído.
- [ ] Favoritar e remover dos favoritos, mantendo a seleção entre sessões.

## 3. Envio e gerenciamento de PDFs

- [ ] Enviar PDFs para o armazenamento e salvar os metadados associados no backend.
- [ ] Validar os campos obrigatórios, o formato e o tamanho do arquivo antes do envio.
- [ ] Associar cada envio ao usuário responsável e às categorias/tags selecionadas.
- [ ] Permitir que o autor edite ou remova seus próprios PDFs.
- [ ] Permitir que Admin/Desenvolvedor gerencie qualquer PDF.
- [ ] Exibir o resultado do envio e tratar falhas sem perder os dados já informados.

## 4. Comunidade e perfis

- [ ] Publicar comentários e avaliações em PDFs e exibir as contribuições existentes.
- [ ] Atualizar a média de avaliações sem duplicar ou perder avaliações.
- [ ] Listar perfis públicos de autores e abrir os PDFs publicados por cada pessoa.
- [ ] Exibir no perfil público estatísticas e informações disponíveis do autor.
- [ ] Exibir no perfil próprio os dados da conta, estatísticas e PDFs enviados.
- [ ] Permitir editar os dados pessoais autorizados e atualizar o perfil exibido.

## 5. Administração

- [ ] Exibir o painel administrativo somente para usuários autorizados.
- [ ] Consultar métricas da biblioteca e apresentar dados atualizados.
- [ ] Listar usuários e permitir as ações administrativas autorizadas, como alterar papel ou bloquear acesso.
- [ ] Criar, editar e remover categorias oficiais.
- [ ] Confirmar ações destrutivas e apresentar o resultado de cada operação.
- [ ] Aplicar as mesmas permissões no backend; ocultar um botão na interface não substitui autorização.

## 6. Backend, segurança e notificações

- [ ] Confirmar conexão e configuração do backend nos ambientes utilizados.
- [ ] Garantir persistência de usuários, PDFs, categorias, comentários, avaliações e favoritos.
- [ ] Aplicar regras de acesso ao banco e ao armazenamento por usuário e papel.
- [ ] Validar acesso negado para operações não autorizadas.
- [ ] Solicitar permissão para notificações quando necessário e permitir consultar notificações recebidas.
- [ ] Tratar indisponibilidade do backend, falta de conexão e respostas inválidas com mensagens claras.

## 7. Verificação antes de disponibilizar

- [ ] Percorrer os fluxos principais como Cliente e como Admin/Desenvolvedor.
- [ ] Testar cadastro, login, logout e recuperação de senha.
- [ ] Testar busca, filtros, leitura, download, favoritos, upload, comentários e avaliações.
- [ ] Testar permissões tentando acessar diretamente páginas e operações restritas.
- [ ] Verificar o layout e os fluxos em navegadores e tamanhos de tela suportados.
- [ ] Executar os testes automatizados e `flutter analyze` sem erros.
- [ ] Conferir configuração de produção, regras do backend e deploy das funções necessárias.

## Recursos complementares (quando habilitados)

- [ ] Validar assinaturas e compras, incluindo restauração e atualização do acesso.
- [ ] Validar recursos de IA, feedback, quadro Kanban e lembretes, caso façam parte do escopo ativo.
- [ ] Validar anúncios, notificações push e integrações de análise nos ambientes configurados.
