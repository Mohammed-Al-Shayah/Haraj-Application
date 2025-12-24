class ApiEndpoints {
  static String baseUrl = 'https://unityaid.net/haraj/api/v1';
  static String imageUrl = 'https://unityaid.net/haraj/uploads/';
  static String baseAPI = '$baseUrl/api';
  static String register = '$baseUrl/auth/register';
  static String login = '$baseUrl/auth/login';
  static String googleAuth = '$baseUrl/auth/google/redirect';
  static String verifyOtp = '$baseUrl/auth/verify-otp';
  static String resendOtp = '$baseUrl/auth/resend-otp';
  static String logout = '$baseUrl/auth/logout';
  static String banners = '$baseUrl/banners';
  static String adsHome = '$baseUrl/ads/home';
  static String nearbyAds = '$baseUrl/ads/nearby';

  static String categoriesHome = '$baseUrl/categories/home-page-menu';

  static String adDetails(int id) => '$baseUrl/ads/$id';
  static String adCommentsPaginate = '$baseUrl/ads/comments/paginate';

  static String addComments(int id) => '$baseUrl/ads/comments/$id';

  static String walletSummary = '$baseUrl/wallet-transactions/wallet-summary';
  static String walletDepositRequest = '$baseUrl/wallet-deposits-requests';

  static String likeAd(int adId) => '$baseUrl/ads/likes/$adId';
  static String removeLike(int likeId) => '$baseUrl/ads/likes/$likeId';

  static String categoriesParents = '$baseUrl/categories/parents';
  static String categoryAttributes(int categoryId) => '$baseUrl/categories/$categoryId/attributes';

  static String featuredSettings = '$baseUrl/ads/featured-settings';
  static String discounts = '$baseUrl/ads/discounts';

  static String createAd = '$baseUrl/ads';
  static String categoryAds(int categoryId) => '$baseUrl/categories/$categoryId/ads';
}
