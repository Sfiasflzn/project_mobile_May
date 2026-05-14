import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'screens/guest/event_directory_screen.dart';
import 'screens/guest/event_detail_screen.dart';
import 'screens/guest/login_prompt_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/exhibitor/exhibitor_home_screen.dart';
import 'screens/exhibitor/select_booth_screen.dart';
import 'screens/exhibitor/booth_detail_screen.dart';
import 'screens/exhibitor/cart_screen.dart';
import 'screens/exhibitor/application_form_screen.dart';
import 'screens/exhibitor/application_status_screen.dart';
import 'screens/exhibitor/my_applications_screen.dart';
import 'screens/organizer/organizer_dashboard_screen.dart';
import 'screens/organizer/create_event_screen.dart';
import 'screens/organizer/booth_management_screen.dart';
import 'screens/organizer/application_review_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/floor_plan_manager_screen.dart';
import 'screens/admin/all_exhibitions_screen.dart';
import 'screens/admin/booth_types_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/all_reservations_screen.dart';
import 'models/booth_model.dart';
import 'models/event_model.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ExhibitSpaceApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Guest
    GoRoute(
      path: '/',
      builder: (_, __) => const EventDirectoryScreen(),
    ),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) {
        final event = state.extra as EventModel;
        return EventDetailScreen(event: event);
      },
    ),
    GoRoute(
      path: '/login-prompt',
      builder: (_, __) => const LoginPromptScreen(),
    ),

    // Auth
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),

    // Exhibitor
    GoRoute(
      path: '/exhibitor',
      builder: (_, __) => const ExhibitorHomeScreen(),
    ),
    GoRoute(
      path: '/exhibitor/select-booth/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return SelectBoothScreen(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/exhibitor/booth-detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return BoothDetailScreen(
          booth: extra['booth'] as BoothModel,
          startDate: extra['startDate'] as DateTime,
          endDate: extra['endDate'] as DateTime,
        );
      },
    ),
    GoRoute(
      path: '/exhibitor/cart',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CartScreen(
          booth: extra['booth'] as BoothModel,
          startDate: extra['startDate'] as DateTime,
          endDate: extra['endDate'] as DateTime,
        );
      },
    ),
    GoRoute(
      path: '/exhibitor/application-form',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ApplicationFormScreen(
          booth: extra['booth'] as BoothModel,
          startDate: extra['startDate'] as DateTime,
          endDate: extra['endDate'] as DateTime,
        );
      },
    ),
    GoRoute(
      path: '/exhibitor/application-status',
      builder: (context, state) {
        final bookingId = state.extra as String;
        return ApplicationStatusScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/exhibitor/applications',
      builder: (_, __) => const MyApplicationsScreen(),
    ),

    // Organizer
    GoRoute(
      path: '/organizer',
      builder: (_, __) => const OrganizerDashboardScreen(),
    ),
    GoRoute(
      path: '/organizer/create-event',
      builder: (context, state) {
        final event = state.extra as EventModel?;
        return CreateEventScreen(existingEvent: event);
      },
    ),
    GoRoute(
      path: '/organizer/booth-management/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return BoothManagementScreen(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/organizer/review',
      builder: (_, __) => const ApplicationReviewScreen(),
    ),

    // Admin
    GoRoute(
      path: '/admin',
      builder: (_, __) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/floor-plan',
      builder: (_, __) => const FloorPlanManagerScreen(),
    ),
    GoRoute(
      path: '/admin/exhibitions',
      builder: (_, __) => const AllExhibitionsScreen(),
    ),
    GoRoute(
      path: '/admin/booth-types',
      builder: (_, __) => const BoothTypesScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (_, __) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/admin/reservations',
      builder: (_, __) => const AllReservationsScreen(),
    ),
  ],
);

class ExhibitSpaceApp extends StatelessWidget {
  const ExhibitSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ExhibitSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 1,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}