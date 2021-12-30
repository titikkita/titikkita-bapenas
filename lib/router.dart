import 'package:flutter/material.dart';
import 'package:titikkita/views/pages/family_member/Category.dart';
import 'package:titikkita/views/pages/information/List.dart';
import 'package:titikkita/views/pages/LoginView.dart';
import 'package:titikkita/views/forms/inputOTPVerification.dart';
import 'package:titikkita/views/pages/map/FamilyMap.dart';
import 'package:titikkita/views/pages/map/OthersMap.dart';
import 'package:titikkita/views/pages/family_member/List.dart';
import 'package:titikkita/views/pages/DashboardView.dart';
import 'package:titikkita/views/widgets/vertexEditingCustom.dart';

Route<dynamic> generateRoute (RouteSettings settings) {
  // Here we'll handle all the routing

  switch (settings.name) {
    case '/login':
      // return MaterialPageRoute(builder: (context) => LoginView());
      return MaterialPageRoute(builder: (context) => LoginView());
    case '/dashboard':
      return MaterialPageRoute(builder: (context) => DashboardView());
    case '/members-category':
      return MaterialPageRoute(
          builder: (context) => FamilyMembersCategoryView());
    case '/members-detail':
      return MaterialPageRoute(
          builder: (context) => FamilyMembersDetailsView());
    case '/information':
      return MaterialPageRoute(builder: (context) => InformationListView());
    case '/otp-verification':
      return MaterialPageRoute(builder: (context) => OTPVerification());
    case '/map':
      return MaterialPageRoute(builder: (context) => MyMapView());
    case '/others-map':
      return MaterialPageRoute(builder: (context) => OthersMap());
  }
}
