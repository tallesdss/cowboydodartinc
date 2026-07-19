import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Central icon registry for the kit.
///
/// Keep UI code using semantic names from this class so the icon pack can be
/// swapped in a single file in the future.
abstract final class KasyIcons {
  static const IconData add = LucideIcons.plus300;

  /// Decrement / remove (minus glyph) — pairs with [add].
  static const IconData minus = LucideIcons.minus300;

  /// Assistente / IA (sparkles).
  static const IconData assistant = LucideIcons.sparkles300;
  static const IconData arrowBack = LucideIcons.arrowLeft300;
  static const IconData arrowBackIos = LucideIcons.chevronLeft300;
  static const IconData arrowForwardIos = LucideIcons.chevronRight300;
  static const IconData arrowUp = LucideIcons.arrowUp300;
  static const IconData arrowDown = LucideIcons.arrowDown300;
  static const IconData chevronUp = LucideIcons.chevronUp300;
  static const IconData chevronUpBold = LucideIcons.chevronUp400;
  static const IconData voteUp = LucideIcons.chevronUp400;
  static const IconData book = LucideIcons.book300;
  static const IconData calendar = LucideIcons.calendar300;

  /// Dashboard / grid of panels.
  static const IconData dashboard = LucideIcons.layoutDashboard300;

  /// Bar chart — analytics / reports.
  static const IconData analytics = LucideIcons.barChart3300;

  /// Folder — projects / collections.
  static const IconData folder = LucideIcons.folder300;

  /// Briefcase — recruitment / jobs.
  static const IconData briefcase = LucideIcons.briefcase300;

  /// Flag — activity / milestones.
  static const IconData flag = LucideIcons.flag300;

  /// Two people — shared / team.
  static const IconData users = LucideIcons.usersRound300;

  /// Shield with check — privacy / verified.
  static const IconData shieldCheck = LucideIcons.shieldCheck300;

  /// Speech bubble — chat / conversations.
  static const IconData chat = LucideIcons.messageCircle300;

  /// Newspaper — news.
  static const IconData newspaper = LucideIcons.newspaper300;

  /// Collapse the left panel (sidebar) — narrow/expand toggle.
  static const IconData panelLeft = LucideIcons.panelLeft300;

  /// Hamburger — opens the navigation drawer (e.g. from an app-bar leading).
  static const IconData menu = LucideIcons.menu300;
  static const IconData cameraAlt = LucideIcons.camera400;
  static const IconData check = LucideIcons.check300;
  static const IconData checkCircle = LucideIcons.circleCheck300;
  static const IconData edit = LucideIcons.squarePen300;
  static const IconData chevronRight = LucideIcons.chevronRight300;
  static const IconData chevronDown = LucideIcons.chevronDown300;
  static const IconData close = LucideIcons.x300;
  static const IconData copy = LucideIcons.copy300;
  static const IconData darkMode = LucideIcons.moon300;
  static const IconData error = LucideIcons.circleAlert300;
  static const IconData eye = LucideIcons.eye300;
  static const IconData eyeOff = LucideIcons.eyeOff300;
  static const IconData favorite = LucideIcons.heart300;
  static const IconData favoriteOutline = LucideIcons.heartOff300;

  /// List filter (funnel) — dropdown filters, subscriber toggles.
  static const IconData filter = LucideIcons.listFilter300;

  /// Filled heart (uses a Material glyph alongside Lucide when a fill is needed).
  static const IconData favoriteFilled = Icons.favorite_rounded;
  static const IconData flash = LucideIcons.zap300;
  static const IconData idea = LucideIcons.lightbulb300;
  static const IconData flashOff = LucideIcons.zapOff300;
  static const IconData flashlight = LucideIcons.flashlight300;
  static const IconData gallery = LucideIcons.images300;

  /// Image missing / failed to load.
  static const IconData imageOff = LucideIcons.imageOff300;
  static const IconData help = LucideIcons.circleQuestionMark300;
  static const IconData info = LucideIcons.info300;
  static const IconData home = LucideIcons.house300;
  static const IconData language = LucideIcons.languages300;
  static const IconData lightMode = LucideIcons.sun300;
  static const IconData logout = LucideIcons.logOut300;
  static const IconData download = LucideIcons.download300;
  static const IconData linkOutlined = LucideIcons.link300;
  static const IconData message = LucideIcons.messageSquare300;
  static const IconData monitor = LucideIcons.monitor300;
  static const IconData moreVert = LucideIcons.ellipsisVertical300;
  static const IconData microphone = LucideIcons.mic300;
  static const IconData northEast = LucideIcons.arrowUpRight300;
  // NOTE: the `bell300` glyph in lucide_icons_flutter 3.1.14+2 is corrupted in the
  // Lucide300 weight font — it renders FILLED instead of outline (the same font
  // renders every other 300 icon correctly). Use the base `bell` (primary Lucide
  // font), which is a proper outline bell, so it matches the rest of the linear set.
  static const IconData notification = LucideIcons.bell;
  static const IconData notificationActive = LucideIcons.bellRing300;
  static const IconData notificationAdd = LucideIcons.bellPlus300;
  static const IconData notificationOff = LucideIcons.bellOff300;
  static const IconData note = LucideIcons.notebook300;
  static const IconData packageOutline = LucideIcons.package300;
  static const IconData payment = LucideIcons.wallet300;
  static const IconData palette = LucideIcons.palette300;
  static const IconData trash = LucideIcons.trash300;
  static const IconData person = LucideIcons.userRound300;
  static const IconData phone = LucideIcons.phone300;
  static const IconData phoneAndroid = LucideIcons.smartphone300;
  static const IconData fingerprint = LucideIcons.fingerprintPattern300;
  static const IconData privacy = LucideIcons.shieldAlert300;
  static const IconData refresh = LucideIcons.refreshCw300;
  static const IconData search = LucideIcons.search300;

  /// Busca sem resultado (lupa com «x») — estados vazios de pesquisa.
  static const IconData searchEmpty = LucideIcons.searchX300;
  static const IconData security = LucideIcons.shield300;
  static const IconData send = LucideIcons.send300;

  /// Compartilhar (Lucide «share» peso 300).
  static const IconData share = LucideIcons.share300;
  static const IconData settings = LucideIcons.settings300;
  static const IconData sms = LucideIcons.messagesSquare300;
  static const IconData shoppingBag = LucideIcons.shoppingBag300;
  static const IconData star = LucideIcons.star300;
  static const IconData time = LucideIcons.clock300;
  static const IconData ticket = LucideIcons.ticket300;
  static const IconData upload = LucideIcons.upload300;
  static const IconData video = LucideIcons.video300;
  static const IconData widgets = LucideIcons.component300;

  /// Device frame visible / hidden (web device preview chrome).
  static const IconData deviceFrame = LucideIcons.smartphone300;
  static const IconData deviceFrameOff = LucideIcons.scan300;

  /// Screen orientation (web device preview chrome).
  static const IconData landscape = LucideIcons.rectangleHorizontal300;
  static const IconData portrait = LucideIcons.rectangleVertical300;

  /// Element inspector pick tool (web device preview chrome).
  static const IconData inspector = LucideIcons.squareDashedMousePointer300;
}
