import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_icons.dart';
import '../../data/recipes.dart';
import '../../l10n/gen/app_localizations.dart';
import 'recipe_image.dart';

/// 17. Fiche recette : image, nutrition, ingrédients, ajout au journal.
class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _fav = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final r = ref.watch(recipeRepositoryProvider).byId(widget.id);
    final title = (r.detailTitle ?? r.name).of(locale);
    final difficulty = r.difficulty == Difficulty.easy ? l.recipeEasy : l.recipeMedium;
    final meta = '${r.time} · ${l.recipeServings(r.servings)} · $difficulty';
    final top = Tch.topInset(context) - 4;

    return Scaffold(
      backgroundColor: Tch.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SizedBox(height: 270, width: double.infinity, child: RecipeHero(recipe: r)),
                // Feuille arrondie qui recouvre le bas de l'image de 26 px.
                Positioned.fill(
                  top: 244,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Tch.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeSlideIn(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: Tch.style(24, weight: FontWeight.w700, height: 1.2)),
                                const SizedBox(height: 6),
                                Text(meta, style: Tch.style(14, color: Tch.textSecondary)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          FadeSlideIn(
                            index: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _Tile(
                                    value: '${r.detailKcal ?? r.kcal}',
                                    label: 'kcal',
                                    bg: Tch.surface,
                                    valueColor: Tch.text,
                                    labelColor: Tch.textSecondary,
                                    shadow: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _Tile(
                                    value: '${r.protein} g',
                                    label: l.journalProt,
                                    bg: Tch.greenLight,
                                    valueColor: Tch.greenDark,
                                    labelColor: const Color(0xFF3E4F43),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _Tile(
                                    value: '${r.carbs} g',
                                    label: l.journalCarbs,
                                    bg: Tch.yellow,
                                    valueColor: Tch.yellowText,
                                    labelColor: Tch.yellowText,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _Tile(
                                    value: '${r.fat} g',
                                    label: l.journalFat,
                                    bg: Tch.peachLight,
                                    valueColor: const Color(0xFF8A3A24),
                                    labelColor: const Color(0xFF8A3A24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          FadeSlideIn(
                            index: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.recipeIngredients,
                                    style: Tch.style(16, weight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                for (final i in r.ingredients)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(color: Tch.borderLight)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(i.name.of(locale),
                                                style: Tch.style(15))),
                                        Text(i.qty.of(locale),
                                            style: Tch.style(15, weight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: top,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundButton(
                        label: l.back,
                        onTap: () => context.go('/journal/recipes'),
                        child: const TchIcon(TchIcons.back,
                            size: 22, color: Tch.text, strokeWidth: 2.2),
                      ),
                      _RoundButton(
                        label: l.recipeFav,
                        onTap: () => setState(() => _fav = !_fav),
                        child: AnimatedSwitcher(
                          duration: Tch.selectDuration,
                          child: TchIcon(
                            TchIcons.heart,
                            key: ValueKey(_fav),
                            size: 22,
                            color: Tch.coral,
                            fill: _fav,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 14, 20, 14 + MediaQuery.of(context).padding.bottom.clamp(18, 40)),
            child: TchButton(
              label: l.recipeAdd,
              onPressed: () => context.go('/journal'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.label, required this.onTap, required this.child});
  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => PressScale(
        semanticLabel: label,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: child),
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.value,
    required this.label,
    required this.bg,
    required this.valueColor,
    required this.labelColor,
    this.shadow = false,
  });
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  final Color labelColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: shadow
              ? const [
                  BoxShadow(color: Color(0x0D2F3437), blurRadius: 10, offset: Offset(0, 2))
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(value, style: Tch.style(17, weight: FontWeight.w700, color: valueColor)),
            Text(label, style: Tch.style(11, color: labelColor)),
          ],
        ),
      );
}
