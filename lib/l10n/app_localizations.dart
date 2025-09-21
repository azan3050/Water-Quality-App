import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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
    Locale('as'),
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get selectYourRole;

  /// No description provided for @loginAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Login as Admin'**
  String get loginAsAdmin;

  /// No description provided for @loginAsAshaWorker.
  ///
  /// In en, this message translates to:
  /// **'Login as ASHA Worker'**
  String get loginAsAshaWorker;

  /// No description provided for @loginAsClinic.
  ///
  /// In en, this message translates to:
  /// **'Login as Clinic'**
  String get loginAsClinic;

  /// No description provided for @viewAlerts.
  ///
  /// In en, this message translates to:
  /// **'View Alerts'**
  String get viewAlerts;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @riskHotspots.
  ///
  /// In en, this message translates to:
  /// **'Risk Hotspots'**
  String get riskHotspots;

  /// No description provided for @totalPredictions.
  ///
  /// In en, this message translates to:
  /// **'Total Predictions'**
  String get totalPredictions;

  /// No description provided for @highRiskAlerts.
  ///
  /// In en, this message translates to:
  /// **'High-Risk Alerts'**
  String get highRiskAlerts;

  /// No description provided for @locationsTested.
  ///
  /// In en, this message translates to:
  /// **'Locations Tested'**
  String get locationsTested;

  /// No description provided for @predictionBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Prediction Breakdown'**
  String get predictionBreakdown;

  /// No description provided for @recentPredictions.
  ///
  /// In en, this message translates to:
  /// **'Recent Predictions'**
  String get recentPredictions;

  /// No description provided for @patientReportsByDisease.
  ///
  /// In en, this message translates to:
  /// **'Patient Reports by Disease'**
  String get patientReportsByDisease;

  /// No description provided for @recentClinicReports.
  ///
  /// In en, this message translates to:
  /// **'Recent Clinic Reports'**
  String get recentClinicReports;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'cases'**
  String get cases;

  /// No description provided for @allAlerts.
  ///
  /// In en, this message translates to:
  /// **'All Alerts'**
  String get allAlerts;

  /// No description provided for @failedToLoadAlerts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alerts.'**
  String get failedToLoadAlerts;

  /// No description provided for @noAlertsToShow.
  ///
  /// In en, this message translates to:
  /// **'No alerts to show yet.'**
  String get noAlertsToShow;

  /// No description provided for @waterQualityRisk.
  ///
  /// In en, this message translates to:
  /// **'Water Quality Risk'**
  String get waterQualityRisk;

  /// No description provided for @clinicReport.
  ///
  /// In en, this message translates to:
  /// **'Clinic Report'**
  String get clinicReport;

  /// No description provided for @patientsWith.
  ///
  /// In en, this message translates to:
  /// **'patient(s) with'**
  String get patientsWith;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterAValidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordMinLength;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get adminLogin;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @accessDeniedNotAdmin.
  ///
  /// In en, this message translates to:
  /// **'Access Denied. Not an Admin user.'**
  String get accessDeniedNotAdmin;

  /// No description provided for @ashaWorkerLogin.
  ///
  /// In en, this message translates to:
  /// **'ASHA Worker Login'**
  String get ashaWorkerLogin;

  /// No description provided for @ashaWorkerPortal.
  ///
  /// In en, this message translates to:
  /// **'ASHA Worker Portal'**
  String get ashaWorkerPortal;

  /// No description provided for @accessDeniedNotAsha.
  ///
  /// In en, this message translates to:
  /// **'Access Denied. Not an ASHA Worker.'**
  String get accessDeniedNotAsha;

  /// No description provided for @dontHaveAnAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAnAccountSignUp;

  /// No description provided for @clinicLogin.
  ///
  /// In en, this message translates to:
  /// **'Clinic Login'**
  String get clinicLogin;

  /// No description provided for @clinicPortal.
  ///
  /// In en, this message translates to:
  /// **'Clinic Portal'**
  String get clinicPortal;

  /// No description provided for @accessDeniedNotClinic.
  ///
  /// In en, this message translates to:
  /// **'Access Denied. Not a Clinic user.'**
  String get accessDeniedNotClinic;

  /// No description provided for @ashaWorkerSignUp.
  ///
  /// In en, this message translates to:
  /// **'ASHA Worker Sign Up'**
  String get ashaWorkerSignUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Failed'**
  String get signUpFailed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @enterWaterQualityData.
  ///
  /// In en, this message translates to:
  /// **'Enter Water Quality Data'**
  String get enterWaterQualityData;

  /// No description provided for @pleaseEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a location'**
  String get pleaseEnterLocation;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @predictAndSave.
  ///
  /// In en, this message translates to:
  /// **'Predict & Save'**
  String get predictAndSave;

  /// No description provided for @predictionResult.
  ///
  /// In en, this message translates to:
  /// **'Prediction Result'**
  String get predictionResult;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get anErrorOccurred;

  /// No description provided for @failedToProcessPrediction.
  ///
  /// In en, this message translates to:
  /// **'Failed to process prediction. Please check your inputs.'**
  String get failedToProcessPrediction;

  /// No description provided for @newDiseaseReport.
  ///
  /// In en, this message translates to:
  /// **'New Disease Report'**
  String get newDiseaseReport;

  /// No description provided for @selectDiseaseType.
  ///
  /// In en, this message translates to:
  /// **'Select Disease Type'**
  String get selectDiseaseType;

  /// No description provided for @diseaseType.
  ///
  /// In en, this message translates to:
  /// **'Disease Type'**
  String get diseaseType;

  /// No description provided for @pleaseSelectDisease.
  ///
  /// In en, this message translates to:
  /// **'Please select a disease'**
  String get pleaseSelectDisease;

  /// No description provided for @numberOfPatients.
  ///
  /// In en, this message translates to:
  /// **'Number of Patients'**
  String get numberOfPatients;

  /// No description provided for @pleaseEnterPatientCount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the number of patients'**
  String get pleaseEnterPatientCount;

  /// No description provided for @locationArea.
  ///
  /// In en, this message translates to:
  /// **'Location / Area'**
  String get locationArea;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @failedToSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report'**
  String get failedToSubmitReport;

  /// No description provided for @postAnAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Post an Announcement'**
  String get postAnAnnouncement;

  /// No description provided for @enterYourMessageHere.
  ///
  /// In en, this message translates to:
  /// **'Enter your message here...'**
  String get enterYourMessageHere;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @announcementPosted.
  ///
  /// In en, this message translates to:
  /// **'Announcement Posted'**
  String get announcementPosted;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available for the selected period.'**
  String get noDataAvailable;

  /// No description provided for @viewFullReport.
  ///
  /// In en, this message translates to:
  /// **'View Full Report'**
  String get viewFullReport;

  /// No description provided for @reportedFrom.
  ///
  /// In en, this message translates to:
  /// **'Reported from'**
  String get reportedFrom;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @anUnknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get anUnknownErrorOccurred;
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
      <String>['as', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
