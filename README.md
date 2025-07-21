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
