import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  String _s(String ar, String en) => isArabic ? ar : en;

  // ── General ──
  String get appName => 'TO Best';
  String get tagline => _s('نظام تدريب رياضي احترافي', 'Professional Training System');
  String get save => _s('حفظ', 'Save');
  String get cancel => _s('إلغاء', 'Cancel');
  String get back => _s('رجوع', 'Back');
  String get loading => _s('جاري التحميل...', 'Loading...');
  String get error => _s('حدث خطأ', 'An error occurred');
  String get success => _s('تم بنجاح', 'Success');
  String get confirm => _s('تأكيد', 'Confirm');
  String get yes => _s('نعم', 'Yes');
  String get no => _s('لا', 'No');
  String get ok => _s('موافق', 'OK');
  String get close => _s('إغلاق', 'Close');
  String get edit => _s('تعديل', 'Edit');
  String get delete => _s('حذف', 'Delete');
  String get add => _s('إضافة', 'Add');
  String get search => _s('بحث', 'Search');
  String get refresh => _s('تحديث', 'Refresh');
  String get submit => _s('إرسال', 'Submit');
  String get share => _s('مشاركة', 'Share');
  String get optional => _s('اختياري', 'Optional');
  String get required => _s('مطلوب', 'Required');
  String get more => _s('المزيد', 'More');
  String get connFail => _s('فشل الاتصال', 'Connection failed');
  String get noData => _s('لا توجد بيانات', 'No data');

  // ── Auth ──
  String get login => _s('تسجيل الدخول', 'Login');
  String get loginBtn => _s('دخول', 'Sign In');
  String get logout => _s('تسجيل الخروج', 'Logout');
  String get register => _s('إنشاء حساب', 'Register');
  String get registerBtn => _s('إنشاء الحساب', 'Create Account');
  String get email => _s('البريد الإلكتروني', 'Email');
  String get password => _s('كلمة المرور', 'Password');
  String get confirmPass => _s('تأكيد كلمة المرور', 'Confirm Password');
  String get fullName => _s('الاسم الكامل', 'Full Name');
  String get phone => _s('رقم الهاتف', 'Phone Number');
  String get changePassword => _s('تغيير كلمة المرور', 'Change Password');
  String get forgotPassword => _s('نسيت كلمة المرور؟', 'Forgot password?');
  String get pendingApproval => _s('في انتظار الموافقة', 'Pending Approval');
  String get pendingDesc => _s('حسابك قيد المراجعة. سيتم إخطارك فور الموافقة.', 'Your account is under review. You will be notified upon approval.');
  String get rejected => _s('تم رفض الطلب', 'Request Rejected');
  String get rejectedDesc => _s('تواصل مع المدرب لمزيد من المعلومات.', 'Contact your coach for more information.');
  String get googleSheets => _s('إعداد الاتصال', 'Connection Setup');
  String get webAppUrl => _s('رابط WebApp', 'WebApp URL');
  String get secretKey => _s('مفتاح الأمان', 'Secret Key');
  String get testConnection => _s('اختبار الاتصال', 'Test Connection');
  String get connectionSettings => _s('إعدادات الاتصال', 'Connection Settings');

  // ── Navigation ──
  String get home => _s('الرئيسية', 'Home');
  String get workout => _s('التمرين', 'Workout');
  String get nutrition => _s('التغذية', 'Nutrition');
  String get attendance => _s('الحضور', 'Attendance');
  String get progress => _s('التقدم', 'Progress');
  String get chat => _s('المحادثات', 'Chat');
  String get settings => _s('الإعدادات', 'Settings');
  String get admin => _s('الإدارة', 'Admin');
  String get profile => _s('الملف الشخصي', 'Profile');

  // ── Home ──
  String get greeting_morning => _s('صباح الخير 🌅', 'Good Morning 🌅');
  String get greeting_afternoon => _s('مساء الخير ☀️', 'Good Afternoon ☀️');
  String get greeting_evening => _s('مساء النور 🌙', 'Good Evening 🌙');
  String get todaySession => _s('تمرين اليوم', "Today's Session");
  String get noSession => _s('يوم راحة 😴', 'Rest Day 😴');
  String get quickAccess => _s('وصول سريع', 'Quick Access');
  String get latestPRs => _s('أحدث الأرقام القياسية', 'Latest PRs');
  String get noPRs => _s('لا توجد أرقام قياسية', 'No PRs Yet');
  String get noPRsDesc => _s('ابدأ التمرين لتسجيل أرقامك القياسية', 'Start training to record your PRs');
  String get totalSessions => _s('الجلسات', 'Sessions');
  String get streak => _s('التتالي 🔥', 'Streak 🔥');
  String get daysPerWeek => _s('أيام/أسبوع', 'days/week');

  // ── Workout ──
  String get startWorkout => _s('بدء التمرين', 'Start Workout');
  String get finishSession => _s('إنهاء الجلسة ✓', 'Finish Session ✓');
  String get warmupProtocol => _s('الإحماء', 'Warm-up Protocol');
  String get warmupDone => _s('تم الإحماء ✓', 'Warmup Done ✓');
  String get weight => _s('الوزن', 'Weight');
  String get reps => _s('التكرارات', 'Reps');
  String get sets => _s('المجموعات', 'Sets');
  String get rest => _s('الراحة', 'Rest');
  String get startRest => _s('ابدأ الراحة', 'Start Rest');
  String get stopRest => _s('أوقف', 'Stop');
  String get kg => _s('كجم', 'kg');
  String get min => _s('دقيقة', 'min');
  String get recentSessions => _s('آخر الجلسات', 'Recent Sessions');
  String get workoutSettings => _s('إعدادات التمرين', 'Workout Settings');
  String get showOldValues => _s('إظهار القيم السابقة', 'Show Previous Values');
  String get wakeLock => _s('إبقاء الشاشة مضاءة', 'Keep Screen Awake');

  // ── Nutrition ──
  String get calories => _s('السعرات', 'Calories');
  String get protein => _s('البروتين', 'Protein');
  String get carbs => _s('الكربوهيدرات', 'Carbs');
  String get fat => _s('الدهون', 'Fat');
  String get fiber => _s('الألياف', 'Fiber');
  String get addFood => _s('إضافة وجبة', 'Add Food');
  String get searchFood => _s('ابحث عن طعام...', 'Search food...');
  String get mealTime => _s('وقت الوجبة', 'Meal Time');
  String get breakfast => _s('الفطور', 'Breakfast');
  String get lunch => _s('الغداء', 'Lunch');
  String get dinner => _s('العشاء', 'Dinner');
  String get snack => _s('وجبة خفيفة', 'Snack');
  String get amount => _s('الكمية (جرام)', 'Amount (grams)');
  String get target => _s('الهدف', 'Target');
  String get consumed => _s('المستهلك', 'Consumed');
  String get remaining => _s('المتبقي', 'Remaining');
  String get noFoodToday => _s('لا توجد وجبات بعد', 'No food entries yet');
  String get waterTracker => _s('تتبع الماء 💧', 'Water Tracker 💧');
  String get waterGoal => _s('هدف الماء اليومي', 'Daily Water Goal');

  // ── Attendance ──
  String get gymDays => _s('أيام الجيم', 'Gym Days');
  String get absentDays => _s('الغياب', 'Absent');
  String get restDays => _s('الراحة', 'Rest');
  String get commitment => _s('الالتزام', 'Commitment');
  String get tapToMark => _s('اضغط على اليوم لتغيير الحالة', 'Tap a day to change status');
  String get gym => _s('جيم', 'Gym');
  String get absent => _s('غياب', 'Absent');
  String get restMark => _s('راحة', 'Rest');

  // ── Calendar weekday labels ──
  String get monS => _s('إث', 'Mo');
  String get tueS => _s('ثل', 'Tu');
  String get wedS => _s('أر', 'We');
  String get thuS => _s('خم', 'Th');
  String get friS => _s('جم', 'Fr');
  String get satS => _s('سب', 'Sa');
  String get sunS => _s('أح', 'Su');

  // ── Progress ──
  String get personalRecords => _s('الأرقام القياسية', 'Personal Records');
  String get bestVolume => _s('أفضل حجم', 'Best Volume');

  // ── Chat ──
  String get chatGeneral => _s('المجموعة العامة', 'General Group');
  String get chatGeneralDesc => _s('تحدث مع جميع أعضاء الفريق', 'Chat with all team members');
  String get chatAnnouncements => _s('الإعلانات', 'Announcements');
  String get chatAnnouncementsDesc => _s('أهم الأخبار والتحديثات', 'Important news and updates');
  String get chatCoach => _s('المدرب', 'Coach');
  String get chatCoachDesc => _s('تواصل مباشر مع مدربك', 'Direct contact with your coach');
  String get chatSupport => _s('الدعم', 'Support');
  String get chatSupportDesc => _s('مساعدة فنية وتقنية', 'Technical support');
  String get chatAI => _s('مساعد TO Best', 'TO Best AI');
  String get chatAIDesc => _s('مساعد ذكي لتحسين أدائك', 'AI assistant to improve your performance');
  String get typeMessage => _s('اكتب رسالة...', 'Type a message...');
  String get noMessages => _s('لا توجد رسائل بعد', 'No messages yet');

  // ── Settings ──
  String get appearance => _s('المظهر', 'Appearance');
  String get darkMode => _s('الوضع الداكن', 'Dark Mode');
  String get language => _s('اللغة', 'Language');
  String get leftHandMode => _s('وضع اليد اليسرى', 'Left-Hand Mode');
  String get about => _s('عن التطبيق', 'About');

  // ── Progress ──
  String get prs => _s('الأرقام القياسية', 'Personal Records');
  String get seeAll => _s('عرض الكل', 'See All');
  String get volume => _s('الحجم', 'Volume');
  String get maxWeight => _s('أعلى وزن', 'Max Weight');
  String get oneRM => _s('الـ 1RM', '1RM');
  String get progressChart => _s('مخطط التقدم', 'Progress Chart');
  String get noProgressData => _s('لا توجد بيانات تقدم بعد', 'No progress data yet');

  // ── Subscription ──
  String get subscription => _s('الاشتراك', 'Subscription');
  String get plans => _s('الخطط', 'Plans');
  String get promoCode => _s('كود الخصم', 'Promo Code');
  String get referral => _s('الإحالة', 'Referral');
  String get yourReferralCode => _s('كود الإحالة الخاص بك', 'Your Referral Code');
  String get referralCoins => _s('نقاط الإحالة', 'Referral Coins');
  String get paymentMethod => _s('طريقة الدفع', 'Payment Method');
  String get bankTransfer => _s('تحويل بنكي', 'Bank Transfer');
  String get submitRequest => _s('إرسال طلب الاشتراك', 'Submit Subscription Request');
  String get subRequested => _s('تم إرسال طلبك ✓', 'Request Submitted ✓');
  String get subPendingAdmin => _s('سيتم مراجعة طلبك قريباً', 'Your request will be reviewed soon');

  // ── Admin ──
  String get users => _s('المستخدمون', 'Users');
  String get pending => _s('قيد الانتظار', 'Pending');
  String get approve => _s('موافقة', 'Approve');
  String get reject => _s('رفض', 'Reject');
  String get ban => _s('حظر', 'Ban');
  String get unban => _s('رفع الحظر', 'Unban');
  String get assignProgram => _s('تعيين برنامج', 'Assign Program');
  String get subRequests => _s('طلبات الاشتراك', 'Subscription Requests');
  String get promoCodes => _s('أكواد الخصم', 'Promo Codes');
  String get guestCodes => _s('أكواد الضيف', 'Guest Codes');
  String get forceLogout => _s('تسجيل خروج قسري', 'Force Logout');
  String get banList => _s('قائمة الحظر', 'Ban List');
  String get referralStats => _s('إحصاء الإحالات', 'Referral Stats');
  String get adminDashboard => _s('لوحة الإدارة', 'Admin Dashboard');

  // ── Program names ──
  String get programUL => _s('أعلى / أسفل', 'Upper / Lower');
  String get programAP => _s('أمامي / خلفي', 'Anterior / Posterior');
  String get programFB => _s('جسم كامل', 'Full Body');
  String get programArnold => _s('أرنولد', 'Arnold');
  String get programPPL => _s('ضغط / شد / أرجل', 'Push / Pull / Legs');
  String get programCustom => _s('مخصص', 'Custom');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
