import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/product/data/product_model.dart';
import '../../features/product/pages/product_form_page.dart';
import '../../features/product/pages/product_list_page.dart';
import '../../features/partner/data/partner_model.dart';
import '../../features/partner/pages/partner_form_page.dart';
import '../../features/partner/pages/partner_list_page.dart';
import '../../features/vehicle/data/vehicle_model.dart';
import '../../features/vehicle/pages/vehicle_form_page.dart';
import '../../features/vehicle/pages/vehicle_list_page.dart';
import '../../features/accident/data/accident_model.dart';
import '../../features/accident/pages/accident_form_page.dart';
import '../../features/accident/pages/accident_list_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.status == AuthStatus.authenticated
        ? '/dashboard'
        : '/login',
    redirect: (context, state) {
      final isAuthenticated =
          authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(
        path: '/products',
        builder: (_, __) => const ProductListPage(),
        routes: [
          GoRoute(path: 'new', builder: (_, __) => const ProductFormPage()),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                ProductFormPage(product: state.extra as Product?),
          ),
        ],
      ),
      GoRoute(
        path: '/partners',
        builder: (_, __) => const PartnerListPage(),
        routes: [
          GoRoute(path: 'new', builder: (_, __) => const PartnerFormPage()),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                PartnerFormPage(partner: state.extra as Partner?),
          ),
        ],
      ),
      GoRoute(
        path: '/vehicles',
        builder: (_, __) => const VehicleListPage(),
        routes: [
          GoRoute(path: 'new', builder: (_, __) => const VehicleFormPage()),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                VehicleFormPage(vehicle: state.extra as Vehicle?),
          ),
        ],
      ),
      GoRoute(
        path: '/accidents',
        builder: (_, __) => const AccidentListPage(),
        routes: [
          GoRoute(path: 'new', builder: (_, __) => const AccidentFormPage()),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                AccidentFormPage(accident: state.extra as Accident?),
          ),
        ],
      ),
    ],
  );
});