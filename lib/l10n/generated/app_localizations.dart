import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

/// Callers can obtain localized strings through [AppLocalizations].
///
/// This class is normally generated via `flutter gen-l10n`, but the generated
/// output is stored in source control so it can be consumed without requiring
/// Flutter's synthetic package support.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// `Pokédex GraphQL`
  String get appTitle;

  /// `ProDex`
  String get homeTitle;

  /// `Pokédex`
  String get homeSectionPokedexTitle;

  /// `National index & regional dexes`
  String get homeSectionPokedexSubtitle;

  /// `Favorites`
  String get homeSectionFavoritesTitle;

  /// `Your saved Pokémon`
  String get homeSectionFavoritesSubtitle;

  /// `Moves`
  String get homeSectionMovesTitle;

  /// `Damage, effects & contest data`
  String get homeSectionMovesSubtitle;

  /// `TM`
  String get homeSectionTmTitle;

  /// `Machines & tutors by generation`
  String get homeSectionTmSubtitle;

  /// `Abilities`
  String get homeSectionAbilitiesTitle;

  /// `Passive effects & triggers`
  String get homeSectionAbilitiesSubtitle;

  /// `Checklists`
  String get homeSectionChecklistsTitle;

  /// `Track goals & collections`
  String get homeSectionChecklistsSubtitle;

  /// `Parties`
  String get homeSectionPartiesTitle;

  /// `Build teams & strategies`
  String get homeSectionPartiesSubtitle;

  /// `Locations`
  String get homeSectionLocationsTitle;

  /// `Regions, maps & encounter data`
  String get homeSectionLocationsSubtitle;

  /// `Gym Leaders & Elite 4`
  String get homeQuickAccessGym;

  /// `Natures`
  String get homeQuickAccessNatures;

  /// `Type Matchups`
  String get homeQuickAccessTypes;

  /// `Evolution Chains`
  String get homeQuickAccessEvolutions;

  /// `Breeding Guides`
  String get homeQuickAccessBreeding;

  /// `Berry Farming`
  String get homeQuickAccessBerries;

  /// `Open notifications`
  String get homeNotificationsLabel;

  /// `Open shop`
  String get homeShopLabel;

  /// `Open settings`
  String get homeSettingsLabel;

  /// `Settings`
  String get settingsTitle;

  /// `Account`
  String get settingsAccountTitle;

  /// `No email registered`
  String get settingsNoEmail;

  /// `Edit profile`
  String get settingsEditProfile;

  /// `Sign out`
  String get settingsLogout;

  /// `Appearance`
  String get settingsAppearance;

  /// `Light mode`
  String get settingsLightModeTitle;

  /// `Bright backgrounds ideal for well-lit environments.`
  String get settingsLightModeSubtitle;

  /// `Dark mode`
  String get settingsDarkModeTitle;

  /// `Dim the UI to reduce eye strain at night.`
  String get settingsDarkModeSubtitle;

  /// `Language`
  String get settingsLanguageTitle;

  /// `Choose how text is displayed across the app.`
  String get settingsLanguageSubtitle;

  /// `Use system language`
  String get settingsLanguageSystem;

  /// `English`
  String get settingsLanguageEnglish;

  /// `Spanish`
  String get settingsLanguageSpanish;

  /// `Changes are saved immediately and affect the entire app.`
  String get settingsInfoNote;

  /// `You haven't saved any Pokémon yet.`
  String get favoritesEmptyTitle;

  /// `Explore the Pokédex and tap the heart to keep your favorite Pokémon.`
  String get favoritesEmptyDescription;

  /// `We couldn't load the Pokédex. Please try again.`
  String get pokedexLoadError;

  /// `Offline mode active. Showing saved data.`
  String get pokedexOfflineSnack;

  /// `Offline mode active. Some filters may be limited.`
  String get pokedexOfflineBanner;

  /// `Connection restored.`
  String get pokedexConnectionRestored;

  /// `Search by name or number`
  String get pokedexSearchHint;

  /// `Filters`
  String get pokedexFiltersTooltip;

  /// `Showing {count} Pokémon`
  String pokedexShowingCount(Object count);

  /// `Showing {count} of {total} Pokémon`
  String pokedexShowingPartial(Object count, Object total);

  /// `ascending`
  String get pokedexSortAscending;

  /// `descending`
  String get pokedexSortDescending;

  /// `Asc`
  String get pokedexSortAscendingShort;

  /// `Desc`
  String get pokedexSortDescendingShort;

  /// `Filters`
  String get pokedexFiltersTitle;

  /// `Close`
  String get pokedexFiltersClose;

  /// `Types`
  String get pokedexFilterTypesTitle;

  /// `No types are available at the moment.`
  String get pokedexFilterTypesEmpty;

  /// `Generations`
  String get pokedexFilterGenerationsTitle;

  /// `No generations are available right now.`
  String get pokedexFilterGenerationsEmpty;

  /// `Regions`
  String get pokedexFilterRegionsTitle;

  /// `No regions are available right now.`
  String get pokedexFilterRegionsEmpty;

  /// `Shapes`
  String get pokedexFilterShapesTitle;

  /// `No shapes are available right now.`
  String get pokedexFilterShapesEmpty;

  /// `Sort by`
  String get pokedexFilterSortTitle;

  /// `Criterion`
  String get pokedexFilterSortCriterion;

  /// `Clear`
  String get pokedexFiltersClear;

  /// `Cancel`
  String get pokedexFiltersCancel;

  /// `Apply`
  String get pokedexFiltersApply;

  /// `Search: {term}`
  String pokedexActiveSearch(Object term);

  /// `Type: {value}`
  String pokedexActiveType(Object value);

  /// `Generation: {value}`
  String pokedexActiveGeneration(Object value);

  /// `Region: {value}`
  String pokedexActiveRegion(Object value);

  /// `Shape: {value}`
  String pokedexActiveShape(Object value);

  /// `Order: {criterion} {direction}`
  String pokedexActiveSort(Object criterion, Object direction);

  /// `{count, plural, one {{count} active filter} other {{count} active filters}}`
  String pokedexActiveFiltersSummary(int count);

  /// `No Pokémon match the current filters.`
  String get pokedexNoResults;

  /// `Number`
  String get pokedexSortByNumber;

  /// `Name`
  String get pokedexSortByName;

  /// `Height`
  String get pokedexSortByHeight;

  /// `Weight`
  String get pokedexSortByWeight;

  /// `Remove from favorites`
  String get pokedexFavoriteRemove;

  /// `Add to favorites`
  String get pokedexFavoriteAdd;

  /// `{name} artwork`
  String pokemonArtworkLabel(Object name);

  /// `Pokémon artwork`
  String get pokemonArtworkGeneric;

  /// `{name}, Pokédex number {number}`
  String pokemonTileLabel(Object name, Object number);

  /// `Double tap to open detailed information.`
  String get pokemonTileTapHint;

  /// `unknown`
  String get pokemonUnknownType;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool isSupported(Locale locale) {
    if (locale.languageCode.isEmpty) {
      return false;
    }
    for (final supportedLocale in AppLocalizations.supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return _AppLocalizationsEn();
    case 'es':
      return _AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "${locale.languageCode}".');
}

class _AppLocalizationsEn extends AppLocalizations {
  _AppLocalizationsEn() : super('en');

  @override
  String get appTitle => 'Pokédex GraphQL';

  @override
  String get homeTitle => 'ProDex';

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
  String get homeSectionLocationsSubtitle =>
      'Regions, maps & encounter data';

  @override
  String get homeQuickAccessGym => 'Gym Leaders & Elite 4';

  @override
  String get homeQuickAccessNatures => 'Natures';

  @override
  String get homeQuickAccessTypes => 'Type Matchups';

  @override
  String get homeQuickAccessEvolutions => 'Evolution Chains';

  @override
  String get homeQuickAccessBreeding => 'Breeding Guides';

  @override
  String get homeQuickAccessBerries => 'Berry Farming';

  @override
  String get homeNotificationsLabel => 'Open notifications';

  @override
  String get homeShopLabel => 'Open shop';

  @override
  String get homeSettingsLabel => 'Open settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountTitle => 'Account';

  @override
  String get settingsNoEmail => 'No email registered';

  @override
  String get settingsEditProfile => 'Edit profile';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLightModeTitle => 'Light mode';

  @override
  String get settingsLightModeSubtitle =>
      'Bright backgrounds ideal for well-lit environments.';

  @override
  String get settingsDarkModeTitle => 'Dark mode';

  @override
  String get settingsDarkModeSubtitle =>
      'Dim the UI to reduce eye strain at night.';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle =>
      'Choose how text is displayed across the app.';

  @override
  String get settingsLanguageSystem => 'Use system language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsInfoNote =>
      'Changes are saved immediately and affect the entire app.';

  @override
  String get favoritesEmptyTitle => "You haven't saved any Pokémon yet.";

  @override
  String get favoritesEmptyDescription =>
      'Explore the Pokédex and tap the heart to keep your favorite Pokémon.';

  @override
  String get pokedexLoadError =>
      "We couldn't load the Pokédex. Please try again.";

  @override
  String get pokedexOfflineSnack =>
      'Offline mode active. Showing saved data.';

  @override
  String get pokedexOfflineBanner =>
      'Offline mode active. Some filters may be limited.';

  @override
  String get pokedexConnectionRestored => 'Connection restored.';

  @override
  String get pokedexSearchHint => 'Search by name or number';

  @override
  String get pokedexFiltersTooltip => 'Filters';

  @override
  String pokedexShowingCount(Object count) {
    return 'Showing $count Pokémon';
  }

  @override
  String pokedexShowingPartial(Object count, Object total) {
    return 'Showing $count of $total Pokémon';
  }

  @override
  String get pokedexSortAscending => 'ascending';

  @override
  String get pokedexSortDescending => 'descending';

  @override
  String get pokedexSortAscendingShort => 'Asc';

  @override
  String get pokedexSortDescendingShort => 'Desc';

  @override
  String get pokedexFiltersTitle => 'Filters';

  @override
  String get pokedexFiltersClose => 'Close';

  @override
  String get pokedexFilterTypesTitle => 'Types';

  @override
  String get pokedexFilterTypesEmpty =>
      'No types are available at the moment.';

  @override
  String get pokedexFilterGenerationsTitle => 'Generations';

  @override
  String get pokedexFilterGenerationsEmpty =>
      'No generations are available right now.';

  @override
  String get pokedexFilterRegionsTitle => 'Regions';

  @override
  String get pokedexFilterRegionsEmpty =>
      'No regions are available right now.';

  @override
  String get pokedexFilterShapesTitle => 'Shapes';

  @override
  String get pokedexFilterShapesEmpty =>
      'No shapes are available right now.';

  @override
  String get pokedexFilterSortTitle => 'Sort by';

  @override
  String get pokedexFilterSortCriterion => 'Criterion';

  @override
  String get pokedexFiltersClear => 'Clear';

  @override
  String get pokedexFiltersCancel => 'Cancel';

  @override
  String get pokedexFiltersApply => 'Apply';

  @override
  String pokedexActiveSearch(Object term) {
    return 'Search: $term';
  }

  @override
  String pokedexActiveType(Object value) {
    return 'Type: $value';
  }

  @override
  String pokedexActiveGeneration(Object value) {
    return 'Generation: $value';
  }

  @override
  String pokedexActiveRegion(Object value) {
    return 'Region: $value';
  }

  @override
  String pokedexActiveShape(Object value) {
    return 'Shape: $value';
  }

  @override
  String pokedexActiveSort(Object criterion, Object direction) {
    return 'Order: $criterion $direction';
  }

  @override
  String pokedexActiveFiltersSummary(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: '$count active filter',
      other: '$count active filters',
    );
  }

  @override
  String get pokedexNoResults =>
      'No Pokémon match the current filters.';

  @override
  String get pokedexSortByNumber => 'Number';

  @override
  String get pokedexSortByName => 'Name';

  @override
  String get pokedexSortByHeight => 'Height';

  @override
  String get pokedexSortByWeight => 'Weight';

  @override
  String get pokedexFavoriteRemove => 'Remove from favorites';

  @override
  String get pokedexFavoriteAdd => 'Add to favorites';

  @override
  String pokemonArtworkLabel(Object name) {
    return '$name artwork';
  }

  @override
  String get pokemonArtworkGeneric => 'Pokémon artwork';

  @override
  String pokemonTileLabel(Object name, Object number) {
    return '$name, Pokédex number $number';
  }

  @override
  String get pokemonTileTapHint =>
      'Double tap to open detailed information.';

  @override
  String get pokemonUnknownType => 'unknown';
}

