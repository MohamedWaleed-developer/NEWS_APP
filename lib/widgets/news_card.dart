import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';
import '../screens/news_details_screen.dart';
import '../utils/app_strings.dart';

class NewsCard extends StatefulWidget {
  final NewsModel news;
  final bool isSaved;
  final VoidCallback? onSaveChanged;

  NewsCard({
    super.key,
    required this.news,
    this.isSaved = false,
    this.onSaveChanged,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isPressed = false;

  Future<void> openNews() async {
    if (widget.news.url.isEmpty) return;

    final uri = Uri.tryParse(widget.news.url);

    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> shareNews() async {
    if (widget.news.url.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(
        text: '${widget.news.title}\n\n${widget.news.url}',
      ),
    );
  }

  void openDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailsScreen(
          news: widget.news,
        ),
      ),
    );
  }

  void toggleBookmark() {
    widget.onSaveChanged?.call();
  }

  String text(String key) {
    return AppStrings.text(context, key);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedScale(
      scale: isPressed ? 0.985 : 1,
      duration: Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            isPressed = false;
          });

          openDetails();
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? Color(0xffE7E7EC)
                  : Color(0xff292930),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(theme),
              _buildContent(theme, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: widget.news.urlToImage.isNotEmpty
          ? Image.network(
        widget.news.urlToImage,
        fit: BoxFit.cover,
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          return Center(
            child: SizedBox(
              width: 25.w,
              height: 25.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        },
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _buildNoImage(theme);
        },
      )
          : _buildNoImage(theme),
    );
  }

  Widget _buildNoImage(ThemeData theme) {
    return Container(
      color: theme.brightness == Brightness.light
          ? Color(0xffF0F0F3)
          : Color(0xff1C1C22),
      padding: EdgeInsets.all(35.w),
      child: Lottie.asset(
        'assets/animation/no_news.json',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildContent(
      ThemeData theme,
      ColorScheme colors,
      ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        15.h,
        12.w,
        10.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withOpacity(0.14),
                  colors.secondary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Text(
              text('latestNews'),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colors.primary,
              ),
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            widget.news.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 13.h),
          Divider(
            height: 1.h,
            color: colors.outlineVariant.withOpacity(0.6),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: openDetails,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  icon: Icon(
                    Icons.arrow_outward_rounded,
                    size: 17.sp,
                  ),
                  label: Text(
                    text('readArticle'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: shareNews,
                tooltip: text('share'),
                icon: Icon(
                  Icons.share_outlined,
                  size: 20.sp,
                  color: colors.onSurfaceVariant,
                ),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 180),
                transitionBuilder: (
                    child,
                    animation,
                    ) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: IconButton(
                  key: ValueKey(widget.isSaved),
                  onPressed: toggleBookmark,
                  tooltip: widget.isSaved
                      ? text('removeFromSaved')
                      : text('save'),
                  icon: Icon(
                    widget.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 21.sp,
                    color: widget.isSaved
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}