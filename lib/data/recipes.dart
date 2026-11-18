import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'models.dart';

enum Difficulty { easy, medium }

class Ingredient {
  const Ingredient(this.name, this.qty);
  final LText name;
  final LText qty;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.kcal,
    required this.time,
    required this.tags,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.tint,
    required this.servings,
    required this.difficulty,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    this.detailTitle,
    this.detailKcal,
  });
  final String id;
  final LText name;
  final int kcal;
  final String time;

  /// Filtres : 1 = Minceur, 2 = Diabète, 3 = Végétarien (0 = Toutes).
  final List<int> tags;
  final Color c1, c2, c3, tint;
  final int servings;
  final Difficulty difficulty;
  final int protein, carbs, fat;
  final List<Ingredient> ingredients;

  /// La fiche de la maquette a un titre et des kcal légèrement différents de la liste.
  final LText? detailTitle;
  final int? detailKcal;
}

/// Recettes. Le backend viendra plus tard derrière cette interface.
abstract class RecipeRepository {
  List<Recipe> all();
  Recipe byId(String id);
}

class MockRecipeRepository implements RecipeRepository {
  static LText _s(String v) => LText(v, v);

  static final _items = <Recipe>[
    Recipe(
      id: 'ndole',
      name: const LText('Ndolé léger', 'Light ndolé'),
      detailTitle: const LText('Ndolé léger aux crevettes', 'Light ndolé with prawns'),
      kcal: 450,
      detailKcal: 420,
      time: '50 min',
      tags: const [2],
      c1: const Color(0xFF4E7A3A),
      c2: const Color(0xFFE6C79C),
      c3: const Color(0xFF5F7E2C),
      tint: const Color(0xFFE7EFE4),
      servings: 4,
      difficulty: Difficulty.easy,
      protein: 34,
      carbs: 28,
      fat: 16,
      ingredients: [
        Ingredient(const LText('Feuilles de ndolé', 'Ndolé leaves'), _s('500 g')),
        Ingredient(const LText('Crevettes', 'Prawns'), _s('300 g')),
        Ingredient(const LText('Arachides', 'Peanuts'), _s('100 g')),
        Ingredient(const LText('Huile', 'Oil'), const LText('1 c. à soupe', '1 tbsp')),
      ],
    ),
    Recipe(
      id: 'poisson',
      name: const LText('Poisson braisé & miondo', 'Grilled fish & miondo'),
      kcal: 540,
      time: '30 min',
      tags: const [1],
      c1: const Color(0xFFF3E3B8),
      c2: const Color(0xFFC97B4E),
      c3: const Color(0xFF8FB394),
      tint: const Color(0xFFFCE9E0),
      servings: 2,
      difficulty: Difficulty.easy,
      protein: 32,
      carbs: 68,
      fat: 14,
      ingredients: [
        Ingredient(const LText('Poisson (bar)', 'Fish (sea bass)'), _s('600 g')),
        Ingredient(const LText('Miondo', 'Miondo'), const LText('4 bâtons', '4 sticks')),
        Ingredient(const LText('Tomates', 'Tomatoes'), _s('2')),
        Ingredient(const LText('Citron', 'Lemon'), _s('1')),
      ],
    ),
    Recipe(
      id: 'salade',
      name: const LText('Salade avocat-mangue', 'Avocado-mango salad'),
      kcal: 380,
      time: '15 min',
      tags: const [1, 3],
      c1: const Color(0xFFA9C77A),
      c2: const Color(0xFFF2B544),
      c3: const Color(0xFF8E5A3C),
      tint: const Color(0xFFFBF0C9),
      servings: 2,
      difficulty: Difficulty.easy,
      protein: 8,
      carbs: 34,
      fat: 22,
      ingredients: [
        Ingredient(const LText('Avocat', 'Avocado'), _s('1')),
        Ingredient(const LText('Mangue', 'Mango'), _s('1')),
        Ingredient(const LText('Citron vert', 'Lime'), _s('1')),
        Ingredient(const LText('Huile', 'Oil'), const LText('1 c. à café', '1 tsp')),
      ],
    ),
    Recipe(
      id: 'poulet-dg',
      name: const LText('Poulet DG allégé', 'Lighter chicken DG'),
      kcal: 480,
      time: '1 h',
      tags: const [2],
      c1: const Color(0xFFD98B4B),
      c2: const Color(0xFFE9B949),
      c3: const Color(0xFF8FB394),
      tint: const Color(0xFFE3E8EE),
      servings: 4,
      difficulty: Difficulty.medium,
      protein: 36,
      carbs: 30,
      fat: 20,
      ingredients: [
        Ingredient(const LText('Poulet', 'Chicken'), _s('800 g')),
        Ingredient(const LText('Plantains mûrs', 'Ripe plantains'), _s('3')),
        Ingredient(const LText('Carottes', 'Carrots'), _s('2')),
        Ingredient(const LText('Haricots verts', 'Green beans'), _s('200 g')),
      ],
    ),
    Recipe(
      id: 'bouillie',
      name: const LText('Bouillie de maïs', 'Corn porridge'),
      kcal: 260,
      time: '20 min',
      tags: const [2, 3],
      c1: const Color(0xFFE8D3A6),
      c2: const Color(0xFFF3E3B8),
      c3: const Color(0xFFC97B4E),
      tint: const Color(0xFFF3EDE3),
      servings: 2,
      difficulty: Difficulty.easy,
      protein: 6,
      carbs: 48,
      fat: 4,
      ingredients: [
        Ingredient(const LText('Farine de maïs', 'Corn flour'), _s('80 g')),
        Ingredient(const LText('Eau', 'Water'), _s('500 ml')),
        Ingredient(const LText('Citron', 'Lemon'), const LText('1/2', '1/2')),
        Ingredient(const LText('Arachides', 'Peanuts'), _s('20 g')),
      ],
    ),
    Recipe(
      id: 'koki',
      name: const LText('Koki de haricots', 'Bean koki'),
      kcal: 390,
      time: '1 h 30',
      tags: const [1, 3],
      c1: const Color(0xFFE9B949),
      c2: const Color(0xFFC2623F),
      c3: const Color(0xFF4E7A3A),
      tint: const Color(0xFFE7EFE4),
      servings: 4,
      difficulty: Difficulty.medium,
      protein: 18,
      carbs: 40,
      fat: 14,
      ingredients: [
        Ingredient(const LText('Haricots niébé', 'Black-eyed beans'), _s('400 g')),
        Ingredient(const LText('Huile de palme', 'Palm oil'), const LText('2 c. à soupe', '2 tbsp')),
        Ingredient(const LText('Feuilles de bananier', 'Banana leaves'), _s('4')),
        Ingredient(const LText('Piment', 'Chili'), _s('1')),
      ],
    ),
  ];

  @override
  List<Recipe> all() => _items;

  @override
  Recipe byId(String id) => _items.firstWhere((r) => r.id == id);
}

final recipeRepositoryProvider = Provider<RecipeRepository>((_) => MockRecipeRepository());
