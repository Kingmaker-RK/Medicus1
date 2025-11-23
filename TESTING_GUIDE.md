# Testing Guide

This document outlines the testing procedures for the AI-Gris application, with a focus on the newly refactored Services Hub.

## Services Hub Testing

The Services Hub has been refactored to be data-driven. To test the new implementation, follow these steps:

1.  **Navigate to the Services Hub**: Launch the application and navigate to the "Services" tab from the bottom navigation bar.

2.  **Verify Service Cards**: Ensure that all the service cards are displayed correctly. The data for these cards is now loaded from `lib/data/services_data.dart`.

3.  **Test Navigation**: Click on each service card and verify that it navigates to the correct screen. The navigation is handled by `GoRouter` and the routes are defined in `lib/constants/app_routes.dart`.

4.  **Add a New Service**: To test the scalability of the new architecture, add a new service to the `lib/data/services_data.dart` file.
    *   Create a new `ServiceModel` instance with a unique title, description, icon, color, and route.
    *   Add a corresponding route in `lib/constants/app_routes.dart` and `lib/config/router.dart`.
    *   Create a new screen for the service.
    *   Relaunch the app and verify that the new service card is displayed and navigates to the correct screen.

## General UI Testing

-   **Responsiveness**: Test the application on different screen sizes and orientations to ensure that the UI is responsive.
-   **Theme**: Verify that the application uses the correct theme and colors as defined in `lib/constants/colors.dart`.
-   **Text**: Check for any text overflow issues and ensure that the font is consistent throughout the application.

## State Management Testing

-   **Providers**: The application uses `provider` for state management. Use the Flutter DevTools to inspect the state of the providers and ensure that they are updated correctly.
-   **Data Persistence**: Verify that the application state is persisted correctly across app launches. The `PatientProfileProvider` uses `shared_preferences` to store the user's profile data.