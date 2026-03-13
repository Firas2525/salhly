class AppApi {
  // base url
  // live:    https://dash.kelshi.com
  // staging: https://kolishi.start-tech.ae
  static const String baseWebSiteUrl = 'https://kelshi.com';

  static const String baseUrl = 'https://www.salhly.lareenmedco.com/api';
  static const String version = 'api/v1';
  static const String login = '$baseUrl/$version/users/auth/login-email';
  static const String register = '$baseUrl/$version/users/auth/register';
  static const String forgotPass =
      '$baseUrl/$version/users/auth/forgot-password';
  static const String sendVerOtp =
      '$baseUrl/$version/users/auth/send-otp-verification';
  static const String verifyOtp =
      '$baseUrl/$version/users/auth/verify-email-otp';
  static const String getCities = '$baseUrl/$version/city/get-cities';

  static const String getBusiness = '$baseUrl/$version/businesses';
  static const String getProp = '$baseUrl/$version/property/get';
  static const String getPropDetail = '$baseUrl/$version/property/find';

  static const String getAgentList = '$baseUrl/$version/agents';
  static const String saveLeads = '$baseUrl/$version/leads/save';
  static const String getFilters = '$baseUrl/$version/property/details';

  static String getSubCategories(int categoryID) =>
      '$baseUrl/$version/categories/sub-category/$categoryID';

  static const String getCurrencies = '$baseUrl/$version/currencies';

  static const String saveItem = '$baseUrl/$version/save-items/save';
  static const String getSaveItems =
      '$baseUrl/$version/save-items/user-save-items';
  static const String getCategories =
      "$baseUrl/$version/property/categories-images";
  static const String getVersionCode = "$baseUrl/$version/versions/app-version";
  static const String getSaveCars = '$baseUrl/$version/car/user-save-cars';
  static const String saveCar = '$baseUrl/$version/car/save';

  //profile
  static const String getCurrentUser = '$baseUrl/$version/users/current-user';
  static const String updateUser = '$baseUrl/$version/users/update';
  static const String changePassword =
      "$baseUrl/$version/users/change-password";
  static const String sendHelp = "$baseUrl/$version/support";

  static const String getPopular = "$baseUrl/$version/search/popular";
  static const String getLatest = "$baseUrl/$version/search/latest";
  static const String getSearchResults = "$baseUrl/$version/search";

  //salon
  static const String getServices = "$baseUrl/$version/services";
  static const String bookSalon = "$baseUrl/$version/booking/booking-now";
  static const String getBookedAppoint =
      "$baseUrl/$version/booking/user-booking";
  static const String cancelAppoint = "$baseUrl/$version/booking/cancel";

  //trips
  static const String getTripsResults = "$baseUrl/$version/trips/search";
  static const String bookingTrip = "$baseUrl/$version/trips/bookings";
  static const String userTrips = "$baseUrl/$version/trips/user-booking";
  static const String getCompany = "$baseUrl/$version/businesses/find_company";

  //healthcare
  static const String getHealthcareResults = "$baseUrl/$version/businesses";
  static const String getProductsResults = "$baseUrl/$version/products";
  static const String getDoctorsResults = "$baseUrl/$version/doctors";
  static const String bookClinic = "$baseUrl/$version/booking/booking-now";
  static const String addReview = "$baseUrl/$version/reviews/create-review";

  //cart

  static const String getCartItems = "$baseUrl/$version/cart/items";
  static const String addCartItem = "$baseUrl/$version/cart/add-item";
  static const String increaseItem = "$baseUrl/$version/cart/increase-item";
  static const String decreaseItem = "$baseUrl/$version/cart/decrease-item";
  static const String removeItem = "$baseUrl/$version/cart/remove-item";
  static const String cartCheckout = "$baseUrl/$version/order/checkout-order";

  //cars
  static const String getCarsMakes = "$baseUrl/$version/car/get-make";
  static const String getCarsModel = "$baseUrl/$version/car/get_make_model";
  static const String getCars = "$baseUrl/$version/car/get";
  static const String getCarColors = "$baseUrl/$version/car/get_colors";
  static const String inquiryCar = "$baseUrl/$version/car/create-inquiry";

  //start
  static const String getStart = '$baseUrl/$version/home/new';
}
