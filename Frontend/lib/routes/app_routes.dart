import 'package:flutter/material.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/profile_screen/edit_profile_screen.dart';
// Compensation Module
import '../presentation/compensation_module/compensation_home_screen.dart';
import '../presentation/compensation_module/compensation_calculator_screen.dart';
import '../presentation/compensation_module/compensation_eligibility_screen.dart';
import '../presentation/compensation_module/compensation_process_screen.dart';
import '../presentation/community_chat/community_chat_screen.dart';
import '../presentation/land_record_module/land_record_home_screen.dart';
// Auth
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/mobile_login_screen/mobile_login_screen.dart';
import '../presentation/otp_verification_screen/otp_verification_screen.dart';
import '../presentation/location_permission_screen/location_permission_screen.dart';

// Dashboard
import '../presentation/main_dashboard_screen/main_dashboard_screen.dart';
import '../presentation/add_product_screen/add_product_screen.dart';
// Modules
import '../presentation/weather_module_screen/weather_module_screen.dart';
import '../presentation/crop_price_screen/crop_price_screen.dart';
import '../presentation/marketplace_screen/marketplace_screen.dart';
import '../presentation/organic_farming_guide_screen/organic_farming_guide_screen.dart';
// Extra
import '../presentation/product_detail_screen/product_detail_screen.dart';
import '../presentation/scheme_detail_screen/scheme_detail_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/ai_chatbot_screen/ai_chatbot_screen.dart';

// Schemes
import '../presentation/schemes_list_screen/schemes_list_screen.dart';


class AppRoutes {
  static const String initial = '/';

  // Auth
  static const String splash = '/splash-screen';
  static const String mobileLogin = '/mobile-login-screen';
  static const String otpVerification = '/otp-verification-screen';
  static const String locationPermission = '/location-permission-screen';
  static const String editProfile = '/edit-profile';

  // Dashboard
  static const String mainDashboard = '/main-dashboard_screen';
  static const String addProduct = '/add-product-screen';
  // Modules
  static const String weatherModule = '/weather-detail-screen';
  static const String cropPrice = '/crop-price-screen';
  static const String marketplace = '/marketplace-screen';
  static const String aiChatbot = '/ai-chatbot-screen';
  static const String organicFarming = '/organic-farming-screen';
  // Extra
  static const String productDetail = '/product-detail-screen';
  static const String landRecord = '/land-record';
  // static const String schemeDetail = '/scheme-detail-screen';
  static const String notifications = '/notifications-screen';

  static const String compensationHome = '/compensation-home';
  static const String compensationCalculator = '/compensation-calculator';
  static const String compensationEligibility = '/compensation-eligibility';
  static const String compensationProcess = '/compensation-process';
  
   // Govt Schemes ✅
  static const String schemesList = '/schemes-list-screen';
  static const String schemeDetail = '/scheme-detail-screen';
  static const String communityChat = '/community-chat';
  static const String profile = '/profile-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),

    // Auth
    splash: (context) => const SplashScreen(),
    mobileLogin: (context) => const MobileLoginScreen(),
    otpVerification: (context) => const OtpVerificationScreen(),
    locationPermission: (context) => const LocationPermissionScreen(),
    editProfile: (context) => const EditProfileScreen(),

    // Dashboard ✅ FIXED
    mainDashboard: (context) => const MainDashboard(),
    addProduct: (context) => const AddProductScreen(),
    // Modules
    weatherModule: (context) => const WeatherModuleScreen(),
    cropPrice: (context) => const CropPriceScreen(),
    marketplace: (context) => const MarketplaceScreen(),
    aiChatbot: (context) => const AiChatbotScreen(),
    communityChat: (context) => const CommunityChatScreen(),
    profile: (context) => const ProfileScreen(),
    // Extra
    productDetail: (context) => const ProductDetailScreen(),
    notifications: (context) => const NotificationsScreen(),
    organicFarming: (context) => const OrganicFarmingGuideScreen(),
    // Schemes ✅
    schemesList: (context) => const SchemesListScreen(),
    schemeDetail: (context) {
      return const SchemeDetailScreen();
    },
    landRecord: (context) => const LandRecordHomeScreen(),
    
    compensationHome: (context) => const CompensationHomeScreen(),
    compensationCalculator: (context) => const CompensationCalculatorScreen(),
    compensationEligibility: (context) => const CompensationEligibilityScreen(),
    compensationProcess: (context) => const CompensationProcessScreen(),

  };
}