# book-my-place-V1.0

# Venue Booking App

The Venue Booking App is a role-based Flutter application that allows users to book venues, manage resources, and visualize data insights using a modern UI and real-time analytics. Built with Flutter and Firebase, it is tailored for organizations and institutions needing efficient venue management.

---

## Features

### Core Functionalities
- Venue reservation system with time-slot management
- Role-based access control (Admin, Manager, User)
- Live analytics dashboard with graphs and booking insights
- Firestore integration for real-time data handling
- User and resource management via Admin panel

### User Roles

**Admin**
- View and manage all bookings
- Add, edit, and delete users
- Access analytics and insights

**Manager**
- Monitor and manage assigned venues
- Track booking schedules

**User**
- Browse available venues
- Book time slots
- View personal booking history

### Analytics & Reporting

- Line charts for daily bookings
- Bar charts for venue-wise booking volume
- Total bookings, venues, and active users summary
- Insights updated in real-time using Firestore streams

---

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Cloud Firestore, Authentication)
- **Data Visualization**: fl_chart
- **State Management**: setState (can be extended to Provider/BLoC)

---

## Installation Instructions

### Prerequisites
- Flutter SDK (3.10 or higher)
- Firebase project with Authentication and Firestore enabled

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-username/venue-booking-app.git
cd venue-booking-app
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Set Up Firebase

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com)
2. Enable **Email/Password** authentication
3. Enable **Cloud Firestore**
4. Download the `google-services.json` file and place it in `android/app/`
5. For iOS, download `GoogleService-Info.plist` and place it in `ios/Runner/`

### Step 4: Run the Application

```bash
flutter run
```

### Step 5: Run the Code in an IDE

Run the code in an IDE like Android Studio or VS Code on an emulator or your local device.

---

## Firebase Firestore Security Rules (Example)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /resources/{resourceId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }

    match /bookings/{bookingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## Directory Structure

```
lib/
├── main.dart
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── booking_screen.dart
│   ├── booking_analytics_screen.dart
│   └── manage_users_screen.dart
├── widgets/
│   ├── analytics_cards.dart
│   └── chart_widgets.dart
├── services/
│   └── auth_service.dart
├── models/
│   └── user_model.dart
└── utils/
    └── constants.dart
```

---

## Development Roadmap

- Role-based authentication [Completed]
- Booking system with Firestore [Completed]
- Analytics dashboard with charts [Completed]
- Notifications and reminders [Planned]
- Calendar-style booking view [Planned]
- Dark mode support [Planned]

---

## Contributing

Contributions are welcome. Fork the repository and create a pull request with your changes. Please follow the existing code style and structure.
