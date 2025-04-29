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
git clone https://github.com/SuyashDatar26/book-my-place-V1.0/tree/master
cd venue-booking-app
