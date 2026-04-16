import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

class RwMaterialLocalizations extends GlobalMaterialLocalizations {
  const RwMaterialLocalizations({
    super.localeName = 'rw',
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  @override
  String get aboutListTileTitleRaw => r'Ibyerekeye $applicationName';

  @override
  String get alertDialogLabel => 'Ikitonderwa';

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get backButtonTooltip => 'Subira inyuma';

  @override
  String get calendarModeButtonLabel => 'Guhindura uburyo bwa kalendari';

  @override
  String get cancelButtonLabel => 'Hagarika';

  @override
  String get closeButtonLabel => 'Funga';

  @override
  String get closeButtonTooltip => 'Funga';

  @override
  String get collapsedIconTapTargetLabel => 'Kwerekana';

  @override
  String get continueButtonLabel => 'Komeza';

  @override
  String get copyButtonLabel => 'Koporora';

  @override
  String get cutButtonLabel => 'Kata';

  @override
  String get deleteButtonLabel => 'Siba';

  @override
  String get dialogLabel => 'Idirishya';

  @override
  String get drawerLabel => 'Menu yo kuruhande';

  @override
  String get expandedIconTapTargetLabel => 'Hisha';

  @override
  String get hideAccountsLabel => 'Hisha imiyoboro';

  @override
  String get licensesPageTitle => 'Impushya';

  @override
  String get modalBarrierDismissLabel => 'Funga';

  @override
  String get nextMonthTooltip => 'Ukwezi gutaha';

  @override
  String get nextPageTooltip => 'Ipaji itaha';

  @override
  String get okButtonLabel => 'Yego';

  @override
  String get openAppDrawerTooltip => 'Gufungura menu';

  @override
  String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow kuri $rowCount';

  @override
  String get pageRowsInfoTitleApproximateRaw => r'$firstRow–$lastRow kuri hafi $rowCount';

  @override
  String get pasteButtonLabel => 'Namata';

  @override
  String get popupMenuLabel => 'Menu nshya';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  String get previousMonthTooltip => 'Ukwezi gushize';

  @override
  String get previousPageTooltip => 'Ipaji iheruka';

  @override
  String get refreshIndicatorSemanticLabel => 'Kuvugurura';

  @override
  String get remainingTextFieldCharacterCountZero => 'Nta nyuguti zisigaye';

  @override
  String get remainingTextFieldCharacterCountOne => 'Inyuguti 1 isigaye';

  @override
  String get remainingTextFieldCharacterCountOther => r'Inyuguti $remainingCount zisigaye';

  @override
  String get rowsPerPageTitle => 'Imirongo ku ipaji:';

  @override
  String get saveButtonLabel => 'Bika';

  @override
  String get scrollUnderneathDividerSemanticLabel => 'Kuzamura';

  @override
  String get searchFieldLabel => 'Shakisha';

  @override
  String get selectAllButtonLabel => 'Hitamo byose';

  @override
  String get selectYearSemanticsLabel => 'Hitamo umwaka';

  @override
  String get showAccountsLabel => 'Erekana imiyoboro';

  @override
  String get showMenuTooltip => 'Erekana menu';

  @override
  String get signedInLabel => 'Winjiye';

  @override
  String get tabLabelRaw => r'Tab $tabIndex kuri $tabCount';

  @override
  String get timePickerHourModeAnnouncement => 'Hitamo amasaha';

  @override
  String get timePickerMinuteModeAnnouncement => 'Hitamo iminota';

  @override
  String get viewLicensesButtonLabel => 'Reba impushya';

  @override
  String get reorderItemToTheStart => 'Murika ku ntangiriro';

  @override
  String get reorderItemToTheEnd => 'Murika ku ndunduro';

  @override
  String get reorderItemUp => 'Murika hejuru';

  @override
  String get reorderItemDown => 'Murika hepfo';

  @override
  String get reorderItemLeft => 'Murika ibumoso';

  @override
  String get reorderItemRight => 'Murika iburyo';

  @override
  String get expandedDrawerMenuLabel => 'Menu yagutse';

  @override
  String get collapsedDrawerMenuLabel => 'Menu yifunze';

  // Missing Members from logs
  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;

  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.h_colon_mm_space_a;

  @override
  String get selectedRowCountTitleOther => r'$selectedRowCount zatoranyijwe';

  @override
  String get licensesPackageDetailTextOther => r'$licenseCount impushya';

  @override
  String get bottomSheetLabel => 'Sheet yo hepfo';

  @override
  String get clearButtonTooltip => 'Siba';

  @override
  String get collapsedHint => 'Yifunze';

  @override
  String get collapsedIconTapHint => 'Yagura';

  @override
  String get currentDateLabel => 'Itariki yanyu';

  @override
  String get dateRangeEndLabel => 'Itariki yo kusoza';

  @override
  String get dateRangeStartLabel => 'Itariki yo gutangira';

  @override
  String get deleteButtonTooltip => 'Siba';

  @override
  String get expandedHint => 'Yagutse';

  @override
  String get expandedIconTapHint => 'Funya';

  @override
  String get expansionTileCollapsedHint => 'Kanda kabiri kugira ngo wagure';

  @override
  String get expansionTileCollapsedTapHint => 'Yagura kugira ngo ubone andi makuru';

  @override
  String get expansionTileExpandedHint => 'Kanda kabiri kugira ngo ufunye';

  @override
  String get expansionTileExpandedTapHint => 'Funya';

  @override
  String get keyboardKeyChannelDown => 'Channel Hepfo';

  @override
  String get keyboardKeyChannelUp => 'Channel Hejuru';

  @override
  String get keyboardKeyPowerOff => 'Zimya';

  @override
  String get keyboardKeyShift => 'Shift';

  @override
  String get moreButtonTooltip => 'Andi makuru';

  @override
  String get reorderItemToEnd => 'Murika ku mpera';

  @override
  String get reorderItemToStart => 'Murika mu ntangiriro';

  @override
  String get selectedDateLabel => 'Itariki yatoranyijwe';

  @override
  String get timePickerDialHelpText => 'HITAMO IGIHE';

  @override
  String get timePickerHourLabel => 'Isaha';

  @override
  String get timePickerInputHelpText => 'INJIZA IGIHE';

  @override
  String get timePickerMinuteLabel => 'Iminota';

  @override
  String get unspecifiedDate => 'Itariki itazwi';

  @override
  String get unspecifiedDateRange => 'Igihe kitazwi';

  static Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      RwMaterialLocalizations(
        fullYearFormat: intl.DateFormat.y(),
        compactDateFormat: intl.DateFormat.yMd(),
        shortDateFormat: intl.DateFormat.yMMMd(),
        mediumDateFormat: intl.DateFormat.yMMMMd(),
        longDateFormat: intl.DateFormat.yMMMMEEEEd(),
        yearMonthFormat: intl.DateFormat.yMMM(),
        shortMonthDayFormat: intl.DateFormat.MMMd(),
        decimalFormat: intl.NumberFormat.decimalPattern(),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00'),
      ),
    );
  }

