import 'package:flutter/material.dart';

class NewsCategory {
  const NewsCategory(this.slug, this.en, this.hi, this.mr, this.icon);
  final String slug;
  final String en;
  final String hi;
  final String mr;
  final IconData icon;
  String name(String lang) => switch (lang) { 'hi' => hi, 'mr' => mr, _ => en };
}

const kCategories = <NewsCategory>[
  NewsCategory('top', 'Top Stories', 'मुख्य खबरें', 'मुख्य बातम्या', Icons.newspaper_outlined),
  NewsCategory('india', 'India', 'भारत', 'भारत', Icons.flag_outlined),
  NewsCategory('world', 'World', 'विश्व', 'जग', Icons.public),
  NewsCategory('business', 'Business', 'व्यापार', 'व्यवसाय', Icons.show_chart),
  NewsCategory('politics', 'Politics', 'राजनीति', 'राजकारण', Icons.account_balance_outlined),
  NewsCategory('sports', 'Sports', 'खेल', 'क्रीडा', Icons.emoji_events_outlined),
  NewsCategory('entertainment', 'Entertainment', 'मनोरंजन', 'मनोरंजन', Icons.movie_outlined),
  NewsCategory('technology', 'Technology', 'टेक्नोलॉजी', 'तंत्रज्ञान', Icons.memory),
  NewsCategory('science', 'Science', 'विज्ञान', 'विज्ञान', Icons.science_outlined),
  NewsCategory('health', 'Health', 'स्वास्थ्य', 'आरोग्य', Icons.monitor_heart_outlined),
  NewsCategory('education', 'Education', 'शिक्षा', 'शिक्षण', Icons.school_outlined),
  NewsCategory('startups', 'Startups', 'स्टार्टअप', 'स्टार्टअप', Icons.rocket_launch_outlined),
];

NewsCategory categoryBySlug(String slug) =>
    kCategories.firstWhere((c) => c.slug == slug, orElse: () => kCategories.first);

const kStates = <String>[
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa',
  'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
  'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland',
  'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
  'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman and Nicobar Islands',
  'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu', 'Delhi',
  'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry',
];

const kStatesHi = <String>[
  'आंध्र प्रदेश', 'अरुणाचल प्रदेश', 'असम', 'बिहार', 'छत्तीसगढ़', 'गोवा', 'गुजरात',
  'हरियाणा', 'हिमाचल प्रदेश', 'झारखंड', 'कर्नाटक', 'केरल', 'मध्य प्रदेश', 'महाराष्ट्र',
  'मणिपुर', 'मेघालय', 'मिज़ोरम', 'नागालैंड', 'ओडिशा', 'पंजाब', 'राजस्थान', 'सिक्किम',
  'तमिलनाडु', 'तेलंगाना', 'त्रिपुरा', 'उत्तर प्रदेश', 'उत्तराखंड', 'पश्चिम बंगाल',
  'अंडमान और निकोबार द्वीपसमूह', 'चंडीगढ़', 'दादरा और नगर हवेली और दमन और दीव', 'दिल्ली',
  'जम्मू और कश्मीर', 'लद्दाख', 'लक्षद्वीप', 'पुदुच्चेरी',
];

const kStatesMr = <String>[
  'आंध्र प्रदेश',
  'अरुणाचल प्रदेश',
  'आसाम',
  'बिहार',
  'छत्तीसगड',
  'गोवा',
  'गुजरात',
  'हरियाणा',
  'हिमाचल प्रदेश',
  'झारखंड',
  'कर्नाटक',
  'केरळ',
  'मध्य प्रदेश',
  'महाराष्ट्र',
  'मणिपूर',
  'मेघालय',
  'मिझोराम',
  'नागालँड',
  'ओडिशा',
  'पंजाब',
  'राजस्थान',
  'सिक्कीम',
  'तमिळनाडू',
  'तेलंगणा',
  'त्रिपुरा',
  'उत्तर प्रदेश',
  'उत्तराखंड',
  'पश्चिम बंगाल',
  'अंदमान आणि निकोबार बेटे',
  'चंदीगड',
  'दादरा आणि नगर हवेली व दमण आणि दीव',
  'दिल्ली',
  'जम्मू आणि काश्मीर',
  'लडाख',
  'लक्षद्वीप',
  'पुदुच्चेरी',
];

String stateLabel(String state, String lang) {
  final names = switch (lang) { 'hi' => kStatesHi, 'mr' => kStatesMr, _ => null };
  if (names == null) return state;
  final i = kStates.indexOf(state);
  return i < 0 ? state : names[i];
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.url,
    required this.category,
    required this.language,
    required this.publishedAt,
    this.imageUrl,
    this.imageCredit,
    this.state,
  });

  final String id;
  final String title;
  final String summary;
  final String source;
  final String url;
  final String category;
  final String language;
  final DateTime publishedAt;
  final String? imageUrl;
  final String? imageCredit;
  final String? state;

  String get domain => Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? source;

  /// Bundled sample images are asset paths; API images are http(s) URLs.
  bool get imageIsAsset => imageUrl?.startsWith('assets/') ?? false;

  factory Article.fromJson(Map<String, dynamic> j) => Article(
        id: j['id'] as String,
        title: j['title'] as String,
        summary: (j['summary'] as String?) ?? '',
        source: j['source'] as String,
        url: j['url'] as String,
        category: j['category'] as String,
        language: (j['language'] as String?) ?? 'en',
        publishedAt: DateTime.parse(j['published_at'] as String),
        imageUrl: j['image_url'] as String?,
        imageCredit: j['image_credit'] as String?,
        state: j['state'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'source': source,
        'url': url,
        'category': category,
        'language': language,
        'published_at': publishedAt.toUtc().toIso8601String(),
        'image_url': imageUrl,
        'image_credit': imageCredit,
        'state': state,
      };
}

class FeedPage {
  const FeedPage({
    required this.items,
    this.nextCursor,
    this.offline = false,
  });
  final List<Article> items;
  final String? nextCursor;

  /// True when items came from the on-device cache or bundled samples.
  final bool offline;
}
