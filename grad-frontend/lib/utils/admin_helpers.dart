import 'package:easy_localization/easy_localization.dart';
import '../data/ankara_locations.dart';

/// A helper class that performs data transformation and analysis for the admin panel. It separates business logic from the UI layer.
class AdminHelpers {
  
  // FUNCTION THAT TRANSLATES THE CATEGORY TITLE
  static String getCategoryTitle(String category) {
    String key = category.trim().toUpperCase()
        .replaceAll('İ', 'I').replaceAll('Ğ', 'G')
        .replaceAll('Ç', 'C').replaceAll('Ş', 'S')
        .replaceAll('Ö', 'O').replaceAll('Ü', 'U');

    switch (key) {
      case 'YANGIN': return 'cat_fire'.tr();
      case 'GAZ KACAGI': return 'cat_gas'.tr();
      case 'SU PATLAGI': return 'cat_water'.tr();
      case 'ELEKTRIK ARIZASI': return 'cat_electric_urgent'.tr();
      case 'YOL COKMESI': return 'cat_road_collapse'.tr();
      case 'CUKUR': return 'cat_pothole'.tr();
      case 'COPLUK': return 'cat_garbage'.tr();
      case 'KIRIK_BANK': return 'cat_bench'.tr();
      case 'TRAFIK': return 'cat_traffic'.tr();
      case 'ELEKTRIK': return 'cat_electric'.tr();
      case 'SCOOTER': return 'cat_scooter'.tr();
      case 'POSTER': return 'cat_poster'.tr();
      case 'AGAC': return 'cat_tree'.tr();
      case 'DIGER': return 'cat_other'.tr(); 
      default: return category; 
    }
  }

  // FUNCTION THAT ESTIMATES THE INSTITUTION
  /// A decision support mechanism that autonomously determines which municipal agency (ASKİ, TEDAŞ, etc.) a complaint should be forwarded to, 
  /// based on the category label provided by artificial intelligence (YOLOv8).
  static String predictInstitution(String category) {
    String cat = category.toUpperCase()
        .replaceAll('İ', 'I').replaceAll('Ç', 'C').replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G').replaceAll('Ü', 'U').replaceAll('Ö', 'O').trim();
    
    switch (cat) {
      case 'YANGIN': 
        return 'EMNIYET';
      case 'GAZ KACAGI':
      case 'ELEKTRIK ARIZASI':
      case 'ELEKTRIK': 
        return 'TEDAS';
      case 'SU PATLAGI': 
        return 'ASKI';
      case 'COPLUK': 
        return 'TEMIZLIK';
      case 'SCOOTER':
      case 'POSTER': 
        return 'ZABITA';
      case 'TRAFIK': 
        return 'UKOME';
      case 'KIRIK_BANK':
      case 'AGAC': 
        return 'PARK_BAHCE';
      case 'YOL COKMESI':
      case 'CUKUR': 
        return 'FEN_ISLERI';
      default: 
        return 'DIGER'; 
    }
  }

  // FUNCTION THAT TRANSLATES THE ORGANIZATION NAME
  static String getInstitutionName(String? code) {
    if (code == null || code.isEmpty || code == 'ATANMADI' || code == 'PENDING' || code == 'STATUS_PENDING') {
      return 'inst_unassigned'.tr();
    }
    
    String cleanCode = code.toUpperCase().replaceAll('INST_', '');
    
    switch (cleanCode) {
      case 'FEN_ISLERI': return 'inst_fen'.tr();
      case 'TEDAS': return 'inst_tedas'.tr(); 
      case 'ASKI': return 'inst_aski'.tr(); 
      case 'ZABITA': return 'inst_zabita'.tr();
      case 'TEMIZLIK': return 'inst_temizlik'.tr();
      case 'EMNIYET': 
      case 'ITFAIYE': 
        return 'inst_police_fire'.tr();
      case 'UKOME': return 'inst_ukome'.tr(); 
      case 'PARK_BAHCE': return 'inst_park_bahce'.tr(); 
      case 'DIGER': return 'inst_other_manual'.tr();
      default: return code; // If an unknown institution appears in the system, display the code as-is
    }
  }

  // DISTRICT ANALYSIS FUNCTION
  /// A function that automatically identifies the correct district by matching it with the official districts and neighborhoods in the AnkaraLocationData dictionary
  static String parseDistrict(String address) {
    if (address.trim().isEmpty) return "admin_loc_unknown".tr();

    // Standardize the input text (capitalization and removal of Turkish characters)
    String addrUpper = address.toUpperCase()
        .replaceAll('İ', 'I').replaceAll('Ğ', 'G')
        .replaceAll('Ç', 'C').replaceAll('Ş', 'S')
        .replaceAll('Ö', 'O').replaceAll('Ü', 'U');

    // CHECK: Did a GPS coordinate come in? (e.g., 39.920, 32.854)
    bool isCoordinate = RegExp(r'\d{2}\.\d{3,}').hasMatch(addrUpper) || RegExp(r'^[0-9.,\s|-]+$').hasMatch(addrUpper);
    if (isCoordinate || addrUpper.contains('MANUEL') || addrUpper.contains('MERKEZ')) {
      return "admin_loc_map".tr();
    }

    // CONTROL: AUTONOMOUS MATCHING USING AnkaraLocationData
    // Any new neighborhood added to the system becomes active here immediately
    for (String district in AnkaraLocationData.districts) {
      String distUpper = district.toUpperCase()
          .replaceAll('İ', 'I').replaceAll('Ç', 'C').replaceAll('Ş', 'S').replaceAll('Ğ', 'G').replaceAll('Ü', 'U').replaceAll('Ö', 'O');
      
      // Does the text directly include the name of the district? (e.g., “Çankaya”)
      if (addrUpper.contains(distUpper)) return district;

      // Does the text include one of the district's neighborhoods? (For example, if the address says “Bahçelievler,” select Çankaya)
      for (String neighborhood in AnkaraLocationData.getNeighborhoods(district)) {
        String neighUpper = neighborhood.toUpperCase()
            .replaceAll('İ', 'I').replaceAll('Ç', 'C').replaceAll('Ş', 'S').replaceAll('Ğ', 'G').replaceAll('Ü', 'U').replaceAll('Ö', 'O');
        
        if (addrUpper.contains(neighUpper)) return district;
      }
    }

    // If the above doesn't work, try to recover the word before the comma (Fallback)
    try {
      List<String> parts = address.split(',');
      if (parts.length >= 2) {
        String potentialDistrict = parts[parts.length - 2].trim().toUpperCase();
        if (potentialDistrict != 'ANKARA' && potentialDistrict != 'TURKIYE' && potentialDistrict.length > 2) {
           return parts[parts.length - 2].trim(); 
        }
      }
    } catch (e) {}

    return "admin_loc_other".tr();
  }

  // TIME FORMATTER
  static String getTimeAgo(String? dateStr) {
    if (dateStr == null) return "time_new".tr();
    DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
    Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "time_now".tr();
    if (diff.inMinutes < 60) return "${diff.inMinutes} ${"time_min".tr()}";
    if (diff.inHours < 24) return "${diff.inHours} ${"time_hour".tr()}";
    return "${diff.inDays} ${"time_day".tr()}";
  }
}