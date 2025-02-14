class Config {
  // Toggle this flag to switch environments
  static const bool isDevelopment = false;  // true for local development, false for production

  // Choose the API URL based on the environment
  static String get apiUrl => isDevelopment
      ? 'http://localhost:5000'  // Local backend URL
      : 'https://energy-game-api-6a18fc829f3d.herokuapp.com';  // Production backend URL
}
