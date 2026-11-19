import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_chip.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_text_field.dart';
import '../../data/api/api_client.dart';
import '../../data/patient_models.dart';
import '../../data/patient_repositories.dart';
import '../../data/recipes.dart';
import '../../l10n/gen/app_localizations.dart';
import 'journal_screen.dart' show mealTypeLabel;

/// Ajout d'un repas au journal (photo facultative). Peut être prérempli depuis une recette.
class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({super.key, this.recipe});
  final Recipe? recipe;

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  late final _name = TextEditingController();
  late final _kcal = TextEditingController();
  late final _protein = TextEditingController();
  late final _carbs = TextEditingController();
  late final _fat = TextEditingController();
  late MealType _type = _defaultType();
  Uint8List? _photo;
  String _photoName = 'repas.jpg';
  bool _saving = false;
  bool _prefilled = false;

  static MealType _defaultType() {
    final h = DateTime.now().hour;
    if (h < 10) return MealType.breakfast;
    if (h < 15) return MealType.lunch;
    if (h < 18) return MealType.snack;
    return MealType.dinner;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final r = widget.recipe;
    if (r != null && !_prefilled) {
      _prefilled = true;
      final locale = Localizations.localeOf(context).toString();
      _name.text = r.name.of(locale);
      _kcal.text = '${r.detailKcal ?? r.kcal}';
      _protein.text = '${r.protein}';
      _carbs.text = '${r.carbs}';
      _fat.text = '${r.fat}';
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _kcal, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photo = bytes;
        _photoName = x.name;
      });
    } catch (_) {
      // Permission refusée ou appareil photo indisponible : on reste sans photo.
    }
  }

  int _int(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final kcal = int.tryParse(_kcal.text.trim());
    if (_name.text.trim().isEmpty || kcal == null || kcal > 5000) {
      messenger.showSnackBar(SnackBar(content: Text(l.addMealInvalid)));
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(journalRepositoryProvider);
    try {
      String? photoId;
      if (_photo != null) {
        photoId = await repo.uploadPhoto(
          _photo!,
          kind: 'meal_photo',
          filename: _photoName,
        );
      }
      await repo.addMeal(
        NewMeal(
          type: _type,
          name: _name.text.trim(),
          kcal: kcal,
          protein: _int(_protein),
          carbs: _int(_carbs),
          fat: _int(_fat),
          photoFileId: photoId,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
      return;
    }
    ref.invalidate(journalDayProvider(dateOnly(DateTime.now())));
    if (mounted) context.go('/journal');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final digits = [FilteringTextInputFormatter.digitsOnly];

    Widget field(
      String label,
      TextEditingController c, {
      bool number = false,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Tch.style(13, weight: FontWeight.w600)),
        const SizedBox(height: 6),
        TchTextField(
          controller: c,
          height: 52,
          semanticLabel: label,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          inputFormatters: number ? digits : null,
        ),
      ],
    );

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        Tch.pagePadding,
        Tch.topInset(context),
        Tch.pagePadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                TchBackButton(onTap: () => context.go('/journal')),
                const SizedBox(width: 12),
                Text(
                  l.addMealTitle,
                  style: Tch.style(24, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            index: 1,
            child: Text(
              l.addMealPhoto,
              style: Tch.style(15, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            index: 1,
            child: _photo != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _photo!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Semantics(
                          button: true,
                          label: l.photoRemove,
                          child: GestureDetector(
                            onTap: () => setState(() => _photo = null),
                            child: Container(
                              width: 44,
                              height: 44,
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: TchIcon(
                                      TchIcons.close,
                                      size: 18,
                                      color: Tch.coralText,
                                      strokeWidth: 2.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _PhotoButton(
                          icon: TchIcons.camera,
                          label: l.photoCamera,
                          onTap: () => _pick(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PhotoButton(
                          icon: TchIcons.journal,
                          label: l.photoGallery,
                          onTap: () => _pick(ImageSource.gallery),
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
                Text(
                  l.addMealType,
                  style: Tch.style(15, weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final t in MealType.values)
                      TchChip(
                        label: mealTypeLabel(l, t),
                        selected: t == _type,
                        onTap: () => setState(() => _type = t),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                field(l.addMealName, _name),
                const SizedBox(height: 14),
                field(l.addMealKcal, _kcal, number: true),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: field(l.addMealProtein, _protein, number: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: field(l.addMealCarbs, _carbs, number: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: field(l.addMealFat, _fat, number: true)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TchButton(label: l.addMealSave, onPressed: _saving ? null : _save),
        ],
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressScale(
    onTap: onTap,
    child: Container(
      height: 96,
      decoration: BoxDecoration(
        color: Tch.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Tch.border, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TchIcon(icon, size: 26, color: Tch.greenDark2),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Tch.style(13, weight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}
