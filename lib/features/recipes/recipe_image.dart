import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/tch_icons.dart';
import '../../data/recipes.dart';

/// Petite assiette (liste des recettes), aux couleurs de la recette.
class RecipePlate extends StatelessWidget {
  const RecipePlate({super.key, required this.recipe, this.size = 104});
  final Recipe recipe;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 110 110">
<circle cx="55" cy="55" r="46" fill="#FFFFFF"/><circle cx="55" cy="55" r="36" fill="#F7F3EC"/>
<ellipse cx="46" cy="48" rx="18" ry="14" fill="${colorHex(recipe.c1)}"/>
<ellipse cx="66" cy="62" rx="15" ry="9" fill="${colorHex(recipe.c2)}" transform="rotate(-20 66 62)"/>
<circle cx="46" cy="70" r="8" fill="${colorHex(recipe.c3)}"/><circle cx="68" cy="40" r="6" fill="#E8775F"/></svg>''',
    width: size,
    height: size,
  );
}

const _ndoleHero = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 270" preserveAspectRatio="xMidYMid slice">
<rect width="390" height="270" fill="#D9C7AB"/><rect y="200" width="390" height="70" fill="#C9B391"/>
<circle cx="195" cy="150" r="104" fill="#FFFFFF"/><circle cx="195" cy="150" r="88" fill="#F5EFE4"/>
<circle cx="180" cy="140" r="56" fill="#6E8F36"/>
<circle cx="160" cy="124" r="7" fill="#536F24"/><circle cx="186" cy="118" r="6" fill="#536F24"/><circle cx="200" cy="148" r="7" fill="#536F24"/>
<ellipse cx="190" cy="132" rx="16" ry="12" fill="#D9A06B"/><ellipse cx="160" cy="146" rx="13" ry="10" fill="#D9A06B"/>
<ellipse cx="236" cy="186" rx="34" ry="22" fill="#F2EAD6"/><circle cx="244" cy="104" r="10" fill="#E8775F"/></svg>''';

/// Grande image de la fiche recette : celle de la maquette pour le ndolé,
/// une image à ses couleurs pour les autres recettes.
class RecipeHero extends StatelessWidget {
  const RecipeHero({super.key, required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final svg = recipe.id == 'ndole'
        ? _ndoleHero
        : '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 270" preserveAspectRatio="xMidYMid slice">
<rect width="390" height="270" fill="#D9C7AB"/><rect y="200" width="390" height="70" fill="#C9B391"/>
<circle cx="195" cy="150" r="104" fill="#FFFFFF"/><circle cx="195" cy="150" r="88" fill="#F5EFE4"/>
<ellipse cx="178" cy="132" rx="52" ry="40" fill="${colorHex(recipe.c1)}"/>
<ellipse cx="226" cy="170" rx="40" ry="20" fill="${colorHex(recipe.c2)}" transform="rotate(-20 226 170)"/>
<circle cx="170" cy="184" r="18" fill="${colorHex(recipe.c3)}"/>
<circle cx="244" cy="104" r="10" fill="#E8775F"/></svg>''';
    return SvgPicture.string(svg, fit: BoxFit.cover);
  }
}
