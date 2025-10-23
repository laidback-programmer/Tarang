import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTab = 0;

  // Define data sources
  final List<MonthlyData> monthlyData = [
    MonthlyData('Jan', 45),
    MonthlyData('Feb', 52),
    MonthlyData('Mar', 48),
    MonthlyData('Apr', 67),
    MonthlyData('May', 58),
    MonthlyData('Jun', 72),
  ];

  final List<TrendData> trendData = [
    TrendData('Flood', 35),
    TrendData('Fire', 25),
    TrendData('Earthquake', 20),
    TrendData('Other', 20),
  ];

  final List<RegionalData> regionalData = [
    RegionalData('Northern Region', 45, 35, 28.6139, 77.2090),
    RegionalData('Southern Region', 32, 28, 13.0827, 80.2707),
    RegionalData('Eastern Region', 28, 22, 22.5726, 88.3639),
    RegionalData('Western Region', 37, 30, 19.0760, 72.8777),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Tab Selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTabButton('Brief', 0),
                const SizedBox(width: 8),
                _buildTabButton('Regional', 1),
                const SizedBox(width: 8),
                _buildTabButton('Trends', 2),
              ],
            ),
          ),

          // Content based on selected tab
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildOverviewTab(),
                _buildRegionalTab(),
                _buildTrendsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedTab = index),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : AppColors.white,
          foregroundColor: isSelected ? AppColors.white : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          ),
        ),
        child: Text(title),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Key Metrics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Metrics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('Response Time', '2.4h', AppColors.info),
                      _buildMetricItem(
                          'Resolution Rate', '78%', AppColors.success),
                      _buildMetricItem(
                          'Citizen Satisfaction', '4.2/5', AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Monthly Trends
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Incident Trends',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <CartesianSeries>[
                        LineSeries<MonthlyData, String>(
                          dataSource: monthlyData,
                          xValueMapper: (MonthlyData data, _) => data.month,
                          yValueMapper: (MonthlyData data, _) => data.incidents,
                          color: AppColors.primary,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Regional Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          initialFocalLatLng: MapLatLng(20.5937, 78.9629),
                          initialZoomLevel: 4,
                          initialMarkersCount: regionalData.length,
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: regionalData[index].lat,
                              longitude: regionalData[index].long,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Regional Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: regionalData.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(regionalData[index].region),
                      subtitle:
                          Text('${regionalData[index].incidents} incidents'),
                      trailing: Chip(
                        label: Text('${regionalData[index].resolved} resolved'),
                        backgroundColor: AppColors.success.withOpacity(0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incident Type Trends',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <CartesianSeries>[
                        ColumnSeries<TrendData, String>(
                          dataSource: trendData,
                          xValueMapper: (TrendData data, _) => data.type,
                          yValueMapper: (TrendData data, _) => data.percentage,
                          color: AppColors.primary,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prediction Analysis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.trending_up, color: AppColors.warning),
                    title:
                        Text('High flood risk predicted for coastal regions'),
                    subtitle: Text('Next 7 days - 65% probability'),
                  ),
                  const ListTile(
                    leading:
                        Icon(Icons.trending_down, color: AppColors.success),
                    title: Text('Fire incidents expected to decrease'),
                    subtitle: Text('Next 30 days - 40% reduction predicted'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Generate Detailed Forecast'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class MonthlyData {
  final String month;
  final int incidents;

  MonthlyData(this.month, this.incidents);
}

class TrendData {
  final String type;
  final int percentage;

  TrendData(this.type, this.percentage);
}

class RegionalData {
  final String region;
  final int incidents;
  final int resolved;
  final double lat;
  final double long;

  RegionalData(this.region, this.incidents, this.resolved, this.lat, this.long);
}
