import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pokédex GraphQL'**
  String get appTitle;

  /// Brand-like title displayed at the top of the Home screen.
  ///
  /// In en, this message translates to:
  /// **'ProDex'**
  String get homeHeaderTitle;

  /// Label for the quick-access chip that opens gym leader resources.
  ///
  /// In en, this message translates to:
  /// **'Gym Leaders & Elite 4'**
  String get homeQuickAccessGymLeaders;

  /// Label for the quick-access chip that opens nature guides.
  ///
  /// In en, this message translates to:
  /// **'Natures'**
  String get homeQuickAccessNatures;

  /// Label for the quick-access chip that shows type matchup information.
  ///
  /// In en, this message translates to:
  /// **'Type Matchups'**
  String get homeQuickAccessMatchups;

  /// Label for the quick-access chip that highlights evolution chain references.
  ///
  /// In en, this message translates to:
  /// **'Evolution Chains'**
  String get homeQuickAccessEvolutionChains;

  /// Label for the quick-access chip that links to breeding guides.
  ///
  /// In en, this message translates to:
  /// **'Breeding Guides'**
  String get homeQuickAccessBreeding;

  /// Label for the quick-access chip that covers berry farming tips.
  ///
  /// In en, this message translates to:
  /// **'Berry Farming'**
  String get homeQuickAccessBerries;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email to access your Pokédex.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'ash.ketchum@poke.app'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginButton;

  /// No description provided for @authNoAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authNoAccountCta;

  /// No description provided for @authLoginError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t sign you in. Try again.'**
  String get authLoginError;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 6 characters.'**
  String get authPasswordLength;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register to sync your teams and collections across all your devices.'**
  String get authRegisterSubtitle;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButton;

  /// No description provided for @authAlreadyHaveAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authAlreadyHaveAccountCta;

  /// No description provided for @authRegisterError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t create your account. Try again later.'**
  String get authRegisterError;

  /// No description provided for @authSecurePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a secure password.'**
  String get authSecurePasswordRequired;

  /// No description provided for @authPasswordStrongSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Use letters and numbers for a stronger password.'**
  String get authPasswordStrongSuggestion;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordsMismatch;

  /// No description provided for @authSnackbarNoUser.
  ///
  /// In en, this message translates to:
  /// **'User information is not available.'**
  String get authSnackbarNoUser;

  /// No description provided for @authProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get authProfileUpdated;

  /// No description provided for @authProfileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update the profile.'**
  String get authProfileUpdateError;

  /// No description provided for @authUpdateInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Update your login information.'**
  String get authUpdateInfoTitle;

  /// No description provided for @authUpdateInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your email address or set a new password. Changes apply immediately.'**
  String get authUpdateInfoSubtitle;

  /// No description provided for @authNewPasswordOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'New password (optional)'**
  String get authNewPasswordOptionalLabel;

  /// Page title for the Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Heading shown above the account information card.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// Fallback text when the authenticated user does not have an email.
  ///
  /// In en, this message translates to:
  /// **'No email on record'**
  String get settingsNoEmail;

  /// Button label that opens the profile editing screen.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settingsEditProfile;

  /// Button label used to log out of the current session.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// Heading shown above the appearance/theme options.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// Heading shown above the language selection card.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// Label for the dropdown that lets the user pick a locale.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguageLabel;

  /// Name of the English locale shown inside the dropdown.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Name of the Spanish locale shown inside the dropdown.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// Title of the light theme option within the appearance card.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get settingsLightModeTitle;

  /// Description that explains when to use the light theme option.
  ///
  /// In en, this message translates to:
  /// **'Bright backgrounds for well-lit environments.'**
  String get settingsLightModeSubtitle;

  /// Title of the dark theme option within the appearance card.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkModeTitle;

  /// Description that explains when to use the dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dim the lights to reduce eye strain at night.'**
  String get settingsDarkModeSubtitle;

  /// Footnote shown below the cards to clarify how settings behave.
  ///
  /// In en, this message translates to:
  /// **'Settings save immediately and affect the entire app.'**
  String get settingsInfo;

  /// Primary action button in the profile settings form.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settingsSaveChanges;

  /// No description provided for @favoritesDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesDefaultTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have favorite Pokémon yet.'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the Pokédex and tap the heart to save your favorites.'**
  String get favoritesEmptySubtitle;

  /// Label for the horizontal list of quick-access chips on Home.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get homeQuickAccessTitle;

  /// Title of the Pokédex feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'Pokédex'**
  String get homeSectionPokedexTitle;

  /// Short description shown under the Pokédex card title.
  ///
  /// In en, this message translates to:
  /// **'National index & regional dexes'**
  String get homeSectionPokedexSubtitle;

  /// Title of the favorites feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get homeSectionFavoritesTitle;

  /// Short description shown under the favorites card title.
  ///
  /// In en, this message translates to:
  /// **'Your saved Pokémon'**
  String get homeSectionFavoritesSubtitle;

  /// Title of the moves feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get homeSectionMovesTitle;

  /// Short description shown under the moves card title.
  ///
  /// In en, this message translates to:
  /// **'Damage, effects & contest data'**
  String get homeSectionMovesSubtitle;

  /// Title of the technical machines feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'TM'**
  String get homeSectionTmTitle;

  /// Short description shown under the TM card title.
  ///
  /// In en, this message translates to:
  /// **'Machines & tutors by generation'**
  String get homeSectionTmSubtitle;

  /// Title of the abilities feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get homeSectionAbilitiesTitle;

  /// Short description shown under the abilities card title.
  ///
  /// In en, this message translates to:
  /// **'Passive effects & triggers'**
  String get homeSectionAbilitiesSubtitle;

  /// Title of the checklist feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'Checklists'**
  String get homeSectionChecklistsTitle;

  /// Short description shown under the checklist card title.
  ///
  /// In en, this message translates to:
  /// **'Track goals & collections'**
  String get homeSectionChecklistsSubtitle;

  /// Title of the parties/teams feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'Parties'**
  String get homeSectionPartiesTitle;

  /// Short description shown under the parties card title.
  ///
  /// In en, this message translates to:
  /// **'Build teams & strategies'**
  String get homeSectionPartiesSubtitle;

  /// Title of the locations feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get homeSectionLocationsTitle;

  /// Short description shown under the locations card title.
  ///
  /// In en, this message translates to:
  /// **'Regions, maps & encounter data'**
  String get homeSectionLocationsSubtitle;

  /// Semantic label for the notifications button
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotificationsSemanticLabel;

  /// Semantic hint for the notifications button
  ///
  /// In en, this message translates to:
  /// **'Opens notifications and alerts'**
  String get homeNotificationsSemanticHint;

  /// Semantic label for the shop button
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get homeStoreSemanticLabel;

  /// Semantic hint for the shop button
  ///
  /// In en, this message translates to:
  /// **'Opens the in-app shop'**
  String get homeStoreSemanticHint;

  /// Semantic label for the settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsSemanticLabel;

  /// Semantic hint for the settings button
  ///
  /// In en, this message translates to:
  /// **'Opens app settings'**
  String get homeSettingsSemanticHint;


  /// No description provided for @abilitiesDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get abilitiesDefaultTitle;

  /// No description provided for @abilitiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search ability…'**
  String get abilitiesSearchHint;

  /// No description provided for @abilitiesErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the abilities.'**
  String get abilitiesErrorMessage;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @abilitiesEmptySearch.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find abilities that match your search.'**
  String get abilitiesEmptySearch;

  /// No description provided for @abilitiesEmptyGeneral.
  ///
  /// In en, this message translates to:
  /// **'No abilities are available right now.'**
  String get abilitiesEmptyGeneral;

  /// No description provided for @abilitiesNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get abilitiesNoDescription;

  /// No description provided for @abilitiesNoShortDescription.
  ///
  /// In en, this message translates to:
  /// **'No short description available.'**
  String get abilitiesNoShortDescription;

  /// No description provided for @abilitiesFullDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Full description'**
  String get abilitiesFullDescriptionTitle;

  /// No description provided for @abilitiesFullDescriptionFallback.
  ///
  /// In en, this message translates to:
  /// **'No description is available in this language.'**
  String get abilitiesFullDescriptionFallback;

  /// No description provided for @abilitiesPokemonSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pokémon with this ability'**
  String get abilitiesPokemonSectionTitle;

  /// No description provided for @abilitiesPokemonEmpty.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find Pokémon associated with this ability.'**
  String get abilitiesPokemonEmpty;

  /// No description provided for @abilitiesPokemonErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the associated Pokémon.'**
  String get abilitiesPokemonErrorTitle;

  /// No description provided for @abilitiesPokemonErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Try again to see which Pokémon have this ability.'**
  String get abilitiesPokemonErrorDescription;

  /// No description provided for @pokedexSortNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get pokedexSortNumberLabel;

  /// No description provided for @pokedexSortNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pokedexSortNameLabel;

  /// No description provided for @pokedexSortHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get pokedexSortHeightLabel;

  /// No description provided for @pokedexSortWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get pokedexSortWeightLabel;

  /// No description provided for @pokedexSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or number'**
  String get pokedexSearchHint;

  /// No description provided for @pokedexFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get pokedexFiltersTooltip;

  /// No description provided for @pokedexOfflineNoCache.
  ///
  /// In en, this message translates to:
  /// **'No connection and no cached data available.'**
  String get pokedexOfflineNoCache;

  /// No description provided for @pokedexOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline mode active. Showing cached data.'**
  String get pokedexOfflineBanner;

  /// No description provided for @pokedexConnectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored.'**
  String get pokedexConnectionRestored;

  /// No description provided for @pokedexLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the Pokédex. Try again.'**
  String get pokedexLoadError;

  /// No description provided for @pokedexOfflineFiltersLimited.
  ///
  /// In en, this message translates to:
  /// **'Offline mode active. Some filters may be limited.'**
  String get pokedexOfflineFiltersLimited;

  /// No description provided for @pokedexActiveFilters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} active filter} other {{count} active filters}}'**
  String pokedexActiveFilters(int count);

  /// No description provided for @pokedexSortDirectionAscending.
  ///
  /// In en, this message translates to:
  /// **'ascending'**
  String get pokedexSortDirectionAscending;

  /// No description provided for @pokedexSortDirectionDescending.
  ///
  /// In en, this message translates to:
  /// **'descending'**
  String get pokedexSortDirectionDescending;

  /// No description provided for @pokedexNoResults.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon match the current filters.'**
  String get pokedexNoResults;

  /// No description provided for @pokedexFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get pokedexFiltersTitle;

  /// No description provided for @pokedexFiltersCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get pokedexFiltersCloseTooltip;

  /// No description provided for @pokedexFilterSectionTypes.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get pokedexFilterSectionTypes;

  /// No description provided for @pokedexFilterSectionGenerations.
  ///
  /// In en, this message translates to:
  /// **'Generations'**
  String get pokedexFilterSectionGenerations;

  /// No description provided for @pokedexFilterSectionRegions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get pokedexFilterSectionRegions;

  /// No description provided for @pokedexFilterSectionShapes.
  ///
  /// In en, this message translates to:
  /// **'Shapes'**
  String get pokedexFilterSectionShapes;

  /// No description provided for @pokedexFilterEmptyTypes.
  ///
  /// In en, this message translates to:
  /// **'No types available right now.'**
  String get pokedexFilterEmptyTypes;

  /// No description provided for @pokedexFilterEmptyGenerations.
  ///
  /// In en, this message translates to:
  /// **'No generations available right now.'**
  String get pokedexFilterEmptyGenerations;

  /// No description provided for @pokedexFilterEmptyRegions.
  ///
  /// In en, this message translates to:
  /// **'No regions available right now.'**
  String get pokedexFilterEmptyRegions;

  /// No description provided for @pokedexFilterEmptyShapes.
  ///
  /// In en, this message translates to:
  /// **'No shapes available right now.'**
  String get pokedexFilterEmptyShapes;

  /// No description provided for @pokedexFiltersClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get pokedexFiltersClear;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @pokedexSortSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get detailOfflineModeSnack;
  String get detailConnectionRestored;
  String get detailOfflineBanner;
  String get detailFallbackTitle;
  String get detailTabInformation;
  String get detailTabStatistics;
  String get detailTabMatchups;
  String get detailTabEvolutions;
  String get detailTabMoves;
  String get detailNoDataFound;
  String get detailOfflineShortMessage;
  String get detailOfflineLongMessage;
  String get detailFavoriteRemoveTooltip;
  String get detailFavoriteAddTooltip;
  String get detailHiddenAbilityLabel;
  String get detailMainAbilityLabel;
  String get detailLoadErrorDescription;
  /// Label for the Pokémon height characteristic.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailCharacteristicHeight;

  /// Label for the Pokémon weight characteristic.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailCharacteristicWeight;

  /// Label for the Pokémon category characteristic.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get detailCharacteristicCategory;

  /// Fallback text when no category information is available.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get detailCharacteristicNoCategory;

  /// Label for the Pokémon catch rate characteristic.
  ///
  /// In en, this message translates to:
  /// **'Catch rate'**
  String get detailCharacteristicCatchRate;

  /// Label for the Pokémon base experience characteristic.
  ///
  /// In en, this message translates to:
  /// **'Base experience'**
  String get detailCharacteristicBaseExperience;

  /// Message shown when weakness data is missing.
  ///
  /// In en, this message translates to:
  /// **'No weakness information available.'**
  String get detailNoWeaknessInfo;

  /// Description for the 4x weakness legend entry.
  ///
  /// In en, this message translates to:
  /// **'Double weakness: damage taken is multiplied by four.'**
  String get detailWeaknessLegendQuadruple;

  /// Description for the 2x weakness legend entry.
  ///
  /// In en, this message translates to:
  /// **'Classic weakness: super effective attacks.'**
  String get detailWeaknessLegendDouble;

  /// Description for the 1.5x weakness legend entry.
  ///
  /// In en, this message translates to:
  /// **'Moderate advantage: slightly increased damage.'**
  String get detailWeaknessLegendModerate;

  /// Button text to expand and show weaknesses.
  ///
  /// In en, this message translates to:
  /// **'Show weaknesses'**
  String get detailWeaknessToggleShow;

  /// Button text to collapse weaknesses.
  ///
  /// In en, this message translates to:
  /// **'Hide weaknesses'**
  String get detailWeaknessToggleHide;
  String get pokedexSortSheetTitle;

  /// No description provided for @pokedexSortCriteriaLabel.
  ///
  /// In en, this message translates to:
  /// **'Criterion'**
  String get pokedexSortCriteriaLabel;

  /// No description provided for @pokedexSortDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get pokedexSortDirectionLabel;

  /// No description provided for @pokedexSortAscendingShort.
  ///
  /// In en, this message translates to:
  /// **'Asc'**
  String get pokedexSortAscendingShort;

  /// No description provided for @pokedexSortDescendingShort.
  ///
  /// In en, this message translates to:
  /// **'Desc'**
  String get pokedexSortDescendingShort;

  /// No description provided for @favoritesRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoritesRemoveAction;

  /// No description provided for @favoritesAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favoritesAddAction;
}
class AppLocalizationsEN extends AppLocalizations {
  AppLocalizationsEN(): super('en');
  @override
  String get appTitle => 'Pokédex GraphQL';
  @override
  String get homeHeaderTitle => 'ProDex';
  @override
  String get homeQuickAccessGymLeaders => 'Gym Leaders & Elite 4';
  @override
  String get homeQuickAccessNatures => 'Natures';
  @override
  String get homeQuickAccessMatchups => 'Type Matchups';
  @override
  String get homeQuickAccessEvolutionChains => 'Evolution Chains';
  @override
  String get homeQuickAccessBreeding => 'Breeding Guides';
  @override
  String get homeQuickAccessBerries => 'Berry Farming';
  @override
  String get authLoginTitle => 'Welcome back';
  @override
  String get authLoginSubtitle => 'Sign in with your email to access your Pokédex.';
  @override
  String get authEmailLabel => 'Email';
  @override
  String get authEmailHint => 'ash.ketchum@poke.app';
  @override
  String get authPasswordLabel => 'Password';
  @override
  String get authLoginButton => 'Sign in';
  @override
  String get authNoAccountCta => 'Don\'t have an account? Sign up';
  @override
  String get authLoginError => 'We couldn\'t sign you in. Try again.';
  @override
  String get authEmailRequired => 'Enter your email.';
  @override
  String get authEmailInvalid => 'Invalid email format.';
  @override
  String get authPasswordRequired => 'Enter your password.';
  @override
  String get authPasswordLength => 'The password must contain at least 6 characters.';
  @override
  String get authRegisterTitle => 'Create your account';
  @override
  String get authRegisterSubtitle => 'Register to sync your teams and collections across all your devices.';
  @override
  String get authCreateAccountButton => 'Create account';
  @override
  String get authAlreadyHaveAccountCta => 'Already have an account? Sign in';
  @override
  String get authRegisterError => 'We couldn\'t create your account. Try again later.';
  @override
  String get authSecurePasswordRequired => 'Enter a secure password.';
  @override
  String get authPasswordStrongSuggestion => 'Use letters and numbers for a stronger password.';
  @override
  String get authConfirmPasswordLabel => 'Confirm password';
  @override
  String get authPasswordsMismatch => 'Passwords do not match.';
  @override
  String get authSnackbarNoUser => 'User information is not available.';
  @override
  String get authProfileUpdated => 'Profile updated successfully.';
  @override
  String get authProfileUpdateError => 'We couldn\'t update the profile.';
  @override
  String get authUpdateInfoTitle => 'Update your login information.';
  @override
  String get authUpdateInfoSubtitle => 'Change your email address or set a new password. Changes apply immediately.';
  @override
  String get authNewPasswordOptionalLabel => 'New password (optional)';
  @override
  String get settingsTitle => 'Settings';
  @override
  String get settingsAccountSection => 'Account';
  @override
  String get settingsNoEmail => 'No email on record';
  @override
  String get settingsEditProfile => 'Edit profile';
  @override
  String get settingsSignOut => 'Sign out';
  @override
  String get settingsAppearanceSection => 'Appearance';
  @override
  String get settingsLanguageSection => 'Language';
  @override
  String get settingsLanguageLabel => 'App language';
  @override
  String get settingsLanguageEnglish => 'English';
  @override
  String get settingsLanguageSpanish => 'Spanish';
  @override
  String get settingsLightModeTitle => 'Light mode';
  @override
  String get settingsLightModeSubtitle => 'Bright backgrounds for well-lit environments.';
  @override
  String get settingsDarkModeTitle => 'Dark mode';
  @override
  String get settingsDarkModeSubtitle => 'Dim the lights to reduce eye strain at night.';
  @override
  String get settingsInfo => 'Settings save immediately and affect the entire app.';
  @override
  String get settingsSaveChanges => 'Save changes';
  @override
  String get favoritesDefaultTitle => 'Favorites';
  @override
  String get favoritesEmptyTitle => 'You don\'t have favorite Pokémon yet.';
  @override
  String get favoritesEmptySubtitle => 'Explore the Pokédex and tap the heart to save your favorites.';
  @override
  String get homeQuickAccessTitle => 'Quick access';
  @override
  String get homeSectionPokedexTitle => 'Pokédex';
  @override
  String get homeSectionPokedexSubtitle => 'National index & regional dexes';
  @override
  String get homeSectionFavoritesTitle => 'Favorites';
  @override
  String get homeSectionFavoritesSubtitle => 'Your saved Pokémon';
  @override
  String get homeSectionMovesTitle => 'Moves';
  @override
  String get homeSectionMovesSubtitle => 'Damage, effects & contest data';
  @override
  String get homeSectionTmTitle => 'TM';
  @override
  String get homeSectionTmSubtitle => 'Machines & tutors by generation';
  @override
  String get homeSectionAbilitiesTitle => 'Abilities';
  @override
  String get homeSectionAbilitiesSubtitle => 'Passive effects & triggers';
  @override
  String get homeSectionChecklistsTitle => 'Checklists';
  @override
  String get homeSectionChecklistsSubtitle => 'Track goals & collections';
  @override
  String get homeSectionPartiesTitle => 'Parties';
  @override
  String get homeSectionPartiesSubtitle => 'Build teams & strategies';
  @override
  String get homeSectionLocationsTitle => 'Locations';
  @override
  String get homeSectionLocationsSubtitle => 'Regions, maps & encounter data';
  @override
  String homeSectionCardSemanticLabel({required String sectionName}) =>
      'Open the ${sectionName} section';
  @override
  String homeSectionCardSemanticHint({required String sectionName}) =>
      'Double tap to navigate to ${sectionName}';
  @override
  String get homeNotificationsSemanticLabel => 'Notifications';
  @override
  String get homeNotificationsSemanticHint => 'Opens notifications and alerts';
  @override
  String get homeStoreSemanticLabel => 'Shop';
  @override
  String get homeStoreSemanticHint => 'Opens the in-app shop';
  @override
  String get homeSettingsSemanticLabel => 'Settings';
  @override
  String get homeSettingsSemanticHint => 'Opens app settings';
  @override
  String homePlaceholderMessage({required String sectionName}) => 'The ${sectionName} section will be available soon.';
  @override
  String get abilitiesDefaultTitle => 'Abilities';
  @override
  String get abilitiesSearchHint => 'Search ability…';
  @override
  String get abilitiesErrorMessage => 'We couldn’t load the abilities.';
  @override
  String get commonRetry => 'Retry';
  @override
  String get abilitiesEmptySearch => 'We couldn’t find abilities that match your search.';
  @override
  String get abilitiesEmptyGeneral => 'No abilities are available right now.';
  @override
  String get abilitiesNoDescription => 'No description available.';
  @override
  String get abilitiesNoShortDescription => 'No short description available.';
  @override
  String get abilitiesFullDescriptionTitle => 'Full description';
  @override
  String get abilitiesFullDescriptionFallback => 'No description is available in this language.';
  @override
  String get abilitiesPokemonSectionTitle => 'Pokémon with this ability';
  @override
  String get abilitiesPokemonEmpty => 'We couldn’t find Pokémon associated with this ability.';
  @override
  String get abilitiesPokemonErrorTitle => 'We couldn’t load the associated Pokémon.';
  @override
  String get abilitiesPokemonErrorDescription => 'Try again to see which Pokémon have this ability.';
  @override
  String abilityCardSemanticLabel({required String abilityName}) =>
      'Open ability ${abilityName}';
  @override
  String abilityCardSemanticHint({required String abilityName}) =>
      'Double tap to see details for ${abilityName}';
  @override
  String get pokedexSortNumberLabel => 'Number';
  @override
  String get pokedexSortNameLabel => 'Name';
  @override
  String get pokedexSortHeightLabel => 'Height';
  @override
  String get pokedexSortWeightLabel => 'Weight';
  @override
  String pokedexCardSemanticLabel({required String pokemonName}) =>
      'Open ${pokemonName} details';
  @override
  String pokedexCardSemanticHint({required String pokemonName}) =>
      'Double tap to view ${pokemonName} in the Pokédex';
  @override
  String get pokedexSearchHint => 'Search by name or number';
  @override
  String get pokedexFiltersTooltip => 'Filters';
  @override
  String get pokedexOfflineNoCache => 'No connection and no cached data available.';
  @override
  String get pokedexOfflineBanner => 'Offline mode active. Showing cached data.';
  @override
  String get pokedexConnectionRestored => 'Connection restored.';
  @override
  String get pokedexLoadError => 'We couldn’t load the Pokédex. Try again.';
  @override
  String get pokedexOfflineFiltersLimited => 'Offline mode active. Some filters may be limited.';
  @override
  String pokedexShowingCountSimple({required int count}) => 'Showing ${count} Pokémon.';
  @override
  String pokedexShowingCountWithTotal({required int count, required int total}) => 'Showing ${count} of ${total} Pokémon.';
  @override
  String pokedexActiveFilters(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: 'count',
      other: 'count',
    );
  }
  @override
  String get pokedexSortDirectionAscending => 'ascending';
  @override
  String get pokedexSortDirectionDescending => 'descending';
  @override
  String pokedexFilterSummarySearch({required String query}) => 'Search: ${query}';
  @override
  String pokedexFilterSummaryType({required String value}) => 'Type: ${value}';
  @override
  String pokedexFilterSummaryGeneration({required String value}) => 'Generation: ${value}';
  @override
  String pokedexFilterSummaryRegion({required String value}) => 'Region: ${value}';
  @override
  String pokedexFilterSummaryShape({required String value}) => 'Form: ${value}';
  @override
  String pokedexFilterSummarySort({required String value}) => 'Sort: ${value}';
  @override
  String get pokedexNoResults => 'No Pokémon match the current filters.';
  @override
  String get pokedexFiltersTitle => 'Filters';
  @override
  String get pokedexFiltersCloseTooltip => 'Close';
  @override
  String get pokedexFilterSectionTypes => 'Types';
  @override
  String get pokedexFilterSectionGenerations => 'Generations';
  @override
  String get pokedexFilterSectionRegions => 'Regions';
  @override
  String get pokedexFilterSectionShapes => 'Shapes';
  @override
  String get pokedexFilterEmptyTypes => 'No types available right now.';
  @override
  String get pokedexFilterEmptyGenerations => 'No generations available right now.';
  @override
  String get pokedexFilterEmptyRegions => 'No regions available right now.';
  @override
  String get pokedexFilterEmptyShapes => 'No shapes available right now.';
  @override
  String get pokedexFiltersClear => 'Clear';
  @override
  String get commonCancel => 'Cancel';
  @override
  String get commonApply => 'Apply';
  @override
  String get detailOfflineModeSnack => 'Offline mode active. Showing locally saved data.';
  @override
  String get detailConnectionRestored => 'Connection restored.';
  @override
  String get detailOfflineBanner => 'Offline mode active. Some advanced data may not be available.';
  @override
  String get detailFallbackTitle => 'Pokémon details';
  @override
  String get detailTabInformation => 'Information';
  @override
  String get detailTabStatistics => 'Statistics';
  @override
  String get detailTabMatchups => 'Matchups';
  @override
  String get detailTabEvolutions => 'Evolutions';
  @override
  String get detailTabMoves => 'Moves';
  @override
  String get detailNoDataFound => 'We couldn\'t find information for this Pokémon.';
  @override
  String get detailOfflineShortMessage => 'Offline mode: showing saved information.';
  @override
  String get detailOfflineLongMessage => 'Detailed information isn\'t available without a connection. Try again when you\'re back online.';
  @override
  String get detailFavoriteRemoveTooltip => 'Remove from favorites';
  @override
  String get detailFavoriteAddTooltip => 'Add to favorites';
  @override
  String get detailHiddenAbilityLabel => 'Hidden ability';
  @override
  String get detailMainAbilityLabel => 'Main ability';
  @override
  String get detailLoadErrorDescription => 'We couldn\'t load the Pokémon details.\nCheck your connection or try again.';
  @override
  String get detailCharacteristicHeight => 'Height';
  @override
  String get detailCharacteristicWeight => 'Weight';
  @override
  String get detailCharacteristicCategory => 'Category';
  @override
  String get detailCharacteristicNoCategory => 'No category';
  @override
  String get detailCharacteristicCatchRate => 'Catch rate';
  @override
  String get detailCharacteristicBaseExperience => 'Base experience';
  @override
  String get detailNoWeaknessInfo => 'No weakness information available.';
  @override
  String get detailWeaknessLegendQuadruple =>
      'Double weakness: damage taken is multiplied by four.';
  @override
  String get detailWeaknessLegendDouble => 'Classic weakness: super effective attacks.';
  @override
  String get detailWeaknessLegendModerate =>
      'Moderate advantage: slightly increased damage.';
  @override
  String get detailWeaknessToggleShow => 'Show weaknesses';
  @override
  String get detailWeaknessToggleHide => 'Hide weaknesses';
  @override
  String get pokedexSortSheetTitle => 'Sort by';
  @override
  String get pokedexSortCriteriaLabel => 'Criterion';
  @override
  String get pokedexSortDirectionLabel => 'Direction';
  @override
  String get pokedexSortAscendingShort => 'Asc';
  @override
  String get pokedexSortDescendingShort => 'Desc';
  @override
  String get favoritesRemoveAction => 'Remove from favorites';
  @override
  String get favoritesAddAction => 'Add to favorites';
}

