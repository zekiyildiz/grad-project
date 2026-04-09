import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 

class EventItem {
  final String title;
  final String date;
  final String time;
  final String location;
  final String category;
  final IconData icon;
  final Color color;

  EventItem(this.title, this.date, this.time, this.location, this.category, this.icon, this.color);
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String? selectedCategory;

  // --- ALT PANEL (BOTTOM SHEET) TASARIMI ---
  void _showEventDetail(BuildContext context, EventItem event, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Arka plan şeffaf ki köşeler yuvarlak olsun
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üstteki küçük gri çekmece çizgisi
            Center(
              child: Container(
                width: 40, height: 5, 
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))
              ),
            ),
            const SizedBox(height: 20),
            
            // Başlık ve İkon
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: event.color.withOpacity(0.2), 
                  child: Icon(event.icon, color: event.color, size: 28)
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    event.title, 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
                  )
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            // Detay Satırları
            _buildDetailRow(Icons.calendar_today, 'event_date_time'.tr(), "${event.date} - ${event.time}", isDark),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.location_on, 'events_location'.tr(), event.location, isDark),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.category, 'events_filter_label'.tr(), event.category, isDark),
            
            const SizedBox(height: 35),
            
            // Takvime Ekle Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Takvime eklendi (Simülasyon)'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                icon: const Icon(Icons.event_available, color: Colors.white),
                label: Text('event_add_calendar'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
      )
    );
  }

  // Detay satırları için yardımcı widget
  Widget _buildDetailRow(IconData icon, String title, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<EventItem> dummyEvents = [
      EventItem('event_1_title'.tr(), '10.11.2025', '20:00', 'event_1_loc'.tr(), 'event_cat_music'.tr(), Icons.music_note, Colors.pink),
      EventItem('event_2_title'.tr(), '12.11.2025', '19:30', 'event_2_loc'.tr(), 'event_cat_art'.tr(), Icons.theaters, Colors.purple),
      EventItem('event_3_title'.tr(), '15.11.2025', '14:00', 'event_3_loc'.tr(), 'event_cat_edu'.tr(), Icons.lightbulb, Colors.orange),
      EventItem('event_4_title'.tr(), '18.11.2025', '16:00', 'event_4_loc'.tr(), 'event_cat_culture'.tr(), Icons.book, Colors.brown),
      EventItem('event_5_title'.tr(), '22.11.2025', '11:00', 'event_5_loc'.tr(), 'event_cat_sport'.tr(), Icons.sports_soccer, Colors.green),
    ];

    final List<String> categories = ['events_cat_all'.tr()] + dummyEvents.map((e) => e.category).toSet().toList();

    if (selectedCategory != null && !categories.contains(selectedCategory)) {
      selectedCategory = 'events_cat_all'.tr();
    }

    List<EventItem> filteredEvents = dummyEvents;
    if (selectedCategory != null && selectedCategory != 'events_cat_all'.tr()) {
      filteredEvents = dummyEvents.where((e) => e.category == selectedCategory).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('events_app_bar_title'.tr()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'events_filter_label'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.filter_list, color: Colors.blue),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100, 
              ),
              value: selectedCategory ?? 'events_cat_all'.tr(),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: isDark ? Colors.grey.shade900 : Colors.white, 
                  child: ListTile(
                    leading: Icon(event.icon, color: event.color, size: 35),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${event.date} - ${event.time}',
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey[700]),
                        ),
                        Text(
                          '${'events_location'.tr()}: ${event.location} (${event.category})',
                          style: TextStyle(color: event.color, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // BURADA BOTTOM SHEET'İ ÇAĞIRIYORUZ!
                      _showEventDetail(context, event, isDark);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}