class _AppLocalizationsEs extends AppLocalizations {
  _AppLocalizationsEs() : super('es');

  @override
  String get appTitle => 'Pokédex GraphQL';

  @override
  String get homeTitle => 'ProDex';

  @override
  String get homeSectionPokedexTitle => 'Pokédex';

  @override
  String get homeSectionPokedexSubtitle =>
      'Índice nacional y dex regionales';

  @override
  String get homeSectionFavoritesTitle => 'Favoritos';

  @override
  String get homeSectionFavoritesSubtitle => 'Tus Pokémon guardados';

  @override
  String get homeSectionMovesTitle => 'Movimientos';

  @override
  String get homeSectionMovesSubtitle =>
      'Daño, efectos y datos de concursos';

  @override
  String get homeSectionTmTitle => 'MT';

  @override
  String get homeSectionTmSubtitle =>
      'Máquinas y tutores por generación';

  @override
  String get homeSectionAbilitiesTitle => 'Habilidades';

  @override
  String get homeSectionAbilitiesSubtitle =>
      'Efectos pasivos y activadores';

  @override
  String get homeSectionChecklistsTitle => 'Listas';

  @override
  String get homeSectionChecklistsSubtitle =>
      'Registra metas y colecciones';

  @override
  String get homeSectionPartiesTitle => 'Equipos';

