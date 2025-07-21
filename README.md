## Project Overview

The **Data Collection Flutter App & SDK** is a system designed to collect user SMS and call log data securely and efficiently. It consists of three main components:

- **Flutter Application:** A mobile app that requests permissions from the user, reads SMS and call logs from the device, and feeds this data into the SDK.
- **Data Collection SDK:** A lightweight Dart module that processes incoming data events, detects important transactional SMS messages, batches non-critical data, and sends the data to the backend API.
- **Backend API:** A minimal Django-based server that receives the data from the SDK, logging or storing it to verify successful data transmission.

The system intelligently handles data by immediately forwarding transactional SMS messages containing keywords such as "OTP", "transaction", "debited", "credited", or "spent" while batching other SMS and call logs to reduce network usage.

This project demonstrates end-to-end data collection, processing, and transmission using Flutter for the frontend, a custom Dart SDK, and a Django backend API.

## Architecture Diagram

The system consists of three main components interacting with each other:


+------------------+ +--------------------+ +----------------+
| | | | | |
| Flutter App | <---> | Data Collection SDK| <---> | Backend API |
| (Permissions, | | (Batching, Logic) | | (Django Server)|
| Data Reading) | | | | |
+------------------+ +--------------------+ +----------------+
