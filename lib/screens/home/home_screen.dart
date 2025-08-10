import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis_mobile_app/config/theme.dart';
import 'package:jarvis_mobile_app/core/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;

  const HomeScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final adminPermissions = ref.watch(adminPermissionsProvider);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _navigateToTab(index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: [
              // Chat
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentIndex == 0
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.chat_bubble,
                    size: 24,
                  ),
                ),
                label: 'Chat',
              ),
              
              // Calendrier
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentIndex == 1
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 24,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: 24,
                  ),
                ),
                label: 'Calendrier',
              ),
              
              // Bio-hacking
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentIndex == 2
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 24,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 24,
                  ),
                ),
                label: 'Bio-hacking',
              ),
              
              // Profil
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentIndex == 3
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
                    child: currentUser?.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              currentUser!.photoUrl!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 16,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                          ),
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: currentUser?.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              currentUser!.photoUrl!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    // Afficher le FAB seulement sur l'onglet chat
    if (_currentIndex != 0) return null;

    return FloatingActionButton(
      onPressed: () {
        // Créer une nouvelle conversation
        // Cette logique sera gérée par l'écran de chat
      },
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add),
    );
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        context.goToChat();
        break;
      case 1:
        context.goToCalendar();
        break;
      case 2:
        context.goToBioHacking();
        break;
      case 3:
        context.goToProfile();
        break;
    }
  }
}
