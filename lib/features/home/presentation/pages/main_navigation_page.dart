import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../posts/presentation/pages/create_post_page.dart';
import '../../../posts/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../search/presentation/pages/search_page.dart';

class MainNavigationPage extends StatefulWidget {
  final String uid;

  const MainNavigationPage({
    super.key,
    required this.uid,
  });

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const HomePage(),
      const SearchPage(),
      const CreatePostPage(),
      const NotificationsPage(),
      ProfilePage(uid: widget.uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          12.w,
          0,
          12.w,
          8.h,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 7.w,
            vertical: 7.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(
              alpha: 0.96,
            ),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GNav(
            selectedIndex: currentIndex,
            onTabChange: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            gap: 5.w,
            tabBorderRadius: 16.r,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            duration: const Duration(
              milliseconds: 220,
            ),
            curve: Curves.easeOutCubic,
            backgroundColor: Colors.transparent,
            color: AppColors.textMuted,
            activeColor: AppColors.primary,
            tabBackgroundColor: AppColors.primary.withValues(
              alpha: 0.09,
            ),
            rippleColor: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            hoverColor: AppColors.primary.withValues(
              alpha: 0.05,
            ),
            tabs: [
              GButton(
                icon: Icons.home_outlined,
                text: 'Home',
                iconActiveColor: AppColors.primary,
              ),
              GButton(
                icon: Icons.search_rounded,
                text: 'Search',
                iconActiveColor: AppColors.primary,
              ),
              GButton(
                icon: Icons.add_rounded,
                text: 'Create',
                iconActiveColor: Colors.white,
                iconColor: AppColors.primary,
              ),
              GButton(
                icon: Icons.notifications_none_rounded,
                text: 'Alerts',
                iconActiveColor: AppColors.primary,
              ),
              GButton(
                icon: Icons.person_outline_rounded,
                text: 'Profile',
                iconActiveColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}