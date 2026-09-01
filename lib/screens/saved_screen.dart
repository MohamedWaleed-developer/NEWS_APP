import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_strings.dart';
import '../models/news_model.dart';
import '../service/saved_news_service.dart';
import 'news_details_screen.dart';

class SavedScreen extends StatefulWidget {
  SavedScreen({
    super.key,
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final SavedNewsService savedNewsService = SavedNewsService();

  List<NewsModel> savedNews = [];

  bool isLoading = true;

  final Color primaryColor = Color(0xff6C5CE7);
  final Color secondaryColor = Color(0xff8B7CF6);

  @override
  void initState() {
    super.initState();
    loadSavedNews();
  }

  Future<void> loadSavedNews() async {
    setState(() {
      isLoading = true;
    });

    final news = await savedNewsService.getSavedNews();

    if (!mounted) return;

    setState(() {
      savedNews = news;
      isLoading = false;
    });
  }

  Future<void> removeNews(NewsModel news) async {
    await savedNewsService.removeNews(news);

    if (!mounted) return;

    setState(() {
      savedNews.removeWhere(
            (item) => item.url == news.url,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.text(
            context,
            'removedFromSaved',
          ),
        ),
      ),
    );
  }

  Future<void> openArticle(NewsModel news) async {
    if (news.url.isEmpty) return;

    final uri = Uri.tryParse(news.url);

    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> shareNews(NewsModel news) async {
    if (news.url.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(
        text: '${news.title}\n\n${news.url}',
      ),
    );
  }

  Future<void> openDetails(NewsModel news) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailsScreen(
          news: news,
        ),
      ),
    );

    loadSavedNews();
  }

  String text(String key) {
    return AppStrings.text(context, key);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
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
        title: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(
                Icons.bookmark_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 11.w),
            Text(
              text('savedNews'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? _buildLoadingState(colors)
          : savedNews.isEmpty
          ? _buildEmptyState(
        theme,
        colors,
        isDark,
      )
          : RefreshIndicator(
        color: primaryColor,
        onRefresh: loadSavedNews,
        child: ListView.separated(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            18.w,
            20.h,
            18.w,
            30.h,
          ),
          itemCount: savedNews.length,
          separatorBuilder: (context, index) {
            return SizedBox(height: 16.h);
          },
          itemBuilder: (context, index) {
            final news = savedNews[index];

            return _buildSavedCard(
              news,
              theme,
              colors,
              isDark,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSavedCard(
      NewsModel news,
      ThemeData theme,
      ColorScheme colors,
      bool isDark,
      ) {
    return GestureDetector(
      onTap: () {
        openDetails(news);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark
                ? Color(0xff292930)
                : Color(0xffE7E7EC),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDark ? 0.16 : 0.035,
              ),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(
              news,
              theme,
              colors,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                15.w,
                14.h,
                10.w,
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
                          primaryColor.withOpacity(0.14),
                          secondaryColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: Text(
                      text('saved').toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 9.h),
                  Text(
                    news.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Divider(
                    height: 1.h,
                    color: colors.outlineVariant.withOpacity(0.6),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            openDetails(news);
                          },
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
                        onPressed: () {
                          shareNews(news);
                        },
                        tooltip: text('share'),
                        icon: Icon(
                          Icons.share_outlined,
                          size: 20.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          openArticle(news);
                        },
                        tooltip: text('readFullArticle'),
                        icon: Icon(
                          Icons.open_in_new_rounded,
                          size: 20.sp,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          removeNews(news);
                        },
                        tooltip: text('removeFromSaved'),
                        icon: Icon(
                          Icons.bookmark_rounded,
                          size: 20.sp,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(
      NewsModel news,
      ThemeData theme,
      ColorScheme colors,
      ) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: news.urlToImage.isNotEmpty
          ? Image.network(
        news.urlToImage,
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
                color: primaryColor,
              ),
            ),
          );
        },
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _buildNoImage(
            theme,
            colors,
          );
        },
      )
          : _buildNoImage(
        theme,
        colors,
      ),
    );
  }

  Widget _buildNoImage(
      ThemeData theme,
      ColorScheme colors,
      ) {
    return Container(
      color: theme.brightness == Brightness.light
          ? Color(0xffF0F0F3)
          : Color(0xff1C1C22),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 42.sp,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLoadingState(
      ColorScheme colors,
      ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30.w,
            height: 30.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            text('loadingLatestStories'),
            style: TextStyle(
              fontSize: 13.sp,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      ThemeData theme,
      ColorScheme colors,
      bool isDark,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color: isDark
                    ? Color(0xff272238)
                    : Color(0xffF0EEFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 36.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              text('noSavedNews'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              text('noSavedNewsDescription'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}