// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get authLoginSubtitle =>
      'Inicia sesión con tu correo electrónico para acceder a tu Pokédex.';

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
  String get authLoginError =>
      'No fue posible iniciar sesión. Inténtalo de nuevo.';

  @override
  String get authEmailRequired => 'Ingresa tu correo electrónico.';

  @override
  String get authEmailInvalid => 'Formato de correo inválido.';

  @override
  String get authPasswordRequired => 'Ingresa tu contraseña.';

  @override
  String get authPasswordLength =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get authRegisterTitle => 'Crea tu cuenta';

  @override
  String get authRegisterSubtitle =>
      'Regístrate para sincronizar tus equipos y colecciones en todos tus dispositivos.';

  @override
  String get authCreateAccountButton => 'Crear cuenta';

  @override
  String get authAlreadyHaveAccountCta =>
      '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get authRegisterError =>
      'No pudimos crear tu cuenta. Inténtalo más tarde.';

  @override
  String get authSecurePasswordRequired => 'Ingresa una contraseña segura.';

  @override
  String get authPasswordStrongSuggestion =>
      'Usa letras y números para una contraseña más fuerte.';

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
  String get authUpdateInfoSubtitle =>
      'Puedes cambiar tu correo electrónico o establecer una nueva contraseña. Los cambios se aplican inmediatamente.';

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
  String get settingsLightModeSubtitle =>
      'Fondos luminosos ideales para entornos bien iluminados.';

  @override
  String get settingsDarkModeTitle => 'Modo oscuro';

  @override
  String get settingsDarkModeSubtitle =>
      'Atenúa la luz para reducir el cansancio visual por la noche.';

  @override
  String get settingsInfo =>
      'La configuración se guarda inmediatamente y afecta a toda la aplicación.';

  @override
  String get settingsSaveChanges => 'Guardar cambios';

  @override
  String get favoritesDefaultTitle => 'Favoritos';

  @override
  String get favoritesEmptyTitle => 'Aún no tienes Pokémon favoritos.';

  @override
  String get favoritesEmptySubtitle =>
      'Explora la Pokédex y marca con el corazón los Pokémon que quieras guardar.';

  @override
  String get homeQuickAccessTitle => 'Accesos rápidos';

  @override
  String get homeSectionPokedexTitle => 'Pokédex';

  @override
  String get homeSectionPokedexSubtitle =>
      'Índice nacional y pokédex regionales';

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
  String get homeSectionLocationsSubtitle =>
      'Regiones, mapas y datos de encuentros';

  @override
  String homeSectionCardSemanticLabel(String sectionName) {
    return 'Abrir la sección $sectionName';
  }

  @override
  String homeSectionCardSemanticHint(String sectionName) {
    return 'Toca dos veces para ir a $sectionName';
  }

  @override
  String get detailInfoTypesTitle => 'Tipos';

  @override
  String get detailInfoTypesFallback => 'Sin información de tipos disponible.';

  @override
  String get detailInfoBasicDataTitle => 'Datos básicos';

  @override
  String get detailCharacteristicHeight => 'Altura';

  @override
  String get detailInfoHeightLabel => 'Altura';

  @override
  String get detailCharacteristicWeight => 'Peso';

  @override
  String get detailInfoWeightLabel => 'Peso';

  @override
  String get detailInfoViewOnMap => 'Ver en mapa';

  @override
  String get detailCharacteristicCategory => 'Categoría';

  @override
  String get detailCharacteristicNoCategory => 'Sin categoría';

  @override
  String get detailCharacteristicCatchRate => 'Ratio de captura';

  @override
  String get detailCharacteristicBaseExperience => 'Experiencia base';

  @override
  String get detailInfoCharacteristicsTitle => 'Características';

  @override
  String get detailInfoAbilitiesTitle => 'Habilidades';

  @override
  String get detailInfoAbilitiesFallback =>
      'Sin información de habilidades disponible.';

  @override
  String get detailInfoMainAbilityFallback =>
      'Sin habilidad principal disponible.';

  @override
  String get detailStatsTitle => 'Estadísticas';

  @override
  String get detailStatsFallback =>
      'Sin información de estadísticas disponible.';

  @override
  String get detailMatchupsWeaknessesTitle => 'Debilidades';

  @override
  String get detailMatchupsResistancesTitle => 'Resistencias e inmunidades';

  @override
  String get detailEvolutionChainTitle => 'Cadena evolutiva';

  @override
  String get detailNoWeaknessInfo =>
      'No hay información de debilidades disponible.';

  @override
  String get detailWeaknessLegendQuadruple =>
      'Doble debilidad: el daño recibido se multiplica por cuatro.';

  @override
  String get detailWeaknessLegendDouble =>
      'Debilidad clásica: ataques súper efectivos.';

  @override
  String get detailWeaknessLegendModerate =>
      'Ventaja moderada: daño ligeramente incrementado.';

  @override
  String get detailWeaknessToggleShow => 'Ver debilidades';

  @override
  String get detailWeaknessToggleHide => 'Ocultar debilidades';

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
  String homePlaceholderMessage(String sectionName) {
    return 'La sección de $sectionName estará disponible pronto.';
  }

  @override
  String get abilitiesDefaultTitle => 'Habilidades';

  @override
  String get abilitiesSearchHint => 'Buscar habilidad…';

  @override
  String get abilitiesErrorMessage => 'No se pudieron cargar las habilidades.';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get abilitiesEmptySearch =>
      'No encontramos habilidades que coincidan con tu búsqueda.';

  @override
  String get abilitiesEmptyGeneral =>
      'No hay habilidades disponibles en este momento.';

  @override
  String get abilitiesNoDescription => 'Sin descripción disponible.';

  @override
  String get abilitiesNoShortDescription => 'Sin descripción breve disponible.';

  @override
  String get abilitiesFullDescriptionTitle => 'Descripción completa';

  @override
  String get abilitiesFullDescriptionFallback =>
      'Sin descripción disponible en este idioma.';

  @override
  String get abilitiesPokemonSectionTitle => 'Pokémon que la poseen';

  @override
  String get abilitiesPokemonEmpty =>
      'No encontramos Pokémon asociados a esta habilidad.';

  @override
  String get abilitiesPokemonErrorTitle =>
      'No pudimos cargar los Pokémon asociados.';

  @override
  String get abilitiesPokemonErrorDescription =>
      'Intenta nuevamente para ver qué Pokémon cuentan con esta habilidad.';

  @override
  String get pokedexSortNumberLabel => 'Número';

  @override
  String get pokedexSortNameLabel => 'Nombre';

  @override
  String get pokedexSortHeightLabel => 'Altura';

  @override
  String get pokedexSortWeightLabel => 'Peso';

  @override
  String abilityCardSemanticLabel(String abilityName) {
    return 'Abrir la habilidad $abilityName';
  }

  @override
  String abilityCardSemanticHint(String abilityName) {
    return 'Toca dos veces para ver detalles de $abilityName';
  }

  @override
  String pokedexCardSemanticLabel(String pokemonName) {
    return 'Abrir detalles de $pokemonName';
  }

  @override
  String pokedexCardSemanticHint(String pokemonName) {
    return 'Toca dos veces para ver a $pokemonName en la Pokédex';
  }

  @override
  String get pokedexSearchHint => 'Buscar por nombre o número';

  @override
  String get pokedexFiltersTooltip => 'Filtros';

  @override
  String get pokedexOfflineNoCache =>
      'Sin conexión y sin datos guardados localmente.';

  @override
  String get pokedexOfflineBanner =>
      'Modo offline activo. Mostrando datos guardados localmente.';

  @override
  String get pokedexConnectionRestored => 'Conexión restablecida.';

  @override
  String get pokedexLoadError =>
      'No se pudo cargar la Pokédex. Intenta nuevamente.';

  @override
  String get pokedexOfflineFiltersLimited =>
      'Modo offline activo. Algunos filtros pueden ser limitados.';

  @override
  String pokedexShowingCountSimple(int visible) {
    return 'Mostrando $visible Pokémon.';
  }

  @override
  String pokedexShowingCountWithTotal(int visible, int total) {
    return 'Mostrando $visible de $total Pokémon.';
  }

  @override
  String pokedexActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtros activos',
      one: '$count filtro activo',
    );
    return '$_temp0';
  }

  @override
  String get pokedexSortDirectionAscending => 'ascendente';

  @override
  String get pokedexSortDirectionDescending => 'descendente';

  @override
  String pokedexFilterSummarySearch(String query) {
    return 'Búsqueda: $query';
  }

  @override
  String pokedexFilterSummaryType(String value) {
    return 'Tipo: $value';
  }

  @override
  String pokedexFilterSummaryGeneration(String value) {
    return 'Generación: $value';
  }

  @override
  String pokedexFilterSummaryRegion(String value) {
    return 'Región: $value';
  }

  @override
  String pokedexFilterSummaryShape(String value) {
    return 'Forma: $value';
  }

  @override
  String pokedexFilterSummarySort(String value) {
    return 'Orden: $value';
  }

  @override
  String get pokedexNoResults =>
      'No se encontraron Pokémon para los filtros actuales.';

  @override
  String get pokedexFiltersTitle => 'Filtros';

  @override
  String get pokedexFiltersCloseTooltip => 'Cerrar';

  @override
  String get pokedexFiltersCancel => 'Cancelar';

  @override
  String get pokedexFiltersApply => 'Aplicar';

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
  String get pokedexFilterEmptyGenerations =>
      'No hay generaciones disponibles por ahora.';

  @override
  String get pokedexFilterEmptyRegions =>
      'No hay regiones disponibles por ahora.';

  @override
  String get pokedexFilterEmptyShapes => 'No hay formas disponibles por ahora.';

  @override
  String get pokedexFiltersClear => 'Limpiar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get detailOfflineModeSnack =>
      'Modo offline activo. Mostrando datos guardados localmente.';

  @override
  String get detailConnectionRestored => 'Conexión restablecida.';

  @override
  String get detailOfflineBanner =>
      'Modo offline activo. Algunos datos avanzados pueden no estar disponibles.';

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
  String get detailMovesTitle => 'Movimientos';

  @override
  String get detailMovesFilterSheetTitle => 'Filtrar movimientos';

  @override
  String get detailMovesFilterMethodTitle => 'Método de aprendizaje';

  @override
  String get detailMovesFilterMethodAll => 'Todos los métodos';

  @override
  String get detailMovesFilterMethodUnknown => 'Desconocido';

  @override
  String get detailMovesFilterButtonLabel => 'Filtros';

  @override
  String get detailMovesFilterVersionTitle => 'Versión del juego';

  @override
  String get detailMovesFilterVersionLabel => 'Versión';

  @override
  String get detailMovesFilterAllVersions => 'Todas las versiones';

  @override
  String get detailMovesFilterOnlyWithLevel => 'Solo movimientos con nivel';

  @override
  String get detailMovesResetButtonLabel => 'Restablecer filtros';

  @override
  String detailMovesCountText(int visibleMoves, int totalMoves) {
    return 'Mostrando $visibleMoves de $totalMoves movimientos';
  }

  @override
  String get detailMovesCountSemanticLabel =>
      'Contador de movimientos mostrados';

  @override
  String get detailNoDataFound =>
      'No se encontró información para este Pokémon.';

  @override
  String get detailOfflineShortMessage =>
      'Modo offline: mostrando información guardada.';

  @override
  String get detailOfflineLongMessage =>
      'La información detallada no está disponible sin conexión. Intenta nuevamente cuando recuperes internet.';

  @override
  String get detailFavoriteRemoveTooltip => 'Quitar de favoritos';

  @override
  String get detailFavoriteAddTooltip => 'Agregar a favoritos';

  @override
  String get detailHiddenAbilityLabel => 'Habilidad oculta';

  @override
  String get detailMainAbilityLabel => 'Habilidad principal';

  @override
  String get detailLoadErrorDescription =>
      'No se pudo obtener los datos del Pokémon.\nVerifica tu conexión o intenta de nuevo.';

  @override
  String get pokedexSortSheetTitle => 'Ordenar por';

  @override
  String get pokedexSortCriteriaLabel => 'Criterio';

  @override
  String get pokedexSortDirectionLabel => 'Dirección';

  @override
  String get pokedexSortAscendingLabel => 'Ascendente';

  @override
  String get pokedexSortDescendingLabel => 'Descendente';

  @override
  String get pokedexSortAscendingShort => 'Asc';

  @override
  String get pokedexSortDescendingShort => 'Desc';

  @override
  String get favoritesRemoveAction => 'Quitar de favoritos';

  @override
  String get favoritesAddAction => 'Agregar a favoritos';
}
