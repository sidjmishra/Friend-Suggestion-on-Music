import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:music_recommend/recommendation.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MusicRecommend());
}

