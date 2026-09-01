import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';
import '../service/api_services.dart';
import '../widgets/news_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiServices api = ApiServices();

  List<NewsModel> newsList = [];

  bool isLoading = false;
  String? errorMessage;

  final List<String> categories = [
    'All',
    'Sports',
    'Gold',
    'Politics',
    'Economy',
    'Technology',
  ];

  String selectedCategory = 'All';

  final Color primaryColor = const Color(0xff2E7D5B);
  final Color backgroundColor = const Color(0xffF5F6F4);
  final Color textColor = const Color(0xff202522);
  final Color secondaryTextColor = const Color(0xff737873);

  @override
  void initState() {
    super.initState();
    getNews();
  }

  Future<void> getNews() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final news = await api.getNews(
        selectedCategory == 'All' ? 'news' : selectedCategory,
      );

      if (!mounted) return;

      setState(() {
        newsList = news;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Something went wrong';
      });
    }
  }

  void selectCategory(String category) {
    if (selectedCategory == category) return;

    setState(() {
      selectedCategory = category;
    });

    getNews();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: getNews,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              SliverToBoxAdapter(
                child: _buildCategories(),
              ),

              SliverToBoxAdapter(
                child: _buildSectionHeader(),
              ),

              if (isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildLoadingState(),
                )
              else if (errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                )
              else if (newsList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      18.w,
                      0,
                      18.w,
                      30.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final news = newsList[index];

                          if (index == 0) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: 24.h,
                              ),
                              child: _buildFeaturedNews(news),
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: 16.h,
                            ),
                            child: NewsCard(
                              news: news,
                            ),
                          );
                        },
                        childCount: newsList.length,
                      ),
                    ),
                  ),

              if (!isLoading && newsList.length > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      18.w,
                      0,
                      18.w,
                      14.h,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Latest Stories',
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 19.sp,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18.w,
        20.h,
        18.w,
        16.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      'STAY INFORMED',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.h),
                Text(
                  'News Today',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your daily dose of what matters.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xffE2E5E1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              size: 22.sp,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) {
          return SizedBox(width: 8.w);
        },
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () => selectCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : const Color(0xffE1E4E1),
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.check_rounded,
                      size: 15.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5.w),
                  ],
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xff444844),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18.w,
        25.h,
        18.w,
        13.h,
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 21.h,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(5.r),
            ),
          ),
          SizedBox(width: 9.w),
          Text(
            selectedCategory == 'All'
                ? 'Top Stories'
                : selectedCategory,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const Spacer(),
          if (!isLoading && newsList.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 9.w,
                vertical: 5.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffEAF3EE),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${newsList.length} stories',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedNews(NewsModel news) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xffE1E5E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 220.h,
                child: news.urlToImage.isNotEmpty
                    ? Image.network(
                  news.urlToImage,
                  fit: BoxFit.cover,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return _buildImagePlaceholder();
                  },
                )
                    : _buildImagePlaceholder(),
              ),
              Positioned(
                top: 14.h,
                left: 14.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.94),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 13.sp,
                        color: primaryColor,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'Featured',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              16.h,
              16.w,
              17.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (news.url.isEmpty) return;
                          final uri = Uri.parse(news.url);
                          launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xffF1F5F2),
                          foregroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(
                            vertical: 11.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(11.r),
                          ),
                        ),
                        child: Text(
                          'Read Article',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 9.w),
                    Container(
                      width: 43.w,
                      height: 43.w,
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F2),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 21.sp,
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
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xffECEFEC),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 42.sp,
          color: const Color(0xff9AA09B),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
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
            'Loading latest stories...',
            style: TextStyle(
              fontSize: 13.sp,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: const Color(0xffEAF3EE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 32.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Unable to load news',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: secondaryTextColor,
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              height: 44.h,
              child: ElevatedButton.icon(
                onPressed: getNews,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18.sp,
                ),
                label: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: const Color(0xffEAF3EE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.article_outlined,
                size: 34.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'No news available',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'There are no stories to show right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}