  @override
  String get homeSectionPartiesSubtitle =>
      'Crea equipos y estrategias';

  @override
  String get homeSectionLocationsTitle => 'Ubicaciones';

  @override
  String get homeSectionLocationsSubtitle =>
      'Regiones, mapas y encuentros';

  @override
  String get homeQuickAccessGym => 'Líderes y Alto Mando';

  @override
  String get homeQuickAccessNatures => 'Naturalezas';

  @override
  String get homeQuickAccessTypes => 'Efectividades de tipo';

  @override
  String get homeQuickAccessEvolutions => 'Cadenas evolutivas';

  @override
  String get homeQuickAccessBreeding => 'Guías de crianza';

  @override
  String get homeQuickAccessBerries => 'Cultivo de bayas';

  @override
  String get homeNotificationsLabel => 'Abrir notificaciones';

  @override
  String get homeShopLabel => 'Abrir tienda';

  @override
  String get homeSettingsLabel => 'Abrir configuración';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAccountTitle => 'Cuenta';

  @override
  String get settingsNoEmail => 'Sin correo registrado';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsLightModeTitle => 'Modo claro';

  @override
  String get settingsLightModeSubtitle =>
      'Fondos luminosos ideales para espacios bien iluminados.';

  @override
  String get settingsDarkModeTitle => 'Modo oscuro';

