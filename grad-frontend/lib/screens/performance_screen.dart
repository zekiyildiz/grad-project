import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 

class Badge {
  final String nameKey;
  final String descriptionKey;
  final IconData icon;
  final bool unlocked;
  final Color color;

  const Badge(this.nameKey, this.descriptionKey, this.icon, this.unlocked, this.color);
}

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({Key? key}) : super(key: key);

  static const Color primaryBlue = Color(0xFF4094FF);

  // SCORE AREA 
  Widget _buildPointsHeader(BuildContext context, int currentPoints) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'perf_total_points'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      // Static posts have been linked to JSON
                      title: Text('perf_info_title'.tr()), 
                      content: Text('perf_info_desc'.tr()),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('close'.tr()))],
                    ),
                  );
                },
                child: const Icon(Icons.info_outline, color: Colors.white70, size: 20),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$currentPoints',
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'perf_value_text'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // BADGE CARD 
  /// An interface component that automatically Eeconfigures color, icon, and clickability properties based on the badge's ‘unlocked’ (On/Off) state.
  Widget _buildBadgeCard(BuildContext context, Badge badge) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.nameKey.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(badge.descriptionKey.tr()),
              ],
            ),
            backgroundColor: badge.unlocked ? badge.color : Colors.grey.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: badge.unlocked 
                  ? badge.color.withOpacity(0.12) 
                  : (isDark ? Colors.grey.shade900 : Colors.grey.shade100), 
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.unlocked 
                    ? badge.color 
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                width: 2.5,
              ),
            ),
            child: Icon(
              badge.unlocked ? badge.icon : Icons.lock_outline,
              size: 32,
              color: badge.unlocked 
                  ? (isDark ? badge.color.withOpacity(0.8) : badge.color) 
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.nameKey.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: badge.unlocked ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: badge.unlocked 
                  ? (isDark ? Colors.white : Colors.black87) 
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentPoints = 850;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Badge> dummyBadges = [
      const Badge('perf_badge1_title', 'perf_badge1_desc', Icons.star, true, Colors.amber),
      const Badge('perf_badge2_title', 'perf_badge2_desc', Icons.visibility, true, Colors.green),
      const Badge('perf_badge3_title', 'perf_badge3_desc', Icons.check_circle, false, Colors.grey),
      const Badge('perf_badge4_title', 'perf_badge4_desc', Icons.poll, true, Colors.blue),
      const Badge('perf_badge5_title', 'perf_badge5_desc', Icons.workspace_premium, false, Colors.brown),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('perf_title'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsHeader(context, currentPoints),
            
            const SizedBox(height: 40),

            Text(
              'perf_badge_collection'.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 24),

            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 30,
                childAspectRatio: 0.75,
              ),
              itemCount: dummyBadges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(context, dummyBadges[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}