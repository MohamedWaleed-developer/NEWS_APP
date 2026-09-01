import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';

class NewsCard extends StatefulWidget {
  final NewsModel news;

  const NewsCard({
    super.key,
    required this.news,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
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
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: const Color(0xffE7E7E7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: widget.news.urlToImage.isNotEmpty
          ? Image.network(
        widget.news.urlToImage,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Center(
            child: SizedBox(
              width: 26.w,
              height: 26.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.2.w,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildNoImage();
        },
      )
          : _buildNoImage(),
    );
  }

  Widget _buildNoImage() {
    return Container(
      color: const Color(0xffF4F4F2),
      padding: EdgeInsets.all(35.w),
      child: Lottie.asset(
        'assets/animation/no_news.json',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        14.h,
        12.w,
        10.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LATEST NEWS',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: const Color(0xff2E7D5B),
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            widget.news.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: const Color(0xff202020),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(
            height: 1.h,
            color: const Color(0xffEEEEEE),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: openNews,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  icon: Icon(
                    Icons.arrow_outward_rounded,
                    size: 18.sp,
                  ),
                  label: Text(
                    'Read Article',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: shareNews,
                tooltip: 'Share',
                splashRadius: 22.r,
                icon: Icon(
                  Icons.share_outlined,
                  size: 20.sp,
                  color: const Color(0xff444444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}