  @override
  String get settingsDarkModeSubtitle =>
      'Atenúa la interfaz para reducir el cansancio visual.';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle =>
      'Elige cómo se muestran los textos en la app.';

  @override
  String get settingsLanguageSystem => 'Usar idioma del sistema';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsInfoNote =>
      'Los cambios se guardan al instante y afectan a toda la app.';

  @override
  String get favoritesEmptyTitle =>
      'Aún no tienes Pokémon favoritos.';

  @override
  String get favoritesEmptyDescription =>
      'Explora la Pokédex y toca el corazón para guardar tus Pokémon preferidos.';

  @override
  String get pokedexLoadError =>
      'No se pudo cargar la Pokédex. Intenta nuevamente.';

  @override
  String get pokedexOfflineSnack =>
      'Modo offline activo. Mostrando datos guardados.';

  @override
  String get pokedexOfflineBanner =>
      'Modo offline activo. Algunos filtros pueden ser limitados.';

  @override
  String get pokedexConnectionRestored => 'Conexión restablecida.';

  @override
  String get pokedexSearchHint => 'Buscar por nombre o número';

  @override
  String get pokedexFiltersTooltip => 'Filtros';

  @override
  String pokedexShowingCount(Object count) {
    return 'Mostrando $count Pokémon';
  }

