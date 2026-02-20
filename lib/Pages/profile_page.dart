import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Providers/firestore_provider.dart' hide firestoreServiceProvider;
import 'package:quantum/Features/auth/Controller/auth_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Providers/property_provider.dart' show storageServiceProvider;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isUploading = false;

  // Edit field dialog
  Future<void> _editField(String field, String currentValue) async {
    final TextEditingController controller = TextEditingController(text: currentValue);

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new $field',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: field.toLowerCase() == 'bio' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newValue != null && newValue.isNotEmpty && newValue != currentValue) {
      await _saveField(field, newValue);
    }
  }

  // Save field to Firestore
  Future<void> _saveField(String field, String value) async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentUser = ref.read(currentUserProfileProvider).value;

      if (currentUser == null) return;

      if (field.toLowerCase() == 'username') {
        await firestoreService.updateUserProfile(
          uid: currentUser.uid,
          username: value,
        );
      } else if (field.toLowerCase() == 'bio') {
        await firestoreService.updateUserProfile(
          uid: currentUser.uid,
          bio: value,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$field updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $field: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Upload profile picture
  Future<void> _uploadProfilePicture() async {
    final storageService = ref.read(storageServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final currentUser = ref.read(currentUserProfileProvider).value;

    if (currentUser == null) return;

    // Show image source selection
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _isUploading = true);

    try {
      // Pick image
      File? imageFile;
      if (source == ImageSource.gallery) {
        imageFile = await storageService.pickImageFromGallery();
      } else {
        imageFile = await storageService.pickImageFromCamera();
      }

      if (imageFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Validate image
      if (!storageService.isValidImage(imageFile, maxSizeMB: 5)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image must be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isUploading = false);
        return;
      }

      // Upload to Firebase Storage
      final downloadUrl = await storageService.uploadProfilePicture(
        userId: currentUser.uid,
        imageFile: imageFile,
      );

      if (downloadUrl != null) {
        // Update Firestore
        await firestoreService.updateUserProfile(
          uid: currentUser.uid,
          profilePicUrl: downloadUrl,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Logout confirmation
  Future<void> _confirmLogout() async {
    print('🔴 LOGOUT: Button tapped'); // DEBUG

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              print('🔴 LOGOUT: User cancelled'); // DEBUG
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              print('🔴 LOGOUT: User confirmed'); // DEBUG
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    print('🔴 LOGOUT: Dialog result = $shouldLogout'); // DEBUG

    if (shouldLogout == true) {
      print('🔴 LOGOUT: Starting logout process'); // DEBUG

      try {
        // Direct Firebase logout (bypass controller for testing)
        await FirebaseAuth.instance.signOut();
        print('🔴 LOGOUT: Firebase signOut completed'); // DEBUG

        // The AuthWrapper should automatically handle navigation

      } catch (e) {
        print('🔴 LOGOUT: Error = $e'); // DEBUG
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: currentUserAsync.when(

        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('No user found. Please login.'),
            );
          }



          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header with Background
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),



                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: _isUploading
                                ? const CircularProgressIndicator(
                              color: Colors.green,
                            )
                                : user.profilePicUrl != null &&
                                user.profilePicUrl!.isNotEmpty
                                ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.profilePicUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.green,
                                ),
                              ),
                            )
                                : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.green,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploading ? null : _uploadProfilePicture,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Username
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Online Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user.isOnline
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: user.isOnline
                                    ? Colors.greenAccent
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.isOnline ? 'Online' : 'Offline',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Username Field
                      ProfileInfoCard(
                        icon: Icons.person_outline,
                        title: 'Username',
                        value: user.username,
                        onEdit: () => _editField('Username', user.username),
                      ),

                      const SizedBox(height: 12),

                      // Email Field (Not editable)
                      ProfileInfoCard(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: user.email,
                        onEdit: null, // Email not editable
                      ),

                      const SizedBox(height: 12),

                      // Bio Field
                      ProfileInfoCard(
                        icon: Icons.description_outlined,
                        title: 'Bio',
                        value: user.bio.isEmpty ? 'Add a bio...' : user.bio,
                        onEdit: () => _editField('Bio', user.bio),
                      ),

                      const SizedBox(height: 30),

                      // Account Info Section
                      Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Member Since
                      ProfileInfoCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Member Since',
                        value: _formatDate(user.createdAt),
                        onEdit: null,
                      ),

                      const SizedBox(height: 12),

                      // Last Seen
                      ProfileInfoCard(
                        icon: Icons.access_time,
                        title: 'Last Seen',
                        value: _formatLastSeen(user.lastSeen),
                        onEdit: null,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading profile: $error'),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return _formatDate(lastSeen);
    }
  }
}

// Profile Info Card Widget
class ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onEdit;

  const ProfileInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green, size: 24),
          ),

          const SizedBox(width: 16),

          // Title and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}

// Add this enum at the top of the file
enum ImageSource { gallery, camera }