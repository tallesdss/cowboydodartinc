import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/library/providers/library_providers.dart';
import 'package:cowboydodartinc/features/library/repositories/models/library_models.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PdfReaderPage extends ConsumerStatefulWidget {
  final String pdfId;

  const PdfReaderPage({super.key, required this.pdfId});

  @override
  ConsumerState<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends ConsumerState<PdfReaderPage> {
  int _currentPage = 1;
  final int _totalPages = 5;
  double _zoom = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _simulateLoading();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      _simulateLoading();
    }
  }

  void _zoomIn() {
    if (_zoom < 2.0) {
      setState(() {
        _zoom += 0.2;
      });
    }
  }

  void _zoomOut() {
    if (_zoom > 0.6) {
      setState(() {
        _zoom -= 0.2;
      });
    }
  }

  // Get simulated text content depending on page number and PDF
  String _getPageContent(String title, int page) {
    switch (page) {
      case 1:
        return '--- CAPÍTULO I: INTRODUÇÃO ---\n\n'
            'Bem-vindo ao material de estudo sobre "$title". '
            'Este documento serve como um guia abrangente projetado para cobrir conceitos fundamentais, '
            'melhores práticas e aplicações no mundo real.\n\n'
            'Ao longo deste curso, exploraremos os pilares teóricos e as etapas práticas para implementar '
            'essas metodologias com eficiência e alto padrão visual, seguindo as diretrizes do Kasy.';
      case 2:
        return '--- CAPÍTULO II: CONCEITOS BÁSICOS ---\n\n'
            'Para compreender "$title" a fundo, precisamos primeiro definir seus blocos de construção essenciais. '
            'Historicamente, as maiores dificuldades em projetos dessa natureza derivam de definições de escopo '
            'inadequadas e da falta de alinhamento entre as partes interessadas.\n\n'
            'Nesta página, abordamos como evitar essas armadilhas estruturando seus fluxos de trabalho e componentes '
            'visuais em camadas independentes e modulares.';
      case 3:
        return '--- CAPÍTULO III: APLICAÇÕES PRÁTICAS ---\n\n'
            'Agora que cobrimos os fundamentos de "$title", vamos analisar cenários de aplicação real. '
            'Considere um projeto com restrições severas de tempo e orçamento:\n\n'
            '1. Planejamento Baseado em Histórico: Utilize métricas reais de velocidade para estimar prazos.\n'
            '2. Prototipagem Rápida: Valide hipóteses de UX com testes de baixa fidelidade.\n'
            '3. Refatoração Incremental: Melhore a qualidade do código em pequenos ciclos seguros.';
      case 4:
        return '--- CAPÍTULO IV: AVALIAÇÃO DE RESULTADOS ---\n\n'
            'Como medimos o sucesso de uma iniciativa envolvendo "$title"? '
            'Indicadores de performance (KPIs) e feedback contínuo dos usuários são indispensáveis.\n\n'
            'A análise cuidadosa de dados quantitativos (tempo de carregamento, cliques) e qualitativos '
            '(entrevistas de usabilidade) nos permite iterar na direção certa, reduzindo desperdício e maximizando valor.';
      case 5:
        return '--- CONCLUSÃO & APÊNDICE ---\n\n'
            'Chegamos ao final deste material sobre "$title". '
            'Esperamos que estes capítulos tenham fornecido insights valiosos para seu crescimento profissional.\n\n'
            'Para referências adicionais, consulte a documentação oficial e os repositórios de exemplo sugeridos nas seções finais deste livro.\n\n'
            'Fim do documento.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfs = ref.watch(pdfsProvider).valueOrNull ?? [];
    final PdfDocument? pdf = pdfs.cast<PdfDocument?>().firstWhere((p) => p?.id == widget.pdfId, orElse: () => null);

    if (pdf == null) {
      return KasyScreen(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kasyAppBarPreferredHeight),
          child: KasyAppBar(
            title: 'Documento não encontrado',
          ),
        ),
        child: Center(
          child: KasyButton(
            label: 'Voltar',
            onPressed: () => context.pop(),
          ),
        ),
      );
    }

    final double viewportWidth = MediaQuery.of(context).size.width;
    final bool isMobile = viewportWidth < 768;
    final double baseWidth = isMobile ? (viewportWidth - KasySpacing.md * 2).clamp(280.0, 500.0) : 550.0;
    final double baseHeight = baseWidth * 1.35;

    return KasyScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kasyAppBarPreferredHeight),
        child: KasyAppBar(
          title: '${t.library.read_sim}: ${pdf.title}',
          onBack: () => context.pop(),
        ),
      ),
      scrollable: false, // We have custom nested scroll views for scaled document
      child: Column(
        children: [
          // Reader Controls Toolbar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KasySpacing.md,
              vertical: KasySpacing.xs,
            ),
            color: context.colors.surfaceSecondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    KasyChromeOrbIconButton(
                      icon: Icons.zoom_out,
                      iconSize: 20,
                      foregroundColor: context.colors.primary,
                      onPressed: _zoomOut,
                      tooltip: t.library.zoom_out,
                    ),
                    const SizedBox(width: KasySpacing.xs),
                    Text(
                      '${(_zoom * 100).toInt()}%',
                      style: context.kasyTextTheme.labelMedium,
                    ),
                    const SizedBox(width: KasySpacing.xs),
                    KasyChromeOrbIconButton(
                      icon: Icons.zoom_in,
                      iconSize: 20,
                      foregroundColor: context.colors.primary,
                      onPressed: _zoomIn,
                      tooltip: t.library.zoom_in,
                    ),
                  ],
                ),
                Row(
                  children: [
                    KasyChromeOrbIconButton(
                      icon: Icons.navigate_before,
                      iconSize: 20,
                      foregroundColor: _currentPage > 1 ? context.colors.primary : context.colors.muted,
                      onPressed: _currentPage > 1 ? _prevPage : () {},
                      tooltip: t.library.prev_page,
                    ),
                    const SizedBox(width: KasySpacing.xs),
                    Text(
                      t.library.page_info(page: _currentPage.toString(), total: _totalPages.toString()),
                      style: context.kasyTextTheme.labelMedium,
                    ),
                    const SizedBox(width: KasySpacing.xs),
                    KasyChromeOrbIconButton(
                      icon: Icons.navigate_next,
                      iconSize: 20,
                      foregroundColor: _currentPage < _totalPages ? context.colors.primary : context.colors.muted,
                      onPressed: _currentPage < _totalPages ? _nextPage : () {},
                      tooltip: t.library.next_page,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PDF Document Viewer Page
          Expanded(
            child: Container(
              color: context.colors.surfaceNeutralSoft,
              padding: const EdgeInsets.all(KasySpacing.lg),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _isLoading
                      ? _PdfReaderSkeleton(width: baseWidth, height: baseHeight)
                      : Transform.scale(
                          scale: _zoom,
                          child: SizedBox(
                            width: baseWidth,
                            height: baseHeight,
                            child: KasyCard(
                              padding: const EdgeInsets.all(KasySpacing.xl),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          pdf.title.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.kasyTextTheme.caption.copyWith(
                                            color: context.colors.muted,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: KasySpacing.xs),
                                      Text(
                                        'Pág. $_currentPage / $_totalPages',
                                        style: context.kasyTextTheme.caption.copyWith(
                                          color: context.colors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: KasySpacing.lg),
                                  Expanded(
                                    child: Text(
                                      _getPageContent(pdf.title, _currentPage),
                                      style: context.kasyTextTheme.bodyMedium.copyWith(
                                        fontSize: 14, // design-check: ignore
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfReaderSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const _PdfReaderSkeleton({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return KasySkeletonGroup(
      child: SizedBox(
        width: width,
        height: height,
        child: const KasyCard(
          padding: EdgeInsets.all(KasySpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  KasySkeleton(width: 120, height: 12),
                  KasySkeleton(width: 60, height: 12),
                ],
              ),
              Divider(height: KasySpacing.lg),
              SizedBox(height: KasySpacing.md),
              KasySkeleton(width: 200, height: 20),
              SizedBox(height: KasySpacing.lg),
              KasySkeleton(width: double.infinity, height: 14),
              SizedBox(height: KasySpacing.sm),
              KasySkeleton(width: double.infinity, height: 14),
              SizedBox(height: KasySpacing.sm),
              KasySkeleton(width: double.infinity, height: 14),
              SizedBox(height: KasySpacing.sm),
              KasySkeleton(width: 250, height: 14),
              SizedBox(height: KasySpacing.lg),
              KasySkeleton(width: double.infinity, height: 14),
              SizedBox(height: KasySpacing.sm),
              KasySkeleton(width: double.infinity, height: 14),
              SizedBox(height: KasySpacing.sm),
              KasySkeleton(width: 180, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

