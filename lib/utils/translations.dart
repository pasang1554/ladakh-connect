class AppTranslations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Ladakh Bazaar',
      'sell_item': 'SELL ITEM',
      'search': 'Search items...',
      'language': 'Language',
      'call': 'Call',
      'whatsapp': 'WhatsApp',
      'description': 'Description',
      'location': 'Location',
      'category': 'Category',
      'price': 'Price',
      'item_name': 'Item Name',
      'phone_number': 'Phone Number',
      'post_ad': 'POST AD NOW',
      'select_category': 'Select Category',
      'select_location': 'Select Location',
      'add_photo': 'Tap to add photo',
      'posted_successfully': 'Ad posted successfully!',
      'error_photo': 'Please add a photo',
      'no_items': 'No items yet. Be the first to sell!',
      'report_ad': 'Report Ad',
      'report_success': 'Ad reported. We will review it.',
      'safety_tips': 'Safety Tips',
    },
    'hi': {
      'title': 'लद्दाख बाज़ार',
      'sell_item': 'सामान बेचें',
      'search': 'वस्तु खोजें...',
      'language': 'भाषा',
      'call': 'कॉल करें',
      'whatsapp': 'व्हाट्सएप',
      'description': 'विवरण',
      'location': 'स्थान',
      'category': 'श्रेणी',
      'price': 'क़ीमत',
      'item_name': 'वस्तु का नाम',
      'phone_number': 'फ़ोन नंबर',
      'post_ad': 'विज्ञापन पोस्ट करें',
      'select_category': 'श्रेणी चुनें',
      'select_location': 'स्थान चुनें',
      'add_photo': 'फोटो जोड़ने के लिए टैप करें',
      'posted_successfully': 'विज्ञापन सफलतापूर्वक पोस्ट किया गया!',
      'error_photo': 'कृपया एक फोटो जोड़ें',
      'no_items': 'कोई सामान नहीं है। सबसे पहले बेचें!',
      'report_ad': 'विज्ञापन की रिपोर्ट करें',
      'report_success': 'रिपोर्ट दर्ज की गई। हम जांच करेंगे।',
      'safety_tips': 'सुरक्षा सुझाव',
    },
    'lb': { // Ladakhi (Bhoti) - Using standard Tibetan script approximations
      'title': 'ལ་དྭགས་ ཁྲོམ་ར།', // Ladakh Khrom-ra
      'sell_item': 'ཅ་ལག་ འཚོང་བ།', // Chalag Tsong-wa
      'search': 'འཚོལ་བ།...', // Tsol-wa
      'language': 'སྐད་རིགས།', // Skad-rigs
      'call': 'ཁ་པར་ གཏོང་བ།', // Khapar Tong-wa
      'whatsapp': 'WhatsApp',
      'description': 'འགྲེལ་བཤད།', // Drel-shad
      'location': 'ས་གནས།', // Sa-gnas
      'category': 'སྡེ་ཚན།', // De-tsan
      'price': 'གོང་ཚད།', // Gong-tshad
      'item_name': 'ཅ་ལག་གི་མིང་།', // Chalag gi ming
      'phone_number': 'ཁ་པར་ཨང་གྲངས།', // Khapar Ang-drang
      'post_ad': 'ཁྱབ་བསྒྲགས།', // Khyab-drag (Advertisement)
      'select_category': 'སྡེ་ཚན་ འདེམས་པ།',
      'select_location': 'ས་གནས་ འདེམས་པ།',
      'add_photo': 'པར་ བཅུག་རོགས།', // Par chug-rogs
      'posted_successfully': 'ཁྱབ་བསྒྲགས་ བྱས་ཟིན།', // Khyab-drag jas-zin
      'error_photo': 'པར་ དགོས།', // Par gos
      'no_items': 'ཅ་ལག་ མི་འདུག', // Chalag mi-dug
      'report_ad': 'གནད་དོན་ ཞུ་བ།', // Report issue
      'report_success': 'ཞུ་གཏུག་ འབྱོར་སོང་།', // Report received
      'safety_tips': 'ཉེན་སྲུང་།', // Safety
    },
  };

  static String get(String code, String key) {
    return _localizedValues[code]?[key] ?? _localizedValues['en']![key]!;
  }
}
