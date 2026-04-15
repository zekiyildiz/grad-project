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

  // --- YENİ: KAYDEDİLEN ETKİNLİKLERİ TUTAN LİSTE ---
  final List<EventItem> _savedEvents = [];

  // --- ALT PANEL (BOTTOM SHEET) TASARIMI ---
  void _showEventDetail(BuildContext context, EventItem event, bool isDark) {
    bool isAlreadySaved = _savedEvents.contains(event);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(radius: 25, backgroundColor: event.color.withOpacity(0.2), child: Icon(event.icon, color: event.color, size: 28)),
                    const SizedBox(width: 15),
                    Expanded(child: Text(event.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87))),
                  ],
                ),
                const SizedBox(height: 25),
                _buildDetailRow(Icons.calendar_today, 'event_date_time'.tr(), "${event.date} - ${event.time}", isDark),
                const SizedBox(height: 15),
                _buildDetailRow(Icons.location_on, 'events_location'.tr(), event.location, isDark),
                const SizedBox(height: 15),
                _buildDetailRow(Icons.category, 'events_filter_label'.tr(), event.category, isDark),
                
                const SizedBox(height: 35),
                
                // --- DİNAMİK TAKVİM SİMÜLASYONU BUTONU ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isAlreadySaved) {
                        // Eğer zaten eklendiyse direkt çıkar
                        setSheetState(() {
                          _savedEvents.remove(event);
                          isAlreadySaved = false;
                        });
                        setState(() {}); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('event_removed'.tr()), backgroundColor: Colors.orange),
                        );
                      } else {
                        // --- 1. TAKVİM ARAYÜZÜNÜ AÇ (DATE PICKER) ---
                        DateTime? parsedDate;
                        try {
                          parsedDate = DateFormat('dd.MM.yyyy').parse(event.date);
                        } catch (e) {
                          parsedDate = DateTime.now();
                        }

                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: parsedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          helpText: 'event_confirm_date'.tr(), // "Tarihi Onaylayın"
                          confirmText: 'event_add_calendar'.tr(), // "Takvime Ekle"
                          cancelText: 'cancel'.tr(),
                          builder: (context, child) {
                            // Karanlık mod ve tema uyumu için
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.blue, 
                                  onPrimary: Colors.white, 
                                  onSurface: isDark ? Colors.white : Colors.black87, 
                                ),
                                dialogBackgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                              ),
                              child: child!,
                            );
                          },
                        );

                        // --- 2. KULLANICI ONAYLARSA SİMÜLASYONU BAŞLAT ---
                        if (picked != null) {
                          // Yükleniyor animasyonu aç (Sanki cihazın takvimine yazıyormuş gibi)
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.blue)),
                          );

                          await Future.delayed(const Duration(milliseconds: 800)); // 0.8 saniye bekle
                          
                          if (!context.mounted) return;
                          Navigator.pop(context); // Animasyonu kapat

                          // Listeye ekle ve UI'ı güncelle
                          setSheetState(() {
                            _savedEvents.add(event);
                            isAlreadySaved = true;
                          });
                          setState(() {}); 

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('event_added'.tr()), backgroundColor: Colors.green),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAlreadySaved ? Colors.red.shade400 : Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    icon: Icon(isAlreadySaved ? Icons.event_busy : Icons.event_available, color: Colors.white),
                    label: Text(
                      isAlreadySaved ? 'event_remove_calendar'.tr() : 'event_add_calendar'.tr(), 
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                )
              ],
            )
          );
        }
      )
    );
  }

  // --- YENİ: KAYDEDİLEN ETKİNLİKLERİ GÖSTEREN EKRAN ---
  void _showSavedEvents(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7, // Ekranın %70'ini kaplasın
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('event_my_calendar'.tr(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: _savedEvents.isEmpty
                      ? Center(child: Text('event_no_saved'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 16)))
                      : ListView.builder(
                          itemCount: _savedEvents.length,
                          itemBuilder: (context, index) {
                            final event = _savedEvents[index];
                            return Card(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: event.color.withOpacity(0.2), child: Icon(event.icon, color: event.color)),
                                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${event.date} - ${event.time}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setSheetState(() => _savedEvents.remove(event));
                                    setState(() {}); // Arkadaki badge de güncellensin
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

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
        actions: [
          // --- YENİ: SAĞ ÜSTTEKİ TAKVİM VE BADGE ---
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month, size: 26),
                onPressed: () => _showSavedEvents(context, isDark),
              ),
              if (_savedEvents.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '${_savedEvents.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 8),
        ],
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
                return DropdownMenuItem<String>(value: category, child: Text(category));
              }).toList(),
              onChanged: (String? newValue) => setState(() => selectedCategory = newValue),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                bool isSaved = _savedEvents.contains(event); // Kayıtlı mı kontrolü

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: isDark ? Colors.grey.shade900 : Colors.white, 
                  child: ListTile(
                    leading: Icon(event.icon, color: event.color, size: 35),
                    title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${event.date} - ${event.time}', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey[700])),
                        Text('${'events_location'.tr()}: ${event.location} (${event.category})', style: TextStyle(color: event.color, fontSize: 12)),
                      ],
                    ),
                    // Eğer etkinlik takvime eklendiyse ufak bir tik işareti gösterelim
                    trailing: isSaved 
                        ? const Icon(Icons.check_circle, color: Colors.green) 
                        : const Icon(Icons.chevron_right),
                    onTap: () => _showEventDetail(context, event, isDark),
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