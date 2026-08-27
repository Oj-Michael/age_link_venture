import 'package:agelink_venture/core/auth/mock_auth_notifier.dart';
import 'package:agelink_venture/features/customers/customer_detail_screen.dart';
import 'package:agelink_venture/features/dashboard/owner_dashboard_screen.dart';
import 'package:agelink_venture/features/login/login_screen.dart';
import 'package:agelink_venture/features/managers/managers_screen.dart';
import 'package:agelink_venture/sharedwidgets/sidebar.dart';
import 'package:agelink_venture/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter? _appRouterInstance;

GoRouter get appRouter => _appRouterInstance ??= createAppRouter();

void initializeAppNavigation() {
  initializeAuth();
  _appRouterInstance ??= createAppRouter();
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainDashboardLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const OwnerDashboardScreen(),
          ),
          GoRoute(
            path: '/managers',
            builder: (context, state) => const ManagersScreen(),
          ),
          GoRoute(
            path: '/managers/:id/customers',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ManagerCustomersScreen(managerId: id);
            },
          ),
          GoRoute(
            path: '/customers/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CustomerDetailScreen(customerId: id);
            },
          ),
        ],
      ),
    ],
  );
}

class MainDashboardLayout extends StatefulWidget {
  const MainDashboardLayout({super.key, required this.child});

  final Widget child;

  @override
  State<MainDashboardLayout> createState() => _MainDashboardLayoutState();
}

class _MainDashboardLayoutState extends State<MainDashboardLayout> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile
          ? Drawer(
              width: Responsive.sidebarWidth(context),
              child: const Sidebar(),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(
              width: Responsive.sidebarWidth(context),
              child: const Sidebar(),
            ),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  onMenuPressed: isMobile
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
