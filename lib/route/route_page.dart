import 'package:flutter/material.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/view/SearchView.dart';
import 'package:mpm/view/condition_about/about_view.dart';
import 'package:mpm/view/condition_about/contact_view.dart';
import 'package:mpm/view/condition_about/privacy_policy_view.dart';
import 'package:mpm/view/condition_about/terms&condition_view.dart';
import 'package:mpm/view/dashboard_view.dart';
import 'package:mpm/view/forms_down.dart';
import 'package:mpm/view/gov_scheme.dart';
import 'package:mpm/view/language_view.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/view/otp_view.dart';
import 'package:mpm/view/personal_view.dart';
import 'package:mpm/view/pesidental_adress_view.dart';
import 'package:mpm/view/profile%20view/profile_view.dart';
import 'package:mpm/view/register_view.dart';
import 'package:mpm/view/samiti%20members/samiti_detail_view.dart';
import 'package:mpm/view/samiti%20members/samiti_members_view.dart';
import 'package:mpm/view/splash_view.dart';
import '../view/make_new_member/add_member_first.dart';
import '../view/make_new_member/add_member_second.dart';

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
      case RouteNames.registration_screen:
        return _buildRoute(RegisterView(), settings);
      case RouteNames.personalinfo:
        return _buildRoute(PersonalView(), settings);
      case RouteNames.residentailinfo:
        return _buildRoute(PesidentalAdressView(), settings);
      case RouteNames.dashboard:
        return _buildRoute(DashboardView(), settings);
      case RouteNames.forms:
        return _buildRoute(FormsDownloadView(), settings);
      case RouteNames.gov_scheme:
        return _buildRoute(GovSchemeView(), settings);
      case RouteNames.profile:
        return _buildRoute(ProfileView(), settings);
      case RouteNames.newMember:
        return _buildRoute(NewMemberView(), settings);
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
      case RouteNames.searchmember:
        return _buildRoute(SearchView(), settings);

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
