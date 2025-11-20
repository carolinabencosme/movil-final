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

  /// Title of the trivia feature card on the Home screen.
  ///
  /// In en, this message translates to:
  /// **'Trivia'**
  String get homeSectionTriviaTitle;

  /// Short description shown under the trivia card title.
  ///
  /// In en, this message translates to:
  /// **'Fun facts & lore highlights'**
  String get homeSectionTriviaSubtitle;

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

  /// Heading for the trivia section.
  ///
  /// In en, this message translates to:
  /// **'Trivia'**
  String get triviaTitle;

  /// Subtitle inviting users to read trivia content.
  ///
  /// In en, this message translates to:
  /// **'Discover fun facts about Pokémon.'**
  String get triviaDescription;

  /// Title for the action card that opens the trivia game.
  ///
  /// In en, this message translates to:
  /// **'Play Pokémon trivia'**
  String get triviaPlayCardTitle;

  /// Subtitle encouraging users to start the trivia game.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge with silhouettes and quick clues.'**
  String get triviaPlayCardSubtitle;

  /// Title for the action card that opens the trivia rankings screen.
  ///
  /// In en, this message translates to:
  /// **'View Top 10 ranking'**
  String get triviaRankingCardTitle;

  /// Subtitle inviting users to explore the top scores.
  ///
  /// In en, this message translates to:
  /// **'Check high scores and get motivated to beat the board.'**
  String get triviaRankingCardSubtitle;

  /// Title for the action card that opens the trivia achievements screen.
  ///
  /// In en, this message translates to:
  /// **'Unlocked achievements'**
  String get triviaAchievementsCardTitle;

  /// Subtitle encouraging users to review their trivia achievements.
  ///
  /// In en, this message translates to:
  /// **"Review the badges you've earned during trivia sessions."**
  String get triviaAchievementsCardSubtitle;

  /// App bar title for the trivia achievements screen.
  ///
  /// In en, this message translates to:
  /// **'Trivia achievements'**
  String get triviaAchievementsTitle;

  /// Empty-state message shown when no achievements are present.
  ///
  /// In en, this message translates to:
  /// **'No achievements available yet.'**
  String get triviaAchievementsEmpty;

  /// Label shown for achievements that are still locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get triviaAchievementsLockedLabel;

  /// Label shown for achievements that have been unlocked, including the unlock date.
  ///
  /// In en, this message translates to:
  /// **'Unlocked · {date}'**
  String triviaAchievementsUnlockedLabel(String date);

  /// Date format used to display the unlock timestamp in the achievements screen.
  ///
  /// In en, this message translates to:
  /// **'d MMM, HH:mm'**
  String get triviaAchievementsDateFormat;

  /// Title for the achievement granted after answering the first trivia question correctly.
  ///
  /// In en, this message translates to:
  /// **'First correct answer'**
  String get triviaAchievementFirstCorrectTitle;

  /// Description for the first correct answer achievement.
  ///
  /// In en, this message translates to:
  /// **'Answer your first trivia question correctly.'**
  String get triviaAchievementFirstCorrectDescription;

  /// Title for the achievement earned after three consecutive correct answers.
  ///
  /// In en, this message translates to:
  /// **'Streak x3'**
  String get triviaAchievementStreakThreeTitle;

  /// Description for the three-answer streak achievement.
  ///
  /// In en, this message translates to:
  /// **'Chain three correct answers in a row.'**
  String get triviaAchievementStreakThreeDescription;

  /// Title for the achievement earned after five consecutive correct answers.
  ///
  /// In en, this message translates to:
  /// **'Living legend'**
  String get triviaAchievementStreakFiveTitle;

  /// Description for the five-answer streak achievement.
  ///
  /// In en, this message translates to:
  /// **'Reach five correct answers in a row.'**
  String get triviaAchievementStreakFiveDescription;

  /// Title for the achievement granted after playing ten questions in one session.
  ///
  /// In en, this message translates to:
  /// **'Trainer endurance'**
  String get triviaAchievementTenQuestionsTitle;

  /// Description for the ten-questions-per-session achievement.
  ///
  /// In en, this message translates to:
  /// **'Play ten questions in a single session.'**
  String get triviaAchievementTenQuestionsDescription;

  /// Title for the achievement granted after scoring 500 points in one session.
  ///
  /// In en, this message translates to:
  /// **'Point hunter'**
  String get triviaAchievementScoreHunterTitle;

  /// Description for the 500-point achievement.
  ///
  /// In en, this message translates to:
  /// **'Reach 500 points in a single session.'**
  String get triviaAchievementScoreHunterDescription;

  /// Title for the trivia fact about Skitty and Wailord breeding.
  ///
  /// In en, this message translates to:
  /// **'Skitty can pair with Wailord'**
  String get triviaFactSkittyTitle;

  /// Description for the trivia fact about Skitty breeding with Wailord.
  ///
  /// In en, this message translates to:
  /// **'Egg groups ignore size, so tiny Skitty and massive Wailord are compatible parents.'**
  String get triviaFactSkittyDescription;

  /// Title for the trivia fact about Ditto and Mew sharing stats.
  ///
  /// In en, this message translates to:
  /// **'Ditto mirrors Mew\'s stats'**
  String get triviaFactDittoTitle;

  /// Description for the trivia fact about Ditto sharing stats with Mew.
  ///
  /// In en, this message translates to:
  /// **'Both share identical base stats and weight in early games, inspiring fan theories.'**
  String get triviaFactDittoDescription;

  /// Title for the trivia fact about Pikachu becoming the series mascot.
  ///
  /// In en, this message translates to:
  /// **'Pikachu replaced Clefairy as mascot'**
  String get triviaFactPikachuTitle;

  /// Description for the trivia fact about Pikachu replacing Clefairy.
  ///
  /// In en, this message translates to:
  /// **'Clefairy was once planned as the star of the series before Pikachu\'s popularity took over.'**
  String get triviaFactPikachuDescription;

  /// Prompt shown for the Pikachu silhouette question.
  ///
  /// In en, this message translates to:
  /// **'Who is this iconic Electric-type Pokémon?'**
  String get triviaQuestionPikachuPrompt;

  /// Prompt shown for the Bulbasaur silhouette question.
  ///
  /// In en, this message translates to:
  /// **'Starts the Pokédex and carries a seed on its back.'**
  String get triviaQuestionBulbasaurPrompt;

  /// Prompt shown for the Charizard silhouette question.
  ///
  /// In en, this message translates to:
  /// **'Fire-breathing dragon from Kanto.'**
  String get triviaQuestionCharizardPrompt;

  /// Localized label for Pikachu used in trivia options and answers.
  ///
  /// In en, this message translates to:
  /// **'Pikachu'**
  String get triviaOptionPikachu;

  /// Localized label for Raichu used in trivia options.
  ///
  /// In en, this message translates to:
  /// **'Raichu'**
  String get triviaOptionRaichu;

  /// Localized label for Pichu used in trivia options.
  ///
  /// In en, this message translates to:
  /// **'Pichu'**
  String get triviaOptionPichu;

  /// Localized label for Bulbasaur used in trivia options and answers.
  ///
  /// In en, this message translates to:
  /// **'Bulbasaur'**
  String get triviaOptionBulbasaur;

  /// Localized label for Ivysaur used in trivia options.
  ///
  /// In en, this message translates to:
  /// **'Ivysaur'**
  String get triviaOptionIvysaur;

  /// Localized label for Oddish used in trivia options.
  ///
  /// In en, this message translates to:
  /// **'Oddish'**
  String get triviaOptionOddish;

  /// Localized label for Charizard used in trivia options and answers.
  ///
  /// In en, this message translates to:
  /// **'Charizard'**
  String get triviaOptionCharizard;

  /// Localized label for Aerodactyl used in trivia options.
  ///
  /// In en, this message translates to:
  /// **'Aerodactyl'**
  String get triviaOptionAerodactyl;

  /// Localized label for Charmeleon used in trivia options.
  ///
  /// In en, this message translates to:
  /// **'Charmeleon'**
  String get triviaOptionCharmeleon;

  /// Label shown above the trivia countdown timer.
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get triviaRemainingTimeLabel;

  /// Displays the remaining seconds in the trivia timer.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String triviaRemainingSeconds(int seconds);

  /// Label for the trivia correct answers counter.
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get triviaStatsCorrectAnswers;

  /// Label for the trivia score counter.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get triviaStatsScore;

  /// Label for the trivia streak counter.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get triviaStatsStreak;

  /// Short suffix for points on the trivia stats chip.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get triviaPointsAbbreviation;

  /// Label for the trivia free-text answer input.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get triviaAnswerLabel;

  /// Label for the button that submits a trivia answer.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get triviaCheckButtonLabel;

  /// Tooltip for the button that skips to the next trivia question.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get triviaSkipTooltip;

  /// Tooltip for the action that opens the trivia ranking screen.
  ///
  /// In en, this message translates to:
  /// **'View ranking'**
  String get triviaRankingTooltip;

  /// Tooltip for the action that opens the trivia achievements screen.
  ///
  /// In en, this message translates to:
  /// **'View achievements'**
  String get triviaAchievementsTooltip;

  /// Tooltip for the action that saves the trivia session to the ranking.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get triviaSaveSessionTooltip;

  /// Snackbar message shown when the trivia timer ends before answering.
  ///
  /// In en, this message translates to:
  /// **'Time is up! The answer was {pokemon}.'**
  String triviaTimeoutMessage(String pokemon);

  /// Snackbar message shown when the trivia answer is correct.
  ///
  /// In en, this message translates to:
  /// **'Correct! It was {pokemon}.'**
  String triviaCorrectMessage(String pokemon);

  /// Snackbar message shown when the trivia answer is incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer. Try the next one.'**
  String get triviaIncorrectMessage;

  /// Snackbar message shown when the ranking repository is unavailable.
  ///
  /// In en, this message translates to:
  /// **"Couldn't access the ranking right now."**
  String get triviaSaveUnavailableMessage;

  /// Snackbar message shown when trying to save a trivia session without playing.
  ///
  /// In en, this message translates to:
  /// **'Play at least one question before saving.'**
  String get triviaSaveNoQuestionsMessage;

  /// Fallback player name used when no authenticated user is present.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get triviaGuestPlayerName;

  /// Snackbar message shown after saving the trivia session.
  ///
  /// In en, this message translates to:
  /// **'Session saved to the ranking'**
  String get triviaSessionSavedMessage;

  /// Heading for the snackbar shown when a trivia achievement unlocks.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked! 🎉'**
  String get triviaAchievementUnlockedTitle;

  /// Semantic label announcing navigation to a home section
  ///
  /// In en, this message translates to:
  /// **'Open the {sectionName} section'**
  String homeSectionCardSemanticLabel(String sectionName);

  /// Semantic hint for opening a home section
  ///
  /// In en, this message translates to:
  /// **'Double tap to navigate to {sectionName}'**
  String homeSectionCardSemanticHint(String sectionName);

  /// Section title for the Pokémon types list on the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get detailInfoTypesTitle;

  /// Fallback message when type data is missing on the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'No type information available.'**
  String get detailInfoTypesFallback;

  /// Section title for the basic data card on the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'Basic data'**
  String get detailInfoBasicDataTitle;

  /// Label for the Pokémon height characteristic.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailCharacteristicHeight;

  /// Label for the height value within the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailInfoHeightLabel;

  /// Label for the Pokémon weight characteristic.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailCharacteristicWeight;

  /// Label for the weight value within the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailInfoWeightLabel;

  /// Call-to-action button label to open the Pokémon location map.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get detailInfoViewOnMap;

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

  /// Section title for the characteristics card on the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'Characteristics'**
  String get detailInfoCharacteristicsTitle;

  /// Section title for the abilities carousel on the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get detailInfoAbilitiesTitle;

  /// Fallback message when ability data is missing on the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'No ability information available.'**
  String get detailInfoAbilitiesFallback;

  /// Fallback message shown when the main ability is missing on the detail info tab.
  ///
  /// In en, this message translates to:
  /// **'No main ability available.'**
  String get detailInfoMainAbilityFallback;

  /// Section title for the stats card on the detail tab.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get detailStatsTitle;

  /// Fallback message when stat data is missing on the detail tab.
  ///
  /// In en, this message translates to:
  /// **'No stat information available.'**
  String get detailStatsFallback;

  /// Section title for the weaknesses list on the matchups tab.
  ///
  /// In en, this message translates to:
  /// **'Weaknesses'**
  String get detailMatchupsWeaknessesTitle;

  /// Section title for the resistances and immunities list on the matchups tab.
  ///
  /// In en, this message translates to:
  /// **'Resistances & immunities'**
  String get detailMatchupsResistancesTitle;

  /// Section title for the evolution chain on the detail tab.
  ///
  /// In en, this message translates to:
  /// **'Evolution chain'**
  String get detailEvolutionChainTitle;

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

  /// Message shown for sections that are not ready yet.
  ///
  /// In en, this message translates to:
  /// **'The {sectionName} section will be available soon.'**
  String homePlaceholderMessage(String sectionName);

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

  /// Semantic label announcing navigation to an ability detail
  ///
  /// In en, this message translates to:
  /// **'Open ability {abilityName}'**
  String abilityCardSemanticLabel(String abilityName);

  /// Semantic hint for opening an ability
  ///
  /// In en, this message translates to:
  /// **'Double tap to see details for {abilityName}'**
  String abilityCardSemanticHint(String abilityName);

  /// Semantic label for navigating to a Pokémon entry
  ///
  /// In en, this message translates to:
  /// **'Open {pokemonName} details'**
  String pokedexCardSemanticLabel(String pokemonName);

  /// Semantic hint for navigating to a Pokémon entry
  ///
  /// In en, this message translates to:
  /// **'Double tap to view {pokemonName} in the Pokédex'**
  String pokedexCardSemanticHint(String pokemonName);

  /// Hint text shown in the Pokédex search field.
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

  /// No description provided for @pokedexShowingCountSimple.
  ///
  /// In en, this message translates to:
  /// **'Showing {visible} Pokémon.'**
  String pokedexShowingCountSimple(int visible);

  /// No description provided for @pokedexShowingCountWithTotal.
  ///
  /// In en, this message translates to:
  /// **'Showing {visible} of {total} Pokémon.'**
  String pokedexShowingCountWithTotal(int visible, int total);

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

  /// No description provided for @pokedexFilterSummarySearch.
  ///
  /// In en, this message translates to:
  /// **'Search: {query}'**
  String pokedexFilterSummarySearch(String query);

  /// No description provided for @pokedexFilterSummaryType.
  ///
  /// In en, this message translates to:
  /// **'Type: {value}'**
  String pokedexFilterSummaryType(String value);

  /// No description provided for @pokedexFilterSummaryGeneration.
  ///
  /// In en, this message translates to:
  /// **'Generation: {value}'**
  String pokedexFilterSummaryGeneration(String value);

  /// No description provided for @pokedexFilterSummaryRegion.
  ///
  /// In en, this message translates to:
  /// **'Region: {value}'**
  String pokedexFilterSummaryRegion(String value);

  /// No description provided for @pokedexFilterSummaryShape.
  ///
  /// In en, this message translates to:
  /// **'Form: {value}'**
  String pokedexFilterSummaryShape(String value);

  /// No description provided for @pokedexFilterSummarySort.
  ///
  /// In en, this message translates to:
  /// **'Sort: {value}'**
  String pokedexFilterSummarySort(String value);

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

  /// No description provided for @pokedexFiltersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pokedexFiltersCancel;

  /// No description provided for @pokedexFiltersApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get pokedexFiltersApply;

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

  /// SnackBar message shown when the detail screen switches to offline mode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode active. Showing locally saved data.'**
  String get detailOfflineModeSnack;

  /// SnackBar message shown when connectivity returns on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Connection restored.'**
  String get detailConnectionRestored;

  /// Banner text shown at the top of the detail screen while offline.
  ///
  /// In en, this message translates to:
  /// **'Offline mode active. Some advanced data may not be available.'**
  String get detailOfflineBanner;

  /// Fallback AppBar title when the Pokémon name is not available.
  ///
  /// In en, this message translates to:
  /// **'Pokémon details'**
  String get detailFallbackTitle;

  /// Label for the detail tab that shows general Pokémon information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get detailTabInformation;

  /// Label for the detail tab that displays Pokémon stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get detailTabStatistics;

  /// Label for the detail tab that explains type matchups.
  ///
  /// In en, this message translates to:
  /// **'Matchups'**
  String get detailTabMatchups;

  /// Label for the detail tab that shows evolution chains.
  ///
  /// In en, this message translates to:
  /// **'Evolutions'**
  String get detailTabEvolutions;

  /// Label for the detail tab that lists Pokémon moves.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get detailTabMoves;

  /// Section title for the moves tab on the Pokémon detail screen.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get detailMovesTitle;

  /// Title displayed at the top of the moves filter bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Filter moves'**
  String get detailMovesFilterSheetTitle;

  /// Section label for filtering moves by learning method.
  ///
  /// In en, this message translates to:
  /// **'Learning method'**
  String get detailMovesFilterMethodTitle;

  /// Choice chip label that clears the learning method filter.
  ///
  /// In en, this message translates to:
  /// **'All methods'**
  String get detailMovesFilterMethodAll;

  /// Label shown when the move learning method is unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get detailMovesFilterMethodUnknown;

  /// Label for the button that opens the moves filter sheet on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get detailMovesFilterButtonLabel;

  /// Section label for filtering moves by game version.
  ///
  /// In en, this message translates to:
  /// **'Game version'**
  String get detailMovesFilterVersionTitle;

  /// Input label for the version group dropdown inside the moves filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get detailMovesFilterVersionLabel;

  /// Dropdown option that clears the version group filter.
  ///
  /// In en, this message translates to:
  /// **'All versions'**
  String get detailMovesFilterAllVersions;

  /// Toggle label to show only moves that include a required level.
  ///
  /// In en, this message translates to:
  /// **'Only moves with level'**
  String get detailMovesFilterOnlyWithLevel;

  /// Label for the button that clears move filters on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get detailMovesResetButtonLabel;

  /// Text showing how many moves are visible after filtering.
  ///
  /// In en, this message translates to:
  /// **'Showing {visibleMoves} of {totalMoves} moves'**
  String detailMovesCountText(int visibleMoves, int totalMoves);

  /// Semantic label describing the moves count text for accessibility.
  ///
  /// In en, this message translates to:
  /// **'Visible moves counter'**
  String get detailMovesCountSemanticLabel;

  /// Message shown when the detail query returns no data.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find information for this Pokémon.'**
  String get detailNoDataFound;

  /// Short message shown in the offline detail view explaining cached data is being used.
  ///
  /// In en, this message translates to:
  /// **'Offline mode: showing saved information.'**
  String get detailOfflineShortMessage;

  /// Longer explanation shown in the offline detail view about missing data.
  ///
  /// In en, this message translates to:
  /// **'Detailed information isn\'t available without a connection. Try again when you\'re back online.'**
  String get detailOfflineLongMessage;

  /// Tooltip shown on the favorite button when the Pokémon is already a favorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get detailFavoriteRemoveTooltip;

  /// Tooltip shown on the favorite button when the Pokémon is not a favorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get detailFavoriteAddTooltip;

  /// Label shown for a Pokémon's hidden ability in the detail header.
  ///
  /// In en, this message translates to:
  /// **'Hidden ability'**
  String get detailHiddenAbilityLabel;

  /// Label shown for a Pokémon's primary ability in the detail header.
  ///
  /// In en, this message translates to:
  /// **'Main ability'**
  String get detailMainAbilityLabel;

  /// Error message displayed when the detail screen cannot load data.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the Pokémon details.\nCheck your connection or try again.'**
  String get detailLoadErrorDescription;

  /// No description provided for @pokedexSortSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
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

  /// No description provided for @pokedexSortAscendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get pokedexSortAscendingLabel;

  /// No description provided for @pokedexSortDescendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get pokedexSortDescendingLabel;

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

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
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