  static const LocalizationsDelegate<MaterialLocalizations> delegate = _RwLocalizationsDelegate();

  @override
  String get calendarModeButtonLabelRaw => 'Guhindura uburyo bwa kalendari';

  @override
  String get dateHelpText => 'mm/dd/yyyy';

  @override
  String get dateInputLabel => 'Injiza itariki';

  @override
  String get dateOutOfRangeLabel => 'Itariki iri hanze y\'igihe cyemewe.';

  @override
  String get datePickerHelpText => 'HITAMO ITARIKI';

  @override
  String get dateRangeEndDateLabel => 'Itariki yo gusoza';

  @override
  String get dateRangeEndDateSemanticLabelRaw => r'Itariki yo gusoza $fullDate';

  @override
  String get dateRangePickerHelpText => 'HITAMO IGIHE';

  @override
  String get dateRangeStartDateLabel => 'Itariki yo gutangira';

  @override
  String get dateRangeStartDateSemanticLabelRaw => r'Itariki yo gutangira $fullDate';

  @override
  String get dateSeparator => '/';

  @override
  String get dialModeButtonLabel => 'Guhidura uburyo bwa dial';

  @override
  String get inputDateModeButtonLabel => 'Guhindura uburyo bwo kwandika itariki';

  @override
  String get inputTimeModeButtonLabel => 'Guhindura uburyo bwo kwandika igihe';