class AppLocalizationsES extends AppLocalizations {
  AppLocalizationsES(): super('es');
  @override
  String get appTitle => 'Pokédex GraphQL';
  @override
  String get homeHeaderTitle => 'ProDex';
  @override
  String get homeQuickAccessGymLeaders => 'Líderes de Gimnasio y Alto Mando';
  @override
  String get homeQuickAccessNatures => 'Naturalezas';
  @override
  String get homeQuickAccessMatchups => 'Enfrentamientos de tipos';
  @override
  String get homeQuickAccessEvolutionChains => 'Cadenas evolutivas';
  @override
  String get homeQuickAccessBreeding => 'Guías de crianza';
  @override
  String get homeQuickAccessBerries => 'Cultivo de bayas';
  @override
  String get authLoginTitle => 'Bienvenido de nuevo';
  @override
  String get authLoginSubtitle => 'Inicia sesión con tu correo electrónico para acceder a tu Pokédex.';
  @override
  String get authEmailLabel => 'Correo electrónico';
  @override
  String get authEmailHint => 'ash.ketchum@poke.app';
  @override
  String get authPasswordLabel => 'Contraseña';
  @override
  String get authLoginButton => 'Iniciar sesión';
  @override
  String get authNoAccountCta => '¿No tienes cuenta? Regístrate';
  @override
  String get authLoginError => 'No fue posible iniciar sesión. Inténtalo de nuevo.';
  @override
  String get authEmailRequired => 'Ingresa tu correo electrónico.';
  @override
  String get authEmailInvalid => 'Formato de correo inválido.';
  @override
  String get authPasswordRequired => 'Ingresa tu contraseña.';
  @override
  String get authPasswordLength => 'La contraseña debe tener al menos 6 caracteres.';
  @override
  String get authRegisterTitle => 'Crea tu cuenta';
  @override
  String get authRegisterSubtitle => 'Regístrate para sincronizar tus equipos y colecciones en todos tus dispositivos.';
  @override
  String get authCreateAccountButton => 'Crear cuenta';
  @override
  String get authAlreadyHaveAccountCta => '¿Ya tienes una cuenta? Inicia sesión';
  @override
  String get authRegisterError => 'No pudimos crear tu cuenta. Inténtalo más tarde.';
  @override
  String get authSecurePasswordRequired => 'Ingresa una contraseña segura.';
  @override
  String get authPasswordStrongSuggestion => 'Usa letras y números para una contraseña más fuerte.';
  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';
  @override
  String get authPasswordsMismatch => 'Las contraseñas no coinciden.';
  @override
  String get authSnackbarNoUser => 'No hay información de usuario disponible.';
  @override
  String get authProfileUpdated => 'Perfil actualizado correctamente.';
  @override
  String get authProfileUpdateError => 'No fue posible actualizar el perfil.';
  @override
  String get authUpdateInfoTitle => 'Actualiza tu información de acceso.';
  @override
  String get authUpdateInfoSubtitle => 'Puedes cambiar tu correo electrónico o establecer una nueva contraseña. Los cambios se aplican inmediatamente.';
  @override
  String get authNewPasswordOptionalLabel => 'Nueva contraseña (opcional)';
  @override
  String get settingsTitle => 'Configuración';
  @override
  String get settingsAccountSection => 'Cuenta';
  @override
  String get settingsNoEmail => 'Sin correo registrado';
  @override
  String get settingsEditProfile => 'Editar perfil';
  @override
  String get settingsSignOut => 'Cerrar sesión';
  @override
  String get settingsAppearanceSection => 'Apariencia';
  @override
  String get settingsLanguageSection => 'Idioma';
  @override
  String get settingsLanguageLabel => 'Idioma de la app';
  @override
  String get settingsLanguageEnglish => 'Inglés';
  @override
  String get settingsLanguageSpanish => 'Español';
  @override
  String get settingsLightModeTitle => 'Modo claro';
  @override
  String get settingsLightModeSubtitle => 'Fondos luminosos ideales para entornos bien iluminados.';
  @override
  String get settingsDarkModeTitle => 'Modo oscuro';
  @override
  String get settingsDarkModeSubtitle => 'Atenúa la luz para reducir el cansancio visual por la noche.';
  @override
  String get settingsInfo => 'La configuración se guarda inmediatamente y afecta a toda la aplicación.';
  @override
  String get settingsSaveChanges => 'Guardar cambios';
  @override
  String get favoritesDefaultTitle => 'Favoritos';
  @override
  String get favoritesEmptyTitle => 'Aún no tienes Pokémon favoritos.';
  @override
  String get favoritesEmptySubtitle => 'Explora la Pokédex y marca con el corazón los Pokémon que quieras guardar.';
  @override
  String get homeQuickAccessTitle => 'Accesos rápidos';
  @override
  String get homeSectionPokedexTitle => 'Pokédex';
  @override
  String get homeSectionPokedexSubtitle => 'Índice nacional y pokédex regionales';
  @override
  String get homeSectionFavoritesTitle => 'Favoritos';
  @override
  String get homeSectionFavoritesSubtitle => 'Tus Pokémon guardados';
  @override
  String get homeSectionMovesTitle => 'Movimientos';
  @override
  String get homeSectionMovesSubtitle => 'Daño, efectos y datos de concursos';
  @override
  String get homeSectionTmTitle => 'MT';
  @override
  String get homeSectionTmSubtitle => 'Máquinas y tutores por generación';
  @override
  String get homeSectionAbilitiesTitle => 'Habilidades';
  @override
  String get homeSectionAbilitiesSubtitle => 'Efectos pasivos y activadores';
  @override
  String get homeSectionChecklistsTitle => 'Listas de control';
  @override
  String get homeSectionChecklistsSubtitle => 'Sigue metas y colecciones';
  @override
  String get homeSectionPartiesTitle => 'Equipos';
  @override
  String get homeSectionPartiesSubtitle => 'Arma equipos y estrategias';
  @override
  String get homeSectionLocationsTitle => 'Ubicaciones';
  @override
  String get homeSectionLocationsSubtitle => 'Regiones, mapas y datos de encuentros';
  @override
  String homeSectionCardSemanticLabel({required String sectionName}) =>
      'Abrir la sección ${sectionName}';
  @override
  String homeSectionCardSemanticHint({required String sectionName}) =>
      'Toca dos veces para ir a ${sectionName}';
  @override
  String get homeNotificationsSemanticLabel => 'Notificaciones';
  @override
  String get homeNotificationsSemanticHint =>
      'Abre tus notificaciones y alertas';
  @override
  String get homeStoreSemanticLabel => 'Tienda';
  @override
  String get homeStoreSemanticHint => 'Abre la tienda de la app';
  @override
  String get homeSettingsSemanticLabel => 'Ajustes';
  @override
  String get homeSettingsSemanticHint => 'Abre la configuración de la app';
  @override
  String homePlaceholderMessage({required String sectionName}) => 'La sección de ${sectionName} estará disponible pronto.';
  @override
  String get abilitiesDefaultTitle => 'Habilidades';
  @override
  String get abilitiesSearchHint => 'Buscar habilidad…';
  @override
  String get abilitiesErrorMessage => 'No se pudieron cargar las habilidades.';
  @override
  String get commonRetry => 'Reintentar';
  @override
  String get abilitiesEmptySearch => 'No encontramos habilidades que coincidan con tu búsqueda.';
  @override
  String get abilitiesEmptyGeneral => 'No hay habilidades disponibles en este momento.';
  @override
  String get abilitiesNoDescription => 'Sin descripción disponible.';
  @override
  String get abilitiesNoShortDescription => 'Sin descripción breve disponible.';
  @override
  String get abilitiesFullDescriptionTitle => 'Descripción completa';
  @override
  String get abilitiesFullDescriptionFallback => 'Sin descripción disponible en este idioma.';
  @override
  String get abilitiesPokemonSectionTitle => 'Pokémon que la poseen';
  @override
  String get abilitiesPokemonEmpty => 'No encontramos Pokémon asociados a esta habilidad.';
  @override
  String get abilitiesPokemonErrorTitle => 'No pudimos cargar los Pokémon asociados.';
  @override
  String get abilitiesPokemonErrorDescription => 'Intenta nuevamente para ver qué Pokémon cuentan con esta habilidad.';
  @override
  String abilityCardSemanticLabel({required String abilityName}) =>
      'Abrir la habilidad ${abilityName}';
  @override
  String abilityCardSemanticHint({required String abilityName}) =>
      'Toca dos veces para ver detalles de ${abilityName}';
  @override
  String get pokedexSortNumberLabel => 'Número';
  @override
  String get pokedexSortNameLabel => 'Nombre';
  @override
  String get pokedexSortHeightLabel => 'Altura';
  @override
  String get pokedexSortWeightLabel => 'Peso';
  @override
  String pokedexCardSemanticLabel({required String pokemonName}) =>
      'Abrir detalles de ${pokemonName}';
  @override
  String pokedexCardSemanticHint({required String pokemonName}) =>
      'Toca dos veces para ver a ${pokemonName} en la Pokédex';
  @override
  String get pokedexSearchHint => 'Buscar por nombre o número';
  @override
  String get pokedexFiltersTooltip => 'Filtros';
  @override
  String get pokedexOfflineNoCache => 'Sin conexión y sin datos guardados localmente.';
  @override
  String get pokedexOfflineBanner => 'Modo offline activo. Mostrando datos guardados localmente.';
  @override
  String get pokedexConnectionRestored => 'Conexión restablecida.';
  @override
  String get pokedexLoadError => 'No se pudo cargar la Pokédex. Intenta nuevamente.';
  @override
  String get pokedexOfflineFiltersLimited => 'Modo offline activo. Algunos filtros pueden ser limitados.';
  @override
  String pokedexShowingCountSimple({required int count}) => 'Mostrando ${count} Pokémon.';
  @override
  String pokedexShowingCountWithTotal({required int count, required int total}) => 'Mostrando ${count} de ${total} Pokémon.';
  @override
  String pokedexActiveFilters(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: 'count',
      other: 'count',
    );
  }
  @override
  String get pokedexSortDirectionAscending => 'ascendente';
  @override
  String get pokedexSortDirectionDescending => 'descendente';
  @override
  String pokedexFilterSummarySearch({required String query}) => 'Búsqueda: ${query}';
  @override
  String pokedexFilterSummaryType({required String value}) => 'Tipo: ${value}';
  @override
  String pokedexFilterSummaryGeneration({required String value}) => 'Generación: ${value}';
  @override
  String pokedexFilterSummaryRegion({required String value}) => 'Región: ${value}';
  @override
  String pokedexFilterSummaryShape({required String value}) => 'Forma: ${value}';
  @override
  String pokedexFilterSummarySort({required String value}) => 'Orden: ${value}';
  @override
  String get pokedexNoResults => 'No se encontraron Pokémon para los filtros actuales.';
  @override
  String get pokedexFiltersTitle => 'Filtros';
  @override
  String get pokedexFiltersCloseTooltip => 'Cerrar';
  @override
  String get pokedexFilterSectionTypes => 'Tipos';
  @override
  String get pokedexFilterSectionGenerations => 'Generaciones';
  @override
  String get pokedexFilterSectionRegions => 'Regiones';
  @override
  String get pokedexFilterSectionShapes => 'Formas';
  @override
  String get pokedexFilterEmptyTypes => 'No hay tipos disponibles por ahora.';
  @override
  String get pokedexFilterEmptyGenerations => 'No hay generaciones disponibles por ahora.';
  @override
  String get pokedexFilterEmptyRegions => 'No hay regiones disponibles por ahora.';
  @override
  String get pokedexFilterEmptyShapes => 'No hay formas disponibles por ahora.';
  @override
  String get pokedexFiltersClear => 'Limpiar';
  @override
  String get commonCancel => 'Cancelar';
  @override
  String get commonApply => 'Aplicar';
  @override
  String get detailOfflineModeSnack => 'Modo offline activo. Mostrando datos guardados localmente.';
  @override
  String get detailConnectionRestored => 'Conexión restablecida.';
  @override
  String get detailOfflineBanner => 'Modo offline activo. Algunos datos avanzados pueden no estar disponibles.';
  @override
  String get detailFallbackTitle => 'Detalles del Pokémon';
  @override
  String get detailTabInformation => 'Información';
  @override
  String get detailTabStatistics => 'Estadísticas';
  @override
  String get detailTabMatchups => 'Enfrentamientos';
  @override
  String get detailTabEvolutions => 'Evoluciones';
  @override
  String get detailTabMoves => 'Movimientos';
  @override
  String get detailNoDataFound => 'No se encontró información para este Pokémon.';
  @override
  String get detailOfflineShortMessage => 'Modo offline: mostrando información guardada.';
  @override
  String get detailOfflineLongMessage => 'La información detallada no está disponible sin conexión. Intenta nuevamente cuando recuperes internet.';
  @override
  String get detailFavoriteRemoveTooltip => 'Quitar de favoritos';
  @override
  String get detailFavoriteAddTooltip => 'Agregar a favoritos';
  @override
  String get detailHiddenAbilityLabel => 'Habilidad oculta';
  @override
  String get detailMainAbilityLabel => 'Habilidad principal';
  @override
  String get detailLoadErrorDescription => 'No se pudo obtener los datos del Pokémon.\nVerifica tu conexión o intenta de nuevo.';
  @override
  String get detailCharacteristicHeight => 'Altura';
  @override
  String get detailCharacteristicWeight => 'Peso';
  @override
  String get detailCharacteristicCategory => 'Categoría';
  @override
  String get detailCharacteristicNoCategory => 'Sin categoría';
  @override
  String get detailCharacteristicCatchRate => 'Ratio de captura';
  @override
  String get detailCharacteristicBaseExperience => 'Experiencia base';
  @override
  String get detailNoWeaknessInfo => 'No hay información de debilidades disponible.';
  @override
  String get detailWeaknessLegendQuadruple =>
      'Doble debilidad: el daño recibido se multiplica por cuatro.';
  @override
  String get detailWeaknessLegendDouble => 'Debilidad clásica: ataques súper efectivos.';
  @override
  String get detailWeaknessLegendModerate =>
      'Ventaja moderada: daño ligeramente incrementado.';
  @override
  String get detailWeaknessToggleShow => 'Ver debilidades';
  @override
  String get detailWeaknessToggleHide => 'Ocultar debilidades';
  @override
  String get pokedexSortSheetTitle => 'Ordenar por';
  @override
  String get pokedexSortCriteriaLabel => 'Criterio';
  @override
  String get pokedexSortDirectionLabel => 'Dirección';
  @override
  String get pokedexSortAscendingShort => 'Asc';
  @override
  String get pokedexSortDescendingShort => 'Desc';
  @override
  String get favoritesRemoveAction => 'Quitar de favoritos';
  @override
  String get favoritesAddAction => 'Agregar a favoritos';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
