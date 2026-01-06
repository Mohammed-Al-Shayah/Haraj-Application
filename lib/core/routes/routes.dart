import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/create_ads/views/screens/post_ad_categories_screen.dart';
import 'package:haraj_adan_app/features/my_account/binding/wallet_binding.dart';
import '../../features/my_account/views/screens/deposit_screen.dart';
import '../../features/my_account/views/screens/wallet_screen.dart';
import '../../features/subcategories/views/screens/subcategories_screen.dart';
import '../../features/support/views/screens/support_detail_screen.dart';
import '../../features/authentication/email_verification/views/screens/verification_screen.dart';
import '../../features/authentication/forgot_password/views/screens/forgot_password_screen.dart';
import '../../features/authentication/login/views/screens/login_screen.dart';
import '../../features/authentication/onboarding/views/screens/onboarding_screen.dart';
import '../../features/authentication/register/views/screens/register_screen.dart';
import '../../features/authentication/reset_password/views/screens/reset_password_screen.dart';
import '../../features/authentication/splash/views/screens/splash_screen.dart';
import '../../features/authentication/login/binding/login_binding.dart';
import '../../features/chat/views/screens/chat_detail_screen.dart';
import '../../features/chat/views/screens/chats_screen.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/permissions/views/screens/permissions_screen.dart';
import '../../features/home/views/screens/ads_result_screen.dart';
import '../../features/home/views/screens/search_screen.dart';
import '../../features/ad_details/bindings/comments_binding.dart';
import '../../features/ad_details/views/screens/ad_details_screen.dart';
import '../../features/create_ads/views/screens/success_posted_screen.dart';
import '../../features/create_ads/views/screens/select_ad_screen.dart';
import '../../features/create_ads/views/screens/post_ad_screen.dart';
import '../../features/my_account/views/screens/favourite_ads_screen.dart';
import '../../features/my_account/views/screens/my_account_screen.dart';
import '../../features/my_account/views/screens/my_profile_screen.dart';
import '../../features/my_account/views/screens/not_published_screen.dart';
import '../../features/my_account/views/screens/rejected_screen.dart';
import '../../features/my_account/views/screens/featured_ads_screen.dart';
import '../../features/my_account/views/screens/on_air_screen.dart';
import '../../features/support/views/screens/support_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String onboardingScreen = '/onboarding-screen';
  static const String registerScreen = '/register-screen';
  static const String loginScreen = '/login-screen';
  static const String forgotPasswordScreen = '/forgot-password-screen';
  static const String resetPasswordScreen = '/reset-password-screen';
  static const String verificationScreen = '/verification-screen';

  /// Home Screens
  static const String homeScreen = '/home-screen';
  static const String subcategoriesScreen = '/subcategories-screen';
  static const String adsResultScreen = '/ads-result-screen';
  static const String searchScreen = '/search-screen';

  static const String supportScreen = '/support-screen';
  static const String supportDetailScreen = '/support-detail-screen';

  /// Ad Details Screens
  static const String adDetailsScreen = '/ad-details-screen';

  /// Chats Screens
  static const String chatsScreen = '/chats-screen';
  static const String chatDetailsScreen = '/chat-details-screen';

  /// My Account Screens
  static const String myAccountScreen = '/my-account-screen';
  static const String myProfileScreen = '/my-profile-screen';
  static const String onAirScreen = '/on-air-screen';
  static const String notPublishedScreen = '/not-published-screen';
  static const String rejectedScreen = '/rejected-screen';
  static const String featuredAdsScreen = '/featured-ads-screen';
  static const String favouriteAdsScreen = '/favourite-ads-screen';
  static const String permissionsScreen = '/permissions-screen';
  static const String walletScreen = '/wallet-screen';
  static const String depositScreen = '/deposit-screen';

  /// Create Ads Screens
  static const String selectAdScreen = '/select-ad-screen';
  static const String successPostedScreen = '/success-posted-screen';
  static const String postAdScreen = '/post-ad-screen';
  static const String postAdCategoriesScreen = '/post-ad-categories';

  static List<GetPage> routes = [
    /// Authentication Screens
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(
      name: Routes.onboardingScreen,
      page: () => const OnboardingScreen(),
    ),
    GetPage(name: Routes.registerScreen, page: () => const RegisterScreen()),
    GetPage(
      name: Routes.loginScreen,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.forgotPasswordScreen,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: Routes.resetPasswordScreen,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(
      name: Routes.verificationScreen,
      page: () => const VerificationScreen(),
    ),

    /// Home Screens
    GetPage(name: Routes.homeScreen, page: () => HomeScreen()),
    GetPage(
      name: Routes.subcategoriesScreen,
      page: () => const SubcategoriesScreen(),
    ),
    GetPage(name: Routes.adsResultScreen, page: () => const AdsResultScreen()),
    GetPage(name: Routes.searchScreen, page: () => const SearchScreen()),
    GetPage(name: Routes.supportScreen, page: () => SupportScreen()),
    GetPage(
      name: Routes.supportDetailScreen,
      page: () => SupportDetailScreen(),
    ),

    /// Ad Details Screens
    GetPage(
      name: Routes.adDetailsScreen,
      page: () => const AdDetailsScreen(),
      binding: CommentsBinding(),
    ),

    /// Chats Screens
    GetPage(name: Routes.chatsScreen, page: () => ChatsScreen()),
    GetPage(
      name: Routes.chatDetailsScreen,
      page: () => const ChatDetailScreen(),
    ),

    /// My Account Screens
    GetPage(name: Routes.myAccountScreen, page: () => const MyAccountScreen()),
    GetPage(name: Routes.myProfileScreen, page: () => MyProfileScreen()),
    GetPage(name: Routes.onAirScreen, page: () => OnAirScreen()),
    GetPage(name: Routes.notPublishedScreen, page: () => NotPublishedScreen()),
    GetPage(name: Routes.rejectedScreen, page: () => RejectedScreen()),
    GetPage(
      name: Routes.featuredAdsScreen,
      page: () => const FeaturedAdsScreen(),
    ),
    GetPage(name: Routes.favouriteAdsScreen, page: () => FavouriteAdsScreen()),
    GetPage(
      name: Routes.permissionsScreen,
      page: () => const PermissionsScreen(),
    ),
    // GetPage(name: Routes.walletScreen, page: () => const WalletScreen()),
    // GetPage(name: Routes.depositScreen, page: () => const DepositScreen()),
    GetPage(
      name: Routes.walletScreen,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.depositScreen,
      page: () => const DepositScreen(),
      binding: WalletBinding(),
    ),

    /// Create Ads Screens
    GetPage(name: Routes.selectAdScreen, page: () => SelectAdScreen()),
    GetPage(name: Routes.postAdScreen, page: () => PostAdScreen()),
    GetPage(
      name: Routes.successPostedScreen,
      page: () => SuccessPostedScreen(),
    ),

    GetPage(
      name: Routes.postAdCategoriesScreen,
      page: () => const PostAdCategoriesScreen(),
    ),
  ];
}
