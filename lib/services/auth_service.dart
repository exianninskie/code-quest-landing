import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

part 'auth_service.g.dart';

// Access the Supabase client anywhere via this provider
@riverpod
SupabaseClient supabase(SupabaseRef ref) => Supabase.instance.client;

// Streams auth state changes (login / logout)
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange.map(
        (event) => event.session?.user,
      );
}

// Current user (synchronous — null if logged out)
@riverpod
User? currentUser(CurrentUserRef ref) {
  return ref.watch(supabaseProvider).auth.currentUser;
}

// User profile data (real-time stream)
@riverpod
Stream<Map<String, dynamic>?> userProfileStream(UserProfileStreamRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return ref
      .watch(supabaseProvider)
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((data) => data.isNotEmpty ? data.first : null);
}

// Service class with sign-in / sign-up / sign-out methods
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(ref.watch(supabaseProvider));
}

class AuthService {
  final SupabaseClient _client;
  AuthService(this._client);

  // Sign up with email + password
  // Supabase automatically sends a confirmation email
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  // Sign in with email + password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Magic Link (passwordless)
  Future<void> signInWithMagicLink(String email) async {
    await _client.auth.signInWithOtp(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get the current session
  Session? get currentSession => _client.auth.currentSession;

  // Pick and upload avatar
  Future<String?> uploadAvatar() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (xFile == null) return null;

    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to upload avatar');

    final bytes = await xFile.readAsBytes();
    final fileExt = xFile.name.split('.').last.toLowerCase();

    if (fileExt != 'png' && fileExt != 'jpg' && fileExt != 'jpeg') {
      throw Exception('Only PNG or JPEG images are allowed.');
    }

    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    // Upload to Supabase Storage
    await _client.storage.from('avatars').uploadBinary(
      fileName,
      bytes,
      fileOptions: FileOptions(
        contentType: fileExt == 'png' ? 'image/png' : 'image/jpeg',
        upsert: true,
      ),
    );

    // Get the public URL of the uploaded image
    final imageUrl = _client.storage.from('avatars').getPublicUrl(fileName);
    print('Generated Avatar URL: $imageUrl');

    // Save URL to the profiles table
    // Use upsert to ensure profile document exists
    await _client.from('profiles').upsert({
      'id': user.id,
      'avatar_url': imageUrl,
      'username': user.userMetadata?['username'] ?? 'Adventurer',
    });
    
    print('Profile updated with new avatar URL.');

    return imageUrl;
  }
}
