import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

part 'chat_service.g.dart';

@riverpod
ChatService chatService(ChatServiceRef ref) {
  return ChatService(ref.watch(supabaseProvider));
}

@riverpod
Stream<List<Map<String, dynamic>>> chatMessages(ChatMessagesRef ref) {
  // We use .stream() for real-time updates on the messages table
  return ref
      .watch(supabaseProvider)
      .from('messages')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false) // Newest on top
      .limit(5)
      .asyncMap((messages) async {
        try {
          if (messages.isEmpty) return [];

          final userIds = messages
              .map((m) => m['user_id']?.toString())
              .whereType<String>()
              .toSet()
              .toList();
          
          if (userIds.isEmpty) return messages;

          final profilesData = await ref
              .read(supabaseProvider)
              .from('profiles')
              .select('*') // Broad select to ensure no missing columns cause failure
              .inFilter('id', userIds);
          
          final profileMap = {
            for (final p in profilesData) p['id'].toString(): p
          };
            
          return messages.map((msg) => {
            ...msg,
            'profiles': profileMap[msg['user_id']?.toString()] ?? {},
          }).toList();
        } catch (e, stack) {
          // Fallback to raw messages if profile fetch fails
          print('--- CHAT ERROR ---');
          print('Error Details: $e');
          print('Stack Trace: $stack');
          print('------------------');
          
          return messages.map((msg) => {
            ...msg,
            'profiles': {},
          }).toList();
        }
      });
}

@riverpod
Stream<List<Map<String, dynamic>>> onlineUsers(OnlineUsersRef ref) {
  final supabase = ref.watch(supabaseProvider);

  Future<List<Map<String, dynamic>>> fetchOnline() async {
    try {
      final sixtySecondsAgo = DateTime.now().subtract(const Duration(seconds: 60)).toUtc().toIso8601String();
      
      final data = await supabase
          .from('profiles')
          .select('id, username, avatar_url, last_active_at, total_xp')
          .gt('last_active_at', sixtySecondsAgo)
          .order('last_active_at', ascending: false);
          
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Online Users Error: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Emit immediately, then poll every 15 seconds
  return Stream<void>.multi((controller) {
    controller.add(null); // Immediate first emit
    final periodic = Stream.periodic(const Duration(seconds: 15));
    periodic.listen((_) => controller.add(null));
  }).asyncMap((_) => fetchOnline());
}

class ChatService {
  final SupabaseClient _client;
  ChatService(this._client);

  static const List<String> templates = [
    'Hey!',
    'Thanks!',
    'Good luck!',
    'See you!',
    'Challenge Accepted!',
    'Almost there!',
    'Wow!',
    'Keep going!',
  ];

  Future<void> sendMessage(String content) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // Fetch current chapter title from profile to store snapshot
    final profile = await _client
        .from('profiles')
        .select('current_chapter_title')
        .eq('id', user.id)
        .single();
    
    final currentChapter = profile['current_chapter_title'] ?? 'Exploring...';

    await _client.from('messages').insert({
      'user_id': user.id,
      'content': content,
      'sender_chapter': currentChapter,
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _client
        .from('messages')
        .delete()
        .eq('id', messageId);
  }

  Future<void> deleteAllMessages() async {
    // Delete all messages. Using neq('id', 0) is a dummy filter to satisfy Supabase's requirement for a filter during delete.
    // Since id is UUID, this will match everything.
    await _client
        .from('messages')
        .delete()
        .neq('id', '00000000-0000-0000-0000-000000000000');
  }

  Future<void> updateCurrentLocation(String chapterTitle) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('profiles').update({
      'current_chapter_title': chapterTitle,
    }).eq('id', user.id);
  }
}
