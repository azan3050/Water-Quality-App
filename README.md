# Jal-Raksha-Kavach

**An AI-powered, multi-lingual mobile application for proactive water quality monitoring and public health management.**

Jal-Raksha-Kavach is a comprehensive Flutter-based ecosystem designed to bridge the critical gap between environmental data collection and public health response. It empowers on-ground health workers (ASHA) and local clinics to report real-time data, which is then visualized and analyzed on a powerful dashboard for administrators to make informed, life-saving decisions.

---

## Key Features

* **Multi-Role Authentication**: Secure login portals for three distinct user types:
    * **ASHA Workers**: The frontline data collectors.
    * **Clinics**: For reporting public health outcomes.
    * **Administrators**: To monitor, analyze, and act on the data.

* **Offline AI-Powered Predictions**: ASHA workers can input 7 key water parameters. An integrated TensorFlow Lite model provides an instant **on-device prediction** of the water's risk level (Low, Medium, or High), which works perfectly even without an internet connection.

* **Real-time Disease Reporting**: Clinics can report outbreaks of water-borne diseases, specifying the disease type, number of patients, and location, creating a live health map.

* **Comprehensive Admin Dashboard**: A powerful, real-time dashboard for administrators featuring:
    * **Time-based Filtering**: View all data from the "Last 7 Days," "Last 30 Days," or "All Time."
    * **At-a-Glance KPIs**: See total predictions, high-risk alerts, and locations tested.
    * **Data Visualization**: Interactive pie charts for risk breakdown and bar charts for disease reports. 

[Image of a data dashboard with charts]

    * **Risk Hotspots**: An intelligent feature that combines water quality data and clinic reports to visually flag high-priority locations with color-coded tags.

* **Public Alerts & Announcements**:
    * A central "Alerts" tab with separate sections for **Reports** and **Announcements**.
    * Admins can post advisories and public health messages directly from their dashboard for all users to see.

* **Multi-Lingual Support**: Full internationalization (i18n) support for **English**, **Hindi**, and **Assamese** to ensure maximum accessibility for all users.

---

## Technology Stack

* **Frontend**: Flutter
* **Backend & Database**: Firebase (Authentication, Cloud Firestore)
* **Machine Learning**: TensorFlow Lite (for on-device inference)
* **Data Visualization**: `fl_chart`

---

## Setup and Installation

1.  **Clone the Repository**:
    ```bash
    git clone <your-repository-url>
    cd Jal-Raksha-Kavach-project
    ```

2.  **Firebase Setup**:
    * Create a new project on the [Firebase Console](https://console.firebase.google.com/).
    * Enable **Authentication** (Email/Password method).
    * Enable **Cloud Firestore** database.
    * Follow the on-screen instructions to add an Android/iOS app to your Firebase project.
    * Follow the FlutterFire CLI instructions to generate the `firebase_options.dart` file.

3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Run the App**:
    ```bash
    flutter run
    ```

---

## Project Structure
```bash
    lib/
├── screens/              # Contains all UI pages, organized by role
│   ├── admin/
│   │   ├── admin_home_page.dart
│   │   └── admin_login_page.dart
│   ├── asha_worker/
│   │   ├── asha_worker_home_page.dart
│   │   ├── asha_worker_login_page.dart
│   │   └── asha_worker_signup_page.dart
│   ├── clinic/
│   │   ├── clinic_home_page.dart
│   │   └── clinic_login_page.dart
│   ├── alerts_page.dart
│   └── role_selection_page.dart
├── services/             # Contains business logic and services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── ml_service.dart
├── l10n/                 # Contains .arb files for multi-lingual text
│   ├── app_en.arb
│   ├── app_hi.arb
│   └── app_as.arb
└── main.dart             # Main application entry point
assets/
└── ann_model.tflite      # The TensorFlow Lite model file
pubspec.yaml
README.md