  @override
  String pokedexShowingPartial(Object count, Object total) {
    return 'Mostrando $count de $total Pokémon';
  }

  @override
  String get pokedexSortAscending => 'ascendente';

  @override
  String get pokedexSortDescending => 'descendente';

  @override
  String get pokedexSortAscendingShort => 'Asc';

  @override
  String get pokedexSortDescendingShort => 'Desc';

  @override
  String get pokedexFiltersTitle => 'Filtros';

  @override
  String get pokedexFiltersClose => 'Cerrar';

  @override
  String get pokedexFilterTypesTitle => 'Tipos';

  @override
  String get pokedexFilterTypesEmpty =>
      'No hay tipos disponibles por ahora.';

  @override
  String get pokedexFilterGenerationsTitle => 'Generaciones';

  @override
  String get pokedexFilterGenerationsEmpty =>
      'No hay generaciones disponibles por ahora.';

  @override
  String get pokedexFilterRegionsTitle => 'Regiones';

  @override
  String get pokedexFilterRegionsEmpty =>
      'No hay regiones disponibles por ahora.';

  @override
  String get pokedexFilterShapesTitle => 'Formas';

  @override
  String get pokedexFilterShapesEmpty =>
      'No hay formas disponibles por ahora.';

  @override
  String get pokedexFilterSortTitle => 'Ordenar por';

  @override
  String get pokedexFilterSortCriterion => 'Criterio';

  @override
  String get pokedexFiltersClear => 'Limpiar';

  @override
  String get pokedexFiltersCancel => 'Cancelar';

  @override
  String get pokedexFiltersApply => 'Aplicar';

  @override
  String pokedexActiveSearch(Object term) {
    return 'Búsqueda: $term';
  }

  @override
  String pokedexActiveType(Object value) {
    return 'Tipo: $value';
  }

  @override
  String pokedexActiveGeneration(Object value) {
    return 'Generación: $value';
  }

  @override
  String pokedexActiveRegion(Object value) {
    return 'Región: $value';
  }

  @override
  String pokedexActiveShape(Object value) {
    return 'Forma: $value';
  }

  @override
  String pokedexActiveSort(Object criterion, Object direction) {
    return 'Orden: $criterion $direction';
  }

  @override
  String pokedexActiveFiltersSummary(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: '$count filtro activo',
      other: '$count filtros activos',
    );
  }

  @override
  String get pokedexNoResults =>
      'No se encontraron Pokémon para los filtros actuales.';

  @override
  String get pokedexSortByNumber => 'Número';

  @override
  String get pokedexSortByName => 'Nombre';

  @override
  String get pokedexSortByHeight => 'Altura';

  @override
  String get pokedexSortByWeight => 'Peso';

  @override
  String get pokedexFavoriteRemove => 'Quitar de favoritos';

  @override
  String get pokedexFavoriteAdd => 'Agregar a favoritos';

  @override
  String pokemonArtworkLabel(Object name) {
    return 'Arte de $name';
  }

  @override
  String get pokemonArtworkGeneric => 'Arte de Pokémon';

  @override
  String pokemonTileLabel(Object name, Object number) {
    return '$name, número de Pokédex $number';
  }

  @override
  String get pokemonTileTapHint =>
      'Doble toque para ver la información detallada.';

  @override
  String get pokemonUnknownType => 'desconocido';
}
