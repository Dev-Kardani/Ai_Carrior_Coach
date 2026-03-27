import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_career_coach/models/chat_message_model.dart';
import 'package:ai_career_coach/core/constants/app_constants.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';

/// Local storage service for chat history and preferences
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
  
  late final SharedPreferences _prefs;
  
  /// Initialize shared preferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // ==================== CHAT HISTORY ====================
  
  /// Save chat history
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    DebugLogger.info('STORAGE', 'SAVE_CHAT', 'Saving ${messages.length} messages to local storage');
    try {
      // Limit to max messages
      final limitedMessages = messages.length > AppConstants.chatHistoryMaxMessages
          ? messages.sublist(0, AppConstants.chatHistoryMaxMessages)
          : messages;
      
      final jsonList = limitedMessages.map((msg) => msg.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      await _prefs.setString(AppConstants.chatHistoryKey, jsonString);
      DebugLogger.success('STORAGE', 'SAVE_CHAT', 'Successfully saved history');
    } catch (e) {
      DebugLogger.failed('STORAGE', 'SAVE_CHAT', e.toString(), error: e);
      throw Exception('Failed to save chat history: ${e.toString()}');
    }
  }
  
  /// Load chat history
  Future<List<ChatMessage>> loadChatHistory() async {
    DebugLogger.info('STORAGE', 'LOAD_CHAT', 'Loading chat history from local storage');
    try {
      final jsonString = _prefs.getString(AppConstants.chatHistoryKey);
      
      
      if (jsonString == null || jsonString.isEmpty) {
        DebugLogger.warning('STORAGE', 'LOAD_CHAT', 'No chat history found');
        return [];
      }
      
      final jsonList = json.decode(jsonString) as List;
      final loadedMessages = jsonList.map((json) => ChatMessage.fromJson(json)).toList();
      DebugLogger.success('STORAGE', 'LOAD_CHAT', 'Loaded ${loadedMessages.length} messages');
      return loadedMessages;
    } catch (e) {
      DebugLogger.failed('STORAGE', 'LOAD_CHAT', e.toString(), error: e);
      return [];
    }
  }
  
  /// Clear chat history
  Future<void> clearChatHistory() async {
    await _prefs.remove(AppConstants.chatHistoryKey);
  }
  
  // ==================== THEME PREFERENCES ====================
  
  /// Save theme mode
  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool(AppConstants.themeKey, isDark);
  }
  
  /// Load theme mode
  bool getThemeMode() {
    return _prefs.getBool(AppConstants.themeKey) ?? true; // Default to dark
  }
}
