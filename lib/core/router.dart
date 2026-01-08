import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../ui/app_shell.dart';

// content will be replaced later with actual screens
import '../features/dashboard/dashboard_screen.dart';
import '../features/events/events_screen.dart';
import '../features/neighborhood/neighborhood_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/events/event_detail_screen.dart';

// Create a key for the global navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EventDetailScreen(eventId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/neighborhood',
          builder: (context, state) => const NeighborhoodScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
