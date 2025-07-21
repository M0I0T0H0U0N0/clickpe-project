## Project Overview

The **Data Collection Flutter App & SDK** is a system designed to collect user SMS and call log data securely and efficiently. It consists of three main components:

- **Flutter Application:** A mobile app that requests permissions from the user, reads SMS and call logs from the device, and feeds this data into the SDK.
- **Data Collection SDK:** A lightweight Dart module that processes incoming data events, detects important transactional SMS messages, batches non-critical data, and sends the data to the backend API.
- **Backend API:** A minimal Django-based server that receives the data from the SDK, logging or storing it to verify successful data transmission.

The system intelligently handles data by immediately forwarding transactional SMS messages containing keywords such as "OTP", "transaction", "debited", "credited", or "spent" while batching other SMS and call logs to reduce network usage.

This project demonstrates end-to-end data collection, processing, and transmission using Flutter for the frontend, a custom Dart SDK, and a Django backend API.



## Architecture Diagram

The data collection system consists of three core components working together:

    +-------------------+       +---------------------+       +----------------+
    |                   |       |                     |       |                |
    |   Flutter App     | <---> | Data Collection SDK | <---> |   Backend API  |
    | (Permissions,     |       |  (Batching & Logic) |       |  (Django REST) |
    |  Data Reading)    |       |                     |       |                |
    +-------------------+       +---------------------+       +----------------+

- **Flutter App:** Handles user permissions, reads SMS and call logs from the device/emulator, and forwards data to the SDK.
- **Data Collection SDK:** Implements buffering, transactional SMS detection, and batch sending logic. Acts as a bridge between the app and backend.
- **Backend API:** Minimal Django server receiving and logging events sent by the SDK to verify data transfer.

This architecture promotes separation of concerns and scalability.

## Core Technologies

| Component     | Technology               |
|---------------|--------------------------|
| **Mobile**    | Flutter, Dart            |
| **SDK**       | Pure Dart Module/Package |
| **Backend**   | Django REST Framework    |
| **Emulator**  | Android Emulator (ADB)   |

---

- **Flutter & Dart:** Used to build the mobile application and the SDK for cross-platform compatibility and efficient performance.
- **Dart SDK:** A standalone module responsible for batching, transactional SMS detection, and sending data.
- **Django REST Framework:** Provides a minimal API backend for receiving and logging event data.
- **Android Emulator & ADB:** Used for testing by simulating SMS and call log entries on a virtual device.


## Functional Requirements

### Part 1: The Minimalist Backend API
- **Endpoint:**  
  Create a single API endpoint: `localhost:8000/drinks`.
- **Functionality:**  
  When this endpoint receives a JSON payload, it should log the entire payload to the console or save it to a simple file/database. Its sole purpose is to confirm that data is received correctly from the SDK.

---

### Part 2: The Data Collection SDK (Core Challenge)
- **Public Interface:**  
  - Initialize the SDK with the backend API endpoint.  
  - Pass individual SMS events for processing.  
  - Pass individual call log events for processing.

- **Internal Logic:**  
  - **Buffering:** Maintain an internal queue or buffer for SMS and call log events.  
  - **Transactional SMS Detection:** Inspect SMS bodies for keywords like `"OTP"`, `"transaction"`, `"debited"`, `"credited"`, `"spent"` to mark them as transactional.  
  - **Intelligent Sending:**  
    - Immediately send transactional SMS events to the backend.  
    - Buffer non-transactional SMS and all call logs.  
    - When buffer size reaches 50, flush and send all events as a batch to the backend.

---

### Part 3: The Flutter Application
- **Permissions:**  
  Request user permissions at startup to read SMS and call logs using packages like `permission_handler`.

- **Data Reading:**  
  Upon permission grant, read the user’s existing SMS and call logs from the device.

- **SDK Integration:**  
  - Initialize the SDK during app startup.  
  - Iterate over SMS and call logs and pass each event to the SDK for processing.

- **UI Requirements:**  
  - Display current permission status (Granted/Denied).  
  - Show a simple log view of events passed to the SDK (e.g., "Sent SMS #123 to SDK", "Sent Call Log #45 to SDK").

## Installation and Setup

### Prerequisites

- **Flutter SDK** installed ([Flutter installation guide](https://flutter.dev/docs/get-started/install))
- **Dart SDK** (comes with Flutter)
- **Python 3.x** installed
- **Django** and **Django REST Framework** installed (`pip install django djangorestframework`)
- **Android Emulator** set up via Android Studio
- **ADB (Android Debug Bridge)** available and added to your system PATH
- Internet connection for package downloads

---

### Clone the Repository

```bash
git clone https://github.com/M0I0T0H0U0N0/clickpe-project.git
cd clickpe-project
```

---
### Running the Backend

After completing the setup and migrations, start the Django backend server with the following command:

```bash
python manage.py runserver
```
This will start the backend server locally at:
http://localhost:8000/drinks

### Running the Flutter App

1. Open a terminal and navigate to the Flutter app directory:

```bash
cd app
```
2. Fetch Flutter dependencies:
   
```bash
flutter pub get
```
3. Connect your Android emulator or physical device.
4. Run the Flutter application:
```bash
flutter run
```
    

### Using the Emulator: Adding Test Data

You can add call logs and send SMS messages to your Android emulator using ADB commands.

#### Insert Call Log

```bash
adb shell content insert --uri content://call_log/calls --bind number:s:'1234567890' --bind type:i:2 --bind duration:i:60 --bind date:l:1721480000000
```
### Sending SMS to Emulator via ADB

```bash
adb emu sms send <sender-number> "<message-text>"

### Usage Flow

1. **Launch the Flutter App**  
   On startup, the app requests permissions to read SMS and call logs.

2. **Grant Permissions**  
   The user grants the required permissions via the permission prompt.

3. **Read Existing Data**  
   Once permissions are granted, the app reads existing SMS messages and call logs from the device.

4. **Initialize SDK**  
   The app initializes the custom Dart SDK with the backend API endpoint.

5. **Send Events to SDK**  
   For each SMS and call log event, the app passes data to the SDK for processing.

6. **SDK Processing**  
   - The SDK inspects each SMS message:
     - If it contains transactional keywords (e.g., "OTP", "transaction"), it sends the SMS immediately to the backend.
     - Non-transactional SMS and call logs are buffered.
   - Once the buffer reaches 50 events, the SDK batches and sends them to the backend.

7. **Backend Receives Data**  
   The backend API endpoint (`POST /v1/events`) receives and logs incoming events.

8. **User Interface Updates**  
   The Flutter app displays the current permission status and logs actions as events are sent to the SDK.
