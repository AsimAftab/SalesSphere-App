import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
          'Terms and Conditions',
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
            // Last Updated
            Text(
              'Last Updated: November 02, 2025',
              style: TextStyle(
                fontSize: 13.sp,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // 1. Introduction and Acceptance
            _buildSectionTitle('1. Introduction and Acceptance'),
            SizedBox(height: 12.h),
            _buildParagraph(
              'Welcome to SalesSphere. These Terms and Conditions ("Terms") govern your access to and use of the SalesSphere platform, including our website, mobile applications, and related services (collectively, the "Service").',
            ),
            SizedBox(height: 8.h),
            _buildParagraph(
              'By accessing or using SalesSphere, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use our Service.',
            ),
            SizedBox(height: 24.h),

            // 2. Definitions
            _buildSectionTitle('2. Definitions'),
            SizedBox(height: 12.h),
            _buildDefinition('"Service"', 'refers to the SalesSphere platform, including all features, applications, and tools.'),
            _buildDefinition('"User," "You," "Your"', 'refers to the individual or organization using the Service.'),
            _buildDefinition('"We," "Us," "Our"', 'refers to SalesSphere and its affiliates.'),
            _buildDefinition('"Account"', 'refers to your registered SalesSphere account.'),
            _buildDefinition('"Content"', 'refers to all data, information, and materials uploaded to the Service.'),
            SizedBox(height: 24.h),

            // 3. Service Description
            _buildSectionTitle('3. Service Description'),
            SizedBox(height: 12.h),
            _buildParagraph('SalesSphere provides a field sales management platform that includes:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('GPS tracking and route optimization'),
            _buildBulletPoint('Order management systems'),
            _buildBulletPoint('Attendance tracking'),
            _buildBulletPoint('Analytics and reporting tools'),
            _buildBulletPoint('Stock management features'),
            _buildBulletPoint('Role-based access control'),
            SizedBox(height: 8.h),
            _buildParagraph('We reserve the right to modify, suspend, or discontinue any part of the Service at any time with reasonable notice.'),
            SizedBox(height: 24.h),

            // 4. Account Registration and Eligibility
            _buildSectionTitle('4. Account Registration and Eligibility'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('4.1 Eligibility'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You must be at least 18 years old to use the Service'),
            _buildBulletPoint('You must have the legal authority to enter into these Terms'),
            _buildBulletPoint('You must provide accurate and complete registration information'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('4.2 Account Security'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You are responsible for maintaining the confidentiality of your account credentials'),
            _buildBulletPoint('You must notify us immediately of any unauthorized access'),
            _buildBulletPoint('You are responsible for all activities that occur under your account'),
            _buildBulletPoint('Sharing account credentials is prohibited'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('4.3 Account Information'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You must provide accurate, current, and complete information'),
            _buildBulletPoint('You must update your information promptly when it changes'),
            _buildBulletPoint('We reserve the right to suspend or terminate accounts with false information'),
            SizedBox(height: 24.h),

            // 5. User Responsibilities and Acceptable Use
            _buildSectionTitle('5. User Responsibilities and Acceptable Use'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('5.1 You Agree To:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Use the Service only for lawful purposes'),
            _buildBulletPoint('Comply with all applicable laws and regulations'),
            _buildBulletPoint('Respect intellectual property rights'),
            _buildBulletPoint('Maintain the security of your account'),
            _buildBulletPoint('Provide accurate data and information'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('5.2 You Agree NOT To:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Violate any laws or regulations'),
            _buildBulletPoint('Infringe on intellectual property rights'),
            _buildBulletPoint('Upload malicious code, viruses, or harmful software'),
            _buildBulletPoint('Attempt to gain unauthorized access to the Service'),
            _buildBulletPoint('Reverse engineer, decompile, or disassemble the software'),
            _buildBulletPoint('Use the Service to spam, harass, or harm others'),
            _buildBulletPoint('Scrape, mine, or extract data without permission'),
            _buildBulletPoint('Resell or redistribute the Service without authorization'),
            _buildBulletPoint('Interfere with or disrupt the Service or servers'),
            _buildBulletPoint('Impersonate others or misrepresent your affiliation'),
            SizedBox(height: 24.h),

            // 6. Subscription and Payment Terms
            _buildSectionTitle('6. Subscription and Payment Terms'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('6.1 Subscription Plans'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Various subscription tiers are available with different features'),
            _buildBulletPoint('Pricing is available on our website and may change with notice'),
            _buildBulletPoint('Subscriptions are billed in advance on a recurring basis'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('6.2 Payment'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You authorize us to charge your payment method for all fees'),
            _buildBulletPoint('All fees are non-refundable except as required by law'),
            _buildBulletPoint('You are responsible for all taxes associated with your use'),
            _buildBulletPoint('Failure to pay may result in service suspension or termination'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('6.3 Free Trials'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Free trials may be offered at our discretion'),
            _buildBulletPoint('We may require payment information before starting a trial'),
            _buildBulletPoint('Trials automatically convert to paid subscriptions unless cancelled'),
            _buildBulletPoint('One free trial per customer'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('6.4 Refund Policy'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Refunds are generally not provided except as required by law'),
            _buildBulletPoint('Requests must be submitted within 30 days of payment'),
            _buildBulletPoint('We reserve the right to approve or deny refund requests'),
            SizedBox(height: 24.h),

            // 7. Intellectual Property Rights
            _buildSectionTitle('7. Intellectual Property Rights'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('7.1 Our Rights'),
            SizedBox(height: 8.h),
            _buildBulletPoint('SalesSphere and all related trademarks, logos, and content are our property'),
            _buildBulletPoint('The Service, including its software, design, and features, is protected by copyright, trademark, and other laws'),
            _buildBulletPoint('You may not use our intellectual property without written permission'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('7.2 Your Rights'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You retain ownership of all content you upload to the Service'),
            _buildBulletPoint('You grant us a license to use, store, and process your content to provide the Service'),
            _buildBulletPoint('This license terminates when you delete content or close your account'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('7.3 Feedback'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Any feedback, suggestions, or ideas you provide become our property'),
            _buildBulletPoint('We may use feedback without compensation or attribution'),
            SizedBox(height: 24.h),

            // 8. License and Restrictions
            _buildSectionTitle('8. License and Restrictions'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('8.1 License Grant'),
            SizedBox(height: 8.h),
            _buildBulletPoint('We grant you a limited, non-exclusive, non-transferable license to use the Service'),
            _buildBulletPoint('This license is subject to these Terms and your subscription status'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('8.2 Restrictions'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You may not copy, modify, or create derivative works'),
            _buildBulletPoint('You may not rent, lease, or sublicense the Service'),
            _buildBulletPoint('You may not use the Service for competitive purposes'),
            _buildBulletPoint('You may not access the Service through automated means without permission'),
            SizedBox(height: 24.h),

            // 9. Data Privacy and Security
            _buildSectionTitle('9. Data Privacy and Security'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('9.1 Data Collection'),
            SizedBox(height: 8.h),
            _buildBulletPoint('We collect and process data as described in our Privacy Policy'),
            _buildBulletPoint('You are responsible for obtaining consent from your users/employees for data collection'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('9.2 Data Security'),
            SizedBox(height: 8.h),
            _buildBulletPoint('We implement reasonable security measures to protect your data'),
            _buildBulletPoint('However, no system is completely secure, and we cannot guarantee absolute security'),
            _buildBulletPoint('You are responsible for backing up your critical data'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('9.3 Data Ownership'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You own all data you input into the Service'),
            _buildBulletPoint('We do not sell your data to third parties'),
            _buildBulletPoint('Upon termination, you may export your data within 30 days'),
            SizedBox(height: 24.h),

            // 10. Third-Party Services and Integrations
            _buildSectionTitle('10. Third-Party Services and Integrations'),
            SizedBox(height: 8.h),
            _buildBulletPoint('The Service may integrate with third-party services'),
            _buildBulletPoint('We are not responsible for third-party services or their terms'),
            _buildBulletPoint('Your use of third-party services is subject to their terms and policies'),
            _buildBulletPoint('We do not endorse or guarantee third-party services'),
            SizedBox(height: 24.h),

            // 11. Warranties and Disclaimers
            _buildSectionTitle('11. Warranties and Disclaimers'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('11.1 Service Availability'),
            SizedBox(height: 8.h),
            _buildBulletPoint('We strive for 99.9% uptime but do not guarantee uninterrupted service'),
            _buildBulletPoint('Scheduled maintenance will be announced in advance when possible'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('11.2 Disclaimer of Warranties'),
            SizedBox(height: 8.h),
            _buildHighlightedText('THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Warranties of merchantability'),
            _buildBulletPoint('Fitness for a particular purpose'),
            _buildBulletPoint('Non-infringement'),
            _buildBulletPoint('Accuracy or reliability of results'),
            SizedBox(height: 8.h),
            _buildParagraph('We do not warrant that:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('The Service will be error-free or uninterrupted'),
            _buildBulletPoint('Defects will be corrected'),
            _buildBulletPoint('The Service is free from viruses or harmful components'),
            SizedBox(height: 24.h),

            // 12. Limitation of Liability
            _buildSectionTitle('12. Limitation of Liability'),
            SizedBox(height: 8.h),
            _buildHighlightedText('TO THE MAXIMUM EXTENT PERMITTED BY LAW:'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('12.1 We shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Loss of profits or revenue'),
            _buildBulletPoint('Loss of data'),
            _buildBulletPoint('Loss of business opportunities'),
            _buildBulletPoint('Business interruption'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('12.2'),
            _buildParagraph('Our total liability shall not exceed the amount you paid us in the 12 months preceding the claim.'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('12.3'),
            _buildParagraph('Some jurisdictions do not allow limitations on liability, so these limitations may not apply to you.'),
            SizedBox(height: 24.h),

            // 13. Indemnification
            _buildSectionTitle('13. Indemnification'),
            SizedBox(height: 8.h),
            _buildParagraph('You agree to indemnify, defend, and hold harmless SalesSphere, its officers, directors, employees, and agents from any claims, liabilities, damages, losses, and expenses (including legal fees) arising from:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Your use of the Service'),
            _buildBulletPoint('Your violation of these Terms'),
            _buildBulletPoint('Your violation of any rights of others'),
            _buildBulletPoint('Your content or data'),
            SizedBox(height: 24.h),

            // 14. Termination
            _buildSectionTitle('14. Termination'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('14.1 By You'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You may cancel your subscription at any time through your account settings'),
            _buildBulletPoint('Cancellation takes effect at the end of the current billing period'),
            _buildBulletPoint('No refunds for partial periods'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('14.2 By Us'),
            SizedBox(height: 8.h),
            _buildParagraph('We may suspend or terminate your account if:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You violate these Terms'),
            _buildBulletPoint('You fail to pay fees'),
            _buildBulletPoint('Your use poses a security risk'),
            _buildBulletPoint('Required by law'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('14.3 Effect of Termination'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Your right to use the Service immediately ceases'),
            _buildBulletPoint('You remain liable for any unpaid fees'),
            _buildBulletPoint('We may delete your data after 30 days'),
            _buildBulletPoint('Provisions that should survive termination will continue'),
            SizedBox(height: 24.h),

            // 15. Modifications to Terms
            _buildSectionTitle('15. Modifications to Terms'),
            SizedBox(height: 8.h),
            _buildBulletPoint('We may modify these Terms at any time'),
            _buildBulletPoint('We will notify you of material changes via email or Service notification'),
            _buildBulletPoint('Continued use after changes constitutes acceptance'),
            _buildBulletPoint('If you disagree with changes, you must stop using the Service'),
            SizedBox(height: 24.h),

            // 16. Governing Law and Dispute Resolution
            _buildSectionTitle('16. Governing Law and Dispute Resolution'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('16.1 Governing Law'),
            SizedBox(height: 8.h),
            _buildParagraph('These Terms shall be governed by and construed in accordance with the laws of Nepal, without regard to its conflict of law principles.'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('16.2 Jurisdiction'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Primary Jurisdiction: The courts of Morang District, Biratnagar, Nepal shall have primary jurisdiction over any disputes arising from these Terms.'),
            _buildBulletPoint('Appellate Jurisdiction: Appeals may be heard by the Biratnagar High Court, Province No. 1, Nepal.'),
            _buildBulletPoint('Final Jurisdiction: The Supreme Court of Nepal in Kathmandu shall have final appellate jurisdiction.'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('16.3 Dispute Resolution Process'),
            SizedBox(height: 8.h),
            _buildParagraph('Parties agree to follow this dispute resolution process:'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Good Faith Negotiations: The parties agree to first attempt to resolve any disputes through good faith negotiations within 30 days of a written notice of dispute.'),
            _buildBulletPoint('Mediation: If negotiations fail, the parties agree to attempt mediation through a mutually agreed mediator in Nepal before pursuing litigation.'),
            _buildBulletPoint('Arbitration (Optional): Parties may mutually agree to binding arbitration under the Nepal Arbitration Act, 2055 (1999), to be conducted in Biratnagar, Nepal.'),
            _buildBulletPoint('Litigation: If mediation or arbitration is unsuccessful or not pursued, either party may file a lawsuit in the appropriate court as specified in Section 16.2.'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('16.4 Class Action Waiver'),
            SizedBox(height: 8.h),
            _buildParagraph('You agree to resolve disputes individually and not as part of a class action or collective proceeding.'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('16.5 Language'),
            SizedBox(height: 8.h),
            _buildParagraph('English shall be the governing language of these Terms. In case of any translation, the English version shall prevail.'),
            SizedBox(height: 24.h),

            // 17. General Provisions
            _buildSectionTitle('17. General Provisions'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('17.1 Entire Agreement'),
            SizedBox(height: 8.h),
            _buildParagraph('These Terms constitute the entire agreement between you and SalesSphere'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('17.2 Severability'),
            SizedBox(height: 8.h),
            _buildParagraph('If any provision is found unenforceable, the remaining provisions remain in effect'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('17.3 Waiver'),
            SizedBox(height: 8.h),
            _buildParagraph('Failure to enforce any provision does not constitute a waiver'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('17.4 Assignment'),
            SizedBox(height: 8.h),
            _buildBulletPoint('You may not assign these Terms without our written consent'),
            _buildBulletPoint('We may assign these Terms without restriction'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('17.5 Force Majeure'),
            SizedBox(height: 8.h),
            _buildParagraph('We are not liable for delays or failures due to circumstances beyond our reasonable control, including but not limited to natural disasters, acts of God, government actions, civil unrest, telecommunications failures, or power outages'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('17.6 Notices'),
            SizedBox(height: 8.h),
            _buildBulletPoint('All notices under these Terms must be in writing'),
            _buildBulletPoint('Notices to SalesSphere should be sent to: info@salessphere360.com'),
            _buildBulletPoint('Notices to you will be sent to the email address associated with your account'),
            SizedBox(height: 24.h),

            // 18. Contact Information
            _buildSectionTitle('18. Contact Information'),
            SizedBox(height: 8.h),
            _buildParagraph('For questions about these Terms, please contact us:'),
            SizedBox(height: 8.h),
            _buildContactItem('Email:', 'info@salessphere360.com'),
            _buildContactItem('Website:', 'www.salessphere360.com'),
            _buildContactItem('Registered Address:', 'Biratnagar, Morang District, Province No. 1, Nepal'),
            SizedBox(height: 24.h),

            // 19. Specific Features and Services
            _buildSectionTitle('19. Specific Features and Services'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('19.1 GPS Tracking'),
            SizedBox(height: 8.h),
            _buildBulletPoint('GPS tracking features require device location permissions'),
            _buildBulletPoint('Users must comply with local privacy laws regarding employee tracking'),
            _buildBulletPoint('You are responsible for obtaining necessary consents from employees or field personnel'),
            _buildBulletPoint('GPS data is processed in accordance with Nepal\'s privacy regulations'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('19.2 Data Analytics'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Analytics are provided for informational purposes only'),
            _buildBulletPoint('We do not guarantee accuracy of analytics or reports'),
            _buildBulletPoint('Business decisions based on analytics are your sole responsibility'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('19.3 Mobile Applications'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Mobile app use is subject to applicable app store terms (Google Play Store, Apple App Store)'),
            _buildBulletPoint('Updates may be required for continued functionality'),
            _buildBulletPoint('Mobile data charges may apply based on your telecommunications provider'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('19.4 Stock Management'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Stock data accuracy depends on timely updates by users'),
            _buildBulletPoint('We are not liable for business losses due to stock discrepancies'),
            _buildBulletPoint('Users are responsible for reconciling physical inventory with system records'),
            SizedBox(height: 24.h),

            // 20. Compliance with Nepal Laws
            _buildSectionTitle('20. Compliance with Nepal Laws'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('20.1 Data Protection'),
            SizedBox(height: 8.h),
            _buildBulletPoint('We comply with applicable Nepal data protection regulations'),
            _buildBulletPoint('Personal data of Nepali citizens is handled in accordance with Nepal\'s privacy laws'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('20.2 Business Registration'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Users operating businesses must comply with Nepal\'s business registration and tax requirements'),
            _buildBulletPoint('SalesSphere does not provide tax or legal compliance advice'),
            SizedBox(height: 12.h),
            _buildSubsectionTitle('20.3 Employment Laws'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Users employing field personnel must comply with Nepal Labour Act and related employment regulations'),
            _buildBulletPoint('GPS tracking and attendance monitoring must comply with employee privacy rights under Nepal law'),
            SizedBox(height: 24.h),

            // Final Statement
            _buildHighlightedText('By using SalesSphere, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.'),
            SizedBox(height: 24.h),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Effective Date: November 02, 2025',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Version: 1.0',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
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
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
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

  Widget _buildDefinition(String term, String definition) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 8.w),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$term ',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            TextSpan(
              text: definition,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
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
}