  @override
  String get invalidDateFormatLabel => 'Itariki ntabwo yemewe.';

  @override
  String get invalidDateRangeLabel => 'Igihe ntabwo gikwiye.';

  @override
  String get invalidTimeLabel => 'Igihe ntabwo gikwiye.';

  @override
  String get keyboardKeyAlt => 'Alt';

  @override
  String get keyboardKeyAltGraph => 'AltGraph';

  @override
  String get keyboardKeyBackspace => 'Backspace';

  @override
  String get keyboardKeyCapsLock => 'Caps Lock';

  @override
  String get keyboardKeyControl => 'Control';

  @override
  String get keyboardKeyDelete => 'Delete';

  @override
  String get keyboardKeyEject => 'Eject';

  @override
  String get keyboardKeyEnd => 'End';

  @override
  String get keyboardKeyEnter => 'Enter';

  @override
  String get keyboardKeyEscape => 'Esc';

  @override
  String get keyboardKeyFn => 'Fn';

  @override
  String get keyboardKeyHome => 'Home';

  @override
  String get keyboardKeyInsert => 'Insert';

  @override
  String get keyboardKeyMeta => 'Meta';

  @override
  String get keyboardKeyMetaMacOs => 'Command';

  @override
  String get keyboardKeyMetaWindows => 'Win';

  @override
  String get keyboardKeyNumLock => 'Num Lock';

  @override
  String get keyboardKeyNumpad0 => 'Num 0';

  @override
  String get keyboardKeyNumpad1 => 'Num 1';

  @override
  String get keyboardKeyNumpad2 => 'Num 2';

  @override
  String get keyboardKeyNumpad3 => 'Num 3';

  @override
  String get keyboardKeyNumpad4 => 'Num 4';

  @override
  String get keyboardKeyNumpad5 => 'Num 5';

  @override
  String get keyboardKeyNumpad6 => 'Num 6';

  @override
  String get keyboardKeyNumpad7 => 'Num 7';

  @override
  String get keyboardKeyNumpad8 => 'Num 8';

  @override
  String get keyboardKeyNumpad9 => 'Num 9';

  @override
  String get keyboardKeyNumpadAdd => 'Num +';

  @override
  String get keyboardKeyNumpadComma => 'Num ,';

  @override
  String get keyboardKeyNumpadDecimal => 'Num .';

  @override
  String get keyboardKeyNumpadDivide => 'Num /';

  @override
  String get keyboardKeyNumpadEnter => 'Num Enter';

  @override
  String get keyboardKeyNumpadEqual => 'Num =';

  @override
  String get keyboardKeyNumpadMultiply => 'Num *';

  @override
  String get keyboardKeyNumpadParenLeft => 'Num (';

  @override
  String get keyboardKeyNumpadParenRight => 'Num )';

  @override
  String get keyboardKeyNumpadSubtract => 'Num -';

  @override
  String get keyboardKeyPageDown => 'PgDn';

  @override
  String get keyboardKeyPageUp => 'PgUp';

  @override
  String get keyboardKeyPower => 'Power';

  @override
  String get keyboardKeyPrintScreen => 'Print Screen';

  @override
  String get keyboardKeyScrollLock => 'Scroll Lock';

  @override
  String get keyboardKeySelect => 'Select';

  @override
  String get keyboardKeySpace => 'Space';

  @override
  String get lastPageTooltip => 'Ipaji ya nyuma';

  @override
  String get lookUpButtonLabel => 'Shakisha';

  @override
  String get menuBarMenuLabel => 'Bar ya menu';

  @override
  String get menuDismissLabel => 'Funga menu';

  @override
  String get firstPageTooltip => 'Ipaji ya mbere';

  @override
  String get scanTextButtonLabel => 'Scan Text';

  @override
  String get scrimLabel => 'Ikirago';

  @override
  String get scrimOnTapHintRaw => r'Funga ikirago $modalRouteName';

  @override
  String get searchWebButtonLabel => 'Shakisha kuri web';

  @override
  String get shareButtonLabel => 'Sangiza';
}

class _RwLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _RwLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) => RwMaterialLocalizations.load(locale);

  @override
  bool shouldReload(_RwLocalizationsDelegate old) => false;
}
