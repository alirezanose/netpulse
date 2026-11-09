import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/test_result.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final List<TestResult> _memoryCache = [];
  bool _isInitialized = false;

  Future<File?> _getLocalFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/netpulse_history.json');
    } catch (e) {
      debugPrint('Error getting local directory: $e');
      return null;
    }
  }

  Future<List<TestResult>> getHistory() async {
    if (_isInitialized) {
      return List.unmodifiable(_memoryCache);
    }

    try {
      final file = await _getLocalFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> jsonList = json.decode(content);
          _memoryCache.clear();
          for (var item in jsonList) {
            _memoryCache.add(TestResult.fromMap(item as Map<String, dynamic>));
          }
          // Sort newest first
          _memoryCache.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        }
      }
    } catch (e) {
      debugPrint('Error reading history file: $e');
    }
    _isInitialized = true;
    return List.unmodifiable(_memoryCache);
  }

  Future<void> saveResult(TestResult result) async {
    _memoryCache.insert(0, result);
    await _persist();
  }

  Future<void> deleteResult(String id) async {
    _memoryCache.removeWhere((item) => item.id == id);
    await _persist();
  }

  Future<void> clearHistory() async {
    _memoryCache.clear();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final file = await _getLocalFile();
      if (file != null) {
        final data = _memoryCache.map((e) => e.toMap()).toList();
        await file.writeAsString(json.encode(data));
      }
    } catch (e) {
      debugPrint('Error persisting history: $e');
    }
  }
}
