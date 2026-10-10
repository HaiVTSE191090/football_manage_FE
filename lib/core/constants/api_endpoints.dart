class ApiEndpoints {
  const ApiEndpoints._();

  // Authentication & Users
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String verifyEmail = '/api/auth/email-verification/verify';
  static const String resendEmail = '/api/auth/email-verification/resend';
  static const String googleLogin = '/api/auth/google';
  static const String me = '/api/users/me';

  // Facilities
  static const String facilities = '/api/facilities';
  static String facilityById(String id) => '/api/facilities/$id';

  // Field Types
  static const String fieldTypes = '/api/field-types';

  // Fields & Availability
  static const String fields = '/api/fields';
  static String fieldById(String id) => '/api/fields/$id';
  static String fieldAvailability(String id) => '/api/fields/$id/availability';

  // Referees
  static const String referees = '/api/referees';
  static const String availableReferees = '/api/referees/available';

  // Bookings
  static const String bookings = '/api/bookings';
  static const String myBookings = '/api/bookings/my';
  static String bookingById(String id) => '/api/bookings/$id';
  static String cancelBooking(String id) => '/api/bookings/$id/cancel';

  // Payments
  static const String payments = '/api/payments';
  static String bookingPayments(String bookingId) => '/api/bookings/$bookingId/payments';
  static const String paymentCallback = '/api/payments/callback';

  // Notifications
  static const String notifications = '/api/notifications';
  static String readNotification(String id) => '/api/notifications/$id/read';

  // AI Chatbot (Grounding with DB)
  static const String aiChat = '/api/ai/chat';

  // Tournaments & Teams (FR29 - FR33)
  static const String tournaments = '/api/tournaments';
  static String tournamentById(String id) => '/api/tournaments/$id';
  static String tournamentRegister(String id) => '/api/tournaments/$id/register';
  static String tournamentMatches(String id) => '/api/tournaments/$id/matches';
  static String tournamentStandings(String id) => '/api/tournaments/$id/standings';
  static const String teams = '/api/teams';
  static const String myTeams = '/api/teams/my';

  // Equipment Rental (FR34 - FR37)
  static const String equipment = '/api/equipment';
  static const String availableEquipment = '/api/equipment/available';

  // Store Products & Orders (FR38 - FR42)
  static const String products = '/api/products';
  static String productById(String id) => '/api/products/$id';
  static const String cart = '/api/cart';
  static const String orders = '/api/orders';

  // Admin Endpoints
  static const String adminFacilities = '/api/admin/facilities';
  static const String adminFieldTypes = '/api/admin/field-types';
  static const String adminFields = '/api/admin/fields';
  static const String adminReferees = '/api/admin/referees';
  static const String adminBookings = '/api/admin/bookings';
  static String adminBookingStatus(String id) => '/api/admin/bookings/$id/status';
  static const String adminNotifications = '/api/admin/notifications';
  static const String adminTournaments = '/api/admin/tournaments';
  static const String adminEquipment = '/api/admin/equipment';
  static const String adminProducts = '/api/admin/products';
  static const String adminOrders = '/api/admin/orders';
}

