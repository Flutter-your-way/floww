import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/measurement_system.dart';
import 'package:floww/config/utils/formatters/measurement_converter.dart';
import 'package:floww/core/profile/models/profile_account.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/core/profile/models/profile_photo_args.dart';
import 'package:floww/core/profile/services/profile_avatar_service.dart';
import 'package:floww/core/profile/services/profile_service.dart';

class EditPersonalInfoViewModel extends ChangeNotifier {
  EditPersonalInfoViewModel(this._service, this._avatarService) {
    load();
  }

  final ProfileService _service;
  final ProfileAvatarService _avatarService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  HeightUnit _heightUnit = HeightUnit.cm;
  WeightUnit _weightUnit = WeightUnit.kg;
  String? _goalId;
  String? _dietId;
  String? _experienceId;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _disposed = false;
  bool _isAvatarBusy = false;
  String? _errorMessage;
  String? _avatarErrorMessage;
  String? _avatarUrl;
  Uint8List? _avatarBytes;
  PersonalInformationDraft? _savedDraft;

  String get title => 'Edit Personal Information';

  String get avatarTitle => 'Profile Photo';

  String get avatarHint => 'Tap the photo to change how you appear in Floww.';

  String get avatarActionLabel => hasAvatar ? 'Change Photo' : 'Add Photo';

  String get avatarSheetTitle => 'Profile photo';

  String get nameLabel => 'Your Name';

  String get nameHint => 'Your name';

  String get heightLabel => 'Height';

  String get heightHint => 'Enter height';

  String get weightLabel => 'Current Weight';

  String get weightHint => 'Enter weight';

  String get saveLabel => 'Save Changes';

  String get unsavedTitle => 'Unsaved changes';

  String get unsavedMessage =>
      'Your personal information has changed. Save it before leaving?';

  String get discardLabel => 'Discard';

  bool get hasUnsavedChanges {
    final savedDraft = _savedDraft;
    if (_isLoading || savedDraft == null) return false;
    return buildDraft() != savedDraft;
  }

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  String? get avatarErrorMessage => _avatarErrorMessage;

  bool get isAvatarBusy => _isAvatarBusy;

  bool get hasAvatar => _avatarBytes != null || _avatarUrl != null;

  Uint8List? get avatarBytes => _avatarBytes;

  String? get avatarUrl => _avatarUrl;

