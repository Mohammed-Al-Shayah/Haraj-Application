<h1>Haraj Adan App</h1>

<img src="assets/images/thumbnail.png" alt="App Thumbnail">

## Description

A mobile app that connects buyers and sellers through product listings and advertisements. Sellers
can promote products using ad plans, while buyers can search, filter, and purchase items seamlessly.
The app includes roles like Super Admin, Admin, and User (Buyer/Seller) to manage functionalities
effectively.

## Key Features:

- **User Registration**: Social media login (Google, Facebook, Apple) and email verification.
- **Product Management**: Create, update, and advertise product listings.
- **Search & Filter**: Advanced search and filtering options for buyers.
- **Advertisement Plans**: Sellers can promote products for higher visibility.
- **Secure Payments**: Payment gateway for ads and purchases.
- **Admin Dashboard**: Manage users, products, ads, and reports.
- **Notifications**: Real-time updates for buyers and sellers.

# Technologies 🛠️

This project leverages the following technologies:

- **Flutter**: A UI toolkit for building natively compiled mobile, web, and desktop applications
  from a single codebase.
- **Dart**: The programming language used to write Flutter applications.
- **Material 3**: The latest iteration of Material Design, providing modern UI components and design
  elements.
- **GetX**: A state management library that simplifies the management of app state, routing, and
  dependencies.
- **API with Dio**: A powerful and easy-to-use HTTP client for Dart, used to fetch data from APIs.
- **Caching**: Efficient data caching techniques to improve performance and reduce unnecessary API
  calls.
- **Localize And Translate**: A package for localization and translation to support multiple
  languages in the app.

These technologies work together to create a robust and scalable application.

## Project Structure 📁

This Flutter project utilizes a clean architecture approach to enhance maintainability and scalability. The project structure is organized as follows:

- lib/core/: Contains core utilities and functionalities used throughout the application.
- lib/features/: Organized by feature modules, each containing its own presentation, domain, and data layers.
- lib/main.dart: The entry point of the application.

This structure promotes a clear separation of concerns and facilitates easier management and extension of the codebase.

![CleanArchitecture](https://github.com/user-attachments/assets/e0695060-f965-45c4-ae2b-d3f30cce9df8)

## .env

Environment configuration for sensitive data (API keys, etc).