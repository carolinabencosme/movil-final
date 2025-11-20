// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get authLoginSubtitle =>
      'Sign in with your email to access your Pokédex.';

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
  String get authPasswordLength =>
      'The password must contain at least 6 characters.';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle =>
      'Register to sync your teams and collections across all your devices.';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authAlreadyHaveAccountCta => 'Already have an account? Sign in';

  @override
  String get authRegisterError =>
      'We couldn\'t create your account. Try again later.';

  @override
  String get authSecurePasswordRequired => 'Enter a secure password.';

  @override
  String get authPasswordStrongSuggestion =>
      'Use letters and numbers for a stronger password.';

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
  String get authUpdateInfoSubtitle =>
      'Change your email address or set a new password. Changes apply immediately.';

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
  String get settingsLightModeSubtitle =>
      'Bright backgrounds for well-lit environments.';

  @override
  String get settingsDarkModeTitle => 'Dark mode';

  @override
  String get settingsDarkModeSubtitle =>
      'Dim the lights to reduce eye strain at night.';

  @override
  String get settingsInfo =>
      'Settings save immediately and affect the entire app.';

  @override
  String get settingsSaveChanges => 'Save changes';

  @override
  String get favoritesDefaultTitle => 'Favorites';

  @override
  String get favoritesEmptyTitle => 'You don\'t have favorite Pokémon yet.';

  @override
  String get favoritesEmptySubtitle =>
      'Explore the Pokédex and tap the heart to save your favorites.';

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
  String homeSectionCardSemanticLabel(String sectionName) {
    return 'Open the $sectionName section';
  }

  @override
  String homeSectionCardSemanticHint(String sectionName) {
    return 'Double tap to navigate to $sectionName';
  }

  @override
  String get detailInfoTypesTitle => 'Types';

  @override
  String get detailInfoTypesFallback => 'No type information available.';

  @override
  String get detailInfoBasicDataTitle => 'Basic data';

  @override
  String get detailCharacteristicHeight => 'Height';

  @override
  String get detailInfoHeightLabel => 'Height';

  @override
  String get detailCharacteristicWeight => 'Weight';

  @override
  String get detailInfoWeightLabel => 'Weight';

  @override
  String get detailInfoViewOnMap => 'View on map';

  @override
  String get detailCharacteristicCategory => 'Category';

  @override
  String get detailCharacteristicNoCategory => 'No category';

  @override
  String get detailCharacteristicCatchRate => 'Catch rate';

  @override
  String get detailCharacteristicBaseExperience => 'Base experience';

  @override
  String get detailInfoCharacteristicsTitle => 'Characteristics';

  @override
  String get detailInfoAbilitiesTitle => 'Abilities';

  @override
  String get detailInfoAbilitiesFallback => 'No ability information available.';

  @override
  String get detailInfoMainAbilityFallback => 'No main ability available.';

  @override
  String get detailStatsTitle => 'Stats';

  @override
  String get detailStatsFallback => 'No stat information available.';

  @override
  String get detailMatchupsWeaknessesTitle => 'Weaknesses';

  @override
  String get detailMatchupsResistancesTitle => 'Resistances & immunities';

  @override
  String get detailEvolutionChainTitle => 'Evolution chain';

  @override
  String get detailNoWeaknessInfo => 'No weakness information available.';

  @override
  String get detailWeaknessLegendQuadruple =>
      'Double weakness: damage taken is multiplied by four.';

  @override
  String get detailWeaknessLegendDouble =>
      'Classic weakness: super effective attacks.';

  @override
  String get detailWeaknessLegendModerate =>
      'Moderate advantage: slightly increased damage.';

  @override
  String get detailWeaknessToggleShow => 'Show weaknesses';

  @override
  String get detailWeaknessToggleHide => 'Hide weaknesses';

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
  String homePlaceholderMessage(String sectionName) {
    return 'The $sectionName section will be available soon.';
  }

  @override
  String get abilitiesDefaultTitle => 'Abilities';

  @override
  String get abilitiesSearchHint => 'Search ability…';

  @override
  String get abilitiesErrorMessage => 'We couldn’t load the abilities.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get abilitiesEmptySearch =>
      'We couldn’t find abilities that match your search.';

  @override
  String get abilitiesEmptyGeneral => 'No abilities are available right now.';

  @override
  String get abilitiesNoDescription => 'No description available.';

  @override
  String get abilitiesNoShortDescription => 'No short description available.';

  @override
  String get abilitiesFullDescriptionTitle => 'Full description';

  @override
  String get abilitiesFullDescriptionFallback =>
      'No description is available in this language.';

  @override
  String get abilitiesPokemonSectionTitle => 'Pokémon with this ability';

  @override
  String get abilitiesPokemonEmpty =>
      'We couldn’t find Pokémon associated with this ability.';

  @override
  String get abilitiesPokemonErrorTitle =>
      'We couldn’t load the associated Pokémon.';

  @override
  String get abilitiesPokemonErrorDescription =>
      'Try again to see which Pokémon have this ability.';

  @override
  String get pokedexSortNumberLabel => 'Number';

  @override
  String get pokedexSortNameLabel => 'Name';

  @override
  String get pokedexSortHeightLabel => 'Height';

  @override
  String get pokedexSortWeightLabel => 'Weight';

  @override
  String abilityCardSemanticLabel(String abilityName) {
    return 'Open ability $abilityName';
  }

  @override
  String abilityCardSemanticHint(String abilityName) {
    return 'Double tap to see details for $abilityName';
  }

  @override
  String pokedexCardSemanticLabel(String pokemonName) {
    return 'Open $pokemonName details';
  }

  @override
  String pokedexCardSemanticHint(String pokemonName) {
    return 'Double tap to view $pokemonName in the Pokédex';
  }

  @override
  String get pokedexSearchHint => 'Search by name or number';

  @override
  String get pokedexFiltersTooltip => 'Filters';

  @override
  String get pokedexOfflineNoCache =>
      'No connection and no cached data available.';

  @override
  String get pokedexOfflineBanner =>
      'Offline mode active. Showing cached data.';

  @override
  String get pokedexConnectionRestored => 'Connection restored.';

  @override
  String get pokedexLoadError => 'We couldn’t load the Pokédex. Try again.';

  @override
  String get pokedexOfflineFiltersLimited =>
      'Offline mode active. Some filters may be limited.';

  @override
  String pokedexShowingCountSimple(int visible) {
    return 'Showing $visible Pokémon.';
  }

  @override
  String pokedexShowingCountWithTotal(int visible, int total) {
    return 'Showing $visible of $total Pokémon.';
  }

  @override
  String pokedexActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active filters',
      one: '$count active filter',
    );
    return '$_temp0';
  }

  @override
  String get pokedexSortDirectionAscending => 'ascending';

  @override
  String get pokedexSortDirectionDescending => 'descending';

  @override
  String pokedexFilterSummarySearch(String query) {
    return 'Search: $query';
  }

  @override
  String pokedexFilterSummaryType(String value) {
    return 'Type: $value';
  }

  @override
  String pokedexFilterSummaryGeneration(String value) {
    return 'Generation: $value';
  }

  @override
  String pokedexFilterSummaryRegion(String value) {
    return 'Region: $value';
  }

  @override
  String pokedexFilterSummaryShape(String value) {
    return 'Form: $value';
  }

  @override
  String pokedexFilterSummarySort(String value) {
    return 'Sort: $value';
  }

  @override
  String get pokedexNoResults => 'No Pokémon match the current filters.';

  @override
  String get pokedexFiltersTitle => 'Filters';

  @override
  String get pokedexFiltersCloseTooltip => 'Close';

  @override
  String get pokedexFiltersCancel => 'Cancel';

  @override
  String get pokedexFiltersApply => 'Apply';

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
  String get pokedexFilterEmptyGenerations =>
      'No generations available right now.';

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
  String get detailOfflineModeSnack =>
      'Offline mode active. Showing locally saved data.';

  @override
  String get detailConnectionRestored => 'Connection restored.';

  @override
  String get detailOfflineBanner =>
      'Offline mode active. Some advanced data may not be available.';

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
  String get detailMovesTitle => 'Moves';

  @override
  String get detailMovesFilterSheetTitle => 'Filter moves';

  @override
  String get detailMovesFilterMethodTitle => 'Learning method';

  @override
  String get detailMovesFilterMethodAll => 'All methods';

  @override
  String get detailMovesFilterMethodUnknown => 'Unknown';

  @override
  String get detailMovesFilterButtonLabel => 'Filters';

  @override
  String get detailMovesFilterVersionTitle => 'Game version';

  @override
  String get detailMovesFilterVersionLabel => 'Version';

  @override
  String get detailMovesFilterAllVersions => 'All versions';

  @override
  String get detailMovesFilterOnlyWithLevel => 'Only moves with level';

  @override
  String get detailMovesResetButtonLabel => 'Reset filters';

  @override
  String detailMovesCountText(int visibleMoves, int totalMoves) {
    return 'Showing $visibleMoves of $totalMoves moves';
  }

  @override
  String get detailMovesCountSemanticLabel => 'Visible moves counter';

  @override
  String get detailNoDataFound =>
      'We couldn\'t find information for this Pokémon.';

  @override
  String get detailOfflineShortMessage =>
      'Offline mode: showing saved information.';

  @override
  String get detailOfflineLongMessage =>
      'Detailed information isn\'t available without a connection. Try again when you\'re back online.';

  @override
  String get detailFavoriteRemoveTooltip => 'Remove from favorites';

  @override
  String get detailFavoriteAddTooltip => 'Add to favorites';

  @override
  String get detailHiddenAbilityLabel => 'Hidden ability';

  @override
  String get detailMainAbilityLabel => 'Main ability';

  @override
  String get detailLoadErrorDescription =>
      'We couldn\'t load the Pokémon details.\nCheck your connection or try again.';

  @override
  String get pokedexSortSheetTitle => 'Sort by';

  @override
  String get pokedexSortCriteriaLabel => 'Criterion';

  @override
  String get pokedexSortDirectionLabel => 'Direction';

  @override
  String get pokedexSortAscendingLabel => 'Ascending';

  @override
  String get pokedexSortDescendingLabel => 'Descending';

  @override
  String get pokedexSortAscendingShort => 'Asc';

  @override
  String get pokedexSortDescendingShort => 'Desc';

  @override
  String get favoritesRemoveAction => 'Remove from favorites';

  @override
  String get favoritesAddAction => 'Add to favorites';
}
