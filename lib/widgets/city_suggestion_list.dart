import 'package:flutter/material.dart';
import '../models/city_suggestion.dart';
import '../theme/app_theme.dart';

/// Daftar saran kota (autocomplete) yang muncul di bawah kolom pencarian.
class CitySuggestionList extends StatelessWidget {
  final String query;
  final List<CitySuggestion> suggestions;
  final bool isLoading;
  final bool noResult;
  final ValueChanged<CitySuggestion> onSelected;

  const CitySuggestionList({
    super.key,
    required this.query,
    required this.suggestions,
    required this.isLoading,
    required this.noResult,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final visible = isLoading || suggestions.isNotEmpty || noResult;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
                boxShadow: [
                  BoxShadow(color: c.shadow, blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildContent(context, c),
            ),
    );
  }

  Widget _buildContent(BuildContext context, AppColors c) {
    if (isLoading && suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
            ),
            const SizedBox(width: 12),
            Text('Mencari kota...', style: TextStyle(fontSize: 13, color: c.textMuted)),
          ],
        ),
      );
    }

    if (noResult) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.location_off_rounded, size: 18, color: c.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tidak ada kota yang cocok dengan "$query"',
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < suggestions.length; i++) ...[
              if (i > 0) Divider(height: 1, color: c.border, indent: 56),
              _SuggestionTile(
                suggestion: suggestions[i],
                query: query,
                onTap: () => onSelected(suggestions[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final CitySuggestion suggestion;
  final String query;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.suggestion,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(suggestion.flag, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlightedName(c),
                  if (suggestion.subtitle.isNotEmpty)
                    Text(
                      suggestion.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: c.textMuted),
                    ),
                ],
              ),
            ),
            Icon(Icons.north_west_rounded, size: 16, color: c.textMuted),
          ],
        ),
      ),
    );
  }

  /// Menebalkan bagian nama kota yang cocok dengan teks yang diketik.
  Widget _highlightedName(AppColors c) {
    final name = suggestion.name;
    final idx = name.toLowerCase().indexOf(query.toLowerCase());
    final base = TextStyle(fontSize: 14, color: c.textSecondary);
    final bold = TextStyle(fontSize: 14, color: c.textPrimary, fontWeight: FontWeight.w800);

    if (query.isEmpty || idx < 0) {
      return Text(name, style: bold, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: name.substring(0, idx)),
          TextSpan(text: name.substring(idx, idx + query.length), style: bold.copyWith(color: c.accent)),
          TextSpan(text: name.substring(idx + query.length)),
        ],
      ),
    );
  }
}
