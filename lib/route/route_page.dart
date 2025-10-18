import 'package:flutter/material.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/view/EnquiryForm/add_enquiry_form.dart';
import 'package:mpm/view/EventTrip/event_trip.dart';
import 'package:mpm/view/OutsideMumbaiLogin/outside_mumbai_login.dart';
import 'package:mpm/view/QRCodeScanner/qr_code.dart';
import 'package:mpm/view/Saraswanilabel/saraswani_label.dart';
import 'package:mpm/view/addmember/add_member_first.dart';
import 'package:mpm/view/addmember/add_member_second.dart';
import 'package:mpm/view/condition_about/about_view.dart';
import 'package:mpm/view/condition_about/contact_view.dart';
import 'package:mpm/view/condition_about/privacy_policy_view.dart';
import 'package:mpm/view/condition_about/terms&condition_view.dart';
import 'package:mpm/view/dashboard_view.dart';
import 'package:mpm/view/discount_offer_view.dart';
import 'package:mpm/view/Events/event_view.dart';
import 'package:mpm/view/forms_down.dart';
import 'package:mpm/view/gov_scheme.dart';
import 'package:mpm/view/home_view.dart';
import 'package:mpm/view/language_view.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/view/notification_view.dart';
import 'package:mpm/view/otp_view.dart';
import 'package:mpm/view/personal_view.dart';
import 'package:mpm/view/reg_otp_view.dart';
import 'package:mpm/view/residental_adress_view.dart';
import 'package:mpm/view/profile%20view/profile_view.dart';
import 'package:mpm/view/register_view.dart';
import 'package:mpm/view/samiti%20members/samiti_detail_view.dart';
import 'package:mpm/view/samiti%20members/samiti_members_view.dart';
import 'package:mpm/view/search_view.dart';
import 'package:mpm/view/splash_view.dart';

class RoutePages {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash_screen:
        return _buildRoute(SplashView(), settings);
      case RouteNames.login_screen:
        return _buildRoute(LoginPage(), settings);
      case RouteNames.language_screen:
        return _buildRoute(LanguageSelectionPage(), settings);
      case RouteNames.otp_screen:
        return _buildRoute(OTPScreen(), settings);
      case RouteNames.regOtp_screen:
        return _buildRoute(RegOTPScreen(), settings);
      case RouteNames.registration_screen:
        return _buildRoute(RegisterView(), settings);
      case RouteNames.personalinfo:
        return _buildRoute(PersonalView(), settings);
      case RouteNames.residentailinfo:
        return _buildRoute(PesidentalAdressView(), settings);
      case RouteNames.home_screen:
        return _buildRoute(const HomeView(), settings);
      case RouteNames.dashboard:
        return _buildRoute(DashboardView(), settings);
      case RouteNames.newMember:
        return _buildRoute(AddNewMemberFirst(), settings);
      case RouteNames.newMember2:
        return _buildRoute(NewMemberResidental(), settings);
      case RouteNames.aboutUs:
        return _buildRoute(AboutViewPage(), settings);
      case RouteNames.contactUs:
        return _buildRoute(ContactViewPage(), settings);
      case RouteNames.pravacypolicy:
        return _buildRoute(PrivacyPolicyViewPage(), settings);
      case RouteNames.termandcondition:
        return _buildRoute(TermsconditionViewPage(), settings);
      case RouteNames.samitimemberview:
        return _buildRoute(SamitiMembersViewPage(), settings);
      case RouteNames.samitimemberdetails:
        return _buildRoute(SamitiDetailPage(), settings);
      case RouteNames.discount_offer_view:
        return _buildRoute(const DiscountofferView(), settings);
      case RouteNames.saraswani_label:
        return _buildRoute(const SaraswanilabelView(), settings);
      case RouteNames.event_view:
        return _buildRoute(const EventsPage(), settings);
      case RouteNames.event_trip:
        return _buildRoute(const EventTripPage(), settings);
      case RouteNames.qr_code:
        return _buildRoute(const QRScannerScreen(), settings);
      case RouteNames.forms:
        return _buildRoute(const FormsDownloadView(), settings);
      case RouteNames.gov_scheme:
        return _buildRoute(GovSchemeView(), settings);
      case RouteNames.add_enquiry_form:
        return _buildRoute(
          const EnquiryFormLoader(),
          settings,
        );

      case RouteNames.profile:
        return _buildRoute(const ProfileView(), settings);
      case RouteNames.searchmember:
        return _buildRoute(SearchView(), settings);
      case RouteNames.notification_view:
        return _buildRoute(NotificationView(), settings);
      case RouteNames.qr_code:
        return _buildRoute(QRScannerScreen(), settings);

      // OutSide Mumbai Login
      case RouteNames.outside_mumbai_login:
        return _buildRoute(OutsideMumbaiLoginPage(), settings);

      default:
        return MaterialPageRoute(builder: (context) {
          return Scaffold(
            body: Center(
              child: Text("No Routes Declare"),
            ),
          );
        });
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings setting) {
    return PageRouteBuilder(
      settings: setting,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

class EnquiryFormLoader extends StatelessWidget {
  const EnquiryFormLoader({super.key});

  Future<AddEnquiryFormView> _loadForm() async {
    final userData = await SessionManager.getSession();
    if (userData == null || userData.memberId == null) {
      throw Exception('User not logged in');
    }

    final memberId = userData.memberId.toString();

    return AddEnquiryFormView(
      memberId: memberId,
      createdBy: memberId,
      addedBy: memberId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AddEnquiryFormView>(
      future: _loadForm(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}

