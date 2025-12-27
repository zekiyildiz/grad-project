import 'package:flutter/material.dart';

// Etkinlik Veri Modeli
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

// Örnek Etkinlik Listesi
final List<EventItem> dummyEvents = [
  EventItem('Yaz Konserleri: Pop Gecesi', '10.11.2025', '20:00', 'Açıkhava Tiyatrosu', 'Müzik', Icons.music_note, Colors.pink),
  EventItem('Mahalle Tiyatro Günleri', '12.11.2025', '19:30', 'Kültür Merkezi Salon A', 'Sanat', Icons.theaters, Colors.purple),
  EventItem('Çevresel Farkındalık Semineri', '15.11.2025', '14:00', 'Belediye Konferans Salonu', 'Eğitim', Icons.lightbulb, Colors.orange),
  EventItem('Halk Kütüphanesi Kitap İmza Günü', '18.11.2025', '16:00', 'Merkez Kütüphane', 'Kültür', Icons.book, Colors.brown),
  EventItem('Engelliler Haftası Spor Turnuvası', '22.11.2025', '11:00', 'Kapalı Spor Salonu', 'Spor', Icons.sports_soccer, Colors.green),
];

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String? selectedCategory;

  // Gerçek projede bu liste API'dan dinamik çekilir.
  List<EventItem> get filteredEvents {
    if (selectedCategory == null || selectedCategory == 'Tümü') {
      return dummyEvents;
    }
    return dummyEvents.where((e) => e.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Tüm kategorileri Tümü seçeneğiyle oluşturma
    final List<String> categories = ['Tümü'] + dummyEvents.map((e) => e.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik Takvimi'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // 1. Kategori Filtresi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori Filtresi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list, color: Colors.blue),
              ),
              value: selectedCategory ?? 'Tümü',
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
          
          // 2. Etkinlik Listesi
          Expanded(
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'Yer: ${event.location} (${event.category})',
                          style: TextStyle(color: event.color, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Etkinlik detay sayfasına yönlendirme
                      print('${event.title} detayları açılıyor.');
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