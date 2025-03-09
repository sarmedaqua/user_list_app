# user_list_app

By Sarmed Ahmed Usmani

A Flutter mobile application that demonstrates Clean Architecture, Riverpod state management, and API integration.

## Features

- User List Screen: Fetch and display users in a list with name and profile picture.
- User Detail Screen: Display selected user details with their profile picture, name, email and phone.
- Search Functionality: Implement a search bar to filter users by name.
- Pagination with infinite scrolling
- Pull-to-refresh functionality
- Error handling with user-friendly messages
- Responsive UI that works on different screen sizes

## Architecture

This project follows Clean Architecture principles, separating the codebase into different layers:

- Core
- Data
- Domain
- Presentation

## Dependencies

- flutter_riverpod
- dio
- shared_preferences
- cached_network_image
- connectivity_plus
- get_it
- shimmer

## Error Handling

The app handles various error scenarios:
- Network failures
- Timeout errors
- Empty responses
- No connectivity
- Server errors

## API Reference

This app uses the [ReqRes API](https://reqres.in/) to fetch user data.

### Installation

1. Clone the repository:
   git clone https://github.com/sarmedaqua/user_list_app.git
2. Navigate to the project directory:
   cd user_list_app
3. Install dependencies:
   flutter pub get
4. Run the app:
   flutter run

## Testing

Run the tests with:
flutter test


