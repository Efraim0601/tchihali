import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_chip.dart';
import '../../data/recipes.dart';
import '../../l10n/gen/app_localizations.dart';
import 'recipe_image.dart';

/// 16. Recettes : puces de filtre et grille de 2 colonnes.
class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final filters = [l.recipesAll, l.recipesSlim, l.recipesDiabetes, l.recipesVeg];
    final list = ref
        .watch(recipeRepositoryProvider)
        .all()
        .where((r) => _filter == 0 || r.tags.contains(_filter))
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          Tch.pagePadding, Tch.topInset(context), Tch.pagePadding, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                TchBackButton(onTap: () => context.go('/journal')),
                const SizedBox(width: 12),
                Text(l.recipesTitle, style: Tch.style(24, weight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            index: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (var i = 0; i < filters.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    TchChip(
                      label: filters[i],
                      selected: i == _filter,
                      onTap: () => setState(() => _filter = i),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < list.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FadeSlideIn(
                      key: ValueKey(list[i].id),
                      index: 2 + i,
                      child: _RecipeCard(recipe: list[i], locale: locale),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < list.length
                        ? FadeSlideIn(
                            key: ValueKey(list[i + 1].id),
                            index: 3 + i,
                            child: _RecipeCard(recipe: list[i + 1], locale: locale),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.locale});
  final Recipe recipe;
  final String locale;

  @override
  Widget build(BuildContext context) => PressScale(
        onTap: () => context.go('/journal/recipes/${recipe.id}'),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Tch.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Color(0x0F2F3437), blurRadius: 16, offset: Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 124,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: recipe.tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: RecipePlate(recipe: recipe),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name.of(locale),
                        style: Tch.style(14, weight: FontWeight.w600, height: 1.3)),
                    const SizedBox(height: 4),
                    Text('${recipe.kcal} kcal · ${recipe.time}',
                        style: Tch.style(12, color: Tch.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
