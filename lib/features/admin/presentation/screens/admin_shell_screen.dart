import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/core/utils/image_utils.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/responsive_card_grid.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/state_views.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/screens/login_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/scan_detail_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});
  static const String routeName = '/admin_shell';

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final shelfProvider = context.watch<ShelfAnalysisProvider>();

    final List<Widget> screens = [
      _AdminDashboardTab(auth: authProvider, shelf: shelfProvider),
      _AdminUsersTab(auth: authProvider),
      _AdminScansTab(shelf: shelfProvider),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _currentIndex == 0
              ? 'Admin Dashboard'
              : _currentIndex == 1
                  ? 'All Users'
                  : 'All Scans',
          style: AppTextStyles.heading.copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.blue),
            tooltip: 'Sign Out',
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
              }
            },
          ),
        ],
      ),
      body: authProvider.isLoading && authProvider.allUsers.isEmpty
          ? const LoadingStateView(message: 'Loading admin data from Firestore...')
          : screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.primaryBright,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'USERS',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'SCANS',
          ),
        ],
      ),
    );
  }
}

// ─── Admin Dashboard Tab ───────────────────────────────────────────────────
class _AdminDashboardTab extends StatelessWidget {
  const _AdminDashboardTab({required this.auth, required this.shelf});
  final AuthProvider auth;
  final ShelfAnalysisProvider shelf;

  @override
  Widget build(BuildContext context) {
    final scans = shelf.scanHistory;
    final totalScans = scans.length;
    final totalUsers = auth.allUsers.length;
    final lowCompliance = scans.where((s) => s.compliance < 85).length;
    final avgCompliance = totalScans > 0
        ? scans.map((s) => s.compliance).reduce((a, b) => a + b) / totalScans
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SYSTEM OVERVIEW', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 6),
          Text(
            'Welcome, ${auth.currentUser?.name ?? 'Admin'}',
            style: AppTextStyles.title.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 24),

          ResponsiveCardGrid(
            minTileWidth: 175,
            children: [
              _StatCard(
                icon: Icons.qr_code_scanner_rounded,
                iconColor: AppColors.primary,
                chipColor: const Color(0xFFE7F9EB),
                chipLabel: 'TOTAL',
                value: '$totalScans',
                label: 'Total Scans',
              ),
              _StatCard(
                icon: Icons.people_rounded,
                iconColor: Colors.blue,
                chipColor: const Color(0xFFE3F0FF),
                chipLabel: 'USERS',
                value: '$totalUsers',
                label: 'Active Users',
              ),
              _StatCard(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.danger,
                chipColor: const Color(0xFFFFEFF0),
                chipLabel: 'ALERT',
                value: '$lowCompliance',
                label: 'Low Compliance',
              ),
              _StatCard(
                icon: Icons.verified_rounded,
                iconColor: Colors.orange,
                chipColor: const Color(0xFFFFF3E0),
                chipLabel: 'AVG',
                value: '${avgCompliance.toStringAsFixed(1)}%',
                label: 'Avg Compliance',
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Overall health bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Overall Shelf Health',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${avgCompliance.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppColors.primaryBright,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: avgCompliance / 100.0,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF6D6D6D),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBright),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Text('Recent Scans (All Users)', style: AppTextStyles.heading.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          if (scans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No scans submitted yet.',
                  style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            for (final scan in scans.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoftCard(
                  padding: const EdgeInsets.all(12),
                  radius: 4,
                  onTap: () {
                    context.read<ShelfAnalysisProvider>().selectScan(scan);
                    Navigator.pushNamed(context, ScanDetailScreen.routeName);
                  },
                  child: Row(
                    children: [
                      ScanImage(
                        imagePath: scan.imagePath,
                        width: 52,
                        height: 52,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(scan.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              'User: ${scan.userName ?? scan.userId}',
                              style: AppTextStyles.body.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${scan.compliance}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scan.compliance >= 85 ? AppColors.primary : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Admin Users Tab ───────────────────────────────────────────────────────
class _AdminUsersTab extends StatelessWidget {
  const _AdminUsersTab({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final users = auth.allUsers;

    if (auth.errorMessage != null && users.isEmpty) {
      return ErrorStateView(
        message: auth.errorMessage!,
        onRetry: auth.fetchAllUsers,
      );
    }

    if (users.isEmpty) {
      return const EmptyStateView(
        title: 'No users yet',
        message: 'Registered users will appear here after they sign up or log in.',
        icon: Icons.people_outline_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isAdmin = user.role == 'admin';
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SoftCard(
            padding: const EdgeInsets.all(16),
            radius: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isAdmin ? AppColors.primaryBright : const Color(0xFFEAE7E7),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                    color: isAdmin ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _RoleDropdown(userId: user.uid, currentRole: user.role),
                    const SizedBox(height: 4),
                    Text(
                      '${user.shiftsCompleted} shifts',
                      style: AppTextStyles.body.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.userId, required this.currentRole});

  final String userId;
  final String currentRole;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: currentRole == 'admin' ? AppColors.primaryBright : const Color(0xFFEAE7E7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRole,
          isDense: true,
          iconSize: 18,
          dropdownColor: Colors.white,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: currentRole == 'admin' ? AppColors.primary : AppColors.textSecondary,
          ),
          items: const [
            DropdownMenuItem(value: 'user', child: Text('USER')),
            DropdownMenuItem(value: 'admin', child: Text('ADMIN')),
          ],
          onChanged: auth.isUpdatingUserRole
              ? null
              : (role) async {
                  if (role == null || role == currentRole) return;
                  final success = await context.read<AuthProvider>().updateUserRole(
                        uid: userId,
                        role: role,
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'User role updated to ${role.toUpperCase()}.'
                            : (context.read<AuthProvider>().errorMessage ?? 'Role update failed.'),
                      ),
                      backgroundColor: success ? AppColors.primary : AppColors.danger,
                    ),
                  );
                },
        ),
      ),
    );
  }
}

// ─── Admin Scans Tab ───────────────────────────────────────────────────────
class _AdminScansTab extends StatelessWidget {
  const _AdminScansTab({required this.shelf});
  final ShelfAnalysisProvider shelf;

  @override
  Widget build(BuildContext context) {
    final scans = shelf.scanHistory;

    if (shelf.isFetching) {
      return const LoadingStateView(message: 'Loading all Firestore scans...');
    }

    if (shelf.errorMessage != null) {
      return ErrorStateView(
        message: shelf.errorMessage!,
        onRetry: shelf.retryCurrentStream,
      );
    }

    if (scans.isEmpty) {
      return const EmptyStateView(
        title: 'No scans submitted yet',
        message: 'User scan records will appear here after the first shelf analysis is saved.',
        icon: Icons.history_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      itemCount: scans.length,
      itemBuilder: (context, index) {
        final scan = scans[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SoftCard(
            padding: const EdgeInsets.all(12),
            radius: 4,
            onTap: () {
              context.read<ShelfAnalysisProvider>().selectScan(scan);
              Navigator.pushNamed(context, ScanDetailScreen.routeName);
            },
            child: Row(
              children: [
                ScanImage(
                  imagePath: scan.imagePath,
                  width: 58,
                  height: 58,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scan.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(
                        'By: ${scan.userName ?? scan.userId}',
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(scan.subtitle, style: AppTextStyles.body.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${scan.compliance}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: scan.compliance >= 85 ? AppColors.primary : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Stat Card Widget ──────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.chipColor,
    required this.chipLabel,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color chipColor;
  final String chipLabel;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 0,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(color: iconColor, fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
