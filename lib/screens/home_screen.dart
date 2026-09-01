import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/language_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/news_model.dart';
import '../service/api_services.dart';
import '../service/saved_news_service.dart';
import '../utils/app_strings.dart';
import '../widgets/app_drawer.dart';
import '../widgets/news_card.dart';
import 'news_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;
  final LanguageController languageController;

  HomeScreen({
    super.key,
    required this.themeController,
    required this.languageController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiServices api = ApiServices();
  final SavedNewsService savedNewsService = SavedNewsService();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  List<NewsModel> newsList = [];
  Set<String> savedNewsUrls = {};

  bool isLoading = false;
  String? errorMessage;
  bool isSearching = false;

  final List<String> categories = [
    'All',
    'Sports',
    'Gold',
    'Politics',
    'Economy',
    'Technology',
  ];

  String selectedCategory = 'All';
  String? searchedKeyword;

  final Color primaryColor = Color(0xff6C5CE7);
  final Color secondaryColor = Color(0xff8B7CF6);

  @override
  void initState() {
    super.initState();
    loadSavedNews();
    getNews();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  String text(String key) {
    return AppStrings.text(context, key);
  }

  String categoryText(String category) {
    switch (category) {
      case 'All':
        return text('all');
      case 'Sports':
        return text('sports');
      case 'Gold':
        return text('gold');
      case 'Politics':
        return text('politics');
      case 'Economy':
        return text('economy');
      case 'Technology':
        return text('technology');
      default:
        return category;
    }
  }

  Future<void> loadSavedNews() async {
    final savedNews = await savedNewsService.getSavedNews();

    if (!mounted) return;

    setState(() {
      savedNewsUrls = savedNews
          .map((news) => news.url)
          .where((url) => url.isNotEmpty)
          .toSet();
    });
  }

  Future<void> toggleBookmark(NewsModel news) async {
    final newState = await savedNewsService.toggleSave(news);

    if (!mounted) return;

    setState(() {
      if (newState) {
        savedNewsUrls.add(news.url);
      } else {
        savedNewsUrls.remove(news.url);
      }
    });
  }

  Future<void> getNews() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final category = searchedKeyword != null &&
          searchedKeyword!.trim().isNotEmpty
          ? searchedKeyword!.trim()
          : selectedCategory == 'All'
          ? 'news'
          : selectedCategory;

      final news = await api.getNews(category);

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
    if (selectedCategory == category && searchedKeyword == null) {
      return;
    }

    setState(() {
      selectedCategory = category;
      searchedKeyword = null;
      searchController.clear();
      isSearching = false;
    });

    getNews();
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;
      searchFocusNode.requestFocus();
    });
  }

  void closeSearch() {
    FocusScope.of(context).unfocus();

    setState(() {
      isSearching = false;
      searchedKeyword = null;
      searchController.clear();
    });

    getNews();
  }

  void searchNews() {
    final keyword = searchController.text.trim();

    if (keyword.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      searchedKeyword = keyword;
      isSearching = true;
    });

    getNews();
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

    await loadSavedNews();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.themeController,
        widget.languageController,
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          drawer: AppDrawer(
            themeController: widget.themeController,
            languageController: widget.languageController,
            onSavedPageClosed: loadSavedNews,
          ),
          appBar: _buildAppBar(theme, colors, isDark),
          body: RefreshIndicator(
            color: primaryColor,
            onRefresh: getNews,
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                if (searchedKeyword != null &&
                    searchedKeyword!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSearchResultHeader(theme, colors),
                  ),
                SliverToBoxAdapter(
                  child: _buildCategories(theme, colors, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionHeader(theme, colors, isDark),
                ),
                if (isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildLoadingState(colors),
                  )
                else if (errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(theme, colors, isDark),
                  )
                else if (newsList.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(theme, colors, isDark),
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
                                  bottom: 26.h,
                                ),
                                child: _buildFeaturedNews(
                                  news,
                                  theme,
                                  colors,
                                  isDark,
                                ),
                              );
                            }

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: 16.h,
                              ),
                              child: NewsCard(
                                news: news,
                                isSaved: savedNewsUrls.contains(news.url),
                                onSaveChanged: () {
                                  toggleBookmark(news);
                                },
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
                            text('latestStories'),
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 19.sp,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      ThemeData theme,
      ColorScheme colors,
      bool isDark,
      ) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leadingWidth: 62.w,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu_rounded,
              size: 31.sp,
              color: colors.onSurface,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      titleSpacing: 4.w,
      toolbarHeight: 76.h,
      title: AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: isSearching
            ? _buildSearchBar(theme, colors)
            : Row(
          key: ValueKey('normalAppBar'),
          children: [
            Expanded(
              child: Text(
                text('appName'),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colors.onSurface,
                ),
              ),
            ),
            _buildAppBarButton(
              icon: Icons.search_rounded,
              onTap: startSearch,
              theme: theme,
              colors: colors,
            ),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
      ThemeData theme,
      ColorScheme colors,
      ) {
    return Container(
      key: ValueKey('searchAppBar'),
      height: 46.h,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(
                  color: colors.outlineVariant,
                ),
              ),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  searchNews();
                },
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colors.onSurface,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: text('searchNews'),
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: colors.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: primaryColor,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: colors.onSurfaceVariant,
                    ),
                  )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.h,
                  ),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(width: 7.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: searchNews,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 20.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 7.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: closeSearch,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colors.outlineVariant,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colors,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colors.outlineVariant,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultHeader(
      ThemeData theme,
      ColorScheme colors,
      ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18.w,
        15.h,
        18.w,
        2.h,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 19.sp,
            color: primaryColor,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              '${text('resultsFor')} "$searchedKeyword"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(
      ThemeData theme,
      ColorScheme colors,
      bool isDark,
      ) {
    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
        ),
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) {
          return SizedBox(width: 8.w);
        },
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category &&
              searchedKeyword == null;

          return GestureDetector(
            onTap: () => selectCategory(category),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                    : null,
                color: isSelected ? null : theme.cardColor,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : isDark
                      ? Color(0xff2B2B30)
                      : Color(0xffE2E2E6),
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.18),
                    blurRadius: 12,
                    offset: Offset(0, 5),
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
                    categoryText(category),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : colors.onSurface,
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

  Widget _buildSectionHeader(
      ThemeData theme,
      ColorScheme colors,
      bool isDark,
      ) {
    final title = searchedKeyword != null &&
        searchedKeyword!.isNotEmpty
        ? text('searchResults')
        : selectedCategory == 'All'
        ? text('topStories')
        : categoryText(selectedCategory);

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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor,
                  secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(5.r),
            ),
          ),
          SizedBox(width: 9.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          Spacer(),
          if (!isLoading && newsList.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 5.h,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Color(0xff272238)
                    : Color(0xffF0EEFF),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${newsList.length} ${text('stories')}',
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

  Widget _buildFeaturedNews(
      NewsModel news,
      ThemeData theme,
      ColorScheme colors,
      bool isDark,
      ) {
    final isSaved = savedNewsUrls.contains(news.url);

    return GestureDetector(
      onTap: () {
        openDetails(news);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Color(0xff2B2B30)
                : Color(0xffE4E4E8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDark ? 0.20 : 0.045,
              ),
              blurRadius: 18,
              offset: Offset(0, 7),
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
                      return _buildImagePlaceholder(
                        theme,
                        colors,
                      );
                    },
                  )
                      : _buildImagePlaceholder(
                    theme,
                    colors,
                  ),
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
                      color: isDark
                          ? Color(0xff17171A).withOpacity(0.92)
                          : Colors.white.withOpacity(0.94),
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
                          text('featured'),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
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
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 43.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                secondaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          child: TextButton(
                            onPressed: () {
                              openDetails(news);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              text('readArticle'),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 9.w),
                      GestureDetector(
                        onTap: () {
                          toggleBookmark(news);
                        },
                        child: Container(
                          width: 43.w,
                          height: 43.w,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Color(0xff25232D)
                                : Color(0xffF1F0F8),
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          child: AnimatedSwitcher(
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
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              key: ValueKey(isSaved),
                              size: 21.sp,
                              color: primaryColor,
                            ),
                          ),
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

  Widget _buildImagePlaceholder(
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
          size: 42.sp,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colors) {
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

  Widget _buildErrorState(
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
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: isDark
                    ? Color(0xff272238)
                    : Color(0xffF0EEFF),
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
              text('unableToLoadNews'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              text('checkConnection'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.onSurfaceVariant,
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
                  text('tryAgain'),
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
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: isDark
                    ? Color(0xff272238)
                    : Color(0xffF0EEFF),
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
              searchedKeyword != null
                  ? text('noResultsFound')
                  : text('noNewsAvailable'),
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              searchedKeyword != null
                  ? text('tryAnotherKeyword')
                  : text('noStoriesRightNow'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}