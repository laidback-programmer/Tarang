import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../services/gemini_news_service.dart';

class NewsScreen extends StatefulWidget {
  static const String routeName = '/news';

  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isLoading = true;
  bool hasDisasters = false;
  String? errorMessage;
  String? locationName;
  String? safetyMessage;
  String? lastUpdated;

  bool isLoadingNationwide = false;
  List<Map<String, dynamic>> nationwideDisasters = [];

  List<Map<String, dynamic>> newsList = [];
  final List<String> categories = [
    "All",
    "Cyclone",
    "Oil Spill",
    "Tsunami",
    "Flood",
    "Storm",
    "Earthquake",
    "Coastal Erosion"
  ];

  @override
  void initState() {
    super.initState();
    _loadDisasterNews();
  }

  Future<void> _loadDisasterNews() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get user location
      final position = await GeminiNewsService.getCurrentLocation();

      // Get city name
      final city = await GeminiNewsService.getCityName(
        position.latitude,
        position.longitude,
      );

      // Fetch disaster news from Gemini
      final response = await GeminiNewsService.fetchDisasterNews(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: city,
      );

      setState(() {
        hasDisasters = response['hasDisasters'] ?? false;
        locationName = response['location'] ?? city ?? 'Your Location';
        safetyMessage = response['safetyMessage'];
        lastUpdated = response['lastUpdated'];

        if (hasDisasters && response['disasters'] != null) {
          newsList = List<Map<String, dynamic>>.from(response['disasters']);
        } else {
          newsList = [];
          // Load nationwide disasters when local area is safe
          _loadNationwideDisasters();
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _loadNationwideDisasters() async {
    setState(() {
      isLoadingNationwide = true;
    });

    try {
      final disasters = await GeminiNewsService.fetchNationwideDisasters();
      setState(() {
        nationwideDisasters = disasters;
        isLoadingNationwide = false;
      });
    } catch (e) {
      setState(() {
        isLoadingNationwide = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNews = newsList.where((news) {
      final matchesCategory =
          selectedCategory == "All" || news["category"] == selectedCategory;
      final matchesSearch =
          news["title"]!.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(locationName ?? AppStrings.newsAndAlerts),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDisasterNews,
            tooltip: 'Refresh',
          ),
          if (hasDisasters)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilters,
            ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : errorMessage != null
              ? _buildErrorState()
              : !hasDisasters
                  ? _buildSafeState()
                  : Column(
                      children: [
                        // Location & Last Updated Info
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primaryLight.withOpacity(0.05)
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      locationName ?? 'Your Location',
                                      style: AppStyles.caption.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              if (lastUpdated != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 12,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Updated: ${_formatTimestamp(lastUpdated!)}',
                                        style: AppStyles.caption.copyWith(
                                            fontSize: 10,
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: AppStrings.searchNewsHint,
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppStyles.borderRadius),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                          ),
                        ),

                        // Categories
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = category == selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (_) => setState(
                                      () => selectedCategory = category),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Disaster Count
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 16, color: AppColors.error),
                              const SizedBox(width: 4),
                              Text(
                                '${filteredNews.length} ${filteredNews.length == 1 ? 'Alert' : 'Alerts'} Found',
                                style: AppStyles.caption
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // News List
                        Expanded(
                          child: filteredNews.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredNews.length,
                                  itemBuilder: (context, index) =>
                                      _buildNewsCard(
                                          filteredNews[index], index),
                                ),
                        ),
                      ],
                    ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return DateFormat('MMM dd, HH:mm').format(date);
      }
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildNewsCard(Map<String, dynamic> news, int index,
      {bool isNationwide = false}) {
    // Generate category-based icon and color
    final categoryIcon = _getCategoryIcon(news["category"] ?? "");
    final categoryColor = _getCategoryColor(news["category"] ?? "");

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        side: BorderSide(
          color:
              news["isBreaking"] == true ? AppColors.error : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showNewsDetail(news),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header with Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppStyles.borderRadius)),
              ),
              child: Row(
                children: [
                  Icon(categoryIcon, size: 20, color: categoryColor),
                  const SizedBox(width: 8),
                  Text(
                    news["category"] ?? "Alert",
                    style: AppStyles.bodyMedium.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isNationwide)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, size: 10, color: AppColors.info),
                          const SizedBox(width: 4),
                          Text(
                            "NATIONWIDE",
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (news["isBreaking"] == true && !isNationwide)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "LIVE",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSeverityBadge(news["severity"]),
                      const Spacer(),
                      Icon(Icons.access_time,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, HH:mm')
                            .format(DateTime.parse(news["date"])),
                        style: AppStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    news["title"],
                    style: AppStyles.headlineSmall.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news["details"],
                    style: AppStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Distance and Affected Areas (show location for nationwide)
                  if (isNationwide && news["location"] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.location_city,
                              size: 14, color: AppColors.info),
                          const SizedBox(width: 4),
                          Text(
                            news["location"],
                            style: AppStyles.caption
                                .copyWith(color: AppColors.info),
                          ),
                        ],
                      ),
                    ),

                  if (!isNationwide && news["distance"] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.place, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${news["distance"]} from you',
                            style: AppStyles.caption
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),

                  if (news["affectedAreas"] != null &&
                      (news["affectedAreas"] as List).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 4,
                        children: (news["affectedAreas"] as List)
                            .take(3)
                            .map((area) => Chip(
                                  label: Text(area.toString()),
                                  labelStyle:
                                      AppStyles.caption.copyWith(fontSize: 10),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ),

                  // Source with NLP badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.psychology,
                                size: 10, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              "AI-Scraped",
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Source: ${news["source"]}",
                          style: AppStyles.caption.copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cyclone':
        return Icons.cyclone;
      case 'tsunami':
        return Icons.waves;
      case 'flood':
        return Icons.water_damage;
      case 'oil spill':
        return Icons.oil_barrel;
      case 'storm':
        return Icons.thunderstorm;
      case 'earthquake':
        return Icons.terrain;
      case 'coastal erosion':
        return Icons.landscape;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cyclone':
        return Colors.purple;
      case 'tsunami':
        return Colors.blue;
      case 'flood':
        return Colors.cyan;
      case 'oil spill':
        return Colors.brown;
      case 'storm':
        return Colors.indigo;
      case 'earthquake':
        return Colors.orange;
      case 'coastal erosion':
        return Colors.teal;
      default:
        return AppColors.error;
    }
  }

  Widget _buildSeverityBadge(String severity) {
    final Map<String, Color> colors = {
      "Critical": Colors.red.shade900,
      "High": AppColors.error,
      "Medium": AppColors.warning,
      "Low": AppColors.success,
    };

    final Map<String, IconData> icons = {
      "Critical": Icons.error,
      "High": Icons.warning,
      "Medium": Icons.info,
      "Low": Icons.check_circle,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[severity]?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors[severity] ?? AppColors.gray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[severity] ?? Icons.info,
              size: 12, color: colors[severity]),
          const SizedBox(width: 4),
          Text(
            severity,
            style: TextStyle(
              color: colors[severity],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(
            'Scanning for disasters nearby...',
            style:
                AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Using AI-powered web scraping with NLP',
            style: AppStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Disaster Data',
              style: AppStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Please check your internet connection',
              style:
                  AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDisasterNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Animated checkmark
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Disasters Nearby',
            style: AppStyles.heading2.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            safetyMessage ??
                'Your area is currently safe. No maritime disasters detected within 500km radius.',
            style: AppStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (locationName != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  locationName!,
                  style: AppStyles.caption.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'AI-Powered Monitoring',
                      style: AppStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Using advanced web scraping with NLP to monitor disaster news from multiple sources including IMD, NDMA, NASA, and local authorities.',
                  style: AppStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDisasterNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          // Nationwide disasters section
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 24),

          Row(
            children: [
              Icon(Icons.public, size: 24, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Disasters Across India',
                style: AppStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recent maritime and coastal disasters from other regions',
            style: AppStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          if (isLoadingNationwide)
            const Padding(
              padding: EdgeInsets.all(32),
              child: LoadingIndicator(),
            )
          else if (nationwideDisasters.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No nationwide disasters reported',
                style: AppStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: nationwideDisasters.length,
              itemBuilder: (context, index) => _buildNewsCard(
                  nationwideDisasters[index], index,
                  isNationwide: true),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.gray),
          const SizedBox(height: 16),
          Text(
            AppStrings.noNewsFound,
            style: AppStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.adjustSearchFilters,
            style: AppStyles.caption,
          ),
        ],
      ),
    );
  }

  void _showNewsDetail(Map<String, dynamic> news) {
    final categoryIcon = _getCategoryIcon(news["category"] ?? "");
    final categoryColor = _getCategoryColor(news["category"] ?? "");

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [categoryColor, categoryColor.withOpacity(0.7)],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(categoryIcon, color: AppColors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          news["category"] ?? "Alert",
                          style: AppStyles.headlineSmall
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                      if (news["isBreaking"] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "LIVE",
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildSeverityBadge(news["severity"]),
                          const Spacer(),
                          Icon(Icons.access_time,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy - HH:mm')
                                .format(DateTime.parse(news["date"])),
                            style: AppStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        news["title"],
                        style: AppStyles.heading2.copyWith(height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        news["details"],
                        style: AppStyles.bodyMedium.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 16),

                      // Location Info
                      if (news["distance"] != null) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.place,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Distance: ${news["distance"]}',
                              style: AppStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (news["latitude"] != null &&
                            news["longitude"] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 26, top: 4),
                            child: Text(
                              'Coordinates: ${news["latitude"]}, ${news["longitude"]}',
                              style: AppStyles.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                      ],

                      // Affected Areas
                      if (news["affectedAreas"] != null &&
                          (news["affectedAreas"] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Affected Areas:',
                          style: AppStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (news["affectedAreas"] as List)
                              .map((area) => Chip(
                                    label: Text(area.toString()),
                                    avatar: Icon(Icons.location_city, size: 16),
                                    labelStyle: AppStyles.caption,
                                  ))
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Source with AI badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.psychology,
                                    size: 14, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text(
                                  "AI-Scraped & Verified",
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.source,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Source: ${news["source"]}",
                              style: AppStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.close),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.filterNews,
              style: AppStyles.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Add filter options here
            // You can implement date filters, severity filters, etc.
            ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category),
                  trailing: selectedCategory == category
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => selectedCategory = category);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
