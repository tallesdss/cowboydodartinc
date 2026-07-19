import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/dev_inspector/dev_inspector_info.dart';
import 'package:cowboydodartinc/core/icons/kasy_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DevInspectorPanel extends StatelessWidget {
  const DevInspectorPanel({
    super.key,
    required this.info,
    required this.onDismiss,
  });

  final DevInspectorInfo info;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHandle(),
              _buildHeader(context),
              if (info.ancestors.isNotEmpty) _buildAncestors(),
              if (info.properties.isNotEmpty) _buildProperties(),
              _buildActions(context),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x332196F3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF2196F3)),
            ),
            child: Text(
              info.widgetType,
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          KasyButton.iconOnly(
            icon: KasyIcons.close,
            variant: KasyButtonVariant.ghost,
            foregroundColor: Colors.white54,
            onPressed: onDismiss,
            semanticLabel: 'Fechar',
          ),
        ],
      ),
    );
  }

  Widget _buildAncestors() {
    final chain = [...info.ancestors.reversed, info.widgetType];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < chain.length; i++) ...[
              Text(
                chain[i],
                style: TextStyle(
                  color: i == chain.length - 1
                      ? Colors.white70
                      : Colors.white30,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              if (i < chain.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    KasyIcons.chevronRight,
                    color: Colors.white24,
                    size: 14,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProperties() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROPRIEDADES',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          for (final prop in info.properties)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                prop,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: KasyButton(
        label: 'Copiar contexto para IA',
        icon: KasyIcons.copy,
        expand: true,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        fontWeight: FontWeight.w600,
        size: KasyButtonSize.large,
        onPressed: () => _copyToClipboard(context),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: info.toAIClipboard()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contexto copiado! Cole no chat do Claude.'),
        backgroundColor: Color(0xFF2196F3),
        duration: Duration(seconds: 2),
      ),
    );
    onDismiss();
  }
}
