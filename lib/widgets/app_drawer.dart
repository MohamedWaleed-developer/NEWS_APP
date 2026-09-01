import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/language_controller.dart';
import '../controllers/theme_controller.dart';
import '../screens/saved_screen.dart';
import '../utils/app_strings.dart';

class AppDrawer extends StatelessWidget {
  final ThemeController themeController;
  final LanguageController languageController;
  final Future<void> Function()? onSavedPageClosed;

  const AppDrawer({
    super.key,
    required this.themeController,
    required this.languageController,
    this.onSavedPageClosed,
  });

  String text(BuildContext context, String key) {
    return AppStrings.text(context, key);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24.w,
                28.h,
                24.w,
                24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff6C5CE7),
                          Color(0xff8B7CF6),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.newspaper_rounded,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    text(context, 'appName'),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    text(context, 'appSubtitle'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.dividerColor,
            ),
            SizedBox(height: 10.h),
            ListTile(
              leading: Icon(
                Icons.bookmark_outline_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                text(context, 'savedNews'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedScreen(),
                  ),
                );

                await onSavedPageClosed?.call();
              },
            ),
            ListTile(
              leading: Icon(
                isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                isDark
                    ? text(context, 'lightMode')
                    : text(context, 'darkMode'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: themeController.toggleTheme,
            ),
            ListTile(
              leading: Icon(
                Icons.translate_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                languageController.isArabic
                    ? text(context, 'english')
                    : text(context, 'arabic'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: languageController.toggleLanguage,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}