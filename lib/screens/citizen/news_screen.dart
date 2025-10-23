import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/common/loading_indicator.dart';

class NewsScreen extends StatefulWidget {
  static const String routeName = '/news'; // Add this if missing
  
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String selectedCategory = "All";
  String searchQuery = "";

  // Fixed: Use local asset paths instead of network URLs
  final List<Map<String, dynamic>> newsList = [
    {
      "title": "Cyclone Varuni Pounds Odisha Coast, Thousands Evacuated",
      "image": "assets/cyclone.jpg", // This should be a local asset
      "details": "Severe Cyclone Varuni struck Odisha coast today, forcing thousands to evacuate. Naval assistance deployed.",
      "category": "Cyclone",
      "date": "2025-09-15 14:30:00",
      "severity": "High",
      "source": "IMD Official",
      "isBreaking": true,
    },
    {
      "title": "Oil Tanker Spill Near Mumbai Leaves Arabian Sea Contaminated",
      "image": "assets/oil_spills.jpg", // This should be a local asset
      "details": "Massive oil spill near Mumbai threatens marine life. Cleanup operations underway.",
      "category": "Oil Spill",
      "date": "2025-07-15 10:15:00",
      "severity": "Medium",
      "source": "Coast Guard",
      "isBreaking": false,
    },
  ];

  final List<String> categories = ["All", "Cyclone", "Oil Spill", "Tsunami", "Flood"];

  @override
  Widget build(BuildContext context) {
    final filteredNews = newsList.where((news) {
      final matchesCategory = selectedCategory == "All" || news["category"] == selectedCategory;
      final matchesSearch = news["title"]!.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.newsAndAlerts),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
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
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
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
                    onSelected: (_) => setState(() => selectedCategory = category),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // News List
          Expanded(
            child: filteredNews.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNews.length,
                    itemBuilder: (context, index) => _buildNewsCard(filteredNews[index], index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news, int index) {
    // Check if image is a network URL or local asset
    final String imageUrl = news["image"];
    final bool isNetworkImage = imageUrl.startsWith('http');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      ),
      child: InkWell(
        onTap: () => _showNewsDetail(news),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppStyles.borderRadius)),
                  child: isNetworkImage 
                    ? CachedNetworkImage(
                        imageUrl: news["image"],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.lightGray,
                          height: 200,
                          child: const Center(child: LoadingIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.lightGray,
                          height: 200,
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Image.asset(
                        news["image"],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.lightGray,
                          height: 200,
                          child: const Icon(Icons.error),
                        ),
                      ),
                ),
                if (news["isBreaking"] == true)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "BREAKING",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
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
                      Text(
                        DateFormat('MMM dd, HH:mm').format(DateTime.parse(news["date"])),
                        style: AppStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news["title"],
                    style: AppStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news["details"],
                    style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${AppStrings.source}: ${news["source"]}",
                    style: AppStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    final Map<String, Color> colors = {
      "High": AppColors.error,
      "Medium": AppColors.warning,
      "Low": AppColors.success,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[severity]?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors[severity] ?? AppColors.gray),
      ),
      child: Text(
        severity,
        style: TextStyle(
          color: colors[severity],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
    // Check if image is a network URL or local asset
    final String imageUrl = news["image"];
    final bool isNetworkImage = imageUrl.startsWith('http');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isNetworkImage
                ? CachedNetworkImage(
                    imageUrl: news["image"],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGray,
                      height: 200,
                      child: const Center(child: LoadingIndicator()),
                    ),
                  )
                : Image.asset(
                    news["image"],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.lightGray,
                      height: 200,
                      child: const Icon(Icons.error),
                    ),
                  ),
              const SizedBox(height: 16),
              Text(
                news["title"],
                style: AppStyles.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                news["details"],
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSeverityBadge(news["severity"]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.parse(news["date"])),
                    style: AppStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${AppStrings.source}: ${news["source"]}",
                style: AppStyles.caption,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
        ],
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