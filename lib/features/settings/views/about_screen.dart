import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'About SalesSphere',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            _buildSectionTitle('Transforming Field Sales, One Team at a Time'),
            SizedBox(height: 12.h),
            _buildParagraph(
              'SalesSphere was born from a simple observation: field sales teams are the backbone of countless businesses, yet they\'re often equipped with outdated tools and disconnected systems. We set out to change that.',
            ),
            SizedBox(height: 8.h),
            _buildParagraph(
              'Founded in 2025, SalesSphere has grown from a vision to revolutionize field sales operations into a comprehensive platform trusted by businesses across industries. We believe that every sales representative in the field deserves the same powerful tools and insights that headquarters enjoys.',
            ),
            SizedBox(height: 24.h),

            // Mission Section
            _buildSectionTitle('Our Mission', fontSize: 20),
            SizedBox(height: 12.h),
            _buildParagraph(
              'To empower field sales teams with intelligent, intuitive technology that transforms how businesses operate outside the office—driving growth, transparency, and success in every interaction.',
            ),
            SizedBox(height: 24.h),

            // What We Do Section
            _buildSectionTitle('What We Do', fontSize: 20),
            SizedBox(height: 12.h),
            _buildParagraph(
              'SalesSphere is the all-in-one field sales management platform that brings together everything your sales team needs to succeed:',
            ),
            SizedBox(height: 16.h),

            _buildSubsectionTitle('For Field Teams:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Real-time GPS tracking and route optimization'),
            _buildBulletPoint('Mobile order creation and management'),
            _buildBulletPoint('Automated attendance with GPS verification'),
            _buildBulletPoint('Instant access to product catalogs and pricing'),
            _buildBulletPoint('Offline functionality for seamless work'),
            SizedBox(height: 16.h),

            _buildSubsectionTitle('For Management:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Comprehensive analytics and performance dashboards'),
            _buildBulletPoint('Territory visibility and revenue trend analysis'),
            _buildBulletPoint('Stock management and inventory reconciliation'),
            _buildBulletPoint('Role-based access control'),
            _buildBulletPoint('Data-driven insights for strategic decisions'),
            SizedBox(height: 16.h),

            _buildSubsectionTitle('For Organizations:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Seamless integration with existing systems'),
            _buildBulletPoint('Scalable infrastructure that grows with you'),
            _buildBulletPoint('Enterprise-grade security and compliance'),
            _buildBulletPoint('AI-powered insights and automation'),
            _buildBulletPoint('Dedicated support and training'),
            SizedBox(height: 24.h),

            // Who We Serve Section
            _buildSectionTitle('Who We Serve', fontSize: 20),
            SizedBox(height: 12.h),
            _buildParagraph(
              'From emerging startups to established enterprises, SalesSphere powers field sales operations across diverse industries:',
            ),
            SizedBox(height: 12.h),
            _buildIndustryItem(
              'Pharmaceuticals',
              'Ensure compliance, track field visits, and manage sample distribution',
            ),
            _buildIndustryItem(
              'Manufacturing',
              'Connect factory to field with real-time stock updates and order processing',
            ),
            _buildIndustryItem(
              'Retail & Consumer Goods',
              'Optimize territory coverage and merchandising activities',
            ),
            SizedBox(height: 24.h),

            // Our Values Section
            _buildSectionTitle('Our Values', fontSize: 20),
            SizedBox(height: 12.h),
            _buildValueItem('Innovation First', 'We continuously evolve our platform with cutting-edge technology to stay ahead of market needs.'),
            _buildValueItem('Customer Success', 'Your growth is our success. We\'re committed to delivering measurable results and ROI.'),
            _buildValueItem('Transparency', 'From pricing to data analytics, we believe in complete visibility and honest communication.'),
            _buildValueItem('Simplicity', 'Powerful doesn\'t mean complicated. We design intuitive solutions that teams actually want to use.'),
            _buildValueItem('Reliability', 'Your business can\'t afford downtime. We ensure 99.9% uptime with enterprise-grade infrastructure.'),
            SizedBox(height: 24.h),

            // Why SalesSphere Section
            _buildSectionTitle('Why SalesSphere?', fontSize: 20),
            SizedBox(height: 12.h),
            _buildFeatureHighlight('Purpose-Built for Field Sales', 'Unlike generic CRM systems, SalesSphere is specifically engineered for the unique challenges of field operations.'),
            _buildFeatureHighlight('Data-Driven Decisions', 'Turn field data into actionable insights with our intuitive analytics dashboard and AI-powered recommendations.'),
            _buildFeatureHighlight('Quick Deployment', 'Get your team up and running in days, not months, with our streamlined onboarding process.'),
            _buildFeatureHighlight('Mobile-First Design', 'Built for the field, optimized for mobile, with offline capabilities that keep your team productive anywhere.'),
            _buildFeatureHighlight('Enterprise Security', 'Bank-level encryption, role-based access, and compliance with international data protection standards.'),
            _buildFeatureHighlight('Dedicated Support', 'Our customer success team is with you every step of the way, from implementation to optimization.'),
            SizedBox(height: 24.h),

            // Our Impact Section
            _buildSectionTitle('Our Impact', fontSize: 20),
            SizedBox(height: 12.h),
            _buildParagraph(
              'Since our inception, SalesSphere has helped businesses achieve:',
            ),
            SizedBox(height: 12.h),
            _buildImpactStat('40% improvement', 'in field sales productivity'),
            _buildImpactStat('35% reduction', 'in operational costs'),
            _buildImpactStat('50% faster', 'order-to-delivery cycles'),
            _buildImpactStat('99.9% system uptime', 'for uninterrupted operations'),
            _buildImpactStat('Thousands of field representatives', 'empowered daily'),
            SizedBox(height: 24.h),

            // Looking Forward Section
            _buildSectionTitle('Looking Forward', fontSize: 20),
            SizedBox(height: 12.h),
            _buildParagraph(
              'The future of field sales is intelligent, connected, and data-driven. At SalesSphere, we\'re not just keeping pace with this future—we\'re building it.',
            ),
            SizedBox(height: 8.h),
            _buildParagraph(
              'Our roadmap includes advanced AI capabilities, predictive analytics, IoT integrations, and deeper automation to make field sales operations even more efficient and effective.',
            ),
            SizedBox(height: 24.h),

            // Contact Section
            _buildSectionTitle('Contact Us', fontSize: 20),
            SizedBox(height: 12.h),
            _buildParagraph(
              'Have questions? Want to learn more? Our team is here to help.',
            ),
            SizedBox(height: 12.h),
            _buildContactItem(
              Icons.email_outlined,
              'info@salessphere360.com',
              'mailto:info@salessphere360.com',
            ),
            SizedBox(height: 8.h),
            _buildContactItem(
              Icons.language,
              'www.salessphere360.com',
              'https://www.salessphere360.com',
            ),
            SizedBox(height: 32.h),

            // Footer
            Center(
              child: Text(
                '© 2025 SalesSphere. All rights reserved.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double fontSize = 22}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h, right: 8.w),
            child: Container(
              width: 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryItem(String industry, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            industry,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlight(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h, right: 12.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.secondary,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStat(String stat, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h, right: 12.w),
            child: Icon(
              Icons.trending_up,
              color: AppColors.secondary,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: stat,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  TextSpan(
                    text: ' $description',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
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

  Widget _buildContactItem(IconData icon, String text, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.secondary,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
