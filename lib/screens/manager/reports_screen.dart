// date range filter affects all charts simultaneously
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/stats_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic> _reports = {};
  bool _loading = true;
  String _selectedRange = 'today';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      _reports = await api.getReports(range: _selectedRange);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل التقارير')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stats = context.watch<StatsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 240,
              color: const Color(0xFF2C1A0E),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      auth.currentWorker?.fullName ?? 'مدير',
                      style: GoogleFonts.cairo(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  _navItem('\u{1F4CA}', 'لوحة التحكم', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerDashboard)),
                  _navItem('\u{1F465}', 'العمال', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerWorkers)),
                  _navItem('\u{1F4C8}', 'التقارير', true, () {}),
                  _navItem('\u{1F464}', 'الزبائن', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerCustomers)),
                  _navItem('\u{2699}', 'الإعدادات', false, () => Navigator.pushReplacementNamed(context, AppRoutes.managerSettings)),
                  const Spacer(),
                  _navItem('\u{1F6AA}', 'خروج', false, () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'التقارير',
                          style: GoogleFonts.cairo(
                            fontSize: 22, fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'today', label: const Text('اليوم')),
                            ButtonSegment(value: 'week', label: const Text('الأسبوع')),
                            ButtonSegment(value: 'month', label: const Text('الشهر')),
                          ],
                          selected: {_selectedRange},
                          onSelectionChanged: (v) {
                            setState(() => _selectedRange = v.first);
                            _loadReports();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: StatsCard(
                                      label: 'الطلبات',
                                      value: '${_reports['orders'] ?? stats.orders}',
                                      icon: Icons.receipt_long,
                                    )),
                                    const SizedBox(width: 12),
                                    Expanded(child: StatsCard(
                                      label: 'الإيرادات',
                                      value: Formatters.priceShort((_reports['revenue'] as num?)?.toDouble() ?? stats.revenue),
                                      icon: Icons.monetization_on,
                                      color: AppColors.success,
                                    )),
                                    const SizedBox(width: 12),
                                    Expanded(child: StatsCard(
                                      label: 'الصفحات',
                                      value: '${_reports['pages'] ?? stats.pages}',
                                      icon: Icons.description,
                                      color: AppColors.info,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'الإيرادات',
                                              style: GoogleFonts.cairo(
                                                fontSize: 16, fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.download),
                                              tooltip: 'تصدير PDF',
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('تصدير PDF غير متوفر بعد')),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 200,
                                          child: _LineChartSample(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'الطلبات حسب اليوم',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 14, fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                height: 160,
                                                child: _BarChartSample(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'حالة الطلبات',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 14, fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                height: 160,
                                                child: _PieChartSample(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String emoji, String label, bool active, VoidCallback onTap) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 18)),
      title: Text(label, style: GoogleFonts.cairo(
        fontSize: 14,
        color: active ? AppColors.accent : Colors.white70,
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
      )),
      onTap: onTap,
    );
  }

}

class _LineChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب'];
                final index = value.toInt();
                return Text(
                  index >= 0 && index < days.length ? days[index] : '',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1200),
              FlSpot(1, 2500),
              FlSpot(2, 800),
              FlSpot(3, 3200),
              FlSpot(4, 1800),
              FlSpot(5, 2600),
              FlSpot(6, 900),
            ],
            isCurved: true,
            color: AppColors.accent,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];
                final index = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    index >= 0 && index < days.length ? days[index] : '',
                    style: const TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarGroup(0, 15, AppColors.accent),
          _makeBarGroup(1, 28, AppColors.primary),
          _makeBarGroup(2, 10, AppColors.accent),
          _makeBarGroup(3, 35, AppColors.primary),
          _makeBarGroup(4, 20, AppColors.accent),
          _makeBarGroup(5, 30, AppColors.primary),
          _makeBarGroup(6, 12, AppColors.accent),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

class _PieChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: [
          PieChartSectionData(
            value: 45,
            color: AppColors.success,
            title: 'منجز',
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            radius: 35,
          ),
          PieChartSectionData(
            value: 30,
            color: AppColors.accent,
            title: 'قيد',
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            radius: 35,
          ),
          PieChartSectionData(
            value: 25,
            color: AppColors.danger,
            title: 'جديد',
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            radius: 35,
          ),
        ],
      ),
    );
  }
}