  String get avatarInitial {
    final name = nameController.text.trim();
    if (name.isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  List<ProfileAvatarOption> get avatarOptions => [
    const ProfileAvatarOption(
      icon: Icons.photo_camera_outlined,
      label: 'Take a photo',
      action: ProfileAvatarAction.takePhoto,
    ),
    const ProfileAvatarOption(
      icon: Icons.photo_library_outlined,
      label: 'Choose from library',
      action: ProfileAvatarAction.chooseFromLibrary,
    ),
    if (hasAvatar) ...[
      const ProfileAvatarOption(
        icon: Icons.fullscreen_rounded,
        label: 'View full screen',
        action: ProfileAvatarAction.viewPhoto,
      ),
      const ProfileAvatarOption(
        icon: Icons.delete_outline_rounded,
        label: 'Remove photo',
        action: ProfileAvatarAction.remove,
      ),
    ],
  ];

  ProfilePhotoArgs get photoArgs => ProfilePhotoArgs(
    title: avatarTitle,
    imageUrl: _avatarUrl,
    imageBytes: _avatarBytes,
  );

  HeightUnit get heightUnit => _heightUnit;

  WeightUnit get weightUnit => _weightUnit;

  List<HeightUnit> get heightUnits => HeightUnit.values;

  List<WeightUnit> get weightUnits => WeightUnit.values;

  String heightUnitLabel(HeightUnit unit) =>
      unit == HeightUnit.cm ? 'cm' : 'in';

  String weightUnitLabel(WeightUnit unit) =>
      unit == WeightUnit.kg ? 'kg' : 'lbs';

  ProfileChoiceGroup get goalGroup => ProfileChoiceGroup(
    title: 'Primary Goal',
    choices: _service.goals(),
    selectedId: _goalId ?? '',
  );

  ProfileChoiceGroup get dietGroup => ProfileChoiceGroup(
    title: 'Diet Preference',
    choices: _service.diets(),
    selectedId: _dietId ?? '',
  );

  ProfileChoiceGroup get experienceGroup => ProfileChoiceGroup(
    title: 'Training Experience',
    choices: _service.experiences(),
    selectedId: _experienceId ?? '',
  );

  bool get canSave =>
      !_isLoading &&
      !_isSaving &&
      nameController.text.trim().isNotEmpty &&
      _parse(heightController.text) != null &&
      _parse(weightController.text) != null &&
      _goalId != null &&
      _dietId != null &&
      _experienceId != null;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _apply(await _service.loadAccount());
      _savedDraft = buildDraft();
    } on ProfileException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<bool> save() async {
    if (!canSave) return false;
    _isSaving = true;
    _errorMessage = null;
    _notify();

    try {
      final draft = buildDraft();
      await _service.savePersonalInformation(draft);
      _savedDraft = draft;
      return true;
    } on ProfileException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  Future<Uint8List?> pickAvatarImage(ProfileAvatarSource source) async {
    if (_isAvatarBusy) return null;
    _isAvatarBusy = true;
    _avatarErrorMessage = null;
    _notify();

    try {
      return await _avatarService.pickImage(source);
    } on ProfileException catch (e) {
      _avatarErrorMessage = e.message;
      return null;
    } finally {
      _isAvatarBusy = false;
      _notify();
    }
  }

  Future<bool> applyAvatar(Uint8List bytes) async {
    if (_isAvatarBusy) return false;
    _isAvatarBusy = true;
    _avatarErrorMessage = null;
    _avatarBytes = bytes;
    _notify();

    try {
      _avatarUrl = await _avatarService.upload(bytes);
      return true;
    } on ProfileException catch (e) {
      _avatarErrorMessage = e.message;
      return false;
    } finally {
      _isAvatarBusy = false;
      _notify();
    }
  }

  Future<bool> removeAvatar() async {
    if (_isAvatarBusy || !hasAvatar) return false;
    _isAvatarBusy = true;
    _avatarErrorMessage = null;
    _notify();

    try {
      await _avatarService.remove();
      _avatarBytes = null;
      _avatarUrl = null;
      return true;
    } on ProfileException catch (e) {
      _avatarErrorMessage = e.message;
      return false;
    } finally {
      _isAvatarBusy = false;
      _notify();
    }
  }

  void updateName(String value) => _notify();

  void updateHeight(String value) => _notify();

  void updateWeight(String value) => _notify();

  void selectHeightUnit(HeightUnit unit) {
    if (unit == _heightUnit) return;
    final value = _parse(heightController.text);
    _heightUnit = unit;
    if (value != null) {
      heightController.text = MeasurementConverter.trimmed(
        unit == HeightUnit.cm
            ? MeasurementConverter.inchesToCm(value)
            : MeasurementConverter.cmToInches(value),
      );
    }
    _notify();
  }

  void selectWeightUnit(WeightUnit unit) {
    if (unit == _weightUnit) return;
    final value = _parse(weightController.text);
    _weightUnit = unit;
    if (value != null) {
      weightController.text = MeasurementConverter.trimmed(
        unit == WeightUnit.kg
            ? MeasurementConverter.lbsToKg(value)
            : MeasurementConverter.kgToLbs(value),
      );
    }
    _notify();
  }

  void selectGoal(String id) {
    if (id == _goalId) return;
    _goalId = id;
    _notify();
  }

  void selectDiet(String id) {
    if (id == _dietId) return;
    _dietId = id;
    _notify();
  }

  void selectExperience(String id) {
    if (id == _experienceId) return;
    _experienceId = id;
    _notify();
  }

  PersonalInformationDraft buildDraft() => PersonalInformationDraft(
    name: nameController.text.trim(),
    height: heightController.text.trim(),
    heightUnit: _heightUnit,
    weight: weightController.text.trim(),
    weightUnit: _weightUnit,
    goalId: _goalId ?? '',
    dietId: _dietId ?? '',
    experienceId: _experienceId ?? '',
  );

  void _apply(ProfileAccount account) {
    final isImperial = account.unitSystem == MeasurementSystem.imperial;
    _heightUnit = isImperial ? HeightUnit.inches : HeightUnit.cm;
    _weightUnit = isImperial ? WeightUnit.lbs : WeightUnit.kg;

    _avatarUrl = account.avatarUrl;
    _avatarBytes = null;
    nameController.text = account.name ?? '';
    heightController.text = _measurement(
      account.heightCm,
      isImperial ? MeasurementConverter.cmToInches : null,
    );
    weightController.text = _measurement(
      account.weightKg,
      isImperial ? MeasurementConverter.kgToLbs : null,
    );

    _goalId = _matching(_service.goals(), account.goal);
    _dietId = _matching(_service.diets(), account.diet);
    _experienceId = _matching(_service.experiences(), account.experience);
  }

  static String _measurement(double? value, double Function(double)? convert) {
    if (value == null) return '';
    return MeasurementConverter.trimmed(
      convert == null ? value : convert(value),
    );
  }

  static String? _matching(List<ProfileChoice> choices, String? value) {
    if (value == null) return null;
    for (final choice in choices) {
      if (choice.id.toLowerCase() == value.toLowerCase()) return choice.id;
    }
    return null;
  }

  double? _parse(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
