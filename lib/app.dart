import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'models/order.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/customer/confirm_screen.dart';
import 'screens/customer/track_order_screen.dart';
import 'screens/customer/upload_screen.dart';
import 'screens/manager/customers_screen.dart';
import 'screens/manager/manager_dashboard_screen.dart';
import 'screens/manager/reports_screen.dart';
import 'screens/manager/settings_screen.dart';
import 'screens/manager/workers_screen.dart';
import 'screens/shared/error_screen.dart';
import 'screens/shared/login_screen.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/worker/order_detail_screen.dart';
import 'screens/worker/worker_dashboard_screen.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';

class LaidaniApp extends StatelessWidget {
  const LaidaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        Provider(create: (ctx) => ApiService(ctx.read<ConnectivityService>())),
        ChangeNotifierProvider(create: (ctx) => AuthProvider(ctx.read<ApiService>())),
        ChangeNotifierProvider(create: (ctx) => OrderProvider(ctx.read<ApiService>())),
        ChangeNotifierProvider(create: (ctx) => QueueProvider(ctx.read<ApiService>())),
        ChangeNotifierProvider(create: (ctx) => StatsProvider(ctx.read<ApiService>())),
      ],
      child: MaterialApp(
        title: 'LAIDANI PRINT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _generateRoute,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.customerUpload:
        return MaterialPageRoute(builder: (_) => const UploadScreen());

      case AppRoutes.customerConfirm:
        final order = settings.arguments as Order;
        return MaterialPageRoute(builder: (_) => ConfirmScreen(order: order));

      case AppRoutes.customerTrack:
        return MaterialPageRoute(builder: (_) => const TrackOrderScreen());

      case AppRoutes.workerDashboard:
        return MaterialPageRoute(builder: (_) => const WorkerDashboardScreen());

      case AppRoutes.orderDetail:
        final order = settings.arguments as Order;
        return MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order));

      case AppRoutes.managerDashboard:
        return MaterialPageRoute(builder: (_) => const ManagerDashboardScreen());

      case AppRoutes.managerWorkers:
        return MaterialPageRoute(builder: (_) => const WorkersScreen());

      case AppRoutes.managerReports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      case AppRoutes.managerCustomers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());

      case AppRoutes.managerCustomerDetail:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());

      case AppRoutes.managerSettings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(message: 'الصفحة غير موجودة'),
        );
    }
  }
}
