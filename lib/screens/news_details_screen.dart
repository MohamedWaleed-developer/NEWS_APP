import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';
import '../service/saved_news_service.dart';
import '../utils/app_strings.dart';

class NewsDetailsScreen extends StatefulWidget {
  final NewsModel news;

  NewsDetailsScreen({
    super.key,
    required this.news,
  });

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  final SavedNewsService savedNewsService = SavedNewsService();

  bool isSaved = false;
  bool isLoadingSaved = true;

  @override
  void initState() {
    super.initState();
    checkSavedNews();
  }

  Future<void> checkSavedNews() async {
    final saved = await savedNewsService.isSaved(widget.news);

    if (!mounted) return;

    setState(() {
      isSaved = saved;
      isLoadingSaved = false;
    });
  }

  Future<void> toggleBookmark() async {
    await savedNewsService.toggleSave(widget.news);

    if (!mounted) return;

    setState(() {
      isSaved = !isSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.text(
            context,
            isSaved ? 'addedToSaved' : 'removedFromSaved',
          ),
        ),
      ),
    );
  }

  Future<void> openArticle() async {
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

  String get formattedDate {
    if (widget.news.publishedAt.isEmpty) {
      return AppStrings.text(context, 'recently');
    }

    final date = DateTime.tryParse(widget.news.publishedAt);

    if (date == null) {
      return AppStrings.text(context, 'recently');
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.h,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colors.outlineVariant,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 21.sp,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: colors.outlineVariant,
                        ),
                      ),
                      child: IconButton(
                        onPressed: isLoadingSaved
                            ? null
                            : toggleBookmark,
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20.sp,
                          color: isSaved
                              ? colors.primary
                              : colors.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: colors.outlineVariant,
                        ),
                      ),
                      child: IconButton(
                        onPressed: shareNews,
                        icon: Icon(
                          Icons.share_outlined,
                          size: 20.sp,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.news.urlToImage.isNotEmpty
                      ? Image.network(
                    widget.news.urlToImage,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return _buildPlaceholder(
                        theme,
                        colors,
                      );
                    },
                  )
                      : _buildPlaceholder(
                    theme,
                    colors,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18.w,
                    right: 18.w,
                    bottom: 18.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primary,
                            colors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        AppStrings.text(
                          context,
                          'latestNews',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                18.w,
                22.h,
                18.w,
                35.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.news.title,
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: -0.5,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16.sp,
                        color: colors.onSurfaceVariant,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      if (widget.news.author.isNotEmpty)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 16.sp,
                                color: colors.onSurfaceVariant,
                              ),
                              SizedBox(width: 5.w),
                              Expanded(
                                child: Text(
                                  widget.news.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  if (widget.news.description.isNotEmpty)
                    Text(
                      widget.news.description,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                        color: colors.onSurface,
                      ),
                    ),
                  if (widget.news.description.isNotEmpty)
                    SizedBox(height: 18.h),
                  if (widget.news.content.isNotEmpty)
                    Text(
                      widget.news.content,
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.7,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primary,
                            colors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: openArticle,
                        icon: Icon(
                          Icons.open_in_new_rounded,
                          size: 19.sp,
                        ),
                        label: Text(
                          AppStrings.text(
                            context,
                            'readFullArticle',
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
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

  Widget _buildPlaceholder(
      ThemeData theme,
      ColorScheme colors,
      ) {
    return Container(
      color: theme.brightness == Brightness.light
          ? Color(0xffEEEEF1)
          : Color(0xff202024),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 45.sp,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}