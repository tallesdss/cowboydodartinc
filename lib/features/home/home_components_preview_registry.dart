import 'package:bart/bart/bart_model.dart';
import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/features/home/home_components_preview_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Previews only instantiate the kit's public widgets (`components.dart` +
/// theme). Rows / scroll / spacing are just showcase layout;
/// visual behavior comes from the component's props (e.g. `KasyAccordion.surfaceRadius`,
/// `KasyButton.borderRadius`). Optional presets: [KasyAvatarGradients],
/// [KasyAvatarDemoPhotos] (avatar package).
class ComponentPreviewDefinition {
  final String title;
  final List<ComponentPreviewVariant> variants;

  const ComponentPreviewDefinition({
    required this.title,
    required this.variants,
  });
}

ComponentPreviewDefinition? getComponentPreviewDefinition(
  String componentName,
) {
  switch (componentName) {
    case 'Accordion':
      return const ComponentPreviewDefinition(
        title: 'Accordion',
        variants: [
          ComponentPreviewVariant(
            label: 'Default variant',
            builder: _buildAccordionDefaultVariant,
          ),
          ComponentPreviewVariant(
            label: 'Surface variant',
            builder: _buildAccordionSurfaceVariant,
          ),
          ComponentPreviewVariant(
            label: 'Multiple expansion',
            builder: _buildAccordionElevatedCardVariant,
          ),
        ],
      );
    case 'Alert':
      return const ComponentPreviewDefinition(
        title: 'Alert',
        variants: [
          ComponentPreviewVariant(
            label: 'Default & Primary',
            builder: _buildAlertDefaultPrimaryVariant,
          ),
          ComponentPreviewVariant(
            label: 'Success, Warning, Danger',
            builder: _buildAlertSemanticVariant,
          ),
          ComponentPreviewVariant(
            label: 'With buttons',
            builder: _buildAlertWithButtonsVariant,
          ),
          ComponentPreviewVariant(
            label: 'With custom indicator',
            builder: _buildAlertLoadingVariant,
          ),
        ],
      );
    case 'AppBar':
      return const ComponentPreviewDefinition(
        title: 'AppBar',
        variants: [
          // Phone / tablet — the page chrome (title + back + orbs).
          ComponentPreviewVariant(
            label: 'Subpage (mobile)',
            builder: _buildAppBarSubpageVariant,
          ),
          ComponentPreviewVariant(
            label: 'Subpage Simple (mobile)',
            builder: _buildAppBarSubpageSimpleVariant,
          ),
          ComponentPreviewVariant(
            label: 'Subpage Actions (mobile)',
            builder: _buildAppBarSubpageActionsVariant,
          ),
          ComponentPreviewVariant(
            label: 'Menu opens sidebar (mobile)',
            builder: _buildAppBarMenuVariant,
          ),
          // Desktop — the application chrome (search + actions + profile).
          ComponentPreviewVariant(
            label: 'Application (desktop)',
            builder: _buildAppBarApplicationVariant,
          ),
          ComponentPreviewVariant(
            label: 'Application + notification (desktop)',
            builder: _buildAppBarApplicationBadgeVariant,
          ),
          ComponentPreviewVariant(
            label: 'Application no avatar (desktop)',
            builder: _buildAppBarApplicationNoAvatarVariant,
          ),
          // Per-screen presets — same bar, a screen picking its own chrome.
          ComponentPreviewVariant(
            label: 'Search only (desktop)',
            builder: _buildAppBarApplicationSearchOnlyVariant,
          ),
          ComponentPreviewVariant(
            label: 'Notifications only (desktop)',
            builder: _buildAppBarApplicationNotificationsOnlyVariant,
          ),
        ],
      );
    case 'Breadcrumbs':
      return const ComponentPreviewDefinition(
        title: 'Breadcrumbs',
        variants: [
          ComponentPreviewVariant(
            label: 'Levels',
            builder: _buildBreadcrumbsLevels,
          ),
          ComponentPreviewVariant(
            label: 'Interactive',
            builder: _buildBreadcrumbsInteractive,
          ),
        ],
      );
    case 'Button':
      return const ComponentPreviewDefinition(
        title: 'Button',
        variants: [
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildButtonSizesVariant,
          ),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildButtonVariantsVariant,
          ),
          ComponentPreviewVariant(
            label: 'Hover fill effect',
            builder: _buildButtonHoverFillVariant,
          ),
          ComponentPreviewVariant(
            label: 'Disabled state',
            builder: _buildButtonDisabledStateVariant,
          ),
          ComponentPreviewVariant(
            label: 'Width/alignment control',
            builder: _buildButtonWidthAlignmentVariant,
          ),
          ComponentPreviewVariant(
            label: 'With icons',
            builder: _buildButtonWithIconsVariant,
          ),
          ComponentPreviewVariant(
            label: 'Icon only',
            builder: _buildButtonIconOnlyVariant,
          ),
          ComponentPreviewVariant(
            label: 'Custom styling',
            builder: _buildButtonCustomStylingVariant,
          ),
          ComponentPreviewVariant(
            label: 'Custom palette hover',
            builder: _buildButtonCustomPaletteHoverVariant,
          ),
          ComponentPreviewVariant(
            label: 'Layout transitions demo',
            builder: _buildButtonLayoutTransitionsVariant,
          ),
        ],
      );
    case 'BottomSheet':
      return const ComponentPreviewDefinition(
        title: 'BottomSheet',
        variants: [
          ComponentPreviewVariant(
            label: 'Basic',
            builder: _buildBottomSheetBasic,
          ),
          ComponentPreviewVariant(
            label: 'Tones',
            builder: _buildBottomSheetTones,
          ),
          ComponentPreviewVariant(
            label: 'Choice list',
            builder: _buildBottomSheetChoiceList,
          ),
          ComponentPreviewVariant(
            label: 'Form',
            builder: _buildBottomSheetForm,
          ),
          ComponentPreviewVariant(
            label: 'Detached',
            builder: _buildBottomSheetDetached,
          ),
          ComponentPreviewVariant(
            label: 'With blur overlay',
            builder: _buildBottomSheetBlurOverlay,
          ),
          ComponentPreviewVariant(
            label: 'Scrollable with snap points',
            builder: _buildBottomSheetScrollableSnap,
          ),
          ComponentPreviewVariant(
            label: 'Page sheet',
            builder: _buildBottomSheetNativeModal,
          ),
          ComponentPreviewVariant(
            label: 'Bottom sheet with text field',
            builder: _buildBottomSheetTextInput,
          ),
          ComponentPreviewVariant(
            label: 'Scrollable',
            builder: _buildBottomSheetScrollable,
          ),
          ComponentPreviewVariant(
            label: 'OTP verification',
            builder: _buildBottomSheetOtpVerification,
          ),
          ComponentPreviewVariant(
            label: 'PIN verification',
            builder: _buildBottomSheetPinVerification,
          ),
        ],
      );
    case 'Calendar':
      return const ComponentPreviewDefinition(
        title: 'Calendar',
        variants: [
          // Calendar "types" — present / future / years — shown separately so
          // each structural variant reads on its own (Figma Calendar Types).
          ComponentPreviewVariant(
            label: 'Present',
            builder: _buildCalendarPresent,
          ),
          ComponentPreviewVariant(
            label: 'Future',
            builder: _buildCalendarFuture,
          ),
          ComponentPreviewVariant(
            label: 'Years',
            builder: _buildCalendarYears,
          ),
          ComponentPreviewVariant(
            label: 'With events',
            builder: _buildCalendarEvents,
          ),
          ComponentPreviewVariant(
            label: 'Range selection',
            builder: _buildCalendarRange,
          ),
          ComponentPreviewVariant(
            label: 'Time selection',
            builder: _buildCalendarTime,
          ),
          ComponentPreviewVariant(
            label: 'Top + bottom content',
            builder: _buildCalendarComposed,
          ),
          ComponentPreviewVariant(
            label: 'Mobile (drag handle)',
            builder: _buildCalendarMobile,
          ),
          ComponentPreviewVariant(
            label: 'Min / max',
            builder: _buildCalendarBounded,
          ),
          // Multi-month is a wide-canvas layout; the builder falls back to an
          // explainer card on narrow viewports, so it sits last.
          ComponentPreviewVariant(
            label: 'Multi-month',
            builder: _buildCalendarMultiMonth,
          ),
        ],
      );
    case 'Card':
      return const ComponentPreviewDefinition(
        title: 'Card',
        variants: [
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildCardVariants,
          ),
          ComponentPreviewVariant(
            label: 'Product card',
            builder: _buildCardProduct,
          ),
          ComponentPreviewVariant(
            label: 'Community cards',
            builder: _buildCardCommunity,
          ),
          ComponentPreviewVariant(
            label: 'Event list',
            builder: _buildCardEventList,
          ),
          ComponentPreviewVariant(label: 'Hero card', builder: _buildCardHero),
          ComponentPreviewVariant(
            label: 'Spotlight icon',
            builder: _buildCardSpotlightIcon,
          ),
          ComponentPreviewVariant(
            label: 'Spotlight media',
            builder: _buildCardSpotlightMedia,
          ),
          ComponentPreviewVariant(
            label: 'Interactive',
            builder: _buildCardInteractiveAll,
          ),
        ],
      );
    case 'Checkbox':
      return const ComponentPreviewDefinition(
        title: 'Checkbox',
        variants: [
          ComponentPreviewVariant(
            label: 'Basic usage',
            builder: _buildCheckboxBasicUsage,
          ),
          ComponentPreviewVariant(
            label: 'States',
            builder: _buildCheckboxStates,
          ),
          ComponentPreviewVariant(
            label: 'Custom styles',
            builder: _buildCheckboxCustomStyles,
          ),
        ],
      );
    case 'Chip':
      return const ComponentPreviewDefinition(
        title: 'Chip',
        variants: [
          ComponentPreviewVariant(
            label: 'Types',
            builder: _buildChipTypes,
          ),
          ComponentPreviewVariant(
            label: 'Status (with dot)',
            builder: _buildChipStatus,
          ),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildChipVariants,
          ),
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildChipSizes,
          ),
          ComponentPreviewVariant(
            label: 'With prefix & suffix',
            builder: _buildChipIcons,
          ),
          ComponentPreviewVariant(
            label: 'Removable tags',
            builder: _buildChipRemovable,
          ),
        ],
      );
    case 'DatePicker':
      return const ComponentPreviewDefinition(
        title: 'DatePicker',
        variants: [
          ComponentPreviewVariant(
            label: 'Presentations',
            builder: _buildDatePickerPresentations,
          ),
          ComponentPreviewVariant(
            label: 'Range selection',
            builder: _buildDatePickerRange,
          ),
          ComponentPreviewVariant(
            label: 'Date formats',
            builder: _buildDatePickerFormats,
          ),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildDatePickerVariants,
          ),
          ComponentPreviewVariant(
            label: 'Field states',
            builder: _buildDatePickerFieldStates,
          ),
          // Multi-month last — it's a desktop-only opt-in layout and the
          // preview itself falls back to an explainer card on mobile, so
          // keeping it at the end avoids burying the main use cases.
          ComponentPreviewVariant(
            label: 'Multi-month',
            builder: _buildDatePickerMultiMonth,
          ),
        ],
      );
    case 'TimePicker':
      return const ComponentPreviewDefinition(
        title: 'TimePicker',
        variants: [
          ComponentPreviewVariant(
            label: 'Presentations',
            builder: _buildTimePickerPresentations,
          ),
          ComponentPreviewVariant(
            label: '24-hour with interval',
            builder: _buildTimePickerInterval,
          ),
          ComponentPreviewVariant(
            label: 'Custom format',
            builder: _buildTimePickerCustomFormat,
          ),
          ComponentPreviewVariant(
            label: 'Field states',
            builder: _buildTimePickerFieldStates,
          ),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildTimePickerVariants,
          ),
        ],
      );
    case 'Dialog':
      return const ComponentPreviewDefinition(
        title: 'Dialog',
        variants: [
          ComponentPreviewVariant(
            label: 'Basic dialog',
            builder: _buildDialogBasic,
          ),
          ComponentPreviewVariant(
            label: 'Dialog with blur backdrop',
            builder: _buildDialogBlurBackdrop,
          ),
          ComponentPreviewVariant(
            label: 'Dialog with TextField',
            builder: _buildDialogTextInput,
          ),
          ComponentPreviewVariant(
            label: 'Dialog with long content',
            builder: _buildDialogLongContent,
          ),
        ],
      );
    case 'DropDown':
      return const ComponentPreviewDefinition(
        title: 'DropDown',
        variants: [
          ComponentPreviewVariant(
            label: 'Basic',
            builder: _buildDropDownBasic,
          ),
          ComponentPreviewVariant(
            label: 'With icons & subtitles',
            builder: _buildDropDownRich,
          ),
          ComponentPreviewVariant(
            label: 'Multiple selection',
            builder: _buildDropDownMulti,
          ),
          ComponentPreviewVariant(
            label: 'Searchable',
            builder: _buildDropDownSearchable,
          ),
          ComponentPreviewVariant(
            label: 'States',
            builder: _buildDropDownStates,
          ),
        ],
      );
    case 'Menu':
      return const ComponentPreviewDefinition(
        title: 'Menu',
        variants: [
          ComponentPreviewVariant(
            label: 'Basic usage',
            builder: _buildMenuBasicUsage,
          ),
          ComponentPreviewVariant(
            label: 'Selection',
            builder: _buildMenuStyles,
          ),
          ComponentPreviewVariant(label: 'Submenu', builder: _buildMenuSubmenu),
          ComponentPreviewVariant(
            label: 'Edge alignment',
            builder: _buildMenuEdges,
          ),
          ComponentPreviewVariant(
            label: 'Opens upward',
            builder: _buildMenuFlipUp,
          ),
          ComponentPreviewVariant(
            label: 'Trailing content',
            builder: _buildMenuTrailing,
          ),
        ],
      );
    case 'Badge':
      return const ComponentPreviewDefinition(
        title: 'Badge',
        variants: [
          ComponentPreviewVariant(
            label: 'Default',
            builder: _buildBadgeDefault,
          ),
          ComponentPreviewVariant(label: 'Colors', builder: _buildBadgeColors),
          ComponentPreviewVariant(label: 'Sizes', builder: _buildBadgeSizes),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildBadgeVariants,
          ),
          ComponentPreviewVariant(
            label: 'Placements',
            builder: _buildBadgePlacements,
          ),
          ComponentPreviewVariant(label: 'Dot badge', builder: _buildBadgeDot),
          ComponentPreviewVariant(
            label: 'With content',
            builder: _buildBadgeWithContent,
          ),
        ],
      );
    case 'Status Tag':
      return const ComponentPreviewDefinition(
        title: 'Status Tag',
        variants: [
          ComponentPreviewVariant(
            label: 'Tones',
            builder: _buildStatusTagTones,
          ),
          ComponentPreviewVariant(
            label: 'Without dot',
            builder: _buildStatusTagNoDot,
          ),
          ComponentPreviewVariant(
            label: 'In a row',
            builder: _buildStatusTagInRow,
          ),
        ],
      );
    case 'TextField':
      return const ComponentPreviewDefinition(
        title: 'TextField',
        variants: [
          ComponentPreviewVariant(
            label: 'Default',
            builder: _buildBasicTextFieldVariant,
          ),
          ComponentPreviewVariant(
            label: 'Label & Description',
            builder: _buildTextFieldWithLabelDescriptionVariant,
          ),
          ComponentPreviewVariant(
            label: 'Standard',
            builder: _buildTextFieldStandard,
          ),
          ComponentPreviewVariant(
            label: 'Character Limit',
            builder: _buildTextFieldCharacterLimit,
          ),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildTextFieldVariantsVariant,
          ),
          ComponentPreviewVariant(
            label: 'States',
            builder: _buildTextFieldStates,
          ),
          ComponentPreviewVariant(
            label: 'With Icons',
            builder: _buildTextFieldWithIcon,
          ),
          ComponentPreviewVariant(
            label: 'Multiline',
            builder: _buildTextFieldMultiline,
          ),
        ],
      );
    case 'TextArea':
      return const ComponentPreviewDefinition(
        title: 'TextArea',
        variants: [
          ComponentPreviewVariant(
            label: 'Basic TextArea',
            builder: _buildTextAreaBasic,
          ),
          ComponentPreviewVariant(
            label: 'With Label & Description',
            builder: _buildTextAreaWithLabelDescription,
          ),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildTextAreaVariants,
          ),
          ComponentPreviewVariant(
            label: 'States',
            builder: _buildTextAreaStates,
          ),
        ],
      );
    case 'TextFieldOTP':
      return const ComponentPreviewDefinition(
        title: 'TextFieldOTP',
        variants: [
          ComponentPreviewVariant(
            label: 'Default',
            builder: _buildTextFieldOTPDefault,
          ),
          ComponentPreviewVariant(
            label: 'Error',
            builder: _buildTextFieldOTPError,
          ),
          ComponentPreviewVariant(
            label: 'Four Digits',
            builder: _buildTextFieldOTPFourDigits,
          ),
          ComponentPreviewVariant(
            label: 'With Placeholder',
            builder: _buildTextFieldOTPWithPlaceholder,
          ),
          ComponentPreviewVariant(
            label: 'Disabled',
            builder: _buildTextFieldOTPDisabled,
          ),
          ComponentPreviewVariant(
            label: 'With Pattern',
            builder: _buildTextFieldOTPWithPattern,
          ),
          ComponentPreviewVariant(
            label: 'Custom Styles',
            builder: _buildTextFieldOTPCustomStyles,
          ),
          ComponentPreviewVariant(
            label: 'With bottom sheet',
            builder: _buildTextFieldOTPBottomSheet,
          ),
        ],
      );
    case 'Toast':
      return const ComponentPreviewDefinition(
        title: 'Toast',
        variants: [
          ComponentPreviewVariant(
            label: 'Default variants',
            builder: _buildToastDefaultVariants,
          ),
          ComponentPreviewVariant(
            label: 'Placement variants',
            builder: _buildToastPlacementVariants,
          ),
          ComponentPreviewVariant(
            label: 'From native modal',
            builder: _buildToastModalPreview,
          ),
          ComponentPreviewVariant(
            label: 'Custom toasts',
            builder: _buildToastCustomVariants,
          ),
          ComponentPreviewVariant(
            label: 'Static preview',
            builder: _buildToastStaticPreview,
          ),
        ],
      );
    case 'Avatar':
      return const ComponentPreviewDefinition(
        title: 'Avatar',
        variants: [
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildAvatarSizesVariant,
          ),
          ComponentPreviewVariant(
            label: 'Default text fallback',
            builder: _buildAvatarDefaultTextFallbackVariant,
          ),
          ComponentPreviewVariant(
            label: 'Soft text fallback',
            builder: _buildAvatarSoftTextFallbackVariant,
          ),
          ComponentPreviewVariant(
            label: 'Default icon fallback',
            builder: _buildAvatarDefaultIconFallbackVariant,
          ),
          ComponentPreviewVariant(
            label: 'Soft icon fallback',
            builder: _buildAvatarSoftIconFallbackVariant,
          ),
          ComponentPreviewVariant(
            label: 'Custom fallback',
            builder: _buildAvatarCustomFallbackVariant,
          ),
          ComponentPreviewVariant(
            label: 'Avatar group',
            builder: _buildAvatarGroupVariant,
          ),
          ComponentPreviewVariant(
            label: 'Custom styles',
            builder: _buildAvatarCustomStylesVariant,
          ),
        ],
      );
    case 'Hover':
      return const ComponentPreviewDefinition(
        title: 'Hover',
        variants: [
          ComponentPreviewVariant(
            label: 'List rows',
            builder: _buildTappableRowListVariant,
          ),
          ComponentPreviewVariant(
            label: 'Custom buttons',
            builder: _buildTappableRowCardVariant,
          ),
          ComponentPreviewVariant(
            label: 'Clickable cards',
            builder: _buildTappableRowGroupVariant,
          ),
        ],
      );
    case 'Tabs':
      return const ComponentPreviewDefinition(
        title: 'Tabs',
        variants: [
          ComponentPreviewVariant(
            label: 'Primary variant',
            builder: _buildTabsPrimaryVariant,
          ),
          ComponentPreviewVariant(
            label: 'Secondary variant',
            builder: _buildTabsSecondaryVariant,
          ),
          ComponentPreviewVariant(
            label: 'Fill mode',
            builder: _buildTabsFillModeVariant,
          ),
        ],
      );
    case 'Sidebar':
      return const ComponentPreviewDefinition(
        title: 'Sidebar',
        variants: [
          ComponentPreviewVariant(
            label: 'App navigation',
            builder: _buildSidebarAppNav,
          ),
          ComponentPreviewVariant(
            label: 'Mobile drawer',
            builder: _buildSidebarMobileDrawer,
          ),
          ComponentPreviewVariant(
            label: 'Collapsed rail',
            builder: _buildSidebarCollapsed,
          ),
          ComponentPreviewVariant(
            label: 'Pinned (always wide)',
            builder: _buildSidebarPinned,
          ),
          ComponentPreviewVariant(
            label: 'Workspace showcase',
            builder: _buildSidebarShowcase,
          ),
        ],
      );
    case 'Skeleton':
      return const ComponentPreviewDefinition(
        title: 'Skeleton',
        variants: [
          ComponentPreviewVariant(
            label: 'Card skeleton',
            builder: _buildSkeletonCardVariant,
          ),
          ComponentPreviewVariant(
            label: 'List skeleton',
            builder: _buildSkeletonListVariant,
          ),
          ComponentPreviewVariant(
            label: 'Text skeletons',
            builder: _buildSkeletonTextVariant,
          ),
          ComponentPreviewVariant(
            label: 'Profile skeleton',
            builder: _buildSkeletonProfileVariant,
          ),
          ComponentPreviewVariant(
            label: 'Grid skeleton',
            builder: _buildSkeletonGridVariant,
          ),
        ],
      );
    case 'SwipeAction':
      return const ComponentPreviewDefinition(
        title: 'SwipeAction',
        variants: [
          ComponentPreviewVariant(
            label: 'Destructive (delete)',
            builder: _buildSwipeActionDestructive,
          ),
          ComponentPreviewVariant(
            label: 'Neutral (archive)',
            builder: _buildSwipeActionNeutral,
          ),
          ComponentPreviewVariant(
            label: 'With confirm',
            builder: _buildSwipeActionWithConfirm,
          ),
        ],
      );
    case 'Switch':
      return const ComponentPreviewDefinition(
        title: 'Switch',
        variants: [
          ComponentPreviewVariant(
            label: 'Settings list',
            builder: _buildSwitchSettingsList,
          ),
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildSwitchSizes,
          ),
          ComponentPreviewVariant(
            label: 'Inline label',
            builder: _buildSwitchInline,
          ),
          ComponentPreviewVariant(
            label: 'States',
            builder: _buildSwitchStates,
          ),
          ComponentPreviewVariant(
            label: 'Custom styles',
            builder: _buildSwitchCustomStyles,
          ),
        ],
      );
    case 'Radio Group':
      return const ComponentPreviewDefinition(
        title: 'Radio Group',
        variants: [
          ComponentPreviewVariant(
            label: 'Plan selection',
            builder: _buildRadioDescriptions,
          ),
          ComponentPreviewVariant(
            label: 'Simple list',
            builder: _buildRadioOptionList,
          ),
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildRadioSizes,
          ),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildRadioVariants,
          ),
          ComponentPreviewVariant(
            label: 'Horizontal',
            builder: _buildRadioHorizontal,
          ),
          ComponentPreviewVariant(
            label: 'Error state',
            builder: _buildRadioError,
          ),
          ComponentPreviewVariant(
            label: 'States',
            builder: _buildRadioStates,
          ),
        ],
      );
    case 'Separator':
      return const ComponentPreviewDefinition(
        title: 'Separator',
        variants: [
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildSeparatorVariants,
          ),
          ComponentPreviewVariant(
            label: 'With text',
            builder: _buildSeparatorText,
          ),
          ComponentPreviewVariant(
            label: 'Vertical',
            builder: _buildSeparatorVertical,
          ),
        ],
      );
    case 'CloseButton':
      return const ComponentPreviewDefinition(
        title: 'CloseButton',
        variants: [
          ComponentPreviewVariant(
            label: 'States',
            builder: _buildCloseButtonStates,
          ),
          ComponentPreviewVariant(
            label: 'In context',
            builder: _buildCloseButtonContext,
          ),
        ],
      );
    case 'LinkButton':
      return const ComponentPreviewDefinition(
        title: 'LinkButton',
        variants: [
          ComponentPreviewVariant(
            label: 'States',
            builder: _buildLinkStates,
          ),
          ComponentPreviewVariant(
            label: 'With icon',
            builder: _buildLinkWithIcon,
          ),
          ComponentPreviewVariant(
            label: 'In context',
            builder: _buildLinkContext,
          ),
        ],
      );
    case 'ToggleButton':
      return const ComponentPreviewDefinition(
        title: 'ToggleButton',
        variants: [
          ComponentPreviewVariant(
            label: 'Filled',
            builder: _buildToggleFilled,
          ),
          ComponentPreviewVariant(
            label: 'Ghost',
            builder: _buildToggleGhost,
          ),
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildToggleSizes,
          ),
          ComponentPreviewVariant(
            label: 'Icon only',
            builder: _buildToggleIconOnly,
          ),
          ComponentPreviewVariant(
            label: 'In context',
            builder: _buildToggleContext,
          ),
        ],
      );
    case 'ToggleButtonGroup':
      return const ComponentPreviewDefinition(
        title: 'ToggleButtonGroup',
        variants: [
          ComponentPreviewVariant(
            label: 'Segmented',
            builder: _buildToggleGroupSegmented,
          ),
          ComponentPreviewVariant(
            label: 'Multi-select',
            builder: _buildToggleGroupMulti,
          ),
          ComponentPreviewVariant(
            label: 'Detached',
            builder: _buildToggleGroupDetached,
          ),
          ComponentPreviewVariant(
            label: 'Vertical',
            builder: _buildToggleGroupVertical,
          ),
        ],
      );
    case 'Tag':
      return const ComponentPreviewDefinition(
        title: 'Tag',
        variants: [
          ComponentPreviewVariant(label: 'Sizes', builder: _buildTagSizes),
          ComponentPreviewVariant(label: 'Variants', builder: _buildTagVariants),
          ComponentPreviewVariant(label: 'States', builder: _buildTagStates),
        ],
      );
    case 'TagGroup':
      return const ComponentPreviewDefinition(
        title: 'TagGroup',
        variants: [
          ComponentPreviewVariant(
            label: 'Selectable',
            builder: _buildTagGroupSelectable,
          ),
          ComponentPreviewVariant(
            label: 'Removable',
            builder: _buildTagGroupRemovable,
          ),
          ComponentPreviewVariant(
            label: 'With label',
            builder: _buildTagGroupLabelled,
          ),
          ComponentPreviewVariant(
            label: 'Overflow',
            builder: _buildTagGroupOverflow,
          ),
        ],
      );
    case 'Surface':
      return const ComponentPreviewDefinition(
        title: 'Surface',
        variants: [
          ComponentPreviewVariant(label: 'Variants', builder: _buildSurfaceVariants),
          ComponentPreviewVariant(
            label: 'Nested',
            builder: _buildSurfaceNested,
          ),
        ],
      );
    case 'Tooltip':
      return const ComponentPreviewDefinition(
        title: 'Tooltip',
        variants: [
          ComponentPreviewVariant(
            label: 'Placements',
            builder: _buildTooltipPlacements,
          ),
          ComponentPreviewVariant(
            label: 'Default & inverse',
            builder: _buildTooltipInverse,
          ),
          ComponentPreviewVariant(
            label: 'No arrow',
            builder: _buildTooltipNoArrow,
          ),
        ],
      );
    case 'SocialAuthButton':
      return const ComponentPreviewDefinition(
        title: 'SocialAuthButton',
        variants: [
          ComponentPreviewVariant(
            label: 'Providers row',
            builder: _buildSocialAuthRow,
          ),
          ComponentPreviewVariant(
            label: 'With label',
            builder: _buildSocialAuthLabeled,
          ),
          ComponentPreviewVariant(
            label: 'Disabled',
            builder: _buildSocialAuthDisabled,
          ),
        ],
      );
    case 'ScrollShadow':
      return const ComponentPreviewDefinition(
        title: 'ScrollShadow',
        variants: [
          ComponentPreviewVariant(
            label: 'Vertical',
            builder: _buildScrollShadowVertical,
          ),
          ComponentPreviewVariant(
            label: 'In surface',
            builder: _buildScrollShadowInSurface,
          ),
          ComponentPreviewVariant(
            label: 'Horizontal',
            builder: _buildScrollShadowHorizontal,
          ),
        ],
      );
    case 'Kbd':
      return const ComponentPreviewDefinition(
        title: 'Kbd',
        variants: [
          ComponentPreviewVariant(
            label: 'Shortcuts',
            builder: _buildKbdShortcuts,
          ),
          ComponentPreviewVariant(
            label: 'Variants',
            builder: _buildKbdVariants,
          ),
          ComponentPreviewVariant(
            label: 'In context',
            builder: _buildKbdInContext,
          ),
        ],
      );
    case 'Label':
      return const ComponentPreviewDefinition(
        title: 'Label',
        variants: [
          ComponentPreviewVariant(
            label: 'Basic & required',
            builder: _buildLabelBasic,
          ),
          ComponentPreviewVariant(
            label: 'Invalid & disabled',
            builder: _buildLabelStates,
          ),
        ],
      );
    case 'Description':
      return const ComponentPreviewDefinition(
        title: 'Description',
        variants: [
          ComponentPreviewVariant(label: 'Default', builder: _buildDescription),
          ComponentPreviewVariant(
            label: 'In context',
            builder: _buildDescriptionContext,
          ),
        ],
      );
    case 'FieldError':
      return const ComponentPreviewDefinition(
        title: 'FieldError',
        variants: [
          ComponentPreviewVariant(label: 'Default', builder: _buildFieldError),
          ComponentPreviewVariant(
            label: 'In context',
            builder: _buildFieldErrorContext,
          ),
        ],
      );
    case 'NumberField':
      return const ComponentPreviewDefinition(
        title: 'NumberField',
        variants: [
          ComponentPreviewVariant(
            label: 'Default',
            builder: _buildNumberFieldDefault,
          ),
          ComponentPreviewVariant(
            label: 'Min / max',
            builder: _buildNumberFieldBounded,
          ),
          ComponentPreviewVariant(label: 'Error', builder: _buildNumberFieldError),
          ComponentPreviewVariant(
            label: 'Disabled',
            builder: _buildNumberFieldDisabled,
          ),
        ],
      );
    case 'Spinner':
      return const ComponentPreviewDefinition(
        title: 'Spinner',
        variants: [
          ComponentPreviewVariant(
            label: 'Colors',
            builder: _buildSpinnerColors,
          ),
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildSpinnerSizes,
          ),
          ComponentPreviewVariant(
            label: 'In context',
            builder: _buildSpinnerInContext,
          ),
        ],
      );
    case 'ProgressBar':
      return const ComponentPreviewDefinition(
        title: 'ProgressBar',
        variants: [
          ComponentPreviewVariant(
            label: 'With label',
            builder: _buildProgressBarLabel,
          ),
          ComponentPreviewVariant(
            label: 'Colors',
            builder: _buildProgressBarColors,
          ),
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildProgressBarSizes,
          ),
          ComponentPreviewVariant(
            label: 'Progress',
            builder: _buildProgressBarProgress,
          ),
          ComponentPreviewVariant(
            label: 'Indeterminate',
            builder: _buildProgressBarIndeterminate,
          ),
        ],
      );
    case 'Slider':
      return const ComponentPreviewDefinition(
        title: 'Slider',
        variants: [
          ComponentPreviewVariant(
            label: 'Default',
            builder: _buildSliderDefault,
          ),
          ComponentPreviewVariant(
            label: 'With marks & steps',
            builder: _buildSliderMarks,
          ),
          ComponentPreviewVariant(
            label: 'Range',
            builder: _buildSliderRange,
          ),
          ComponentPreviewVariant(
            label: 'Disabled',
            builder: _buildSliderDisabled,
          ),
        ],
      );
    case 'ProgressCircle':
      return const ComponentPreviewDefinition(
        title: 'ProgressCircle',
        variants: [
          ComponentPreviewVariant(
            label: 'With label',
            builder: _buildProgressCircleLabel,
          ),
          ComponentPreviewVariant(
            label: 'Colors',
            builder: _buildProgressCircleColors,
          ),
          ComponentPreviewVariant(
            label: 'Sizes',
            builder: _buildProgressCircleSizes,
          ),
          ComponentPreviewVariant(
            label: 'Progress',
            builder: _buildProgressCircleProgress,
          ),
          ComponentPreviewVariant(
            label: 'Indeterminate',
            builder: _buildProgressCircleIndeterminate,
          ),
        ],
      );
    default:
      return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar — interactive preview
// ─────────────────────────────────────────────────────────────────────────────

// The live Home configuration (real pages, highlight-only nav). The default —
// adapts to the breakpoint, which is what actually ships in the app.
Widget _buildSidebarAppNav(BuildContext context) => const _SidebarPreview(
      caption: 'The default app navigation, wired to the live Home pages. '
          'Adapts to the breakpoint: wide on desktop, a thin icon rail on '
          'tablet and mobile — the toggle expands it on any screen.',
    );

// The mobile pattern: always opens wide as a slide-in drawer, no collapse
// toggle (the sheet you open from an app-bar menu button on a phone).
Widget _buildSidebarMobileDrawer(BuildContext context) => const _SidebarPreview(
      isDrawer: true,
      caption: 'The phone pattern: always opens wide as a slide-in drawer, with '
          'the collapse toggle hidden. This is what an app-bar menu button opens.',
    );

// Starts as the narrow icon rail (tooltips on hover), at any breakpoint.
Widget _buildSidebarCollapsed(BuildContext context) => const _SidebarPreview(
      collapseMode: KasySidebarCollapseMode.collapsed,
      caption: 'Starts collapsed to the thin icon rail (labels show as hover '
          'tooltips). Expand it with the toggle on any breakpoint.',
    );

// Pinned wide on every breakpoint; the user collapses it themselves.
Widget _buildSidebarPinned(BuildContext context) => const _SidebarPreview(
      collapseMode: KasySidebarCollapseMode.expanded,
      caption: 'Pinned wide on every breakpoint instead of auto-collapsing; the '
          'user narrows it with the toggle when they want the room.',
    );

// The rich SaaS showcase (workspace selector, KasyTabs segment, ⌘K search).
Widget _buildSidebarShowcase(BuildContext context) => const _SidebarPreview(
      showcase: true,
      caption: 'The rich SaaS layout: workspace switcher, a KasyTabs segment '
          '(Layers / Assets) and a pinned ⌘K search row.',
    );

/// Launches a [KasySidebar] as a full-height drawer (left + right buttons) so
/// the full-bleed chrome can be inspected without crushing the preview card. A
/// short [caption] (Kasy typography) explains what each configuration is.
/// Connected variants mirror the live Home; [showcase] swaps to the HeroUI
/// workspace demo.
class _SidebarPreview extends StatelessWidget {
  const _SidebarPreview({
    required this.caption,
    this.showcase = false,
    this.collapseMode = KasySidebarCollapseMode.responsive,
    this.isDrawer = false,
  });

  final String caption;
  final bool showcase;
  final KasySidebarCollapseMode collapseMode;
  final bool isDrawer;

  Widget _sidebar({required bool fromEnd}) {
    final KasySidebarSide side =
        fromEnd ? KasySidebarSide.right : KasySidebarSide.left;
    if (showcase) {
      return KasySidebar(collapseMode: collapseMode, side: side);
    }
    return _DemoSidebar(
      isDrawer: isDrawer,
      collapseMode: collapseMode,
      side: side,
    );
  }

  void _open(BuildContext context, {required bool fromEnd}) =>
      _openSidebarDrawer(
        context,
        fromEnd: fromEnd,
        child: _sidebar(fromEnd: fromEnd),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
        const SizedBox(height: KasySpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
          child: _previewIntrinsicLaunch(
            KasyButton(
              label: 'Open Left',
              variant: KasyButtonVariant.soft,
              onPressed: () => _open(context, fromEnd: false),
            ),
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
          child: _previewIntrinsicLaunch(
            KasyButton(
              label: 'Open Right',
              variant: KasyButtonVariant.soft,
              onPressed: () => _open(context, fromEnd: true),
            ),
          ),
        ),
      ],
    );
  }
}

/// A [KasySidebar] wired to the live Home configuration (real pages) with
/// highlight-only navigation, so the showcase mirrors the actual app. Shared by
/// the sidebar previews and the app-bar drawer demo.
class _DemoSidebar extends StatefulWidget {
  const _DemoSidebar({
    this.isDrawer = false,
    this.collapseMode = KasySidebarCollapseMode.responsive,
    this.side = KasySidebarSide.left,
  });

  final bool isDrawer;
  final KasySidebarCollapseMode collapseMode;
  final KasySidebarSide side;

  @override
  State<_DemoSidebar> createState() => _DemoSidebarState();
}

class _DemoSidebarState extends State<_DemoSidebar> {
  final ValueNotifier<int> _current = ValueNotifier<int>(0);

  // The same four tabs the live app wires into the sidebar (Home / Support /
  // Notifications / Settings); pages are stubs since this is a visual demo.
  late final List<BartMenuRoute> _routes = <BartMenuRoute>[
    BartMenuRoute.bottomBar(
        label: 'Home', icon: KasyIcons.home, path: 'home', pageBuilder: _stub),
    BartMenuRoute.bottomBar(
        label: 'Support',
        icon: KasyIcons.help,
        path: 'support',
        pageBuilder: _stub),
    BartMenuRoute.bottomBar(
        label: 'Notifications',
        icon: KasyIcons.notification,
        path: 'notifications',
        pageBuilder: _stub),
    BartMenuRoute.bottomBar(
        label: 'Settings',
        icon: KasyIcons.settings,
        path: 'settings',
        pageBuilder: _stub),
  ];

  static Widget _stub(BuildContext _, BuildContext _, RouteSettings? _) =>
      const SizedBox.shrink();

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KasySidebar(
      routes: _routes,
      currentItem: _current,
      onTapItem: (i) => _current.value = i, // highlight only
      isDrawer: widget.isDrawer,
      collapseMode: widget.collapseMode,
      side: widget.side,
    );
  }
}

/// Slides [child] in as a full-height drawer from the left ([fromEnd] = right),
/// over a dim barrier — the mobile navigation-drawer pattern.
void _openSidebarDrawer(
  BuildContext context, {
  required bool fromEnd,
  required Widget child,
}) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.42),
    transitionDuration: const Duration(milliseconds: 290),
    pageBuilder: (ctx, anim, secAnim) => Align(
      alignment: fromEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(height: double.infinity, child: child),
    ),
    transitionBuilder: (ctx, anim, secAnim, c) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(fromEnd ? 1.0 : -1.0, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: c,
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Tabs — interactive demos
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildTabsPrimaryVariant(BuildContext context) =>
    const _TabsPrimaryPreview();

Widget _buildTabsSecondaryVariant(BuildContext context) =>
    const _TabsSecondaryPreview();

Widget _buildTabsFillModeVariant(BuildContext context) =>
    const _TabsFillModePreview();

// ── Shared tab content helpers ────────────────────────────────────────────

/// Fades [child] in when [tabIndex] == [currentIndex], out otherwise.
///
/// Used inside an [IndexedStack] so the content area never changes height —
/// the stack always sizes to the tallest child and only the active one is
/// visible.
Widget _tabFade(int tabIndex, int currentIndex, Widget child) {
  return AnimatedOpacity(
    opacity: tabIndex == currentIndex ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 180),
    curve: Curves.easeInOut,
    child: child,
  );
}

// ── Card container helper ─────────────────────────────────────────────────

Widget _tabsCard(BuildContext context, Widget child) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: KasyRadius.lgBorderRadius,
      border: Border.all(
        color: context.colors.outline.withValues(alpha: 0.4),
      ),
    ),
    child: child,
  );
}

// ── Divider helper ────────────────────────────────────────────────────────

Widget _tabsDivider(BuildContext context) => Divider(
      height: 1,
      thickness: 1,
      indent: KasySpacing.md,
      endIndent: KasySpacing.md,
      color: context.colors.outline.withValues(alpha: 0.33),
    );

// ── Radio-style option row ────────────────────────────────────────────────

/// Single-select option row that looks like a radio button using KasyCheckbox.
class _RadioOptionTile extends StatelessWidget {
  const _RadioOptionTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      child: KasyCheckbox(
        value: selected,
        onChanged: (_) => onTap(),
        label: label,
        description: description,
        style: const KasyCheckboxStyle(
          shape: KasyCheckboxShape.circle,
        ),
      ),
    );
  }
}

// ── Primary variant ────────────────────────────────────────────────────────

class _TabsPrimaryPreview extends StatefulWidget {
  const _TabsPrimaryPreview();

  @override
  State<_TabsPrimaryPreview> createState() => _TabsPrimaryPreviewState();
}

class _TabsPrimaryPreviewState extends State<_TabsPrimaryPreview> {
  int _index = 0;

  // General tab
  final TextEditingController _urlController = TextEditingController();
  bool _analytics = true;
  bool _errorReports = false;

  // Appearance tab
  int _theme = 0; // 0=Auto 1=Light 2=Dark
  int _fontSize = 1; // 0=Small 1=Medium 2=Large

  // Notifications tab
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _mentions = true;
  bool _weeklyDigest = false;

  // Profile tab
  final TextEditingController _nameController =
      TextEditingController(text: 'Paulo Morales');
  final TextEditingController _usernameController =
      TextEditingController(text: 'paulomorales');

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Widget _generalTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(KasySpacing.md),
          child: KasyTextField(
            controller: _urlController,
            variant: KasyTextFieldVariant.secondary,
            label: 'Homepage URL',
            hint: 'https://yoursite.com',
          ),
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _analytics,
          onChanged: (v) => setState(() => _analytics = v),
          label: 'Enable analytics',
          description: 'Collect anonymous usage data to improve the app',
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _errorReports,
          onChanged: (v) => setState(() => _errorReports = v),
          label: 'Send error reports',
          description: 'Automatically share crash reports with the team',
        ),
      ],
    );
  }

  Widget _appearanceTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KasySpacing.md,
            KasySpacing.md,
            KasySpacing.md,
            KasySpacing.sm,
          ),
          child: Text(
            'Theme',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _RadioOptionTile(
          label: 'Auto',
          description: 'Follows your system appearance',
          selected: _theme == 0,
          onTap: () => setState(() => _theme = 0),
        ),
        _tabsDivider(context),
        _RadioOptionTile(
          label: 'Light',
          description: 'Always use the light theme',
          selected: _theme == 1,
          onTap: () => setState(() => _theme = 1),
        ),
        _tabsDivider(context),
        _RadioOptionTile(
          label: 'Dark',
          description: 'Always use the dark theme',
          selected: _theme == 2,
          onTap: () => setState(() => _theme = 2),
        ),
        _tabsDivider(context),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KasySpacing.md,
            KasySpacing.md,
            KasySpacing.md,
            KasySpacing.sm,
          ),
          child: Text(
            'Font size',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _RadioOptionTile(
          label: 'Small',
          description: 'Compact text for more content on screen',
          selected: _fontSize == 0,
          onTap: () => setState(() => _fontSize = 0),
        ),
        _tabsDivider(context),
        _RadioOptionTile(
          label: 'Medium',
          description: 'Balanced size for most displays',
          selected: _fontSize == 1,
          onTap: () => setState(() => _fontSize = 1),
        ),
        _tabsDivider(context),
        _RadioOptionTile(
          label: 'Large',
          description: 'Larger text for better readability',
          selected: _fontSize == 2,
          onTap: () => setState(() => _fontSize = 2),
        ),
      ],
    );
  }

  Widget _notificationsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyCheckboxTile(
          value: _pushEnabled,
          onChanged: (v) => setState(() => _pushEnabled = v),
          label: 'Push notifications',
          description: 'Receive alerts directly on your device',
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _emailEnabled,
          onChanged: (v) => setState(() => _emailEnabled = v),
          label: 'Email notifications',
          description: 'Get updates delivered to your inbox',
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _mentions,
          onChanged: (v) => setState(() => _mentions = v),
          label: 'Mentions and replies',
          description: 'Notify when someone mentions or replies to you',
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _weeklyDigest,
          onChanged: (v) => setState(() => _weeklyDigest = v),
          label: 'Weekly digest',
          description: 'A summary of activity sent every Monday',
        ),
      ],
    );
  }

  Widget _profileTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KasySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyTextField(
            controller: _nameController,
            variant: KasyTextFieldVariant.secondary,
            label: 'Name',
            hint: 'Your full name',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: KasySpacing.md),
          KasyTextField(
            controller: _usernameController,
            variant: KasyTextFieldVariant.secondary,
            label: 'Username',
            hint: 'yourhandle',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: KasySpacing.md),
          KasyButton(
            label: 'Update profile',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyTabs(
          tabs: const ['General', 'Appearance', 'Notifications', 'Profile'],
          selectedIndex: _index,
          onTabSelected: (i) => setState(() => _index = i),
        ),
        const SizedBox(height: KasySpacing.md),
        // IndexedStack keeps height fixed at the tallest child (Appearance).
        // AnimatedOpacity on each child provides the smooth crossfade.
        _tabsCard(
          context,
          IndexedStack(
            index: _index,
            children: [
              _tabFade(0, _index, _generalTab(context)),
              _tabFade(1, _index, _appearanceTab(context)),
              _tabFade(2, _index, _notificationsTab(context)),
              _tabFade(3, _index, _profileTab(context)),
            ],
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        // Disabled tab demo
        Text(
          'WITH DISABLED TAB',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.muted,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyTabs.items(
          items: const [
            KasyTabItem(label: 'Active'),
            KasyTabItem(label: 'Disabled', enabled: false),
            KasyTabItem(label: 'Active'),
          ],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      ],
    );
  }
}

// ── Secondary variant ──────────────────────────────────────────────────────

class _TabsSecondaryPreview extends StatefulWidget {
  const _TabsSecondaryPreview();

  @override
  State<_TabsSecondaryPreview> createState() => _TabsSecondaryPreviewState();
}

class _TabsSecondaryPreviewState extends State<_TabsSecondaryPreview> {
  int _index = 0;

  // General tab
  final TextEditingController _siteController = TextEditingController();
  bool _cacheEnabled = true;
  bool _debugMode = false;

  // Notifications tab
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _weeklyDigest = true;

  // Profile tab
  final TextEditingController _nameController =
      TextEditingController(text: 'Paulo Morales');
  final TextEditingController _emailController =
      TextEditingController(text: 'paulo@kasy.dev');

  @override
  void dispose() {
    _siteController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _generalTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(KasySpacing.md),
          child: KasyTextField(
            controller: _siteController,
            variant: KasyTextFieldVariant.secondary,
            label: 'Site URL',
            hint: 'https://yoursite.com',
          ),
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _cacheEnabled,
          onChanged: (v) => setState(() => _cacheEnabled = v),
          label: 'Enable caching',
          description: 'Speed up page loads with local cache',
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _debugMode,
          onChanged: (v) => setState(() => _debugMode = v),
          label: 'Debug mode',
          description: 'Show detailed logs and error messages',
        ),
      ],
    );
  }

  Widget _notificationsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyCheckboxTile(
          value: _pushEnabled,
          onChanged: (v) => setState(() => _pushEnabled = v),
          label: 'Push notifications',
          description: 'Receive alerts directly on your device',
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _emailEnabled,
          onChanged: (v) => setState(() => _emailEnabled = v),
          label: 'Email notifications',
          description: 'Get updates delivered to your inbox',
        ),
        _tabsDivider(context),
        KasyCheckboxTile(
          value: _weeklyDigest,
          onChanged: (v) => setState(() => _weeklyDigest = v),
          label: 'Weekly digest',
          description: 'A summary of activity sent every Monday',
        ),
      ],
    );
  }

  Widget _profileTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KasySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyTextField(
            controller: _nameController,
            variant: KasyTextFieldVariant.secondary,
            label: 'Name',
            hint: 'Your full name',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: KasySpacing.md),
          KasyTextField(
            controller: _emailController,
            variant: KasyTextFieldVariant.secondary,
            label: 'Email',
            hint: 'email@example.com',
            contentType: KasyTextFieldContentType.email,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: KasySpacing.md),
          KasyButton(
            label: 'Save changes',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyTabs(
          tabs: const ['General', 'Notifications', 'Profile'],
          selectedIndex: _index,
          onTabSelected: (i) => setState(() => _index = i),
          variant: KasyTabsVariant.secondary,
        ),
        const SizedBox(height: KasySpacing.md),
        _tabsCard(
          context,
          IndexedStack(
            index: _index,
            children: [
              _tabFade(0, _index, _generalTab(context)),
              _tabFade(1, _index, _notificationsTab(context)),
              _tabFade(2, _index, _profileTab(context)),
            ],
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        // With icons
        Text(
          'WITH ICONS',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.muted,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyTabs.items(
          items: const [
            KasyTabItem(label: 'Home', icon: KasyIcons.home),
            KasyTabItem(label: 'Profile', icon: KasyIcons.person),
            KasyTabItem(label: 'Settings', icon: KasyIcons.settings),
          ],
          selectedIndex: 1,
          onTabSelected: (_) {},
          variant: KasyTabsVariant.secondary,
        ),
      ],
    );
  }
}

// ── Fill mode ──────────────────────────────────────────────────────────────

class _TabsFillModePreview extends StatefulWidget {
  const _TabsFillModePreview();

  @override
  State<_TabsFillModePreview> createState() => _TabsFillModePreviewState();
}

class _TabsFillModePreviewState extends State<_TabsFillModePreview> {
  int _primaryIndex = 0;
  int _iconIndex = 0;

  static const List<String> _primaryContent = [
    'Overview — see a high-level summary of your project status and recent activity.',
    'Analytics — track metrics like sessions, retention, and conversion rates over time.',
    'Settings — manage project configuration, integrations, and team access.',
  ];

  @override
  Widget build(BuildContext context) {
    final TextStyle sectionLabel =
        context.textTheme.labelSmall?.copyWith(
          color: context.colors.muted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('PRIMARY FILL', style: sectionLabel),
        const SizedBox(height: KasySpacing.sm),
        KasyTabs(
          tabs: const ['Overview', 'Analytics', 'Settings'],
          selectedIndex: _primaryIndex,
          onTabSelected: (i) => setState(() => _primaryIndex = i),
          mode: KasyTabsMode.fill,
        ),
        const SizedBox(height: KasySpacing.md),
        _tabsCard(
          context,
          Padding(
            padding: const EdgeInsets.all(KasySpacing.md),
            child: IndexedStack(
              index: _primaryIndex,
              children: List.generate(
                _primaryContent.length,
                (i) => _tabFade(
                  i,
                  _primaryIndex,
                  Text(
                    _primaryContent[i],
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        Text('SECONDARY FILL + ICONS', style: sectionLabel),
        const SizedBox(height: KasySpacing.sm),
        KasyTabs.items(
          items: const [
            KasyTabItem(label: 'Home', icon: KasyIcons.home),
            KasyTabItem(label: 'Profile', icon: KasyIcons.person),
            KasyTabItem(label: 'Settings', icon: KasyIcons.settings),
          ],
          selectedIndex: _iconIndex,
          onTabSelected: (i) => setState(() => _iconIndex = i),
          variant: KasyTabsVariant.secondary,
          mode: KasyTabsMode.fill,
        ),
      ],
    );
  }
}

Widget _buildSkeletonCardVariant(BuildContext context) {
  return const _SkeletonCardPreview();
}

Widget _buildSkeletonListVariant(BuildContext context) {
  return const _SkeletonListPreview();
}

Widget _buildSkeletonTextVariant(BuildContext context) {
  return const _SkeletonTextPreview();
}

Widget _buildSkeletonProfileVariant(BuildContext context) {
  return const _SkeletonProfilePreview();
}

Widget _buildSkeletonGridVariant(BuildContext context) {
  return const _SkeletonGridPreview();
}

Widget _buildAccordionDefaultVariant(BuildContext context) {
  return const _AccordionPreview(variant: KasyAccordionVariant.defaultList);
}

Widget _buildAccordionSurfaceVariant(BuildContext context) {
  return const _AccordionPreview(variant: KasyAccordionVariant.surface);
}

Widget _buildAccordionElevatedCardVariant(BuildContext context) {
  return const _AccordionPreview(variant: KasyAccordionVariant.elevatedCard);
}

Widget _buildAlertDefaultPrimaryVariant(BuildContext context) {
  final TextStyle labelStyle =
      context.textTheme.labelSmall?.copyWith(
        color: context.colors.muted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ) ??
      const TextStyle();
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('DEFAULT', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      KasyAlert(
        title: 'New features available',
        message:
            'Check out our latest updates including dark mode support and improved accessibility features.',
        leading: Icon(
          KasyIcons.error,
          size: 19,
          color: context.colors.onSurface.withValues(alpha: 0.92),
        ),
      ),
      const SizedBox(height: KasySpacing.lg),
      Text('ACCENT', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      const KasyAlert(
        title: 'Update available',
        message:
            'A new version of the application is available. Please refresh to get the latest features and bug fixes.',
        emphasizeTitleWithTone: true,
      ),
    ],
  );
}

Widget _buildAlertSemanticVariant(BuildContext context) {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KasyAlert(
        title: 'Success',
        message:
            'Your profile information has been updated. Review the changes in your account settings.',
        tone: KasyAlertTone.success,
        emphasizeTitleWithTone: true,
      ),
      SizedBox(height: KasySpacing.sm),
      KasyAlert(
        title: 'Scheduled maintenance',
        message:
            'Our services will be unavailable on Sunday, March 15th from 2:00 AM to 6:00 AM UTC for scheduled maintenance.',
        tone: KasyAlertTone.warning,
        icon: Icons.warning_amber_rounded,
        emphasizeTitleWithTone: true,
      ),
      SizedBox(height: KasySpacing.sm),
      KasyAlert(
        title: 'Unable to connect to server',
        message:
            'Unable to connect to the server. Check your internet connection and try again.',
        tone: KasyAlertTone.danger,
        emphasizeTitleWithTone: true,
      ),
    ],
  );
}

Widget _buildAlertWithButtonsVariant(BuildContext context) {
  final TextStyle labelStyle =
      context.textTheme.labelSmall?.copyWith(
        color: context.colors.muted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ) ??
      const TextStyle();
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('ONE ACTION', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      KasyAlert(
        title: 'Update available',
        message:
            'A new version of the application is available. Please refresh to get the latest features and bug fixes.',
        emphasizeTitleWithTone: true,
        trailing: KasyAlertActionButton(
          label: 'Refresh',
          onPressed: () => _triggerTapFeedback(),
        ),
      ),
      const SizedBox(height: KasySpacing.lg),
      Text('TWO ACTIONS', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      KasyAlert(
        title: 'Unable to connect to server',
        message:
            'Unable to connect to the server. Check your internet connection and try again.',
        tone: KasyAlertTone.danger,
        emphasizeTitleWithTone: true,
        trailing: KasyAlertActionButton(
          label: 'Retry',
          tone: KasyAlertTone.danger,
          onPressed: () => _triggerTapFeedback(),
        ),
      ),
      const SizedBox(height: KasySpacing.lg),
      Text('DESTRUCTIVE', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      const KasyAlert(
        title: 'Profile updated successfully',
        tone: KasyAlertTone.success,
        emphasizeTitleWithTone: true,
        trailing: KasyAlertCircleButton(onPressed: _triggerTapFeedback),
      ),
    ],
  );
}

Widget _buildAlertLoadingVariant(BuildContext context) {
  return const _AlertLoadingPreview();
}

Widget _buildAvatarSizesVariant(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyAvatar.gradientFill(
            size: KasyAvatarSize.small,
            gradient: KasyAvatarGradients.blue,
            onTap: _triggerTapFeedback,
          ),
          const SizedBox(height: KasySpacing.sm),
          Text(
            'SM',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.muted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyAvatar.gradientFill(
            size: KasyAvatarSize.medium,
            gradient: KasyAvatarGradients.hotPink,
            onTap: _triggerTapFeedback,
          ),
          const SizedBox(height: KasySpacing.sm),
          Text(
            'MD',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.muted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyAvatar.gradientFill(
            size: KasyAvatarSize.large,
            gradient: KasyAvatarGradients.red,
            onTap: _triggerTapFeedback,
          ),
          const SizedBox(height: KasySpacing.sm),
          Text(
            'LG',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.muted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildAvatarDefaultTextFallbackVariant(BuildContext context) {
  return _avatarToneRow(
    (KasyAvatarTone tone, String letters) =>
        KasyAvatar(initials: letters, tone: tone, onTap: _triggerTapFeedback),
  );
}

Widget _buildAvatarSoftTextFallbackVariant(BuildContext context) {
  return _avatarToneRow(
    (KasyAvatarTone tone, String letters) => KasyAvatar(
      initials: letters,
      tone: tone,
      fallbackSurface: KasyAvatarFallbackSurface.soft,
      onTap: _triggerTapFeedback,
    ),
  );
}

Widget _buildAvatarDefaultIconFallbackVariant(BuildContext context) {
  return _avatarToneRow(
    (KasyAvatarTone tone, _) =>
        KasyAvatar(tone: tone, onTap: _triggerTapFeedback),
  );
}

Widget _buildAvatarSoftIconFallbackVariant(BuildContext context) {
  return _avatarToneRow(
    (KasyAvatarTone tone, _) => KasyAvatar(
      tone: tone,
      fallbackSurface: KasyAvatarFallbackSurface.soft,
      onTap: _triggerTapFeedback,
    ),
  );
}

Widget _buildAvatarCustomFallbackVariant(BuildContext context) {
  return Center(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KasyAvatar(
            customChild: SizedBox(
              width: KasyAvatarSize.medium.diameter,
              height: KasyAvatarSize.medium.diameter,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(
                      fontSize: KasyAvatarSize.medium.diameter * 0.42,
                    ),
                  ),
                ),
              ),
            ),
            onTap: _triggerTapFeedback,
          ),
          const SizedBox(width: KasySpacing.md),
          const KasyAvatar(
            initials: 'GB',
            backgroundGradient: KasyAvatarGradients.forest,
            onTap: _triggerTapFeedback,
          ),
          const SizedBox(width: KasySpacing.md),
          const KasyAvatar(
            tone: KasyAvatarTone.neutral,
            onTap: _triggerTapFeedback,
          ),
        ],
      ),
    ),
  );
}

Widget _buildAvatarGroupVariant(BuildContext context) {
  const double d = 48;

  Widget label(String text) => Text(
    text,
    style: context.textTheme.labelSmall?.copyWith(
      color: context.colors.muted,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w700,
    ),
  );

  // Shared gradient avatars list
  final List<Widget> gradients = [
    KasyAvatar.gradientFill(size: KasyAvatarSize.small, diameter: d, showShadow: false, gradient: KasyAvatarGradients.blue),
    KasyAvatar.gradientFill(size: KasyAvatarSize.small, diameter: d, showShadow: false, gradient: KasyAvatarGradients.sky),
    KasyAvatar.gradientFill(size: KasyAvatarSize.small, diameter: d, showShadow: false, gradient: KasyAvatarGradients.orange),
    KasyAvatar.gradientFill(size: KasyAvatarSize.small, diameter: d, showShadow: false, gradient: KasyAvatarGradients.red),
    KasyAvatar.gradientFill(size: KasyAvatarSize.small, diameter: d, showShadow: false, gradient: KasyAvatarGradients.silver),
  ];

  // Shared photo avatars list
  const List<Widget> photos = [
    KasyAvatar(diameter: d, image: NetworkImage(KasyAvatarDemoPhotos.manGlasses)),
    KasyAvatar(diameter: d, image: NetworkImage(KasyAvatarDemoPhotos.womanSmile)),
    KasyAvatar(diameter: d, image: NetworkImage(KasyAvatarDemoPhotos.womanCurly)),
    KasyAvatar(diameter: d, image: NetworkImage(KasyAvatarDemoPhotos.manBeard)),
    KasyAvatar(diameter: d, image: NetworkImage(KasyAvatarDemoPhotos.manGlasses)),
  ];

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      label('GRADIENTS + ADD'),
      const SizedBox(height: KasySpacing.sm),
      Center(
        child: KasyAvatarGroup(
          maxVisible: 5,
          extraCount: 5,
          avatars: gradients,
          onAdd: () {},
        ),
      ),
      const SizedBox(height: KasySpacing.lg),
      label('PHOTOS + ADD'),
      const SizedBox(height: KasySpacing.sm),
      Center(
        child: KasyAvatarGroup(
          maxVisible: 5,
          extraCount: 5,
          avatars: photos,
          onAdd: () {},
        ),
      ),
      const SizedBox(height: KasySpacing.lg),
      label('WITHOUT ADD'),
      const SizedBox(height: KasySpacing.sm),
      Center(
        child: KasyAvatarGroup(
          avatars: gradients,
        ),
      ),
    ],
  );
}

Widget _buildAvatarCustomStylesVariant(BuildContext context) {
  return const Center(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KasyAvatar(
            image: NetworkImage(KasyAvatarDemoPhotos.manGlasses),
            onTap: _triggerTapFeedback,
          ),
          SizedBox(width: KasySpacing.md),
          KasyAvatar(
            image: NetworkImage(KasyAvatarDemoPhotos.womanSmile),
            shape: KasyAvatarShape.roundedSquare,
            onTap: _triggerTapFeedback,
          ),
          SizedBox(width: KasySpacing.md),
          KasyAvatar(
            image: NetworkImage(KasyAvatarDemoPhotos.womanCurly),
            showStoryRing: true,
            onTap: _triggerTapFeedback,
          ),
          SizedBox(width: KasySpacing.md),
          KasyAvatar(
            image: NetworkImage(KasyAvatarDemoPhotos.manBeard),
            status: KasyAvatarStatus.online,
            onTap: _triggerTapFeedback,
          ),
        ],
      ),
    ),
  );
}

Widget _avatarToneRow(
  KasyAvatar Function(KasyAvatarTone tone, String letters) buildOne,
) {
  const List<(KasyAvatarTone, String)> data = <(KasyAvatarTone, String)>[
    (KasyAvatarTone.blue, 'AC'),
    (KasyAvatarTone.neutral, 'DF'),
    (KasyAvatarTone.green, 'SC'),
    (KasyAvatarTone.orange, 'WR'),
    (KasyAvatarTone.red, 'DG'),
  ];
  return Center(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(data.length, (int index) {
          final (KasyAvatarTone tone, String letters) = data[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < data.length - 1 ? KasySpacing.sm : 0,
            ),
            child: buildOne(tone, letters),
          );
        }),
      ),
    ),
  );
}

Widget _buildAppBarSubpageVariant(BuildContext context) {
  return const _AppBarPreview(variant: KasyAppBarStyle.subpage);
}

Widget _buildAppBarSubpageSimpleVariant(BuildContext context) {
  return const _AppBarPreview(variant: KasyAppBarStyle.subpageSimple);
}

Widget _buildAppBarSubpageActionsVariant(BuildContext context) {
  return const _AppBarPreview(variant: KasyAppBarStyle.subpageActions);
}

Widget _buildAppBarMenuVariant(BuildContext context) {
  return const _AppBarPreview(
    variant: KasyAppBarStyle.rootTab,
    withMenu: true,
  );
}

/// A fully-wired desktop config for previews — every element active, so each
/// variant can switch one thing on/off and read clearly.
KasyAppBarConfig _demoAppBarConfig() => KasyAppBarConfig(
      onToggleTheme: () {},
      onNotifications: () {},
      onCreate: () {},
      onAvatarTap: () {},
    );

Widget _buildAppBarApplicationVariant(BuildContext context) {
  return _ApplicationBarPreview(config: _demoAppBarConfig());
}

Widget _buildAppBarApplicationBadgeVariant(BuildContext context) {
  return _ApplicationBarPreview(
    config: _demoAppBarConfig().copyWith(showNotificationBadge: true),
  );
}

Widget _buildAppBarApplicationNoAvatarVariant(BuildContext context) {
  return _ApplicationBarPreview(
    config: _demoAppBarConfig().copyWith(showAvatar: false),
  );
}

// Per-screen presets: the same component, different chrome chosen by a screen.
Widget _buildAppBarApplicationSearchOnlyVariant(BuildContext context) {
  return _ApplicationBarPreview(
    config: _demoAppBarConfig().only(search: true, themeToggle: true),
  );
}

Widget _buildAppBarApplicationNotificationsOnlyVariant(BuildContext context) {
  return _ApplicationBarPreview(
    config: _demoAppBarConfig().only(notifications: true, themeToggle: true),
  );
}

Widget _buildButtonSizesVariant(BuildContext context) {
  return const _ButtonSizesPreview();
}

Widget _buildButtonVariantsVariant(BuildContext context) {
  return const _ButtonVariantsPreview();
}

Widget _buildButtonDisabledStateVariant(BuildContext context) {
  return const _ButtonDisabledStatePreview();
}

Widget _buildButtonWidthAlignmentVariant(BuildContext context) {
  return const _ButtonWidthAlignmentPreview();
}

Widget _buildButtonWithIconsVariant(BuildContext context) {
  return const _ButtonWithIconsPreview();
}

Widget _buildButtonIconOnlyVariant(BuildContext context) {
  return const _ButtonIconOnlyPreview();
}

Widget _buildButtonCustomStylingVariant(BuildContext context) {
  return const _ButtonCustomStylingPreview();
}

Widget _buildButtonCustomPaletteHoverVariant(BuildContext context) {
  return const _ButtonCustomPaletteHoverPreview();
}

Widget _buildButtonHoverFillVariant(BuildContext context) {
  return _ButtonHoverFillPreview();
}

Widget _buildButtonLayoutTransitionsVariant(BuildContext context) {
  return const _ButtonLayoutTransitionsPreview();
}

/// Accent used only in catalog demos (retail price); not a DS semantic token.
const Color _kCatalogRetailPriceAccent = Color(0xFFE91E63);

/// Stable Unsplash URLs for Card catalog previews (HTTPS).
abstract final class _CardCatalogPhotos {
  static const String communityA =
      'https://images.unsplash.com/photo-1513682121497-80211f36a7d3?w=600&q=80&auto=format&fit=crop';
  static const String communityB =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&q=80&auto=format&fit=crop';
  static const String eventA =
      'https://images.unsplash.com/photo-1496096265110-f83ad7f96608?w=320&q=80&auto=format&fit=crop';
  static const String eventB =
      'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=320&q=80&auto=format&fit=crop';
  static const String heroRobot =
      'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=960&q=80&auto=format&fit=crop';
}

Widget _buildCardVariants(BuildContext context) {
  final bool dark = context.isDark;
  final Color secondaryBg = dark
      ? const Color(0xFF232325)
      : const Color(0xFFEFEFEF);
  final Color tertiaryBg = dark
      ? const Color(0xFF262728)
      : const Color(0xFFEAEAEA);

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const KasyCard(
        padding: EdgeInsets.all(KasySpacing.md),
        child: _CatalogTwoLineCardBody(
          title: 'Default',
          description:
              'Standard card appearance (surface-secondary). '
              'The default card variant for most use cases',
        ),
      ),
      const SizedBox(height: KasySpacing.md),
      KasyCard(
        variant: KasyCardVariant.filled,
        color: secondaryBg,
        padding: const EdgeInsets.all(KasySpacing.md),
        child: const _CatalogTwoLineCardBody(
          title: 'Secondary',
          description:
              'Medium prominence (surface-tertiary). Use to '
              'draw moderate attention.',
        ),
      ),
      const SizedBox(height: KasySpacing.md),
      KasyCard(
        variant: KasyCardVariant.filled,
        color: tertiaryBg,
        padding: const EdgeInsets.all(KasySpacing.md),
        child: const _CatalogTwoLineCardBody(
          title: 'Tertiary',
          description:
              'Higher prominence (surface-tertiary). Use for '
              'important content.',
        ),
      ),
      const SizedBox(height: KasySpacing.md),
      const KasyCard(
        variant: KasyCardVariant.outlined,
        padding: EdgeInsets.all(KasySpacing.md),
        child: _CatalogTwoLineCardBody(
          title: 'Transparent',
          description:
              'Minimal prominence with transparent background. '
              'Use for less important content or nested cards.',
        ),
      ),
    ],
  );
}

Widget _buildCardProduct(BuildContext context) {
  return KasyCard(
    padding: const EdgeInsets.all(KasySpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          r'$450',
          style: context.textTheme.headlineSmall?.copyWith(
            color: _kCatalogRetailPriceAccent,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(
          'Living room Sofa',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: KasySpacing.xs),
        Text(
          'This sofa is perfect for modern tropical spaces, baroque inspired spaces.',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        const KasyButton(
          label: 'Buy now',
          expand: true,
          onPressed: _triggerTapFeedback,
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyHover(
          onTap: _triggerTapFeedback,
          borderRadius: KasyRadius.mdBorderRadius,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add to cart',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(KasyIcons.shoppingBag, size: 18),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCardCommunity(BuildContext context) {
  return const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _CatalogCommunityImageCard(
          imageUrl: _CardCatalogPhotos.communityA,
          title: 'Indie Hackers',
          subtitle: '148 members',
          handle: '@indiehackers',
          dotColor: Color(0xFFFF6B6B),
        ),
      ),
      SizedBox(width: KasySpacing.md),
      Expanded(
        child: _CatalogCommunityImageCard(
          imageUrl: _CardCatalogPhotos.communityB,
          title: 'AI Builders',
          subtitle: '362 members',
          handle: '@aibuilders',
          dotColor: Color(0xFF51CF66),
        ),
      ),
    ],
  );
}

Widget _buildCardEventList(BuildContext context) {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _CatalogHorizontalImageCard(
        imageUrl: _CardCatalogPhotos.eventA,
        title: 'Avocado Hackathon',
        subtitle: 'Today, 6:30 PM',
      ),
      SizedBox(height: KasySpacing.md),
      _CatalogHorizontalImageCard(
        imageUrl: _CardCatalogPhotos.eventB,
        title: 'Sound Electro',
        subtitle: 'Wed, 4:30 PM',
      ),
    ],
  );
}

Widget _buildCardHero(BuildContext context) {
  final TextTheme textTheme = Theme.of(context).textTheme;
  return KasyCard(
    padding: EdgeInsets.zero,
    child: AspectRatio(
      aspectRatio: 0.95,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(KasyRadius.xl),
            child: Image.network(
              _CardCatalogPhotos.heroRobot,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  ColoredBox(color: context.colors.surfaceNeutralSoft),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KasyRadius.xl),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
          Positioned(
            left: KasySpacing.lg,
            top: KasySpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEO',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: KasySpacing.xs),
                Text(
                  'Home robot',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: KasySpacing.lg,
            right: KasySpacing.lg,
            bottom: KasySpacing.lg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Available soon',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Get notified',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                const KasyButton(
                  label: 'Notify me',
                  variant: KasyButtonVariant.inverse,
                  size: KasyButtonSize.small,
                  foregroundColor: Colors.black,
                  onPressed: _triggerTapFeedback,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCardSpotlightIcon(BuildContext context) {
  return const KasySpotlightCard.icon(
    tag: 'Privacidade',
    icon: Icons.shield_outlined,
    headline: 'Feito pra você, com respeito',
    body: 'Conteúdo alinhado ao seu perfil.',
  );
}

Widget _buildCardSpotlightMedia(BuildContext context) {
  final String asset = context.isDark
      ? 'assets/branding/logo-dark.png'
      : 'assets/branding/logo-light.png';

  return KasySpotlightCard.media(
    tag: 'Pra você',
    headline: 'Seu plano anual com 50% off',
    body: 'Oferta personalizada com base no que você mais usa.',
    cta: 'Saiba mais',
    imageAsset: asset,
  );
}

Widget _buildCardInteractiveAll(BuildContext context) {
  final TextStyle labelStyle =
      context.textTheme.labelSmall?.copyWith(
        color: context.colors.muted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ) ??
      const TextStyle();
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('ZOOM  ·  onTap', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      ..._buildCardInteractiveItems(context),
      const SizedBox(height: KasySpacing.lg),
      Text('FILL  ·  KasyHover', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      const _PressableCardsPreview(),
    ],
  );
}

List<Widget> _buildCardInteractiveItems(BuildContext context) {
  return [
    KasyCard(
      padding: const EdgeInsets.all(KasySpacing.md),
      onTap: _triggerTapFeedback,
      child: Row(
        children: [
          Icon(KasyIcons.star, color: context.colors.warning, size: 20),
          const SizedBox(width: KasySpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap me',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cards with onTap get pressable depth feedback.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(KasyIcons.chevronRight, color: context.colors.muted, size: 18),
        ],
      ),
    ),
    const SizedBox(height: KasySpacing.md),
    KasyCard(
      variant: KasyCardVariant.filled,
      padding: const EdgeInsets.all(KasySpacing.md),
      onTap: _triggerTapFeedback,
      child: Row(
        children: [
          Icon(
            KasyIcons.notification,
            color: context.colors.primary,
            size: 20,
          ),
          const SizedBox(width: KasySpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filled interactive',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Works with any variant.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(KasyIcons.chevronRight, color: context.colors.muted, size: 18),
        ],
      ),
    ),
  ];
}

Widget _buildDialogBasic(BuildContext context) {
  return _previewIntrinsicLaunch(
    KasyButton(
      label: 'Basic dialog',
      variant: KasyButtonVariant.soft,
      onPressed: () {
        showKasyDialog<void>(
          context: context,
          builder: (dialogCtx) => KasyDialog(
            leadingIcon: KasyIcons.download,
            title: 'Low Disk Space',
            message:
                'You are running low on disk space. Delete unnecessary files '
                'to free up space.',
            confirmLabel: 'Confirm',
            onConfirm: () {
              Navigator.of(dialogCtx).pop();
              _triggerTapFeedback();
            },
          ),
        );
      },
    ),
  );
}

/// Catalog: outer [showKasyBottomSheet], then nested [showKasyDialog] from the
/// sheet route context.
Widget _buildDialogBlurBackdrop(BuildContext context) {
  return _previewIntrinsicLaunch(
    KasyButton(
      label: 'Dialog with blur backdrop',
      variant: KasyButtonVariant.soft,
      onPressed: () {
        showKasyBlurDialog<void>(
          context: context,
          builder: (dialogCtx) => KasyDialog(
            leadingIcon: KasyIcons.trash,
            iconTone: KasyDialogIconTone.danger,
            title: 'Delete product',
            message:
                'Are you sure you want to delete this product? '
                'This action cannot be undone.',
            showCloseButton: false,
            actions: [
              KasyButton(
                label: 'Delete',
                variant: KasyButtonVariant.destructive,
                expand: true,
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  _triggerTapFeedback();
                },
              ),
              KasyButton(
                label: 'Cancel',
                variant: KasyButtonVariant.neutral,
                expand: true,
                onPressed: () => Navigator.of(dialogCtx).pop(),
              ),
            ],
          ),
        );
      },
    ),
  );
}

bool _isProfileEmailCandidateValid(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  final RegExp pattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return pattern.hasMatch(trimmed);
}

class _UpdateProfileInputDialog extends StatefulWidget {
  const _UpdateProfileInputDialog();

  @override
  State<_UpdateProfileInputDialog> createState() =>
      _UpdateProfileInputDialogState();
}

class _UpdateProfileInputDialogState extends State<_UpdateProfileInputDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final FocusNode _nameFocus;
  String? _nameErrorText;
  String? _emailErrorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _nameFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final String trimmedName = _nameController.text.trim();
    final bool nameOk = trimmedName.isNotEmpty;
    final bool emailOk = _isProfileEmailCandidateValid(_emailController.text);
    setState(() {
      _nameErrorText = nameOk ? null : 'Please enter your full name';
      _emailErrorText = emailOk ? null : 'Please enter a valid email address';
    });
    if (!nameOk || !emailOk) {
      return;
    }
    Navigator.of(context).pop();
    _triggerTapFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return KasyDialog(
      title: 'Update Profile',
      closeAboveTitle: true,
      closeButtonStyle: KasyDialogCloseButtonStyle.filledNeutral,
      closeFilledButtonExtent: 36,
      closeFilledIconGlyphSize: 14,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyTextField(
            controller: _nameController,
            focusNode: _nameFocus,
            variant: KasyTextFieldVariant.secondary,
            label: 'Full Name',
            showRequiredIndicator: true,
            hint: 'Enter your name',
            errorText: _nameErrorText,
            onChanged: (_) {
              if (_nameErrorText != null) {
                setState(() => _nameErrorText = null);
              }
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: KasySpacing.md),
          KasyTextField(
            controller: _emailController,
            variant: KasyTextFieldVariant.secondary,
            label: 'Email Address',
            showRequiredIndicator: true,
            hint: 'email@example.com',
            contentType: KasyTextFieldContentType.email,
            errorText: _emailErrorText,
            onChanged: (_) {
              if (_emailErrorText != null) {
                setState(() => _emailErrorText = null);
              }
            },
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onSubmit(),
          ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          KasyButton(
            label: 'Cancel',
            variant: KasyButtonVariant.ghost,
            size: KasyButtonSize.small,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: KasySpacing.sm),
          KasyButton(
            label: 'Update Profile',
            size: KasyButtonSize.small,
            onPressed: _onSubmit,
          ),
        ],
      ),
    );
  }
}

Widget _buildDialogTextInput(BuildContext context) {
  return _previewIntrinsicLaunch(
    KasyButton(
      label: 'Dialog with TextField',
      variant: KasyButtonVariant.soft,
      onPressed: () {
        showKasyBlurDialog<void>(
          context: context,
          builder: (_) => const _UpdateProfileInputDialog(),
        );
      },
    ),
  );
}

const String _dialogLongContentLorem =
    'Zacchaeus was a chief tax collector living in Jericho, a prosperous city along the Jordan River. '
    'He had grown wealthy by collecting taxes on behalf of the Roman Empire, often taking more than what was required.\n\n'
    'Despite his wealth, Zacchaeus carried a deep sense of loneliness. He was despised by his own people, '
    'who considered him a traitor for serving Rome. No one invited him to their table, and no one called him a friend.\n\n'
    'One day, word spread through the city that Jesus of Nazareth was passing through Jericho. Crowds gathered along the road, '
    'eager to catch a glimpse of the man everyone was talking about. Zacchaeus wanted to see him too, '
    'but being short in stature, he could not see over the crowd. So he ran ahead and climbed a sycamore tree.\n\n'
    'When Jesus reached the spot, he looked up and said, "Zacchaeus, come down immediately. I must stay at your house today." '
    'The crowd murmured in disapproval — why would Jesus go to the home of a sinner? '
    'But Zacchaeus came down at once and welcomed Jesus with great joy.\n\n'
    'That encounter changed everything. Zacchaeus stood before Jesus and declared that he would give half of his possessions '
    'to the poor and repay four times the amount to anyone he had cheated. Jesus smiled and said, '
    '"Today salvation has come to this house." Zacchaeus had been seen, truly seen, and that was enough to transform him.';

Widget _buildDialogLongContent(BuildContext context) {
  return _previewIntrinsicLaunch(
    KasyButton(
      label: 'Dialog with long content',
      variant: KasyButtonVariant.soft,
      onPressed: () {
        showKasyScaffoldToneDialog<void>(
          context: context,
          builder: (dialogCtx) {
            final MediaQueryData mq = MediaQuery.of(dialogCtx);
            final double safeHeight = mq.size.height - mq.padding.vertical;
            final double bodyMax = (safeHeight * 0.35).clamp(
              180.0,
              safeHeight * 0.40,
            );
            return KasyDialog(
              title: 'Upload Audio',
              titleCentered: true,
              closeAboveTitle: true,
              body: KasyDialogScrollableBody(
                maxHeight: bodyMax,
                padding: const EdgeInsets.symmetric(horizontal: KasySpacing.sm),
                child: Text(
                  _dialogLongContentLorem,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogCtx).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.6,
                    color: dialogCtx.colors.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KasyButton(
                    label: 'Agree to Terms',
                    variant: KasyButtonVariant.soft,
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

// — Variants (emphasis) for one type —

Widget _buildChipVariants(BuildContext context) {
  Widget row(String name, KasyChipVariant variant) => Padding(
        padding: const EdgeInsets.symmetric(vertical: KasySpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                name,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.muted,
                ),
              ),
            ),
            KasyChip(
              label: 'Primary',
              type: KasyChipType.primary,
              variant: variant,
            ),
          ],
        ),
      );
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      row('Primary', KasyChipVariant.primary),
      row('Secondary', KasyChipVariant.secondary),
      row('Tertiary', KasyChipVariant.tertiary),
      row('Soft', KasyChipVariant.soft),
    ],
  );
}

// — Types (semantic colour), soft variant —

Widget _buildChipTypes(BuildContext context) {
  return const Wrap(
    spacing: KasySpacing.sm,
    runSpacing: KasySpacing.sm,
    alignment: WrapAlignment.center,
    children: [
      KasyChip(label: 'Primary', type: KasyChipType.primary),
      KasyChip(label: 'Default'),
      KasyChip(label: 'Success', type: KasyChipType.success),
      KasyChip(label: 'Warning', type: KasyChipType.warning),
      KasyChip(label: 'Danger', type: KasyChipType.danger),
    ],
  );
}

// — Sizes —

Widget _buildChipSizes(BuildContext context) {
  return const Wrap(
    spacing: KasySpacing.md,
    runSpacing: KasySpacing.sm,
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      KasyChip(
        label: 'Large',
        type: KasyChipType.primary,
        variant: KasyChipVariant.primary,
        size: KasyChipSize.lg,
      ),
      KasyChip(
        label: 'Medium',
        type: KasyChipType.primary,
        variant: KasyChipVariant.primary,
      ),
      KasyChip(
        label: 'Small',
        type: KasyChipType.primary,
        variant: KasyChipVariant.primary,
        size: KasyChipSize.sm,
      ),
    ],
  );
}

// — Prefix & suffix —

Widget _buildChipIcons(BuildContext context) {
  return const Wrap(
    spacing: KasySpacing.sm,
    runSpacing: KasySpacing.sm,
    alignment: WrapAlignment.center,
    children: [
      KasyChip(
        label: 'Favorite',
        type: KasyChipType.danger,
        prefixIcon: KasyIcons.favoriteFilled,
      ),
      KasyChip(
        label: 'Verified',
        type: KasyChipType.success,
        variant: KasyChipVariant.primary,
        prefixIcon: KasyIcons.check,
      ),
      KasyChip(
        label: 'Dropdown',
        type: KasyChipType.primary,
        suffixIcon: KasyIcons.chevronDown,
      ),
      KasyChip(
        label: 'Disabled',
        prefixIcon: KasyIcons.star,
        enabled: false,
      ),
    ],
  );
}

// — Removable tags (interactive) —

Widget _buildChipRemovable(BuildContext context) => const _ChipRemovablePreview();

class _ChipRemovablePreview extends StatefulWidget {
  const _ChipRemovablePreview();

  @override
  State<_ChipRemovablePreview> createState() => _ChipRemovablePreviewState();
}

class _ChipRemovablePreviewState extends State<_ChipRemovablePreview> {
  List<String> _tags = ['Flutter', 'Dart', 'Firebase', 'Design', 'Kasy'];

  @override
  Widget build(BuildContext context) {
    if (_tags.isEmpty) {
      return KasyChip(
        label: 'Reset tags',
        type: KasyChipType.primary,
        prefixIcon: KasyIcons.refresh,
        onPressed: () => setState(() {
          _tags = ['Flutter', 'Dart', 'Firebase', 'Design', 'Kasy'];
        }),
      );
    }
    return Wrap(
      spacing: KasySpacing.sm,
      runSpacing: KasySpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final tag in _tags)
          KasyChip(
            label: tag,
            type: KasyChipType.primary,
            suffixIcon: KasyIcons.close,
            onSuffixTap: () => setState(() => _tags.remove(tag)),
          ),
      ],
    );
  }
}

// — Status list (mirrors the HeroUI "Examples" section) —

// Status chips with a leading colour dot — mirrors the HeroUI Chip "Examples"
// section: the same four statuses shown twice, as `secondary` (soft grey fill,
// top row) then `primary` (solid fill, bottom row).
Widget _buildChipStatus(BuildContext context) {
  final KasyColors c = context.colors;

  // The dot always matches the label colour: soft-foreground on the non-solid
  // rows (e.g. danger #a43532), foreground on the solid `primary` row (e.g.
  // danger white). (label, type, soft-foreground, solid-row foreground)
  final List<(String, KasyChipType, Color, Color)> statuses = [
    ('Information', KasyChipType.neutral, c.neutralForeground, c.neutralForeground),
    ('Completed', KasyChipType.success, c.successSoftForeground, c.successForeground),
    ('Pending', KasyChipType.warning, c.warningSoftForeground, c.warningForeground),
    ('Failed', KasyChipType.danger, c.dangerSoftForeground, c.dangerForeground),
  ];

  // The dot lives in a 14px box (matching the chip's icon footprint) with the
  // circle centred inside — that surrounding space is what gives the dot its
  // breathing room and clean vertical centring against the label, exactly like
  // the icon slots in the Figma kit.
  Widget dot(Color color) => SizedBox(
        width: 14,
        height: 14,
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      );

  KasyChip chip(
    (String, KasyChipType, Color, Color) s,
    KasyChipVariant variant,
  ) {
    final (label, type, vivid, onSolid) = s;
    return KasyChip(
      label: label,
      type: type,
      variant: variant,
      prefix: dot(variant == KasyChipVariant.primary ? onSolid : vivid),
    );
  }

  // 2-up / 2-down so the four statuses never wrap unevenly (a single row drops
  // "Failed" onto its own line on narrow widths).
  Widget grid(KasyChipVariant variant) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              chip(statuses[0], variant),
              const SizedBox(width: KasySpacing.sm),
              chip(statuses[1], variant),
            ],
          ),
          const SizedBox(height: KasySpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              chip(statuses[2], variant),
              const SizedBox(width: KasySpacing.sm),
              chip(statuses[3], variant),
            ],
          ),
        ],
      );

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      grid(KasyChipVariant.secondary),
      const SizedBox(height: KasySpacing.lg),
      grid(KasyChipVariant.primary),
    ],
  );
}

Widget _buildBadgeDefault(BuildContext context) {
  final TextStyle labelStyle =
      context.textTheme.labelSmall?.copyWith(
        color: context.colors.muted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ) ??
      const TextStyle();
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KasyBadged(
              badge: const KasyBadge(text: '5'),
              child: KasyAvatar.gradientFill(
                size: KasyAvatarSize.medium,
                showShadow: false,
                gradient: KasyAvatarGradients.blue,
              ),
            ),
            const SizedBox(height: KasySpacing.sm),
            Text('UNREAD', style: labelStyle),
          ],
        ),
        const SizedBox(width: KasySpacing.md),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KasyBadged(
              badge: const KasyBadge(text: 'New', tone: KasyBadgeTone.primary),
              child: KasyAvatar.gradientFill(
                size: KasyAvatarSize.medium,
                showShadow: false,
                gradient: KasyAvatarGradients.hotPink,
              ),
            ),
            const SizedBox(height: KasySpacing.sm),
            Text('COUNT', style: labelStyle),
          ],
        ),
        const SizedBox(width: KasySpacing.md),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KasyBadged(
              placement: KasyBadgePlacement.bottomRight,
              badge: const KasyBadge.dot(
                tone: KasyBadgeTone.success,
                size: KasyBadgeSize.lg,
              ),
              child: KasyAvatar.gradientFill(
                size: KasyAvatarSize.medium,
                showShadow: false,
                gradient: KasyAvatarGradients.sky,
              ),
            ),
            const SizedBox(height: KasySpacing.sm),
            Text('MAX COUNT', style: labelStyle),
          ],
        ),
      ],
    ),
  );
}

// ── Status Tag previews ──────────────────────────────────────────────────────

Widget _buildStatusTagTones(BuildContext context) {
  return const Center(
    child: Wrap(
      spacing: KasySpacing.sm,
      runSpacing: KasySpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        KasyStatusTag(label: 'Active', tone: KasyStatusTagTone.success),
        KasyStatusTag(label: 'Subscriber', tone: KasyStatusTagTone.primary),
        KasyStatusTag(label: 'Pending', tone: KasyStatusTagTone.warning),
        KasyStatusTag(label: 'Blocked', tone: KasyStatusTagTone.danger),
        KasyStatusTag(label: 'Inactive'),
      ],
    ),
  );
}

Widget _buildStatusTagNoDot(BuildContext context) {
  return const Center(
    child: Wrap(
      spacing: KasySpacing.sm,
      runSpacing: KasySpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        KasyStatusTag(
          label: 'Visible',
          tone: KasyStatusTagTone.success,
          showDot: false,
        ),
        KasyStatusTag(
          label: 'Hidden',
          showDot: false,
        ),
      ],
    ),
  );
}

Widget _buildStatusTagInRow(BuildContext context) {
  return const Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyStatusTag(label: 'Active', tone: KasyStatusTagTone.success),
        SizedBox(width: KasySpacing.sm),
        KasyStatusTag(label: 'Subscriber', tone: KasyStatusTagTone.primary),
      ],
    ),
  );
}

Widget _buildBadgeColors(BuildContext context) {
  return const _BadgeColorsPreview();
}

Widget _buildBadgeSizes(BuildContext context) {
  return const _BadgeSizesPreview();
}

Widget _buildBadgeVariants(BuildContext context) {
  return const _BadgeVariantsPreview();
}

Widget _buildBadgePlacements(BuildContext context) {
  return const _BadgePlacementsPreview();
}

Widget _buildBadgeDot(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'TONES',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.muted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: KasySpacing.sm),
      const _BadgeDotPreview(),
    ],
  );
}

Widget _buildBadgeWithContent(BuildContext context) {
  return const _BadgeWithContentPreview();
}

Widget _buildBasicTextFieldVariant(BuildContext context) {
  return const _BasicTextFieldVariantContent();
}

Widget _buildTextFieldWithLabelDescriptionVariant(BuildContext context) {
  return const _TextFieldWithLabelDescriptionVariantContent();
}

Widget _buildTextFieldStandard(BuildContext context) {
  return const _TextFieldStandardContent();
}

Widget _buildTextFieldCharacterLimit(BuildContext context) {
  final TextStyle labelStyle =
      context.textTheme.labelSmall?.copyWith(
        color: context.colors.muted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ) ??
      const TextStyle();
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('TITLE FIELD', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      const KasyTextField(
        label: 'Resource title',
        hint: 'Enter a short descriptive title',
        maxLength: 40,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: KasySpacing.lg),
      Text('DESCRIPTION FIELD', style: labelStyle),
      const SizedBox(height: KasySpacing.sm),
      const KasyTextField(
        label: 'Description',
        hint: 'Describe the resource or improvement',
        minLines: 5,
        maxLines: 5,
        maxLength: 1000,
        textInputAction: TextInputAction.newline,
      ),
    ],
  );
}

Widget _buildTextFieldVariantsVariant(BuildContext context) {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KasyTextField(
        label: 'Primary Variant',
        hint: 'Primary style text field',
        description: 'Default variant with primary styling',
        contentType: KasyTextFieldContentType.email,
      ),
      SizedBox(height: KasySpacing.lg),
      KasyTextField(
        label: 'Secondary Variant',
        hint: 'Secondary style text field',
        description: 'Elevated fill on cards and modals',
        variant: KasyTextFieldVariant.secondary,
        contentType: KasyTextFieldContentType.email,
      ),
      SizedBox(height: KasySpacing.lg),
      KasyTextField(
        label: 'Flat Variant',
        hint: 'Flat style text field',
        description: 'Surface fill, field-flat border, no shadow',
        variant: KasyTextFieldVariant.flat,
        contentType: KasyTextFieldContentType.email,
      ),
      SizedBox(height: KasySpacing.lg),
      KasyTextField(
        label: 'Tonal Variant',
        hint: 'Search…',
        description: 'surface/secondary fill, no border (header search)',
        variant: KasyTextFieldVariant.tonal,
        prefix: Icon(KasyIcons.search),
      ),
    ],
  );
}

Widget _buildTextFieldStates(BuildContext context) {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KasyTextField(
        label: 'Default State',
        hint: 'Enter your email',
        description: 'Normal text field state',
        contentType: KasyTextFieldContentType.email,
      ),
      SizedBox(height: KasySpacing.lg),
      KasyTextField(
        label: 'Disabled State',
        hint: 'Read only value',
        description: 'TextField is disabled and cannot be edited',
        enabled: false,
        contentType: KasyTextFieldContentType.email,
      ),
      SizedBox(height: KasySpacing.lg),
      KasyTextField(
        label: 'Invalid State',
        hint: 'Enter your email',
        errorText: 'Please enter a valid email address',
        isInvalid: true,
        contentType: KasyTextFieldContentType.email,
      ),
    ],
  );
}

Widget _buildTextFieldWithIcon(BuildContext context) {
  return const _TextFieldWithIconContent();
}

Widget _buildTextFieldMultiline(BuildContext context) {
  return const _TextFieldMultilineContent();
}

Widget _buildTextAreaBasic(BuildContext context) {
  return const _TextAreaBasicContent();
}

Widget _buildTextAreaWithLabelDescription(BuildContext context) {
  return const _TextAreaWithLabelDescriptionContent();
}

Widget _buildTextAreaVariants(BuildContext context) {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KasyTextArea(
        label: 'Primary Variant',
        hint: 'Primary style text area',
        description: 'Default variant with primary styling',
      ),
      SizedBox(height: KasySpacing.lg),
      KasyTextArea(
        label: 'Secondary Variant',
        hint: 'Secondary style text area',
        description: 'Secondary variant for surfaces',
        variant: KasyTextFieldVariant.secondary,
      ),
      SizedBox(height: KasySpacing.lg),
      KasyTextArea(
        label: 'Flat Variant',
        hint: 'Flat style text area',
        description: 'Primary fill, hairline border, no shadow',
        variant: KasyTextFieldVariant.flat,
      ),
    ],
  );
}

Widget _buildTextAreaStates(BuildContext context) {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KasyTextArea(
        label: 'Disabled State',
        hint: 'Read only value',
        description: 'Text area is disabled and cannot be edited',
        enabled: false,
      ),
      SizedBox(height: KasySpacing.lg),
      KasyTextArea(
        label: 'Invalid State',
        hint: 'Enter your message',
        isInvalid: true,
        errorText: 'Please enter a valid message',
      ),
    ],
  );
}

Widget _buildToastDefaultVariants(BuildContext context) =>
    const _ToastVariantsPreview();

Widget _buildToastPlacementVariants(BuildContext context) =>
    const _ToastPlacementPreview();

Widget _buildToastModalPreview(BuildContext context) =>
    const _ToastModalPreview();

Widget _buildToastCustomVariants(BuildContext context) =>
    const _ToastCustomVariantsPreview();

Widget _buildToastStaticPreview(BuildContext context) =>
    const _ToastStaticPreview();

// — Toast: custom variants launcher —

class _ToastCustomVariantsPreview extends StatefulWidget {
  const _ToastCustomVariantsPreview();

  @override
  State<_ToastCustomVariantsPreview> createState() =>
      _ToastCustomVariantsPreviewState();
}

class _ToastCustomVariantsPreviewState
    extends State<_ToastCustomVariantsPreview> {
  bool _active = false;

  void _show(Widget Function(VoidCallback dismiss) builder) {
    setState(() => _active = true);
    showKasyToastWidget(
      context,
      persistent: true,
      onClose: () {
        if (mounted) setState(() => _active = false);
      },
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _previewIntrinsicLaunch(
          KasyButton(
            label: 'Achievement toast',
            variant: KasyButtonVariant.soft,
            onPressed: _active
                ? null
                : () =>
                    _show((d) => _AchievementToastCard(onClose: d)),
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        _previewIntrinsicLaunch(
          KasyButton(
            label: 'Load data toast',
            variant: KasyButtonVariant.soft,
            onPressed:
                _active ? null : () => _show((d) => _LoadDataToastCard(onClose: d)),
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        _previewIntrinsicLaunch(
          KasyButton(
            label: 'Start upload toast',
            variant: KasyButtonVariant.soft,
            onPressed:
                _active ? null : () => _show((d) => _UploadToastCard(onClose: d)),
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        _previewIntrinsicLaunch(
          KasyButton(
            label: 'Hide all toasts',
            variant: KasyButtonVariant.destructiveSoft,
            onPressed: () {
              hideAllKasyToasts();
              setState(() => _active = false);
            },
          ),
        ),
      ],
    );
  }
}

// — Achievement toast card (warm bg + floating dots) —

class _AchievementToastCard extends StatefulWidget {
  const _AchievementToastCard({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_AchievementToastCard> createState() => _AchievementToastCardState();
}

class _AchievementToastCardState extends State<_AchievementToastCard>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dotCtrls;
  late final List<Animation<double>> _dotAnims;

  static const List<Color> _dotColors = [
    Color(0xFFF97316),
    Color(0xFFFBBF24),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
  ];

  static const List<Offset> _dotTargets = [
    Offset(-18, -14),
    Offset(-8, -22),
    Offset(8, -20),
    Offset(18, -12),
  ];

  @override
  void initState() {
    super.initState();
    _dotCtrls = List.generate(
      _dotColors.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      ),
    );
    _dotAnims = _dotCtrls
        .map(
          (c) => CurvedAnimation(parent: c, curve: Curves.easeOut),
        )
        .toList();

    // Staggered start
    for (int i = 0; i < _dotCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: 120 * i), () {
        if (mounted) _dotCtrls[i].repeat(reverse: true);
      });
    }

    // Auto-dismiss after 5s
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) widget.onClose();
    });
  }

  @override
  void dispose() {
    for (final c in _dotCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3E7),
        borderRadius: KasyRadius.lgBorderRadius,
        border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                KasyIcons.star,
                size: 24,
                color: Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: KasySpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New achievement!',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFF97316),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "You're on a 1-day study streak",
                    style: context.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF7C2D12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KasySpacing.smd),
            // Close button with floating dots
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < _dotColors.length; i++)
                  AnimatedBuilder(
                    animation: _dotAnims[i],
                    builder: (context, _) {
                      final t = _dotAnims[i].value;
                      return Positioned(
                        left: _dotTargets[i].dx * t,
                        top: _dotTargets[i].dy * t,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _dotColors[i].withValues(alpha: t),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: KasyButton(
                    label: 'Close',
                    size: KasyButtonSize.small,
                    backgroundColor:
                        const Color(0xFFF97316).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFFF97316),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// — Load data toast card (spinner → checkmark) —

class _LoadDataToastCard extends StatefulWidget {
  const _LoadDataToastCard({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_LoadDataToastCard> createState() => _LoadDataToastCardState();
}

class _LoadDataToastCardState extends State<_LoadDataToastCard>
    with SingleTickerProviderStateMixin {
  bool _done = false;
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() => _done = true);
      _spinCtrl.stop();
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) widget.onClose();
      });
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final bool isDark = context.isDark;

    // Spinner: gray + thin. Icon: green checkmark on success.
    final Widget indicator = _done
        ? Icon(KasyIcons.checkCircle, size: 18, color: c.success)
        : RotationTransition(
            turns: _spinCtrl,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(c.muted),
              ),
            ),
          );

    return UnconstrainedBox(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: KasyRadius.lgBorderRadius,
            border: Border.all(
              color: c.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Both icon and text change instantly via setState;
                // only AnimatedSize handles the smooth width expansion.
                indicator,
                const SizedBox(width: 8),
                Text(
                  _done ? 'Load success!' : 'Loading...',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: _done ? c.success : c.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// — Upload toast card (animated progress bar) —

class _UploadToastCard extends StatefulWidget {
  const _UploadToastCard({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_UploadToastCard> createState() => _UploadToastCardState();
}

class _UploadToastCardState extends State<_UploadToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..forward();

    _progressCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) widget.onClose();
        });
      }
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final bool isDark = context.isDark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: KasyRadius.lgBorderRadius,
        border: Border.all(
          color: c.outline.withValues(alpha: isDark ? 0.22 : 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _progressCtrl,
              builder: (context, _) {
                // Transition from primary → success in the last 10% of progress
                final colorT =
                    ((_progressCtrl.value - 0.9) / 0.1).clamp(0.0, 1.0);
                final iconColor =
                    Color.lerp(c.primary, c.success, colorT)!;
                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(KasyIcons.arrowUp, size: 24, color: iconColor),
                );
              },
            ),
            const SizedBox(width: KasySpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (context, _) {
                      final pct = (_progressCtrl.value * 100).round();
                      final bool done = _progressCtrl.value >= 1.0;
                      return Text(
                        done ? 'Upload complete!' : 'Uploading... $pct%',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: done ? c.success : c.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (context, _) {
                      final bool done = _progressCtrl.value >= 1.0;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: _progressCtrl.value,
                          minHeight: 5,
                          backgroundColor:
                              c.outline.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            done ? c.success : c.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// — Toast: interactive launcher —

class _ToastVariantsPreview extends StatelessWidget {
  const _ToastVariantsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _toastBtn(
          context,
          label: 'Default toast',
          onTap: () => showKasyToast(
            context,
            title: 'Join a team',
            message:
                'You have been invited to join the team!',
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        _toastBtn(
          context,
          label: 'Accent toast',
          onTap: () => showKasyToast(
            context,
            title: 'You have 2 credits left',
            message: 'Get a paid plan for more credits',
            tone: KasyToastTone.primary,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        _toastBtn(
          context,
          label: 'Success toast',
          onTap: () => showKasyToast(
            context,
            title: 'You have upgraded your plan',
            message: 'You can continue using Kasy Chat',
            tone: KasyToastTone.success,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        _toastBtn(
          context,
          label: 'Warning toast',
          onTap: () => showKasyToast(
            context,
            title: 'You have no credits left',
            message: 'Upgrade to a paid plan to continue',
            tone: KasyToastTone.warning,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        _toastBtn(
          context,
          label: 'Danger toast',
          onTap: () => showKasyToast(
            context,
            title: 'Storage is full',
            message:
                'Remove files to release space. Adding more content may cause issues.',
            tone: KasyToastTone.danger,
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        _previewIntrinsicLaunch(
          const KasyButton(
            label: 'Hide all toasts',
            variant: KasyButtonVariant.destructiveSoft,
            onPressed: hideAllKasyToasts,
          ),
        ),
      ],
    );
  }

  Widget _toastBtn(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return _previewIntrinsicLaunch(
      KasyButton(
        label: label,
        variant: KasyButtonVariant.soft,
        onPressed: onTap,
      ),
    );
  }
}

// — Toast: static cards preview (all 5 tones, close buttons functional) —

class _ToastStaticPreview extends StatefulWidget {
  const _ToastStaticPreview();

  @override
  State<_ToastStaticPreview> createState() => _ToastStaticPreviewState();
}

class _ToastStaticPreviewState extends State<_ToastStaticPreview> {
  final Set<int> _dismissed = {};

  @override
  Widget build(BuildContext context) {
    final items = <(int, KasyToast)>[
      (
        0,
        // Default (neutral) tone renders the app brand logo automatically.
        KasyToast(
          title: 'Join a team',
          message:
              'You have been invited to join the team!',
          onClose: () => setState(() => _dismissed.add(0)),
        ),
      ),
      (
        1,
        KasyToast(
          title: 'You have 2 credits left',
          message: 'Get a paid plan for more credits',
          tone: KasyToastTone.primary,
          onClose: () => setState(() => _dismissed.add(1)),
        ),
      ),
      (
        2,
        KasyToast(
          title: 'You have upgraded your plan',
          message: 'You can continue using Kasy Chat',
          tone: KasyToastTone.success,
          onClose: () => setState(() => _dismissed.add(2)),
        ),
      ),
      (
        3,
        KasyToast(
          title: 'You have no credits left',
          message: 'Upgrade to a paid plan to continue',
          tone: KasyToastTone.warning,
          onClose: () => setState(() => _dismissed.add(3)),
        ),
      ),
      (
        4,
        KasyToast(
          title: 'Storage is full',
          message:
              "Remove files to release space. I'm adding more text as usual but it's okay I guess I just want to see how it looks with a lot of information",
          tone: KasyToastTone.danger,
          onClose: () => setState(() => _dismissed.add(4)),
        ),
      ),
    ];

    final visible = items.where((e) => !_dismissed.contains(e.$1)).toList();

    if (visible.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(KasyIcons.checkCircle,
                size: 32, color: context.colors.success),
            const SizedBox(height: KasySpacing.sm),
            Text(
              'All dismissed',
              style: context.textTheme.bodySmall
                  ?.copyWith(color: context.colors.muted),
            ),
            const SizedBox(height: KasySpacing.md),
            KasyButton(
              label: 'Reset',
              variant: KasyButtonVariant.soft,
              onPressed: () => setState(() => _dismissed.clear()),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (idx, toast) in visible) ...[
          if (idx != visible.first.$1) const SizedBox(height: KasySpacing.sm),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: toast,
          ),
        ],
      ],
    );
  }
}

// — Toast: placement variants (top / bottom) —

class _ToastPlacementPreview extends StatelessWidget {
  const _ToastPlacementPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _previewIntrinsicLaunch(
          KasyButton(
            label: 'Top toast',
            variant: KasyButtonVariant.soft,
            onPressed: () => showKasyToast(
              context,
              title: 'Top notification',
              message: 'Slide in from the top of the screen',
              tone: KasyToastTone.primary,
            ),
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        _previewIntrinsicLaunch(
          KasyButton(
            label: 'Bottom toast',
            variant: KasyButtonVariant.soft,
            onPressed: () => showKasyToast(
              context,
              title: 'Bottom notification',
              message: 'Slide in from the bottom of the screen',
              tone: KasyToastTone.success,
              placement: KasyToastPlacement.bottom,
            ),
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        _previewIntrinsicLaunch(
          const KasyButton(
            label: 'Hide all toasts',
            variant: KasyButtonVariant.destructiveSoft,
            onPressed: hideAllKasyToasts,
          ),
        ),
      ],
    );
  }
}

// — Toast: from native modal —

class _ToastModalPreview extends StatelessWidget {
  const _ToastModalPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.pageHorizontalGutter,
      ),
      child: _previewIntrinsicLaunch(
        KasyButton(
          label: 'Open page sheet',
          variant: KasyButtonVariant.soft,
          onPressed: () {
            _triggerTapFeedback();
            showKasyBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (sheetCtx) => FractionallySizedBox(
                heightFactor: 0.92,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(KasyRadius.xl),
                  ),
                  child: ColoredBox(
                    color: sheetCtx.colors.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const KasyAppBar(
                          title: 'Toast from page sheet',
                          style: KasyAppBarStyle.rootTab,
                          useSafeArea: false,
                          toolbarHeight: 48,
                          topInset: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KasySpacing.lg,
                            vertical: KasySpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Toasts aparecem acima do page sheet, sobre qualquer camada de navegacao.',
                                style: sheetCtx.textTheme.bodyMedium?.copyWith(
                                  color: sheetCtx.colors.onSurface
                                      .withValues(alpha: 0.6),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: KasySpacing.lg),
                              _previewIntrinsicLaunch(
                                KasyButton(
                                  label: 'Show toast',
                                  variant: KasyButtonVariant.soft,
                                  onPressed: () => showKasyToast(
                                    sheetCtx,
                                    title: 'Toast from page sheet',
                                    message:
                                        'Appears above the sheet as expected',
                                    tone: KasyToastTone.success,
                                  ),
                                ),
                              ),
                              const SizedBox(height: KasySpacing.sm),
                              _previewIntrinsicLaunch(
                                const KasyButton(
                                  label: 'Hide all toasts',
                                  variant: KasyButtonVariant.destructiveSoft,
                                  onPressed: hideAllKasyToasts,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AccordionPreview extends StatefulWidget {
  final KasyAccordionVariant variant;

  const _AccordionPreview({required this.variant});

  @override
  State<_AccordionPreview> createState() => _AccordionPreviewState();
}

class _AccordionPreviewState extends State<_AccordionPreview> {
  late Set<int> _expandedIndices;

  @override
  void initState() {
    super.initState();
    _expandedIndices = widget.variant == KasyAccordionVariant.elevatedCard
        ? <int>{0, 1}
        : <int>{1};
  }

  @override
  void didUpdateWidget(covariant _AccordionPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant) {
      _expandedIndices = widget.variant == KasyAccordionVariant.elevatedCard
          ? <int>{0, 1}
          : <int>{1};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == KasyAccordionVariant.elevatedCard) {
      return KasyAccordion.multiple(
        surfaceRadius: 28,
        items: _kAccordionElevatedItems,
        expandedIndices: _expandedIndices,
        onExpandedIndicesChanged: (Set<int> next) {
          setState(() => _expandedIndices = next);
          KasyHaptics.selection(context);
        },
      );
    }
    return KasyAccordion.single(
      variant: widget.variant,
      surfaceRadius: 22,
      items: _kAccordionItems,
      expandedIndex: _expandedIndices.isEmpty ? -1 : _expandedIndices.first,
      onExpandedIndexChanged: (int index) {
        setState(() {
          _expandedIndices = index < 0 ? <int>{} : <int>{index};
        });
        KasyHaptics.selection(context);
      },
    );
  }
}

/// Presents [KasyAppBar.application] inside a desktop browser-window mock (title
/// bar + faux sidebar + content) so the preview reads as the desktop chrome it
/// is — the responsive desktop half of [KasyAppBar].
class _ApplicationBarPreview extends StatelessWidget {
  /// The exact config a screen would publish — rendered through the same
  /// [KasyAppBar.fromConfig] the shell uses, so the preview mirrors real usage.
  final KasyAppBarConfig config;

  const _ApplicationBarPreview({required this.config});

  /// Width the mock window is laid out at. The application bar is desktop chrome
  /// (220px search + actions), so it needs a desktop-class width — we render at
  /// this width and scale the whole window down to fit the (narrow) preview card.
  /// Without this, the bar overflows on a phone-sized preview.
  static const double _mockWindowWidth = 760;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: _mockWindowWidth,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(KasyRadius.lg),
            border: Border.all(color: c.onSurface.withValues(alpha: 0.10)),
            boxShadow: [KasyShadows.component(context)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KasyRadius.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BrowserTopBar(),
                // The real bar, flush — no corner radius of its own.
                KasyAppBar.fromConfig(config),
                const SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DesktopMockSidebar(),
                      Expanded(child: _DesktopMockContent()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// macOS-style window chrome: traffic-light dots + an address pill.
class _BrowserTopBar extends StatelessWidget {
  const _BrowserTopBar();

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.surfaceNeutralSoft,
        border: Border(
          bottom: BorderSide(color: c.onSurface.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          _trafficDot(const Color(0xFFFF5F57)),
          const SizedBox(width: 8),
          _trafficDot(const Color(0xFFFEBC2E)),
          const SizedBox(width: 8),
          _trafficDot(const Color(0xFF28C840)),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(KasyRadius.full),
                border: Border.all(
                  color: c.onSurface.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trafficDot(Color color) => Container(
    width: 11,
    height: 11,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Narrow faux navigation rail to the left of the content area.
class _DesktopMockSidebar extends StatelessWidget {
  const _DesktopMockSidebar();

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Container(
      width: 76,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          right: BorderSide(color: c.onSurface.withValues(alpha: 0.08)),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(KasySpacing.smd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _AppBarBodyLine(widthFactor: 1),
            SizedBox(height: KasySpacing.sm),
            _AppBarBodyLine(widthFactor: 0.8),
            SizedBox(height: KasySpacing.sm),
            _AppBarBodyLine(widthFactor: 0.9),
            SizedBox(height: KasySpacing.sm),
            _AppBarBodyLine(widthFactor: 0.7),
          ],
        ),
      ),
    );
  }
}

/// Faux content area shown under the header in the desktop mock.
class _DesktopMockContent extends StatelessWidget {
  const _DesktopMockContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(KasySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _AppBarBodyLine(widthFactor: 0.4),
          SizedBox(height: KasySpacing.md),
          _AppBarBodyLine(widthFactor: 0.95),
          SizedBox(height: KasySpacing.sm),
          _AppBarBodyLine(widthFactor: 0.85),
          SizedBox(height: KasySpacing.sm),
          _AppBarBodyLine(widthFactor: 0.9),
        ],
      ),
    );
  }
}

class _AppBarPreview extends StatelessWidget {
  final KasyAppBarStyle variant;

  /// Shows a hamburger leading that opens a [KasySidebar] drawer from the left —
  /// the mobile "menu opens navigation" pattern.
  final bool withMenu;

  const _AppBarPreview({required this.variant, this.withMenu = false});

  @override
  Widget build(BuildContext context) {
    final Widget trailing = KasyChromeOrbIconButton(
      icon: Icons.more_vert,
      iconSize: 20,
      foregroundColor: context.colors.onSurface,
      fillColor: kasyChromeOrbFillColor(context),
      tooltip: 'More',
      onPressed: () {},
    );
    final Widget? leading = withMenu
        ? KasyChromeOrbIconButton(
            icon: KasyIcons.menu,
            iconSize: 20,
            foregroundColor: context.colors.onSurface,
            fillColor: kasyChromeOrbFillColor(context),
            tooltip: 'Menu',
            onPressed: () => _openSidebarDrawer(
              context,
              fromEnd: false,
              child: const _DemoSidebar(isDrawer: true),
            ),
          )
        : null;
    final KasyColors c = context.colors;
    // KasyAppBar hides itself at desktop width; the preview must always show it,
    // so pin a phone-sized MediaQuery just for the bar's own width check.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(size: const Size(390, 844)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(KasyRadius.xl),
          border: Border.all(
            color: c.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [KasyShadows.component(context)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(KasyRadius.xl),
          child: SizedBox(
            height: 236,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _AppBarMockBody(),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: KasyAppBar(
                    useSafeArea: false,
                    title: withMenu ? 'Home' : 'Preview',
                    style: variant,
                    onBack: () {},
                    leading: leading,
                    trailing: variant == KasyAppBarStyle.subpageActions
                        ? trailing
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarMockBody extends StatelessWidget {
  const _AppBarMockBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        KasySpacing.md,
        92,
        KasySpacing.md,
        KasySpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _AppBarBodyLine(widthFactor: 0.58),
          SizedBox(height: KasySpacing.sm),
          _AppBarBodyLine(widthFactor: 0.84),
          SizedBox(height: KasySpacing.sm),
          _AppBarBodyLine(widthFactor: 0.72),
          Spacer(),
          _AppBarBodyLine(widthFactor: 0.48),
        ],
      ),
    );
  }
}

class _AppBarBodyLine extends StatelessWidget {
  final double widthFactor;

  const _AppBarBodyLine({required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.outline.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(KasyRadius.full),
        ),
        child: const SizedBox(height: 10),
      ),
    );
  }
}

class _AlertLoadingPreview extends StatelessWidget {
  const _AlertLoadingPreview();

  @override
  Widget build(BuildContext context) {
    return const KasyAlert(
      title: 'Processing your request',
      message:
          'Please wait while we sync your data. This may take a few moments.',
      emphasizeTitleWithTone: true,
      isLoading: true,
    );
  }
}

class _ButtonSizesPreview extends StatelessWidget {
  const _ButtonSizesPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KasyButton(
          label: 'Small Button',
          onPressed: _noop,
          size: KasyButtonSize.small,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(label: 'Medium Button', onPressed: _noop, expand: true),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Large Button',
          onPressed: _noop,
          size: KasyButtonSize.large,
          expand: true,
        ),
      ],
    );
  }
}

class _ButtonVariantsPreview extends StatelessWidget {
  const _ButtonVariantsPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KasyButton(label: 'Primary', onPressed: _noop, expand: true),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Secondary',
          onPressed: _noop,
          variant: KasyButtonVariant.secondary,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Tertiary',
          onPressed: _noop,
          variant: KasyButtonVariant.tertiary,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Outline',
          onPressed: _noop,
          variant: KasyButtonVariant.outline,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Ghost',
          onPressed: _noop,
          variant: KasyButtonVariant.ghost,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Danger',
          onPressed: _noop,
          variant: KasyButtonVariant.destructive,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Danger Soft',
          onPressed: _noop,
          variant: KasyButtonVariant.destructiveSoft,
          expand: true,
        ),
      ],
    );
  }
}

class _ButtonDisabledStatePreview extends StatelessWidget {
  const _ButtonDisabledStatePreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KasyButton(
          label: 'Loading',
          onPressed: null,
          isLoading: true,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Loading',
          onPressed: null,
          isLoading: true,
          variant: KasyButtonVariant.neutral,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Access Denied',
          onPressed: null,
          icon: KasyIcons.info,
          variant: KasyButtonVariant.neutral,
          expand: true,
        ),
      ],
    );
  }
}

class _ButtonWidthAlignmentPreview extends StatelessWidget {
  const _ButtonWidthAlignmentPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KasyButton(label: 'Full Width Button', onPressed: _noop, expand: true),
        SizedBox(height: KasySpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: KasyButton(
            label: 'Start',
            onPressed: _noop,
            variant: KasyButtonVariant.soft,
            size: KasyButtonSize.small,
            width: 116,
          ),
        ),
        SizedBox(height: KasySpacing.md),
        Align(
          child: KasyButton(
            label: 'Center',
            onPressed: _noop,
            variant: KasyButtonVariant.soft,
            size: KasyButtonSize.small,
            width: 132,
          ),
        ),
        SizedBox(height: KasySpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: KasyButton(
            label: 'End',
            onPressed: _noop,
            variant: KasyButtonVariant.soft,
            size: KasyButtonSize.small,
            width: 108,
          ),
        ),
      ],
    );
  }
}

class _ButtonWithIconsPreview extends StatelessWidget {
  const _ButtonWithIconsPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KasyButton(
          label: 'Add Member',
          onPressed: _noop,
          icon: KasyIcons.add,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Download',
          onPressed: _noop,
          icon: KasyIcons.download,
          iconAlignment: KasyButtonIconAlignment.trailing,
          variant: KasyButtonVariant.soft,
          expand: true,
        ),
        SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Delete',
          onPressed: _noop,
          icon: KasyIcons.trash,
          variant: KasyButtonVariant.destructive,
          expand: true,
        ),
      ],
    );
  }
}

class _ButtonIconOnlyPreview extends StatelessWidget {
  const _ButtonIconOnlyPreview();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 4, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: KasyButton.iconOnly(
              icon: KasyIcons.share,
              onPressed: _noop,
              size: KasyButtonSize.small,
              hapticFeedbackEnabled: false,
              semanticLabel: 'Share',
            ),
          ),
          SizedBox(width: KasySpacing.md),
          Padding(
            padding: EdgeInsets.only(top: 14),
            child: KasyButton.iconOnly(
              icon: KasyIcons.favoriteFilled,
              onPressed: _noop,
              variant: KasyButtonVariant.soft,
              foregroundColor: KasyColors.semanticError,
              hapticFeedbackEnabled: false,
              semanticLabel: 'Favorite',
            ),
          ),
          SizedBox(width: KasySpacing.md),
          Padding(
            padding: EdgeInsets.only(top: 26),
            child: KasyButton.iconOnly(
              icon: KasyIcons.trash,
              onPressed: _noop,
              variant: KasyButtonVariant.destructive,
              size: KasyButtonSize.large,
              hapticFeedbackEnabled: false,
              semanticLabel: 'Delete',
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonCustomStylingPreview extends StatelessWidget {
  const _ButtonCustomStylingPreview();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;
    return Column(
      children: [
        const KasyButton(
          label: 'Custom Avocado',
          onPressed: _noop,
          backgroundColor: Color(0xFF7ACA45),
          foregroundColor: Colors.white,
          expand: true,
        ),
        const SizedBox(height: KasySpacing.md),
        const KasyButton(
          label: 'Gradient',
          onPressed: _noop,
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF94C9FF), Color(0xFF1E56A0)],
          ),
          foregroundColor: Colors.white,
          expand: true,
        ),
        const SizedBox(height: KasySpacing.md),
        const KasyButton(
          label: 'Pill Radius',
          onPressed: _noop,
          borderRadius: BorderRadius.all(Radius.circular(KasyRadius.full)),
          expand: true,
        ),
        const SizedBox(height: KasySpacing.md),
        KasyButton(
          label: 'Add to Cart',
          onPressed: _noop,
          icon: KasyIcons.shoppingBag,
          backgroundColor: isDark ? Colors.white : const Color(0xFF121212),
          foregroundColor: isDark ? Colors.black : Colors.white,
          borderColor: isDark
              ? const Color(0x1F000000)
              : const Color(0x0FFFFFFF),
          outlineWidth: 0.38,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          expand: true,
        ),
      ],
    );
  }
}

/// Cream + gold border pair from external Figma screens — hover on web
/// should stay on-palette (Components → Button → Custom palette hover).
class _ButtonCustomPaletteHoverPreview extends StatelessWidget {
  const _ButtonCustomPaletteHoverPreview();

  static const Color _creamFill = Color(0xFFFFF8E6);
  static const Color _goldBorder = Color(0xFFFFB900);
  static const Color _goldSolid = Color(0xFFFEBA43);

  @override
  Widget build(BuildContext context) {
    final TextStyle? caption = context.textTheme.bodySmall?.copyWith(
      color: context.colors.muted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (caption != null)
          Text(
            'Hover on web: veil follows border/fill, not label grey.',
            style: caption,
          ),
        if (caption != null) const SizedBox(height: KasySpacing.md),
        Row(
          children: [
            Expanded(
              child: KasyButton(
                label: 'Cancel booking',
                size: KasyButtonSize.small,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: _creamFill,
                borderColor: _goldBorder,
                foregroundColor: const Color(0xFF0D0D12),
                onPressed: _noop,
              ),
            ),
            const SizedBox(width: KasySpacing.smd),
            Expanded(
              child: KasyButton(
                label: 'E-Receipt',
                size: KasyButtonSize.small,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: _goldSolid,
                borderColor: _goldSolid,
                foregroundColor: Colors.white,
                onPressed: _noop,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ButtonHoverFillPreview extends StatelessWidget {
  static const BorderRadius _pill =
      BorderRadius.all(Radius.circular(KasyRadius.full));

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      color: context.colors.muted,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w700,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('FILL', style: labelStyle),
        const SizedBox(height: KasySpacing.sm),
        KasyButton(
          label: 'View plans',
          icon: KasyIcons.payment,
          variant: KasyButtonVariant.outline,
          pressEffect: KasyButtonPressEffect.fill,
          backgroundColor: context.colors.surface,
          borderRadius: _pill,
          expand: true,
          onPressed: _noop,
        ),
        const SizedBox(height: KasySpacing.sm),
        const KasyButton(
          label: 'Add to list',
          icon: KasyIcons.add,
          variant: KasyButtonVariant.outline,
          pressEffect: KasyButtonPressEffect.fill,
          expand: true,
          onPressed: _noop,
        ),
        const SizedBox(height: KasySpacing.lg),
        Text('ZOOM + FILL', style: labelStyle),
        const SizedBox(height: KasySpacing.sm),
        const KasyButton(
          label: 'Subscribe now',
          icon: KasyIcons.star,
          pressEffect: KasyButtonPressEffect.both,
          borderRadius: _pill,
          expand: true,
          onPressed: _noop,
        ),
        const SizedBox(height: KasySpacing.sm),
        const KasyButton(
          label: 'Add to list',
          icon: KasyIcons.add,
          variant: KasyButtonVariant.outline,
          pressEffect: KasyButtonPressEffect.both,
          expand: true,
          onPressed: _noop,
        ),
      ],
    );
  }
}

class _ButtonLayoutTransitionsPreview extends StatefulWidget {
  const _ButtonLayoutTransitionsPreview();

  @override
  State<_ButtonLayoutTransitionsPreview> createState() =>
      _ButtonLayoutTransitionsPreviewState();
}

class _ButtonLayoutTransitionsPreviewState
    extends State<_ButtonLayoutTransitionsPreview> {
  bool _isLoading = false;
  static const String _label = 'Download now';

  Future<void> _onDownloadPressed() async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Demo fallback only. In production, await the real work Future.
      await Future<void>.delayed(const Duration(seconds: 2));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle =
        context.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.05,
        ) ??
        const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.05,
        );
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: _label, style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    final double buttonWidth = textPainter.width + (18 * 2);

    return Center(
      child: KasyButton(
        label: _label,
        onPressed: _onDownloadPressed,
        isLoading: _isLoading,
        width: buttonWidth,
        borderRadius: BorderRadius.circular(KasyRadius.full),
        loadingBehavior: KasyButtonLoadingBehavior.shrinkToCircle,
        semanticLabel: _label,
      ),
    );
  }
}

class _CatalogTwoLineCardBody extends StatelessWidget {
  final String title;
  final String description;

  const _CatalogTwoLineCardBody({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: KasySpacing.xs),
        Text(
          description,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _CatalogCommunityImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String handle;
  final Color dotColor;

  const _CatalogCommunityImageCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.handle,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return KasyCard(
      padding: const EdgeInsets.all(KasySpacing.smd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(KasyRadius.md),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    ColoredBox(color: context.colors.surfaceNeutralSoft),
              ),
            ),
          ),
          const SizedBox(height: KasySpacing.smd),
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.muted,
            ),
          ),
          const SizedBox(height: KasySpacing.smd),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  handle,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatalogHorizontalImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const _CatalogHorizontalImageCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const double imageSize = 84;
    return KasyCard(
      padding: const EdgeInsets.all(KasySpacing.smd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(KasyRadius.md),
            child: SizedBox(
              width: imageSize,
              height: imageSize,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    ColoredBox(color: context.colors.surfaceNeutralSoft),
              ),
            ),
          ),
          const SizedBox(width: KasySpacing.smd),
          Expanded(
            child: SizedBox(
              height: imageSize,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ),
                  KasyHover(
                    onTap: _triggerTapFeedback,
                    borderRadius: KasyRadius.smBorderRadius,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Details',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          KasyIcons.northEast,
                          size: 16,
                          color: context.colors.primary,
                        ),
                      ],
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
}

class _BadgeColorsPreview extends StatelessWidget {
  const _BadgeColorsPreview();

  @override
  Widget build(BuildContext context) {
    const List<KasyBadgeTone> tones = [
      KasyBadgeTone.neutral,
      KasyBadgeTone.primary,
      KasyBadgeTone.success,
      KasyBadgeTone.warning,
      KasyBadgeTone.danger,
    ];
    final List<KasyAvatarGradientData> gradients = [
      KasyAvatarGradients.blue,
      KasyAvatarGradients.sky,
      KasyAvatarGradients.purple,
      KasyAvatarGradients.orange,
      KasyAvatarGradients.red,
    ];
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(tones.length, (int i) {
          return Padding(
            padding: EdgeInsets.only(right: i == tones.length - 1 ? 0 : 18),
            child: KasyBadged(
              badge: KasyBadge.dot(tone: tones[i]),
              child: KasyAvatar.gradientFill(
                size: KasyAvatarSize.medium,
                showShadow: false,
                gradient: gradients[i],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BadgeSizesPreview extends StatelessWidget {
  const _BadgeSizesPreview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BadgeSizeItem(label: 'sm', size: KasyBadgeSize.sm),
          SizedBox(width: 22),
          _BadgeSizeItem(label: 'md', size: KasyBadgeSize.md),
          SizedBox(width: 22),
          _BadgeSizeItem(label: 'lg', size: KasyBadgeSize.lg),
        ],
      ),
    );
  }
}

class _BadgeSizeItem extends StatelessWidget {
  final String label;
  final KasyBadgeSize size;

  const _BadgeSizeItem({required this.label, required this.size});

  @override
  Widget build(BuildContext context) {
    final KasyAvatarSize avatarSize = switch (size) {
      KasyBadgeSize.sm => KasyAvatarSize.small,
      KasyBadgeSize.md => KasyAvatarSize.medium,
      KasyBadgeSize.lg => KasyAvatarSize.large,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyBadged(
          badge: KasyBadge(text: '5', size: size),
          child: KasyAvatar.gradientFill(
            size: avatarSize,
            showShadow: false,
            gradient: KasyAvatarGradients.red,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}

class _BadgePlacementsPreview extends StatelessWidget {
  const _BadgePlacementsPreview();

  @override
  Widget build(BuildContext context) {
    const List<(KasyBadgePlacement, String)> placements = [
      (KasyBadgePlacement.topRight, 'top-right'),
      (KasyBadgePlacement.topLeft, 'top-left'),
      (KasyBadgePlacement.bottomRight, 'bottom-right'),
      (KasyBadgePlacement.bottomLeft, 'bottom-left'),
    ];
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(placements.length, (int i) {
          final (p, label) = placements[i];
          return Padding(
            padding: EdgeInsets.only(
              right: i == placements.length - 1 ? 0 : 22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KasyBadged(
                  placement: p,
                  badge: const KasyBadge.dot(),
                  child: KasyAvatar.gradientFill(
                    size: KasyAvatarSize.medium,
                    showShadow: false,
                    gradient: KasyAvatarGradients.purple,
                  ),
                ),
                const SizedBox(height: KasySpacing.sm),
                Text(label, style: context.textTheme.bodySmall),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BadgeDotPreview extends StatelessWidget {
  const _BadgeDotPreview();

  static const List<(KasyBadgeTone, KasyAvatarGradientData)> _items = [
    (KasyBadgeTone.neutral, KasyAvatarGradients.blue),
    (KasyBadgeTone.primary, KasyAvatarGradients.sky),
    (KasyBadgeTone.success, KasyAvatarGradients.purple),
    (KasyBadgeTone.warning, KasyAvatarGradients.red),
    (KasyBadgeTone.danger, KasyAvatarGradients.orange),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(_items.length, (int i) {
          final (tone, gradient) = _items[i];
          return Padding(
            padding: EdgeInsets.only(right: i == _items.length - 1 ? 0 : 18),
            child: KasyBadged(
              placement: KasyBadgePlacement.bottomRight,
              badge: KasyBadge.dot(tone: tone),
              child: KasyAvatar.gradientFill(
                size: KasyAvatarSize.medium,
                showShadow: false,
                gradient: gradient,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BadgeVariantsPreview extends StatelessWidget {
  const _BadgeVariantsPreview();

  static const List<KasyBadgeTone> _tones = [
    KasyBadgeTone.neutral,
    KasyBadgeTone.primary,
    KasyBadgeTone.success,
    KasyBadgeTone.warning,
    KasyBadgeTone.danger,
  ];

  static const List<KasyAvatarGradientData> _gradients = [
    KasyAvatarGradients.blue,
    KasyAvatarGradients.sky,
    KasyAvatarGradients.purple,
    KasyAvatarGradients.red,
    KasyAvatarGradients.orange,
  ];

  static const List<KasyAvatarTone> _avatarTones = [
    KasyAvatarTone.blue,
    KasyAvatarTone.neutral,
    KasyAvatarTone.green,
    KasyAvatarTone.orange,
    KasyAvatarTone.red,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _variantRow(context, 'Primary', _buildPrimaryRow(context)),
        const Divider(height: KasySpacing.xl),
        _variantRow(context, 'Secondary', _buildSecondaryRow(context)),
        const Divider(height: KasySpacing.xl),
        _variantRow(context, 'Soft', _buildSoftRow(context)),
      ],
    );
  }

  Widget _variantRow(BuildContext context, String label, Widget row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: KasySpacing.sm),
          child: Text(label, style: context.textTheme.bodySmall),
        ),
        Center(child: row),
      ],
    );
  }

  Widget _buildPrimaryRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_tones.length, (int i) {
        return Padding(
          padding: EdgeInsets.only(right: i == _tones.length - 1 ? 0 : 14),
          child: KasyBadged(
            badge: KasyBadge(text: '5', tone: _tones[i]),
            child: KasyAvatar.gradientFill(
              size: KasyAvatarSize.medium,
              showShadow: false,
              gradient: _gradients[i],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSecondaryRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_tones.length, (int i) {
        return Padding(
          padding: EdgeInsets.only(right: i == _tones.length - 1 ? 0 : 14),
          child: KasyBadged(
            badge: KasyBadge(text: '5', tone: _tones[i]),
            child: KasyAvatar(
              initials: 'JD',
              tone: _avatarTones[i],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSoftRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_tones.length, (int i) {
        return Padding(
          padding: EdgeInsets.only(right: i == _tones.length - 1 ? 0 : 14),
          child: KasyBadged(
            badge: KasyBadge(text: '5', tone: _tones[i]),
            child: KasyAvatar(
              initials: 'JD',
              tone: _avatarTones[i],
              fallbackSurface: KasyAvatarFallbackSurface.soft,
            ),
          ),
        );
      }),
    );
  }
}

class _BadgeWithContentPreview extends StatelessWidget {
  const _BadgeWithContentPreview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BadgeContentItem(
            label: 'Number',
            badge: KasyBadge(text: '5'),
            gradient: KasyAvatarGradients.orange,
          ),
          SizedBox(width: KasySpacing.lg),
          _BadgeContentItem(
            label: 'Text',
            badge: KasyBadge(text: 'New', tone: KasyBadgeTone.primary),
            gradient: KasyAvatarGradients.blue,
          ),
          SizedBox(width: KasySpacing.lg),
          _BadgeContentItem(
            label: 'Overflow',
            badge: KasyBadge(text: '99+'),
            gradient: KasyAvatarGradients.purple,
          ),
        ],
      ),
    );
  }
}

class _BadgeContentItem extends StatelessWidget {
  final String label;
  final KasyBadge badge;
  final KasyAvatarGradientData gradient;

  const _BadgeContentItem({
    required this.label,
    required this.badge,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyBadged(
          badge: badge,
          child: KasyAvatar.gradientFill(
            size: KasyAvatarSize.medium,
            showShadow: false,
            gradient: gradient,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}

class _BasicTextFieldVariantContent extends StatelessWidget {
  const _BasicTextFieldVariantContent();

  @override
  Widget build(BuildContext context) {
    return const KasyTextField(
      hint: 'Enter your email',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
    );
  }
}

class _TextFieldWithLabelDescriptionVariantContent extends StatelessWidget {
  const _TextFieldWithLabelDescriptionVariantContent();

  @override
  Widget build(BuildContext context) {
    return const KasyTextField(
      label: 'Email',
      hint: 'Enter your email',
      description: "We'll never share your email with anyone else.",
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
    );
  }
}

class _TextFieldStandardContent extends StatelessWidget {
  const _TextFieldStandardContent();

  @override
  Widget build(BuildContext context) {
    return const KasyTextField(
      label: 'Email',
      hint: 'Enter your email',
      contentType: KasyTextFieldContentType.email,
      textInputAction: TextInputAction.done,
    );
  }
}

class _TextFieldWithIconContent extends StatefulWidget {
  const _TextFieldWithIconContent();

  @override
  State<_TextFieldWithIconContent> createState() =>
      _TextFieldWithIconContentState();
}

class _TextFieldWithIconContentState extends State<_TextFieldWithIconContent> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KasyTextField(
          label: 'Phone',
          hint: '5550000000',
          prefix: Icon(KasyIcons.phone),
          contentType: KasyTextFieldContentType.phone,
        ),
        const SizedBox(height: KasySpacing.lg),
        const KasyTextField(
          label: 'Password',
          hint: 'Enter your password',
          contentType: KasyTextFieldContentType.password,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTextField(
          controller: _messageController,
          label: 'Message',
          hint: 'Type here...',
          prefix: const Icon(KasyIcons.message),
          suffix: _messageController.text.isEmpty
              ? null
              : GestureDetector(
                  onTap: () => _messageController.clear(),
                  child: const Icon(KasyIcons.close),
                ),
        ),
      ],
    );
  }
}

class _TextFieldMultilineContent extends StatefulWidget {
  const _TextFieldMultilineContent();

  @override
  State<_TextFieldMultilineContent> createState() =>
      _TextFieldMultilineContentState();
}

class _TextFieldMultilineContentState
    extends State<_TextFieldMultilineContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KasyTextField(
      controller: _controller,
      label: 'Description',
      hint: 'Type here...',
      maxLines: 5,
      textInputAction: TextInputAction.newline,
    );
  }
}

// ---------------------------------------------------------------------------
// TextArea preview widgets
// ---------------------------------------------------------------------------

class _TextAreaBasicContent extends StatelessWidget {
  const _TextAreaBasicContent();

  @override
  Widget build(BuildContext context) {
    return const KasyTextArea(hint: 'Enter your message');
  }
}

class _TextAreaWithLabelDescriptionContent extends StatelessWidget {
  const _TextAreaWithLabelDescriptionContent();

  @override
  Widget build(BuildContext context) {
    return const KasyTextArea(
      label: 'Message',
      hint: 'Enter your message here...',
      description: 'Please provide as much detail as possible.',
    );
  }
}

void _noop() {}

void _triggerTapFeedback() {}

/// Preview hosts apply a maximum width to the content; a centered [Row]
/// keeps [KasyButton] without `expand` at its label's intrinsic width.
Widget _previewIntrinsicLaunch(Widget child) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[child],
  );
}

// ── Menu (KasyMenu) previews ─────────────────────────────────────────────────
// Each preset is triggered by a button — a real menu opens, anchored to it.
// Most open as the default floating menu (popover, both platforms); one opens as
// a bottom sheet to show the opt-in presentation.

// Basic usage menu — mirrors the HeroUI "Actions / Danger zone" dropdown
// (Figma 17840:22571): grouped rows with an icon, title + description and a
// keyboard shortcut, plus a destructive "Danger zone". The kit has no pencil
// glyph yet, so Edit file borrows the note icon.
const List<KasyMenuSection> _kMenuActions = [
  KasyMenuSection(
    label: 'Actions',
    items: [
      KasyMenuItem(
        icon: KasyIcons.add,
        title: 'New file',
        description: 'Create a new file',
        shortcut: '⌘ N',
        onTap: _triggerTapFeedback,
      ),
      KasyMenuItem(
        icon: KasyIcons.copy,
        title: 'Copy link',
        description: 'Copy the file link',
        shortcut: '⌘ L',
        onTap: _triggerTapFeedback,
      ),
      KasyMenuItem(
        icon: KasyIcons.note,
        title: 'Edit file',
        description: 'Make changes',
        shortcut: '⌘ E',
        onTap: _triggerTapFeedback,
      ),
    ],
  ),
  KasyMenuSection(
    label: 'Danger zone',
    items: [
      KasyMenuItem(
        icon: KasyIcons.trash,
        title: 'Delete file',
        description: 'Move to trash',
        shortcut: '⌘ ⇧ K',
        tone: KasyMenuItemTone.danger,
        onTap: _triggerTapFeedback,
      ),
    ],
  ),
];

const List<KasyMenuSection> _kMenuSubmenu = [
  KasyMenuSection(
    items: [
      KasyMenuItem(
        icon: KasyIcons.share,
        title: 'Share',
        submenu: [
          KasyMenuSection(
            items: [
              KasyMenuItem(title: 'WhatsApp', onTap: _triggerTapFeedback),
              KasyMenuItem(title: 'Telegram', onTap: _triggerTapFeedback),
              KasyMenuItem(title: 'Email', onTap: _triggerTapFeedback),
            ],
          ),
        ],
      ),
      KasyMenuItem(
        icon: KasyIcons.copy,
        title: 'Copy link',
        onTap: _triggerTapFeedback,
      ),
      // Disabled row: dimmed and not tappable (e.g. nothing to download yet).
      KasyMenuItem(
        icon: KasyIcons.download,
        title: 'Download',
        enabled: false,
        onTap: _triggerTapFeedback,
      ),
    ],
  ),
];


// Layout shared by the two interactive menu demos: the trigger floats centered
// in the open area (so the menu has room to anchor against it) and a toggle is
// pinned at the bottom, just above the variant title. Height is a slice of the
// viewport, clamped, and kept under the preview height so it still centers.
class _MenuDemoFrame extends StatelessWidget {
  final Widget trigger;
  final String controlTitle;
  final String controlSubtitle;
  final bool controlValue;
  final ValueChanged<bool> onControlChanged;

  const _MenuDemoFrame({
    required this.trigger,
    required this.controlTitle,
    required this.controlSubtitle,
    required this.controlValue,
    required this.onControlChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Give the demo real vertical room so the control row can sit near the
    // bottom (like a settings row) instead of crowding under the trigger. The
    // trigger still lives in a plain centering Row — the menu anchors to its
    // render box via LayerLink, so the surrounding height never moves the menu.
    final double viewportHeight = MediaQuery.sizeOf(context).height;
    final double frameHeight = (viewportHeight - 260).clamp(320.0, 520.0);
    return SizedBox(
      height: frameHeight,
      child: Column(
        children: [
          const Spacer(flex: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [trigger]),
          const Spacer(flex: 6),
          Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controlTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                  Text(
                    controlSubtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                ],
              ),
            ),
            // The same KasySwitch the Settings screen uses.
            KasySwitch(value: controlValue, onChanged: onControlChanged),
          ],
          ),
        ],
      ),
    );
  }
}

Widget _buildMenuBasicUsage(BuildContext context) => const _MenuBasicUsageDemo();

// First preview: the trigger + a "Bottom Sheet" toggle. Off → the menu opens as
// a popover anchored to the button; on → it slides up as a bottom sheet. The
// same compact menu either way — only the container changes.
class _MenuBasicUsageDemo extends StatefulWidget {
  const _MenuBasicUsageDemo();

  @override
  State<_MenuBasicUsageDemo> createState() => _MenuBasicUsageDemoState();
}

class _MenuBasicUsageDemoState extends State<_MenuBasicUsageDemo> {
  bool _bottomSheet = false;

  @override
  Widget build(BuildContext context) {
    return _MenuDemoFrame(
      controlTitle: 'Bottom Sheet',
      controlSubtitle: 'Toggle bottom sheet presentation',
      controlValue: _bottomSheet,
      onControlChanged: (bool v) => setState(() => _bottomSheet = v),
      trigger: KasyMenuAnchor(
        sections: _kMenuActions,
        // Wider panel: rows carry a title + description (HeroUI menu).
        width: 288,
        presentation: _bottomSheet
            ? KasyMenuPresentation.bottomSheet
            : KasyMenuPresentation.popover,
        builder: (BuildContext context, VoidCallback open) => KasyButton(
          label: 'Actions',
          variant: KasyButtonVariant.soft,
          onPressed: () {
            _triggerTapFeedback();
            open();
          },
        ),
      ),
    );
  }
}

Widget _buildMenuStyles(BuildContext context) => const _MenuSelectionDemo();

// Second preview: a real, interactive selection menu. Tapping a "Text Style"
// row toggles its check (multi-select); tapping a "Text Alignment" row moves the
// filled dot (single-select). The selection persists across reopens. A "Should
// Close On Select" toggle controls whether picking an item dismisses the menu:
// off → keep picking, tap outside to close (HeroUI editor menu); on → one pick
// closes it.
class _MenuSelectionDemo extends StatefulWidget {
  const _MenuSelectionDemo();

  @override
  State<_MenuSelectionDemo> createState() => _MenuSelectionDemoState();
}

class _MenuSelectionDemoState extends State<_MenuSelectionDemo> {
  // Multi-select set + single-select value, kept on the demo so reopening the
  // menu shows the last selection.
  final Set<String> _styles = <String>{'Bold', 'Underline'};
  String _align = 'Right';
  bool _closeOnSelect = false;

  static const List<(String, String)> _styleItems = [
    ('Bold', '⌘ B'),
    ('Italic', '⌘ I'),
    ('Underline', '⌘ U'),
  ];
  static const List<(String, String)> _alignItems = [
    ('Left', '⌥ A'),
    ('Center', '⌥ H'),
    ('Right', '⌥ D'),
  ];

  void _toggleStyle(String title) {
    setState(() {
      if (!_styles.remove(title)) _styles.add(title);
    });
  }

  void _selectAlign(String title) => setState(() => _align = title);

  // Built from state so each tap (via setState) rebuilds the anchor and the
  // open menu reflects the new selection in place.
  List<KasyMenuSection> _buildSections() => [
    KasyMenuSection(
      label: 'Text Style',
      selectionMode: KasyMenuSelectionMode.multiple,
      items: [
        for (final (String title, String shortcut) in _styleItems)
          KasyMenuItem(
            title: title,
            shortcut: shortcut,
            selected: _styles.contains(title),
            onTap: () => _toggleStyle(title),
          ),
      ],
    ),
    KasyMenuSection(
      label: 'Text Alignment',
      selectionMode: KasyMenuSelectionMode.single,
      items: [
        for (final (String title, String shortcut) in _alignItems)
          KasyMenuItem(
            title: title,
            shortcut: shortcut,
            selected: _align == title,
            onTap: () => _selectAlign(title),
          ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _MenuDemoFrame(
      controlTitle: 'Should Close On Select',
      controlSubtitle: 'Toggle should close on select',
      controlValue: _closeOnSelect,
      onControlChanged: (bool v) => setState(() => _closeOnSelect = v),
      trigger: KasyMenuAnchor(
        sections: _buildSections(),
        closeOnSelect: _closeOnSelect,
        builder: (BuildContext context, VoidCallback open) => KasyButton(
          label: 'Text styles',
          variant: KasyButtonVariant.soft,
          onPressed: () {
            _triggerTapFeedback();
            open();
          },
        ),
      ),
    );
  }
}

Widget _buildMenuSubmenu(BuildContext context) {
  return _previewIntrinsicLaunch(
    KasyMenuAnchor(
      sections: _kMenuSubmenu,
      builder: (BuildContext context, VoidCallback open) => KasyButton(
        label: 'Share',
        variant: KasyButtonVariant.soft,
        onPressed: () {
          _triggerTapFeedback();
          open();
        },
      ),
    ),
  );
}

// Edge alignment — triggers pinned to the left and right edges. The menu is
// centered on its trigger, but clamps to the viewport, so a corner button still
// gets a fully visible menu instead of one spilling off the screen.
Widget _buildMenuEdges(BuildContext context) {
  KasyMenuAnchor cornerMenu(String label) => KasyMenuAnchor(
    sections: _kMenuActions,
    width: 260,
    builder: (BuildContext context, VoidCallback open) => KasyButton(
      label: label,
      size: KasyButtonSize.small,
      variant: KasyButtonVariant.soft,
      onPressed: () {
        _triggerTapFeedback();
        open();
      },
    ),
  );

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Triggers at the screen edges: the menu stays glued to the button but '
        'never leaves the screen.',
        textAlign: TextAlign.center,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.muted,
        ),
      ),
      const SizedBox(height: KasySpacing.xxxl),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [cornerMenu('Left'), cornerMenu('Right')],
      ),
    ],
  );
}

// Opens upward — the trigger sits low, with content right below it, so there's
// no room to drop down. The menu detects that and flips above the button
// instead (also accounting for the bottom safe area).
Widget _buildMenuFlipUp(BuildContext context) {
  final double viewportHeight = MediaQuery.sizeOf(context).height;
  final double frameHeight = (viewportHeight - 200).clamp(360.0, 600.0);
  return SizedBox(
    height: frameHeight,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'The trigger sits near the bottom with content below it. With no room '
          'to drop down, the menu opens above the button.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KasyMenuAnchor(
              sections: _kMenuActions,
              width: 260,
              builder: (BuildContext context, VoidCallback open) => KasyButton(
                label: 'Actions',
                variant: KasyButtonVariant.soft,
                onPressed: () {
                  _triggerTapFeedback();
                  open();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: KasySpacing.md),
        // Stand-in page content directly below the trigger, so it's clear why
        // the menu has to open upward instead of covering it.
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KasyButton(
              label: 'Save changes',
              variant: KasyButtonVariant.ghost,
              onPressed: _triggerTapFeedback,
            ),
          ],
        ),
      ],
    ),
  );
}

// Trailing content — the suffix slot takes any widget, not just a keyboard
// shortcut. Uses [KasyStatusTag] (the same padded pill the admin users table
// uses) for counts and status labels (HeroUI "end content").
const List<KasyMenuSection> _kMenuTrailing = [
  KasyMenuSection(
    items: [
      KasyMenuItem(
        icon: KasyIcons.message,
        title: 'Inbox',
        trailing: KasyStatusTag(label: '12', showDot: false),
        onTap: _triggerTapFeedback,
      ),
      KasyMenuItem(
        icon: KasyIcons.notification,
        title: 'Notifications',
        trailing: KasyStatusTag(
          label: '3',
          tone: KasyStatusTagTone.primary,
          showDot: false,
        ),
        onTap: _triggerTapFeedback,
      ),
      KasyMenuItem(
        icon: KasyIcons.idea,
        title: "What's new",
        trailing: KasyStatusTag(
          label: 'New',
          tone: KasyStatusTagTone.success,
          showDot: false,
        ),
        onTap: _triggerTapFeedback,
      ),
      KasyMenuItem(
        icon: KasyIcons.star,
        title: 'Upgrade plan',
        trailing: KasyStatusTag(
          label: 'Pro',
          tone: KasyStatusTagTone.warning,
          showDot: false,
        ),
        onTap: _triggerTapFeedback,
      ),
    ],
  ),
];

Widget _buildMenuTrailing(BuildContext context) {
  return _previewIntrinsicLaunch(
    KasyMenuAnchor(
      sections: _kMenuTrailing,
      builder: (BuildContext context, VoidCallback open) => KasyButton(
        label: 'Account',
        variant: KasyButtonVariant.soft,
        onPressed: () {
          _triggerTapFeedback();
          open();
        },
      ),
    ),
  );
}

const List<KasyAccordionItemData> _kAccordionItems = <KasyAccordionItemData>[
  KasyAccordionItemData(
    icon: KasyIcons.send,
    title: 'How do I place an order?',
    description:
        'Open your cart, review your items, choose a payment method, and confirm. You will immediately receive an order confirmation.',
  ),
  KasyAccordionItemData(
    icon: KasyIcons.refresh,
    title: 'Can I modify or cancel my order?',
    description:
        'Lorem ipsum dolor sit amet consectetur. Netus nunc mauris risus consequat. Libero placerat dignissim consectetur nisl. Ornare imperdiet amet lorem adipiscing.',
  ),
  KasyAccordionItemData(
    icon: KasyIcons.payment,
    title: 'How much does shipping cost?',
    description:
        'Shipping cost depends on your location and delivery method. You can always see the final amount before confirming payment.',
  ),
  KasyAccordionItemData(
    icon: KasyIcons.language,
    title: 'Do you ship internationally?',
    description:
        'Yes. International delivery is available for selected countries and may include import taxes calculated at checkout.',
  ),
];

const List<KasyAccordionItemData> _kAccordionElevatedItems =
    <KasyAccordionItemData>[
      KasyAccordionItemData(
        icon: KasyIcons.shoppingBag,
        title: 'How do I place an order?',
        description:
            'Open your cart, review your items, choose a payment method, '
            'and confirm. You will immediately receive an order confirmation.',
      ),
      KasyAccordionItemData(
        icon: KasyIcons.ticket,
        title: 'Can I modify or cancel my order?',
        description:
            'Lorem ipsum dolor sit amet consectetur. Netus nunc mauris risus '
            'consequat. Libero placerat dignissim consectetur nisl. Ornare '
            'imperdiet amet lorem adipiscing.',
      ),
      KasyAccordionItemData(
        icon: KasyIcons.packageOutline,
        title: 'How much does shipping cost?',
        description:
            'Shipping cost depends on your location and delivery method. You '
            'can always see the final amount before confirming payment.',
      ),
    ];

// ── BottomSheet previews ─────────────────────────────────────────────────────

// Choice-list archetype: the component owns the scaffold via [showKasyChoiceSheet]
// — the call site only declares a title and the [KasyBottomSheetOption]s (leading
// icon, a selected check, a destructive row auto-separated by a divider). This is
// the shape the avatar and language pickers use.
Widget _buildBottomSheetChoiceList(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
    child: _previewIntrinsicLaunch(
      KasyButton(
        label: 'Choice list',
        variant: KasyButtonVariant.soft,
        onPressed: () {
          _triggerTapFeedback();
          showKasyChoiceSheet<void>(
            context: context,
            title: 'Profile photo',
            options: [
              KasyBottomSheetOption(
                icon: KasyIcons.cameraAlt,
                label: 'Take photo',
                onTap: () {},
              ),
              KasyBottomSheetOption(
                icon: KasyIcons.gallery,
                label: 'Photo library',
                selected: true,
                onTap: () {},
              ),
              KasyBottomSheetOption(
                icon: KasyIcons.trash,
                label: 'Remove photo',
                danger: true,
                onTap: () {},
              ),
            ],
          );
        },
      ),
    ),
  );
}

// Form archetype: [KasyBottomSheet.form] gives a compact, left-aligned title
// over a field and stacked actions, hugging its content and lifting above the
// keyboard. The call site declares only the title, body and actions.
Widget _buildBottomSheetForm(BuildContext context) {
  return _BottomSheetTrigger(
    label: 'Form',
    isScrollControlled: true,
    builder: (sheetCtx) => KasyBottomSheet.form(
      title: 'Edit name',
      body: KasyTextField(
        label: 'Name',
        hint: 'Your name',
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.of(sheetCtx).pop(),
      ),
      actions: [
        KasyButton(
          label: 'Save',
          expand: true,
          onPressed: () => Navigator.of(sheetCtx).pop(),
        ),
        KasyButton(
          label: 'Cancel',
          variant: KasyButtonVariant.ghost,
          expand: true,
          onPressed: () => Navigator.of(sheetCtx).pop(),
        ),
      ],
    ),
  );
}

Widget _buildBottomSheetBasic(BuildContext context) {
  return _BottomSheetTrigger(
    label: 'Basic bottom sheet',
    builder: (sheetCtx) => KasyBottomSheet(
      icon: KasyIcons.security,
      iconTone: KasySheetIconTone.success,
      title: 'Keep yourself safe',
      message:
          'Update your software to the latest version for better security and performance.',
      actions: [
        KasyButton(
          label: 'Update Now',
          expand: true,
          onPressed: () => Navigator.of(sheetCtx).pop(),
        ),
        KasyButton(
          label: 'Later',
          variant: KasyButtonVariant.tertiary,
          expand: true,
          onPressed: () => Navigator.of(sheetCtx).pop(),
        ),
      ],
    ),
  );
}

Widget _buildBottomSheetTones(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _BottomSheetTrigger(
        label: 'Info',
        builder: (sheetCtx) => KasyBottomSheet(
          icon: KasyIcons.info,
          title: 'New feature available',
          message: "Explore what's new in this version of the app.",
          actions: [
            KasyButton(
              label: 'Got it',
              expand: true,
              onPressed: () => Navigator.of(sheetCtx).pop(),
            ),
          ],
        ),
      ),
      const SizedBox(height: KasySpacing.sm),
      _BottomSheetTrigger(
        label: 'Success',
        builder: (sheetCtx) => KasyBottomSheet(
          icon: KasyIcons.checkCircle,
          iconTone: KasySheetIconTone.success,
          title: 'Payment complete',
          message: 'Your order has been confirmed and is on its way.',
          actions: [
            KasyButton(
              label: 'Done',
              expand: true,
              backgroundColor: sheetCtx.colors.success,
              foregroundColor: sheetCtx.colors.onSuccess,
              onPressed: () => Navigator.of(sheetCtx).pop(),
            ),
          ],
        ),
      ),
      const SizedBox(height: KasySpacing.sm),
      _BottomSheetTrigger(
        label: 'Warning',
        builder: (sheetCtx) => KasyBottomSheet(
          icon: KasyIcons.time,
          iconTone: KasySheetIconTone.warning,
          title: 'Session expiring',
          message: "You'll be signed out in 5 minutes due to inactivity.",
          actions: [
            KasyButton(
              label: 'Stay signed in',
              expand: true,
              onPressed: () => Navigator.of(sheetCtx).pop(),
            ),
            KasyButton(
              label: 'Sign out',
              variant: KasyButtonVariant.tertiary,
              expand: true,
              onPressed: () => Navigator.of(sheetCtx).pop(),
            ),
          ],
        ),
      ),
      const SizedBox(height: KasySpacing.sm),
      _BottomSheetTrigger(
        label: 'Danger',
        builder: (sheetCtx) => KasyBottomSheet(
          icon: KasyIcons.trash,
          iconTone: KasySheetIconTone.danger,
          title: 'Delete account',
          message:
              'This action is permanent. All your data will be removed and cannot be recovered.',
          actions: [
            KasyButton(
              label: 'Delete forever',
              variant: KasyButtonVariant.destructive,
              expand: true,
              onPressed: () => Navigator.of(sheetCtx).pop(),
            ),
            KasyButton(
              label: 'Cancel',
              variant: KasyButtonVariant.tertiary,
              expand: true,
              onPressed: () => Navigator.of(sheetCtx).pop(),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildBottomSheetDetached(BuildContext context) {
  return _BottomSheetTrigger(
    label: 'Detached bottom sheet',
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.fromLTRB(
        KasySpacing.md,
        0,
        KasySpacing.md,
        MediaQuery.paddingOf(sheetCtx).bottom + KasySpacing.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KasyRadius.xl),
        child: KasyBottomSheet(
          addBottomSafeArea: false,
          icon: KasyIcons.payment,
          iconTone: KasySheetIconTone.success,
          title: 'Oh! Your wallet is empty',
          message: "You'll need to top up to buy",
          actions: [
            KasyButton(
              label: 'Add Cash',
              expand: true,
              backgroundColor: sheetCtx.colors.success,
              foregroundColor: sheetCtx.colors.onSuccess,
              onPressed: () => Navigator.of(sheetCtx).pop(),
            ),
            Builder(
              builder: (ctx) => Center(
                child: Text(
                  'Apple Pay • Mastercard • Visa • Amex',
                  style: ctx.textTheme.bodySmall?.copyWith(
                    color: ctx.colors.muted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildBottomSheetBlurOverlay(BuildContext context) {
  return _BottomSheetBlurTrigger(
    label: 'Bottom sheet with blur overlay',
    builder: (sheetCtx) => KasyBottomSheet(
      title: 'Delete account?',
      message:
          "If you delete your account, you won't be able to restore it or receive support.\n\n"
          'Our app will no longer be able to provide support for any of your trips, '
          'such as providing a refund or locking for lost items.\n\n'
          'For other deletion options, see our Privacy Policy.',
      actions: [
        KasyButton(
          label: 'Delete forever',
          variant: KasyButtonVariant.destructive,
          expand: true,
          onPressed: () => Navigator.of(sheetCtx).pop(),
        ),
        KasyButton(
          label: 'Cancel',
          variant: KasyButtonVariant.tertiary,
          expand: true,
          onPressed: () => Navigator.of(sheetCtx).pop(),
        ),
      ],
    ),
  );
}

Widget _buildBottomSheetScrollableSnap(BuildContext context) {
  return _BottomSheetTrigger(
    label: 'Scrollable with snap points',
    isScrollControlled: true,
    builder: (sheetCtx) =>
        _SnapSheetContainer(onClose: () => Navigator.of(sheetCtx).pop()),
  );
}

class _SnapSheetContainer extends StatefulWidget {
  final VoidCallback onClose;

  const _SnapSheetContainer({required this.onClose});

  @override
  State<_SnapSheetContainer> createState() => _SnapSheetContainerState();
}

class _SnapSheetContainerState extends State<_SnapSheetContainer> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.animateTo(
          0.42,
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.13,
      minChildSize: 0.13,
      maxChildSize: 0.82,
      snap: true,
      snapSizes: const [0.13, 0.42, 0.68, 0.82],
      expand: false,
      builder: (_, scrollController) => _SnapSheet(
        scrollController: scrollController,
        onClose: widget.onClose,
      ),
    );
  }
}

class _SnapSheet extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onClose;

  const _SnapSheet({required this.scrollController, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final double bottomPad = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KasyRadius.xl),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                const SliverToBoxAdapter(child: KasyDragHandle()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KasySpacing.lg,
                      KasySpacing.md,
                      KasySpacing.md,
                      KasySpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select a way to travel',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            KasyIcons.close,
                            size: 18,
                            color: context.colors.onSurface,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: context.colors.surfaceNeutralSoft,
                          ),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KasySpacing.lg,
                  ),
                  sliver: SliverList.list(
                    children: [
                      const _SnapTaxiRow(
                        icon: Icons.bolt,
                        label: 'Taxi Priority',
                        subtitle: 'in 1 min • 4',
                        price: 'c. €12-19',
                      ),
                      const _SnapTaxiRow(
                        icon: Icons.star_border_rounded,
                        label: 'Taxi Comfort',
                        subtitle: 'in 6 min • 4',
                        price: 'c. €11-18',
                      ),
                      _SnapTaxiRow(
                        icon: Icons.eco,
                        iconBackground: context.colors.success,
                        label: 'Green Taxi',
                        subtitle: 'in 6 min • 4',
                        price: 'c. €11-17',
                      ),
                      const _SnapTaxiRow(
                        icon: Icons.directions_car,
                        label: 'Premium',
                        subtitle: 'in 10 min • 4',
                        price: '€30.89',
                        badge: 'High end cars, top drivers',
                        highlighted: true,
                      ),
                      const _SnapTaxiRow(
                        icon: Icons.directions_car,
                        label: 'Taxi XL',
                        subtitle: 'in 2 min • 5-8',
                        price: 'c. €12-19',
                      ),
                      const SizedBox(height: KasySpacing.md),
                      _SnapPromoRow(),
                      const SizedBox(height: KasySpacing.sm),
                      _SnapPaymentRow(),
                      const SizedBox(height: KasySpacing.lg),
                      const _SnapSection(
                        title: 'Trip Details',
                        body:
                            'Estimated arrival time: 10 minutes\nDistance: 4.2 km\n\n'
                            'Your driver will arrive at the pickup location shortly. '
                            'Please be ready when they arrive.',
                      ),
                      const SizedBox(height: KasySpacing.lg),
                      const _SnapSection(
                        title: 'Important Information',
                        body:
                            '• All prices include taxes and fees\n'
                            '• Payment will be processed after trip completion\n'
                            '• Cancellation fees may apply if cancelled after 2 minutes\n'
                            '• For support, contact us through the app or call +1-800-TAXI-HELP',
                      ),
                      const SizedBox(height: KasySpacing.lg),
                      const _SnapSection(
                        title: 'Safety & Security',
                        body:
                            'All our drivers are verified and background-checked. '
                            'Your safety is our top priority.\n\n'
                            'Share your trip details with friends and family for added security.',
                      ),
                      const SizedBox(height: KasySpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.colors.outline.withValues(alpha: 0.30),
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                KasySpacing.md,
                KasySpacing.md,
                KasySpacing.md,
                bottomPad + KasySpacing.lg,
              ),
              child: KasyButton(
                label: 'Order Premium now',
                variant: KasyButtonVariant.destructive,
                expand: true,
                onPressed: onClose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapTaxiRow extends StatelessWidget {
  final IconData icon;
  final Color? iconBackground;
  final String label;
  final String subtitle;
  final String price;
  final String? badge;
  final bool highlighted;

  const _SnapTaxiRow({
    required this.icon,
    this.iconBackground,
    required this.label,
    required this.subtitle,
    required this.price,
    this.badge,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = iconBackground ?? context.colors.onSurface;
    final Widget row = Padding(
      padding: const EdgeInsets.fromLTRB(6, KasySpacing.sm, 0, KasySpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: KasySpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                if (badge != null)
                  Text(
                    badge!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.success,
                    ),
                  )
                else
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              price,
              textAlign: TextAlign.right,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: KasySpacing.xs),
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: highlighted ? context.colors.muted : Colors.transparent,
            ),
          ),
        ],
      ),
    );
    if (!highlighted) return row;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(KasyRadius.md),
      ),
      child: row,
    );
  }
}

class _SnapPromoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(KasyRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.smd,
          vertical: KasySpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.warning,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: KasySpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '10% off all trips with PLUS',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  Text(
                    'Subscribe for €6.99/month',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}

class _SnapPaymentRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceNeutralSoft,
        borderRadius: BorderRadius.circular(KasyRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.smd,
          vertical: KasySpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: KasyColors.semanticError,
                borderRadius: BorderRadius.circular(KasyRadius.sm),
              ),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(width: KasySpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  Text(
                    'Visa ••••',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}

class _SnapSection extends StatelessWidget {
  final String title;
  final String body;

  const _SnapSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: KasySpacing.xs),
        Text(
          body,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.65),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

Widget _buildBottomSheetTextInput(BuildContext context) {
  return _BottomSheetTrigger(
    label: 'Bottom sheet with text field',
    isScrollControlled: true,
    builder: (sheetCtx) =>
        _TextInputSheet(onClose: () => Navigator.of(sheetCtx).pop()),
  );
}

class _TextInputSheet extends StatefulWidget {
  final VoidCallback onClose;

  const _TextInputSheet({required this.onClose});

  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  final TextEditingController _textController = TextEditingController();
  final DraggableScrollableController _dragController =
      DraggableScrollableController();
  String _query = '';
  bool _wasKeyboardOpen = false;

  static const double _initialSize = 0.58;
  static const double _maxSize = 0.92;

  static const List<({String initials, String name, String email})>
  _contacts = [
    (initials: 'JD', name: 'John Doe', email: 'john.doe@example.com'),
    (initials: 'JS', name: 'Jane Smith', email: 'jane.smith@example.com'),
    (initials: 'AJ', name: 'Alice Johnson', email: 'alice.johnson@example.com'),
    (initials: 'BW', name: 'Bob Williams', email: 'bob.williams@example.com'),
    (initials: 'CB', name: 'Charlie Brown', email: 'charlie.brown@example.com'),
    (initials: 'DP', name: 'Diana Prince', email: 'diana.prince@example.com'),
    (initials: 'EN', name: 'Edward Norton', email: 'edward.norton@example.com'),
    (initials: 'FA', name: 'Fiona Apple', email: 'fiona.apple@example.com'),
    (initials: 'GL', name: 'George Lucas', email: 'george.lucas@example.com'),
    (
      initials: 'HM',
      name: 'Hannah Montana',
      email: 'hannah.montana@example.com',
    ),
    (initials: 'IK', name: 'Ivan Koch', email: 'ivan.koch@example.com'),
    (initials: 'JL', name: 'Julia Lima', email: 'julia.lima@example.com'),
    (initials: 'KR', name: 'Kevin Ross', email: 'kevin.ross@example.com'),
    (initials: 'LM', name: 'Laura Mendes', email: 'laura.mendes@example.com'),
    (initials: 'MN', name: 'Marcus Nolan', email: 'marcus.nolan@example.com'),
    (initials: 'NP', name: 'Nina Park', email: 'nina.park@example.com'),
    (initials: 'OQ', name: 'Oscar Quinn', email: 'oscar.quinn@example.com'),
  ];

  static const List<KasyAvatarTone> _tones = [
    KasyAvatarTone.blue,
    KasyAvatarTone.neutral,
    KasyAvatarTone.green,
    KasyAvatarTone.orange,
    KasyAvatarTone.red,
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() => _query = _textController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void _expandForKeyboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dragController.isAttached &&
          _dragController.size < _maxSize - 0.01) {
        _dragController.animateTo(
          _maxSize,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasKeyboard = MediaQuery.viewInsetsOf(context).bottom > 80;
    if (hasKeyboard && !_wasKeyboardOpen) {
      _wasKeyboardOpen = true;
      _expandForKeyboard();
    } else if (!hasKeyboard) {
      _wasKeyboardOpen = false;
    }

    final List<({String initials, String name, String email})> filtered =
        _contacts
            .where(
              (c) =>
                  c.name.toLowerCase().contains(_query) ||
                  c.email.toLowerCase().contains(_query),
            )
            .toList();

    return DraggableScrollableSheet(
      controller: _dragController,
      initialChildSize: _initialSize,
      minChildSize: 0.35,
      maxChildSize: _maxSize,
      expand: false,
      snap: true,
      snapSizes: const [_initialSize, _maxSize],
      builder: (_, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(KasyRadius.xl),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              const SliverToBoxAdapter(child: KasyDragHandle()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KasySpacing.md,
                    KasySpacing.md,
                    KasySpacing.md,
                    KasySpacing.sm,
                  ),
                  child: KasyTextField(
                    controller: _textController,
                    variant: KasyTextFieldVariant.secondary,
                    hint: 'Search by name or email...',
                    prefix: Icon(
                      Icons.search,
                      size: 20,
                      color: context.colors.muted,
                    ),
                    suffix: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _textController.clear(),
                            child: Icon(
                              KasyIcons.close,
                              size: 18,
                              color: context.colors.muted,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search,
                          size: 40,
                          color: context.colors.muted,
                        ),
                        const SizedBox(height: KasySpacing.sm),
                        Text(
                          'No users found',
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: KasySpacing.xs),
                        Text(
                          'Try a different search term',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KasySpacing.md,
                    0,
                    KasySpacing.md,
                    KasySpacing.xl,
                  ),
                  sliver: SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, int i) {
                          final contact = filtered[i];
                          final int originalIndex = _contacts.indexOf(contact);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: KasySpacing.sm,
                            ),
                            child: Row(
                              children: [
                                KasyAvatar(
                                  initials: contact.initials,
                                  tone: _tones[originalIndex % _tones.length],
                                  size: KasyAvatarSize.small,
                                ),
                                const SizedBox(width: KasySpacing.smd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contact.name,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.onSurface,
                                            ),
                                      ),
                                      Text(
                                        contact.email,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: context.colors.muted,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildBottomSheetNativeModal(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: KasySpacing.pageHorizontalGutter,
    ),
    child: _previewIntrinsicLaunch(
      KasyButton(
        label: 'Page sheet',
        variant: KasyButtonVariant.soft,
        onPressed: () {
          _triggerTapFeedback();
          showKasyBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (sheetCtx) => FractionallySizedBox(
              heightFactor: 0.92,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(KasyRadius.xl),
                ),
                child: ColoredBox(
                  color: sheetCtx.colors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const KasyAppBar(
                        title: 'Page sheet',
                        style: KasyAppBarStyle.rootTab,
                        useSafeArea: false,
                        toolbarHeight: 48,
                        topInset: 10,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KasySpacing.lg,
                            vertical: KasySpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'A page sheet behaves like a screen. Tap a button below to see nested interactions.',
                                style: sheetCtx.textTheme.bodyMedium?.copyWith(
                                  color: sheetCtx.colors.onSurface
                                      .withValues(alpha: 0.6),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: KasySpacing.lg),
                              _BottomSheetTrigger(
                                label: 'Open bottom sheet',
                                builder: (innerCtx) => KasyBottomSheet(
                                  icon: KasyIcons.security,
                                  iconTone: KasySheetIconTone.success,
                                  title: 'Keep yourself safe',
                                  message:
                                      'Update your software to the latest version for better security and performance.',
                                  actions: [
                                    KasyButton(
                                      label: 'Update Now',
                                      expand: true,
                                      onPressed: () =>
                                          Navigator.of(innerCtx).pop(),
                                    ),
                                    KasyButton(
                                      label: 'Later',
                                      variant: KasyButtonVariant.tertiary,
                                      expand: true,
                                      onPressed: () =>
                                          Navigator.of(innerCtx).pop(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: KasySpacing.sm),
                              _previewIntrinsicLaunch(
                                KasyButton(
                                  label: 'Open dialog',
                                  variant: KasyButtonVariant.soft,
                                  onPressed: () {
                                    showKasyDialog<void>(
                                      context: sheetCtx,
                                      builder: (dialogCtx) => KasyDialog(
                                        leadingIcon: KasyIcons.download,
                                        title: 'Low Disk Space',
                                        message:
                                            'You are running low on disk space. Delete unnecessary files to free up space.',
                                        confirmLabel: 'Confirm',
                                        onConfirm: () {
                                          Navigator.of(dialogCtx).pop();
                                          _triggerTapFeedback();
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildBottomSheetScrollable(BuildContext context) {
  return _BottomSheetTrigger(
    label: 'Open scrollable sheet',
    isScrollControlled: true,
    builder: (sheetCtx) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 0.92],
      builder: (draggableCtx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetCtx.colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(KasyRadius.xl),
            ),
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              0,
              0,
              0,
              MediaQuery.paddingOf(draggableCtx).bottom + KasySpacing.lg,
            ),
            itemCount: 8 + 2 + 1,
            itemBuilder: (itemCtx, i) {
              if (i == 0) {
                return const KasyDragHandle();
              }
                  if (i == 1) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          KasySpacing.lg,
                          KasySpacing.md,
                          KasySpacing.lg,
                          0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(KasyRadius.lg),
                          child: Image.network(
                            'https://picsum.photos/seed/kasy/800/400',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            frameBuilder:
                                (ctx, child, frame, wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    return child;
                                  }
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    child: frame != null
                                        ? child
                                        : Container(
                                            key: const ValueKey('placeholder'),
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: sheetCtx
                                                  .colors
                                                  .surfaceNeutralSoft,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    KasyRadius.lg,
                                                  ),
                                            ),
                                          ),
                                  );
                                },
                          ),
                        ),
                      );
                    }
                    if (i == 2) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          KasySpacing.lg,
                          KasySpacing.md,
                          KasySpacing.lg,
                          KasySpacing.sm,
                        ),
                        child: Text(
                          'Terms & Conditions',
                          style: sheetCtx.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: sheetCtx.colors.onSurface,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KasySpacing.lg,
                        0,
                        KasySpacing.lg,
                        KasySpacing.md,
                      ),
                      child: Text(
                        'Section ${i - 2}. Lorem ipsum dolor sit amet consectetur '
                        'adipiscing elit. Sed do eiusmod tempor incididunt ut labore '
                        'et dolore magna aliqua. Ut enim ad minim veniam, quis '
                        'nostrud exercitation ullamco laboris.',
                        style: sheetCtx.textTheme.bodyMedium?.copyWith(
                          color: sheetCtx.colors.onSurface.withValues(
                            alpha: 0.65,
                          ),
                          height: 1.5,
                        ),
                      ),
                    );
                  },
          ),
        );
      },
    ),
  );
}

Widget _buildBottomSheetOtpVerification(BuildContext context) {
  return _BottomSheetTrigger(
    label: 'OTP verification',
    isScrollControlled: true,
    builder: (sheetCtx) =>
        KasyOtpVerificationBottomSheet(sheetContext: sheetCtx),
  );
}

Widget _buildBottomSheetPinVerification(BuildContext context) {
  return _BottomSheetTrigger(
    label: 'PIN verification',
    isScrollControlled: true,
    builder: (sheetCtx) => KasyOtpVerificationBottomSheet(
      sheetContext: sheetCtx,
      preset: KasyOtpVerificationSheetPreset.pinDigits,
    ),
  );
}

class _BottomSheetBlurTrigger extends StatelessWidget {
  final String label;
  final WidgetBuilder builder;

  const _BottomSheetBlurTrigger({required this.label, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
      child: _previewIntrinsicLaunch(
        KasyButton(
          label: label,
          variant: KasyButtonVariant.soft,
          onPressed: () {
            _triggerTapFeedback();
            showKasyBlurBottomSheet(context: context, builder: builder);
          },
        ),
      ),
    );
  }
}

class _BottomSheetTrigger extends StatelessWidget {
  final String label;
  final WidgetBuilder builder;
  final bool isScrollControlled;

  const _BottomSheetTrigger({
    required this.label,
    required this.builder,
    this.isScrollControlled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
      child: _previewIntrinsicLaunch(
        KasyButton(
          label: label,
          variant: KasyButtonVariant.soft,
          onPressed: () {
            _triggerTapFeedback();
            showKasyBottomSheet(
              context: context,
              isScrollControlled: isScrollControlled,
              builder: builder,
            );
          },
        ),
      ),
    );
  }
}

// ─── TextFieldOTP builders ───────────────────────────────────────────────────

Widget _buildTextFieldOTPDefault(BuildContext context) {
  return _TextFieldOTPPreviewFrame(
    width: KasyTextFieldOTP.visualWidthFor(separatorAfterIndex: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Verify account',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onBackground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "We've sent a code to a****@gmail.com",
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyTextFieldOTP(
          separatorAfterIndex: 2,
          onCompleted: (_) => _triggerTapFeedback(),
        ),
        const SizedBox(height: KasySpacing.md),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Didn't receive a code? ",
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.muted,
              ),
            ),
            const _ResendCodeButton(onTap: _triggerTapFeedback),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTextFieldOTPError(BuildContext context) {
  return const _TextFieldOTPValidationPreview();
}

class _TextFieldOTPValidationPreview extends StatefulWidget {
  const _TextFieldOTPValidationPreview();

  @override
  State<_TextFieldOTPValidationPreview> createState() =>
      _TextFieldOTPValidationPreviewState();
}

class _TextFieldOTPValidationPreviewState
    extends State<_TextFieldOTPValidationPreview> {
  static const String _expectedCode = '123456';

  String _code = '';

  /// Set on each Submit only; stays true while editing until the next Submit clears it.
  bool _showSubmitError = false;

  bool get _hasError => _showSubmitError;

  void _submit() {
    setState(() => _showSubmitError = _code != _expectedCode);
    _triggerTapFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return _TextFieldOTPPreviewFrame(
      width: KasyTextFieldOTP.visualWidthFor(separatorAfterIndex: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Verify account',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: _hasError
                  ? context.colors.error
                  : context.colors.onBackground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Hint: The code is 123456',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.muted,
            ),
          ),
          const SizedBox(height: KasySpacing.sm),
          KasyTextFieldOTP(
            separatorAfterIndex: 2,
            hasError: _hasError,
            onChanged: (value) => setState(() => _code = value),
            onCompleted: (_) => _triggerTapFeedback(),
          ),
          if (_hasError) ...[
            const SizedBox(height: KasySpacing.sm),
            Text(
              'The code you entered is incorrect.',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: _hasError ? KasySpacing.lg : KasySpacing.md),
          KasyButton(
            label: 'Submit',
            variant: KasyButtonVariant.soft,
            size: KasyButtonSize.small,
            width: 124,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

Widget _buildTextFieldOTPFourDigits(BuildContext context) {
  return _TextFieldOTPPreviewFrame(
    width: KasyTextFieldOTP.visualWidthFor(length: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter your PIN',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onBackground,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyTextFieldOTP(length: 4, onCompleted: (_) => _triggerTapFeedback()),
      ],
    ),
  );
}

Widget _buildTextFieldOTPWithPlaceholder(BuildContext context) {
  return _TextFieldOTPPreviewFrame(
    width: KasyTextFieldOTP.visualWidthFor(separatorAfterIndex: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter verification code',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onBackground,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyTextFieldOTP(
          separatorAfterIndex: 2,
          placeholder: '-',
          neutralFlatCells: true,
          onCompleted: (_) => _triggerTapFeedback(),
        ),
      ],
    ),
  );
}

Widget _buildTextFieldOTPDisabled(BuildContext context) {
  return _TextFieldOTPPreviewFrame(
    width: KasyTextFieldOTP.visualWidthFor(separatorAfterIndex: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter verification code',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.muted,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        const KasyTextFieldOTP(separatorAfterIndex: 2, enabled: false),
      ],
    ),
  );
}

Widget _buildTextFieldOTPWithPattern(BuildContext context) {
  return _TextFieldOTPPreviewFrame(
    width: KasyTextFieldOTP.visualWidthFor(separatorAfterIndex: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter code (letters only)',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onBackground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Only alphabetic characters are allowed',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.muted,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyTextFieldOTP(
          separatorAfterIndex: 2,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
          ],
          onCompleted: (_) => _triggerTapFeedback(),
        ),
      ],
    ),
  );
}

Widget _buildTextFieldOTPCustomStyles(BuildContext context) {
  const double gap = 2;
  final double otpWidth = KasyTextFieldOTP.visualWidthFor(
    separatorAfterIndex: 2,
    cellGap: gap,
    separatorStrokeVisible: false,
  );
  const double horizontalInset = KasySpacing.xxl;
  final double frameWidth = otpWidth + horizontalInset * 2;
  return _TextFieldOTPPreviewFrame(
    width: frameWidth,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(KasyRadius.xl),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.22),
        ),
        boxShadow: [KasyShadows.component(context)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KasyRadius.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: KasySpacing.md,
          ),
          child: Center(
            child: KasyTextFieldOTP(
              separatorAfterIndex: 2,
              separatorStrokeVisible: false,
              placeholder: '-',
              cellGap: gap,
              cellFillColor: Colors.transparent,
              suppressCellShadow: true,
              suppressFocusBorder: true,
              onCompleted: (_) => _triggerTapFeedback(),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildTextFieldOTPBottomSheet(BuildContext context) {
  return _previewIntrinsicLaunch(
    KasyButton(
      label: 'Bottom sheet with OTP input',
      variant: KasyButtonVariant.soft,
      onPressed: () {
        _triggerTapFeedback();
        showKasyOtpVerificationBottomSheet<void>(context: context);
      },
    ),
  );
}

class _TextFieldOTPPreviewFrame extends StatelessWidget {
  final double width;
  final Widget child;

  const _TextFieldOTPPreviewFrame({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double resolvedWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth < width
            ? constraints.maxWidth
            : width;

        return Center(
          child: SizedBox(width: resolvedWidth, child: child),
        );
      },
    );
  }
}

class _ResendCodeButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ResendCodeButton({required this.onTap});

  @override
  State<_ResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends State<_ResendCodeButton> {
  bool _pressed = false;

  Future<void> _handleTap() async {
    setState(() => _pressed = true);
    await KasyHaptics.selection(context);
    await Future<void>.delayed(const Duration(milliseconds: 130));
    if (mounted) setState(() => _pressed = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Text(
            'Resend code',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pressable previews ──────────────────────────────────────────────────────

Widget _buildTappableRowListVariant(BuildContext context) {
  return const _PressableListPreview();
}

Widget _buildTappableRowCardVariant(BuildContext context) {
  return const _PressableButtonsPreview();
}

Widget _buildTappableRowGroupVariant(BuildContext context) {
  return const _PressableCardsPreview();
}

// ─── Variant 1: List rows ────────────────────────────────────────────────────
// Full-bleed rows inside a grouped container — mirrors Settings / Features.
// borderRadius: zero (default); fill covers edge to edge, clipped by the
// outer ClipRRect so the first and last rows respect the container corners.

class _PressableListItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PressableListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

const List<_PressableListItem> _kPressableListItems = [
  _PressableListItem(
    icon: KasyIcons.notification,
    title: 'Notifications',
    subtitle: 'App alerts and reminders',
  ),
  _PressableListItem(
    icon: KasyIcons.payment,
    title: 'Subscription',
    subtitle: 'Plans and payment history',
  ),
  _PressableListItem(
    icon: KasyIcons.assistant,
    title: 'Assistant',
    subtitle: 'AI assistant preferences',
  ),
];

class _PressableListPreview extends StatelessWidget {
  const _PressableListPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(KasyRadius.lg),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.4),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KasyRadius.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _kPressableListItems.length; i++) ...[
              KasyHover(
                onTap: () => KasyHaptics.selection(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: KasySpacing.smd,
                  vertical: 14,
                ),
                semanticLabel: _kPressableListItems[i].title,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(KasyRadius.md),
                      ),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          _kPressableListItems[i].icon,
                          size: 20,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: KasySpacing.smd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _kPressableListItems[i].title,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _kPressableListItems[i].subtitle,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: KasySpacing.xs,
                        top: 8,
                      ),
                      child: Icon(
                        KasyIcons.chevronRight,
                        color: context.colors.muted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _kPressableListItems.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: KasySpacing.smd,
                  color: context.colors.outline.withValues(alpha: 0.33),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Variant 2: Custom buttons ───────────────────────────────────────────────
// Different button shapes — outlined pill, tonal pill, icon-grid.
class _PressableButtonsPreview extends StatelessWidget {
  const _PressableButtonsPreview();

  static const BorderRadius _pillRadius =
      BorderRadius.all(Radius.circular(KasyRadius.full));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyButton(
          label: 'View plans',
          icon: KasyIcons.payment,
          variant: KasyButtonVariant.outline,
          pressEffect: KasyButtonPressEffect.fill,
          backgroundColor: context.colors.surface,
          borderRadius: _pillRadius,
          expand: true,
          onPressed: _noop,
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyButton(
          label: 'Subscribe now',
          icon: KasyIcons.star,
          variant: KasyButtonVariant.soft,
          pressEffect: KasyButtonPressEffect.fill,
          backgroundColor: context.colors.primary.withValues(alpha: 0.10),
          borderColor: context.colors.primary.withValues(alpha: 0.25),
          borderRadius: _pillRadius,
          expand: true,
          onPressed: _noop,
        ),
      ],
    );
  }
}

class _HoverIconGrid extends StatelessWidget {
  const _HoverIconGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (IconData icon, String label) in <(IconData, String)>[
          (KasyIcons.gallery, 'Gallery'),
          (KasyIcons.message, 'Message'),
          (KasyIcons.notification, 'Alerts'),
        ])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: KasySpacing.xs),
              child: KasyCard(
                variant: KasyCardVariant.outlined,
                color: context.colors.surface,
                borderRadius: KasyRadius.mdBorderRadius,
                child: KasyHover(
                  onTap: _noop,
                  semanticLabel: label,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 22, color: context.colors.onSurface),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Variant 3: Clickable cards ──────────────────────────────────────────────
// KasyCard with onTap — the card handles interaction via KasyPressableDepth.

class _PressableCardsPreview extends StatelessWidget {
  const _PressableCardsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyCard(
          variant: KasyCardVariant.outlined,
          color: context.colors.primary.withValues(alpha: 0.08),
          borderColor: context.colors.primary.withValues(alpha: 0.25),
          borderRadius: KasyRadius.lgBorderRadius,
          child: KasyHover(
            onTap: _noop,
            pressColor: context.colors.primary,
            padding: const EdgeInsets.all(KasySpacing.md),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(KasyRadius.md),
                  ),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      KasyIcons.star,
                      size: 24,
                      color: context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: KasySpacing.smd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore premium',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Unlock all features without limits',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  KasyIcons.chevronRight,
                  color: context.colors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        Row(
          children: [
            for (final (IconData icon, String title, String desc)
                in <(IconData, String, String)>[
              (KasyIcons.assistant, 'AI Chat', 'Smart conversations'),
              (KasyIcons.gallery, 'Gallery', 'Browse photos'),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KasySpacing.xs,
                  ),
                  child: KasyCard(
                    variant: KasyCardVariant.outlined,
                    color: context.colors.surface,
                    borderRadius: KasyRadius.lgBorderRadius,
                    child: KasyHover(
                      onTap: _noop,
                      padding: const EdgeInsets.all(KasySpacing.smd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, size: 22, color: context.colors.primary),
                          const SizedBox(height: KasySpacing.sm),
                          Text(
                            title,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: KasySpacing.sm),
        const _HoverIconGrid(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Checkbox previews
// ---------------------------------------------------------------------------

Widget _buildCheckboxBasicUsage(BuildContext context) =>
    const _CheckboxBasicPreview();

Widget _buildCheckboxStates(BuildContext context) =>
    const _CheckboxStatesPreview();

Widget _buildCheckboxCustomStyles(BuildContext context) =>
    const _CheckboxCustomStylesPreview();

// — Basic usage —

class _CheckboxBasicPreview extends StatefulWidget {
  const _CheckboxBasicPreview();

  @override
  State<_CheckboxBasicPreview> createState() => _CheckboxBasicPreviewState();
}

class _CheckboxBasicPreviewState extends State<_CheckboxBasicPreview> {
  bool _newsletter = true;
  bool _marketing = false;
  bool _terms = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: KasyRadius.lgBorderRadius,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyCheckboxTile(
            value: _newsletter,
            onChanged: (v) => setState(() => _newsletter = v),
            label: 'Subscribe to newsletter',
            description: 'Get weekly updates about new features and tips',
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: KasySpacing.md,
            endIndent: KasySpacing.md,
            color: context.colors.outline.withValues(alpha: 0.33),
          ),
          KasyCheckboxTile(
            value: _marketing,
            onChanged: (v) => setState(() => _marketing = v),
            label: 'Marketing communications',
            description: 'Receive promotional emails and special offers',
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: KasySpacing.md,
            endIndent: KasySpacing.md,
            color: context.colors.outline.withValues(alpha: 0.33),
          ),
          KasyCheckboxTile(
            value: _terms,
            onChanged: (v) => setState(() => _terms = v),
            label: 'Accept terms and conditions',
            description: 'Agree to our Terms of Service and Privacy Policy',
          ),
        ],
      ),
    );
  }
}

// — States —

class _CheckboxStatesPreview extends StatefulWidget {
  const _CheckboxStatesPreview();

  @override
  State<_CheckboxStatesPreview> createState() => _CheckboxStatesPreviewState();
}

class _CheckboxStatesPreviewState extends State<_CheckboxStatesPreview> {
  bool _default = true;
  bool _invalid = true;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        context.textTheme.labelSmall?.copyWith(
          color: context.colors.muted,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle();

    Widget labeled(String l, Widget checkbox) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            checkbox,
            const SizedBox(height: KasySpacing.sm),
            Text(l, style: labelStyle),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        labeled(
          'Default',
          KasyCheckbox(
            value: _default,
            onChanged: (v) => setState(() => _default = v),
          ),
        ),
        const SizedBox(width: KasySpacing.xl),
        labeled(
          'Invalid',
          KasyCheckbox(
            value: _invalid,
            isInvalid: true,
            onChanged: (v) => setState(() => _invalid = v),
          ),
        ),
        const SizedBox(width: KasySpacing.xl),
        labeled(
          'Disabled',
          const KasyCheckbox(value: true),
        ),
      ],
    );
  }
}

// — Custom styles —

class _CheckboxCustomStylesPreview extends StatefulWidget {
  const _CheckboxCustomStylesPreview();

  @override
  State<_CheckboxCustomStylesPreview> createState() =>
      _CheckboxCustomStylesPreviewState();
}

class _CheckboxCustomStylesPreviewState
    extends State<_CheckboxCustomStylesPreview> {
  bool _fav = false;
  bool _notif = true;
  bool _done = true;

  // Style 1 — favorite: no bg, outline heart ↔ filled heart, red icon
  static const KasyCheckboxStyle _favStyle = KasyCheckboxStyle(
    size: 26,
    activeColor: Colors.transparent,
    inactiveColor: Colors.transparent,
    borderColor: Colors.transparent,
    checkedIcon: KasyIcons.favoriteFilled,
    uncheckedIcon: KasyIcons.favorite,
    checkColor: Color(0xFFEF4444),
    borderWidth: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Style 2 — notification on/off: always filled, bell swaps
    final Color notifInactive = context.isDark
        ? const Color(0xFF475569)
        : const Color(0xFF94A3B8);

    final KasyCheckboxStyle notifStyle = KasyCheckboxStyle(
      size: 28,
      activeColor: const Color(0xFFF59E0B),
      inactiveColor: notifInactive,
      borderColor: Colors.transparent,
      checkedIcon: KasyIcons.notificationActive,
      uncheckedIcon: KasyIcons.notificationOff,
      checkColor: Colors.white,
      borderWidth: 0,
    );

    // Style 3 — approve/deny: red X (off) → green check (on)
    const KasyCheckboxStyle doneStyle = KasyCheckboxStyle(
      size: 52,
      shape: KasyCheckboxShape.circle,
      activeColor: Color(0xFF10B981),
      inactiveColor: Color(0xFFEF4444),
      borderColor: Colors.transparent,
      checkedIcon: KasyIcons.check,
      uncheckedIcon: KasyIcons.close,
      checkColor: Colors.white,
      borderWidth: 0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        KasyCheckbox(
          value: _fav,
          onChanged: (v) => setState(() => _fav = v),
          style: _favStyle,
        ),
        const SizedBox(width: KasySpacing.xl),
        KasyCheckbox(
          value: _notif,
          onChanged: (v) => setState(() => _notif = v),
          style: notifStyle,
        ),
        const SizedBox(width: KasySpacing.xl),
        KasyCheckbox(
          value: _done,
          onChanged: (v) => setState(() => _done = v),
          style: doneStyle,
        ),
      ],
    );
  }
}

// ─── Switch preview ───────────────────────────────────────────────────────────

Widget _buildSwitchSettingsList(BuildContext context) =>
    const _SwitchSettingsPreview();

Widget _buildSwitchSizes(BuildContext context) => const _SwitchSizesPreview();

Widget _buildSwitchInline(BuildContext context) => const _SwitchInlinePreview();

Widget _buildSwitchStates(BuildContext context) => const _SwitchStatesPreview();

Widget _buildSwitchCustomStyles(BuildContext context) =>
    const _SwitchCustomStylesPreview();

// — Settings list (label left, switch right) —

class _SwitchSettingsPreview extends StatefulWidget {
  const _SwitchSettingsPreview();

  @override
  State<_SwitchSettingsPreview> createState() => _SwitchSettingsPreviewState();
}

class _SwitchSettingsPreviewState extends State<_SwitchSettingsPreview> {
  bool _push = true;
  bool _email = false;
  bool _biometrics = true;

  @override
  Widget build(BuildContext context) {
    Widget divider() => Divider(
          height: 1,
          thickness: 1,
          indent: KasySpacing.md,
          endIndent: KasySpacing.md,
          color: context.colors.outline.withValues(alpha: 0.33),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: KasyRadius.lgBorderRadius,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasySwitchTile(
            value: _push,
            onChanged: (v) => setState(() => _push = v),
            label: 'Push notifications',
            description: 'Alerts on your device when something happens',
          ),
          divider(),
          KasySwitchTile(
            value: _email,
            onChanged: (v) => setState(() => _email = v),
            label: 'Email digest',
            description: 'A weekly summary in your inbox',
          ),
          divider(),
          KasySwitchTile(
            value: _biometrics,
            onChanged: (v) => setState(() => _biometrics = v),
            label: 'Unlock with biometrics',
            description: 'Use Face ID or fingerprint to sign in',
          ),
        ],
      ),
    );
  }
}

// — Sizes —

class _SwitchSizesPreview extends StatefulWidget {
  const _SwitchSizesPreview();

  @override
  State<_SwitchSizesPreview> createState() => _SwitchSizesPreviewState();
}

class _SwitchSizesPreviewState extends State<_SwitchSizesPreview> {
  final Map<KasySwitchSize, bool> _on = {
    KasySwitchSize.sm: true,
    KasySwitchSize.md: true,
    KasySwitchSize.lg: true,
  };

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        context.textTheme.labelSmall?.copyWith(
          color: context.colors.muted,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle();

    Widget labeled(String l, KasySwitchSize size) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KasySwitch(
              value: _on[size]!,
              size: size,
              onChanged: (v) => setState(() => _on[size] = v),
            ),
            const SizedBox(height: KasySpacing.sm),
            Text(l, style: labelStyle),
          ],
        );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        labeled('SM', KasySwitchSize.sm),
        labeled('MD', KasySwitchSize.md),
        labeled('LG', KasySwitchSize.lg),
      ],
    );
  }
}

// — Inline label —

class _SwitchInlinePreview extends StatefulWidget {
  const _SwitchInlinePreview();

  @override
  State<_SwitchInlinePreview> createState() => _SwitchInlinePreviewState();
}

class _SwitchInlinePreviewState extends State<_SwitchInlinePreview> {
  bool _wifi = true;
  bool _airplane = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasySwitch(
          value: _wifi,
          onChanged: (v) => setState(() => _wifi = v),
          label: 'Wi-Fi',
        ),
        const SizedBox(height: KasySpacing.lg),
        KasySwitch(
          value: _airplane,
          onChanged: (v) => setState(() => _airplane = v),
          label: 'Airplane mode',
          description: 'Turns off wireless connections',
        ),
      ],
    );
  }
}

// — States —

class _SwitchStatesPreview extends StatefulWidget {
  const _SwitchStatesPreview();

  @override
  State<_SwitchStatesPreview> createState() => _SwitchStatesPreviewState();
}

class _SwitchStatesPreviewState extends State<_SwitchStatesPreview> {
  bool _on = true;
  bool _off = false;
  bool _invalid = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        context.textTheme.labelSmall?.copyWith(
          color: context.colors.muted,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle();

    Widget labeled(String l, Widget control) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            control,
            const SizedBox(height: KasySpacing.sm),
            Text(l, style: labelStyle),
          ],
        );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        labeled(
          'On',
          KasySwitch(
            value: _on,
            onChanged: (v) => setState(() => _on = v),
          ),
        ),
        labeled(
          'Off',
          KasySwitch(
            value: _off,
            onChanged: (v) => setState(() => _off = v),
          ),
        ),
        labeled(
          'Invalid',
          KasySwitch(
            value: _invalid,
            isInvalid: true,
            onChanged: (v) => setState(() => _invalid = v),
          ),
        ),
        labeled(
          'Disabled on',
          const KasySwitch(value: true),
        ),
        labeled(
          'Disabled off',
          const KasySwitch(value: false),
        ),
      ],
    );
  }
}

// — Custom styles —

class _SwitchCustomStylesPreview extends StatefulWidget {
  const _SwitchCustomStylesPreview();

  @override
  State<_SwitchCustomStylesPreview> createState() =>
      _SwitchCustomStylesPreviewState();
}

class _SwitchCustomStylesPreviewState
    extends State<_SwitchCustomStylesPreview> {
  bool _theme = false;
  bool _flash = true;
  bool _large = true;

  // Style 1 — theme toggle: sun ↔ moon inside the thumb.
  static const KasySwitchStyle _themeStyle = KasySwitchStyle(
    activeColor: Color(0xFF6366F1),
    thumbIconActive: KasyIcons.darkMode,
    thumbIconInactive: KasyIcons.lightMode,
  );

  // Style 2 — flashlight: amber track, flash glyph.
  static const KasySwitchStyle _flashStyle = KasySwitchStyle(
    activeColor: Color(0xFFF59E0B),
    thumbIconActive: KasyIcons.flash,
    thumbIconInactive: KasyIcons.flashOff,
  );

  // Style 3 — gradient track.
  static const KasySwitchStyle _gradientStyle = KasySwitchStyle(
    activeGradient: LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
    ),
  );

  @override
  Widget build(BuildContext context) {
    // lg so the thumb glyphs read clearly.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        KasySwitch(
          value: _theme,
          onChanged: (v) => setState(() => _theme = v),
          size: KasySwitchSize.lg,
          style: _themeStyle,
        ),
        KasySwitch(
          value: _flash,
          onChanged: (v) => setState(() => _flash = v),
          size: KasySwitchSize.lg,
          style: _flashStyle,
        ),
        KasySwitch(
          value: _large,
          onChanged: (v) => setState(() => _large = v),
          size: KasySwitchSize.lg,
          style: _gradientStyle,
        ),
      ],
    );
  }
}

// ─── Radio Group preview ──────────────────────────────────────────────────────

Widget _buildRadioOptionList(BuildContext context) =>
    const _RadioOptionListPreview();

Widget _buildRadioDescriptions(BuildContext context) =>
    const _RadioDescriptionsPreview();

Widget _buildRadioHorizontal(BuildContext context) =>
    const _RadioHorizontalPreview();

Widget _buildRadioError(BuildContext context) => const _RadioErrorPreview();

Widget _buildRadioStates(BuildContext context) => const _RadioStatesPreview();

Widget _buildRadioSizes(BuildContext context) => const _RadioSizesPreview();

Widget _buildRadioVariants(BuildContext context) =>
    const _RadioVariantsPreview();

// — Option list (managed group) —

class _RadioOptionListPreview extends StatefulWidget {
  const _RadioOptionListPreview();

  @override
  State<_RadioOptionListPreview> createState() =>
      _RadioOptionListPreviewState();
}

class _RadioOptionListPreviewState extends State<_RadioOptionListPreview> {
  String _plan = 'monthly';

  @override
  Widget build(BuildContext context) {
    return KasyRadioGroup<String>(
      value: _plan,
      onChanged: (v) => setState(() => _plan = v ?? _plan),
      label: 'Billing period',
      options: const [
        KasyRadioOption(value: 'monthly', label: 'Monthly'),
        KasyRadioOption(value: 'yearly', label: 'Yearly'),
        KasyRadioOption(value: 'lifetime', label: 'Lifetime'),
      ],
    );
  }
}

// — With descriptions —

class _RadioDescriptionsPreview extends StatefulWidget {
  const _RadioDescriptionsPreview();

  @override
  State<_RadioDescriptionsPreview> createState() =>
      _RadioDescriptionsPreviewState();
}

class _RadioDescriptionsPreviewState extends State<_RadioDescriptionsPreview> {
  String _plan = 'pro';

  @override
  Widget build(BuildContext context) {
    return KasyRadioGroup<String>(
      value: _plan,
      onChanged: (v) => setState(() => _plan = v ?? _plan),
      label: 'Plan selection',
      description: 'Choose the plan that suits you best',
      options: const [
        KasyRadioOption(
          value: 'free',
          label: 'Free',
          description: 'Core features, up to 3 projects',
        ),
        KasyRadioOption(
          value: 'pro',
          label: 'Pro',
          description: 'Unlimited projects and priority support',
        ),
        KasyRadioOption(
          value: 'team',
          label: 'Team',
          description: 'Everything in Pro plus shared workspaces',
        ),
      ],
    );
  }
}

// — Horizontal orientation —

class _RadioHorizontalPreview extends StatefulWidget {
  const _RadioHorizontalPreview();

  @override
  State<_RadioHorizontalPreview> createState() =>
      _RadioHorizontalPreviewState();
}

class _RadioHorizontalPreviewState extends State<_RadioHorizontalPreview> {
  String _visibility = 'public';

  @override
  Widget build(BuildContext context) {
    return KasyRadioGroup<String>(
      value: _visibility,
      onChanged: (v) => setState(() => _visibility = v ?? _visibility),
      label: 'Visibility',
      orientation: KasyRadioOrientation.horizontal,
      options: const [
        KasyRadioOption(value: 'public', label: 'Public'),
        KasyRadioOption(value: 'private', label: 'Private'),
        KasyRadioOption(value: 'unlisted', label: 'Unlisted'),
      ],
    );
  }
}

// — Error state —

class _RadioErrorPreview extends StatefulWidget {
  const _RadioErrorPreview();

  @override
  State<_RadioErrorPreview> createState() => _RadioErrorPreviewState();
}

class _RadioErrorPreviewState extends State<_RadioErrorPreview> {
  String? _plan;

  @override
  Widget build(BuildContext context) {
    return KasyRadioGroup<String>(
      value: _plan,
      onChanged: (v) => setState(() => _plan = v),
      label: 'Plan selection',
      errorText: _plan == null ? 'Select a plan to continue' : null,
      options: const [
        KasyRadioOption(value: 'basic', label: 'Basic Plan'),
        KasyRadioOption(value: 'premium', label: 'Premium Plan'),
        KasyRadioOption(value: 'business', label: 'Business Plan'),
      ],
    );
  }
}

// — States —

class _RadioStatesPreview extends StatefulWidget {
  const _RadioStatesPreview();

  @override
  State<_RadioStatesPreview> createState() => _RadioStatesPreviewState();
}

class _RadioStatesPreviewState extends State<_RadioStatesPreview> {
  // Live pair: tap to move selection between the two (shows selected +
  // unselected side by side).
  String _pick = 'a';
  // Invalid pair: same, but rendered with error tones.
  String _invalidPick = 'a';

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        context.textTheme.labelSmall?.copyWith(
          color: context.colors.muted,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle();

    Widget group(String title, Widget control) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            control,
            const SizedBox(height: KasySpacing.sm),
            Text(title, style: labelStyle),
          ],
        );

    Widget pair({required bool invalid}) {
      final String value = invalid ? _invalidPick : _pick;
      void set(String? v) => setState(() {
            if (invalid) {
              _invalidPick = v ?? _invalidPick;
            } else {
              _pick = v ?? _pick;
            }
          });
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyRadio<String>(
            value: 'a',
            groupValue: value,
            isInvalid: invalid,
            onChanged: set,
          ),
          const SizedBox(width: KasySpacing.md),
          KasyRadio<String>(
            value: 'b',
            groupValue: value,
            isInvalid: invalid,
            onChanged: set,
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        group('Selectable', pair(invalid: false)),
        group('Invalid', pair(invalid: true)),
        group(
          'Disabled',
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KasyRadio<String>(value: 'a', groupValue: 'a'),
              SizedBox(width: KasySpacing.md),
              KasyRadio<String>(value: 'b', groupValue: 'a'),
            ],
          ),
        ),
      ],
    );
  }
}

// — Sizes (sm / md / lg) —

class _RadioSizesPreview extends StatefulWidget {
  const _RadioSizesPreview();

  @override
  State<_RadioSizesPreview> createState() => _RadioSizesPreviewState();
}

class _RadioSizesPreviewState extends State<_RadioSizesPreview> {
  String _pick = 'md';

  @override
  Widget build(BuildContext context) {
    Widget row(KasyRadioSize size, String value, String label) => KasyRadio<String>(
          value: value,
          groupValue: _pick,
          size: size,
          label: label,
          onChanged: (v) => setState(() => _pick = v ?? _pick),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        row(KasyRadioSize.sm, 'sm', 'Small'),
        const SizedBox(height: KasySpacing.smd),
        row(KasyRadioSize.md, 'md', 'Medium (default)'),
        const SizedBox(height: KasySpacing.smd),
        row(KasyRadioSize.lg, 'lg', 'Large'),
      ],
    );
  }
}

// — Variants (primary / secondary) —

class _RadioVariantsPreview extends StatefulWidget {
  const _RadioVariantsPreview();

  @override
  State<_RadioVariantsPreview> createState() => _RadioVariantsPreviewState();
}

class _RadioVariantsPreviewState extends State<_RadioVariantsPreview> {
  // Each variant keeps its own selection so both selected + unselected discs
  // are visible at once (the variants only differ while unselected).
  String _primary = 'a';
  String _secondary = 'a';

  @override
  Widget build(BuildContext context) {
    final TextStyle? caption = context.textTheme.bodySmall?.copyWith(
      color: context.colors.muted,
    );

    Widget pair(KasyRadioVariant variant, String value, void Function(String?) set) =>
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KasyRadio<String>(
              value: 'a',
              groupValue: value,
              variant: variant,
              onChanged: set,
            ),
            const SizedBox(width: KasySpacing.md),
            KasyRadio<String>(
              value: 'b',
              groupValue: value,
              variant: variant,
              onChanged: set,
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Primary', style: caption),
        const SizedBox(height: KasySpacing.sm),
        pair(KasyRadioVariant.primary, _primary,
            (v) => setState(() => _primary = v ?? _primary)),
        const SizedBox(height: KasySpacing.lg),
        Text('Secondary', style: caption),
        const SizedBox(height: KasySpacing.sm),
        pair(KasyRadioVariant.secondary, _secondary,
            (v) => setState(() => _secondary = v ?? _secondary)),
      ],
    );
  }
}

// ─── Spinner preview ──────────────────────────────────────────────────────────

const List<(KasySpinnerColor, String)> _kSpinnerColors = [
  (KasySpinnerColor.primary, 'Primary'),
  (KasySpinnerColor.current, 'Current'),
  (KasySpinnerColor.success, 'Success'),
  (KasySpinnerColor.warning, 'Warning'),
  (KasySpinnerColor.danger, 'Danger'),
];

Widget _spinnerLabelled(BuildContext context, Widget child, String label) =>
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: KasySpacing.sm),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ],
    );

Widget _buildSpinnerColors(BuildContext context) => Wrap(
      alignment: WrapAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        for (final (KasySpinnerColor color, String label) in _kSpinnerColors)
          _spinnerLabelled(context, KasySpinner(variant: color), label),
      ],
    );

Widget _buildSpinnerSizes(BuildContext context) => Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        _spinnerLabelled(
            context, const KasySpinner(size: KasySpinnerSize.sm), 'Small'),
        _spinnerLabelled(context, const KasySpinner(), 'Medium'),
        _spinnerLabelled(
            context, const KasySpinner(size: KasySpinnerSize.lg), 'Large'),
      ],
    );

Widget _buildSpinnerInContext(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KasySpinner(size: KasySpinnerSize.sm),
            SizedBox(width: KasySpacing.smd),
            Text('Loading your workspace…'),
          ],
        ),
        const SizedBox(height: KasySpacing.lg),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(KasyRadius.md),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: KasySpacing.lg,
              vertical: KasySpacing.smd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KasySpinner(
                  size: KasySpinnerSize.sm,
                  color: Colors.white,
                  softColor: Color(0x40FFFFFF),
                ),
                SizedBox(width: KasySpacing.sm),
                Text(
                  'Saving',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

// ─── ProgressCircle preview ─────────────────────────────────────────────────

const List<(KasyProgressCircleColor, String)> _kProgressColors = [
  (KasyProgressCircleColor.primary, 'Primary'),
  (KasyProgressCircleColor.neutral, 'Neutral'),
  (KasyProgressCircleColor.success, 'Success'),
  (KasyProgressCircleColor.warning, 'Warning'),
  (KasyProgressCircleColor.danger, 'Danger'),
];

Widget _buildProgressCircleLabel(BuildContext context) => const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KasyProgressCircle(value: 0.25, label: '25% Complete'),
        SizedBox(height: KasySpacing.lg),
        KasyProgressCircle(
          value: 0.7,
          variant: KasyProgressCircleColor.success,
          label: 'Uploading',
        ),
      ],
    );

Widget _buildProgressCircleColors(BuildContext context) => Wrap(
      alignment: WrapAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        for (final (KasyProgressCircleColor color, String label)
            in _kProgressColors)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KasyProgressCircle(value: 0.65, variant: color),
              const SizedBox(height: KasySpacing.sm),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.muted,
                ),
              ),
            ],
          ),
      ],
    );

Widget _buildProgressCircleSizes(BuildContext context) => const Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        KasyProgressCircle(value: 0.6, size: KasyProgressCircleSize.sm),
        KasyProgressCircle(value: 0.6),
        KasyProgressCircle(value: 0.6, size: KasyProgressCircleSize.lg),
      ],
    );

Widget _buildProgressCircleProgress(BuildContext context) =>
    const _ProgressCircleProgressPreview();

Widget _buildProgressCircleIndeterminate(BuildContext context) => const Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      children: [
        KasyProgressCircle(size: KasyProgressCircleSize.sm),
        KasyProgressCircle(),
        KasyProgressCircle(
          size: KasyProgressCircleSize.lg,
          variant: KasyProgressCircleColor.success,
        ),
      ],
    );

// Interactive determinate demo — a slider drives the arc.
class _ProgressCircleProgressPreview extends StatefulWidget {
  const _ProgressCircleProgressPreview();

  @override
  State<_ProgressCircleProgressPreview> createState() =>
      _ProgressCircleProgressPreviewState();
}

class _ProgressCircleProgressPreviewState
    extends State<_ProgressCircleProgressPreview> {
  double _value = 0.4;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyProgressCircle(
          value: _value,
          size: KasyProgressCircleSize.lg,
          label: '${(_value * 100).round()}% Complete',
        ),
        const SizedBox(height: KasySpacing.lg),
        SizedBox(
          width: 240,
          child: Slider(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
      ],
    );
  }
}

// ─── ProgressBar preview ────────────────────────────────────────────────────

const List<(KasyProgressBarColor, String)> _kProgressBarColors = [
  (KasyProgressBarColor.primary, 'Primary'),
  (KasyProgressBarColor.neutral, 'Neutral'),
  (KasyProgressBarColor.success, 'Success'),
  (KasyProgressBarColor.warning, 'Warning'),
  (KasyProgressBarColor.danger, 'Danger'),
];

Widget _buildProgressBarLabel(BuildContext context) => const SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyProgressBar(value: 0.6, label: 'Storage', valueLabel: '60%'),
          SizedBox(height: KasySpacing.lg),
          KasyProgressBar(
            value: 0.92,
            variant: KasyProgressBarColor.warning,
            label: 'Upload',
            valueLabel: '92%',
          ),
        ],
      ),
    );

Widget _buildProgressBarColors(BuildContext context) => SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (KasyProgressBarColor color, String label)
              in _kProgressBarColors) ...[
            KasyProgressBar(value: 0.6, variant: color, label: label),
            const SizedBox(height: KasySpacing.md),
          ],
        ],
      ),
    );

Widget _buildProgressBarSizes(BuildContext context) => const SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyProgressBar(value: 0.6, size: KasyProgressBarSize.sm),
          SizedBox(height: KasySpacing.lg),
          KasyProgressBar(value: 0.6),
          SizedBox(height: KasySpacing.lg),
          KasyProgressBar(value: 0.6, size: KasyProgressBarSize.lg),
        ],
      ),
    );

Widget _buildProgressBarProgress(BuildContext context) =>
    const _ProgressBarProgressPreview();

Widget _buildProgressBarIndeterminate(BuildContext context) => const SizedBox(
      width: 280,
      child: KasyProgressBar(label: 'Syncing'),
    );

class _ProgressBarProgressPreview extends StatefulWidget {
  const _ProgressBarProgressPreview();

  @override
  State<_ProgressBarProgressPreview> createState() =>
      _ProgressBarProgressPreviewState();
}

class _ProgressBarProgressPreviewState
    extends State<_ProgressBarProgressPreview> {
  double _value = 0.4;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasyProgressBar(
            value: _value,
            label: 'Download',
            valueLabel: '${(_value * 100).round()}%',
          ),
          const SizedBox(height: KasySpacing.lg),
          Slider(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ],
      ),
    );
  }
}

// ─── Slider preview ───────────────────────────────────────────────────────────

Widget _buildSliderDefault(BuildContext context) => const _SliderDefaultPreview();

Widget _buildSliderMarks(BuildContext context) => const _SliderMarksPreview();

Widget _buildSliderRange(BuildContext context) => const _SliderRangePreview();

Widget _buildSliderDisabled(BuildContext context) => const SizedBox(
      width: 280,
      child: KasySlider(
        value: 0.4,
        label: 'Brightness',
        valueText: '40%',
      ),
    );

class _SliderDefaultPreview extends StatefulWidget {
  const _SliderDefaultPreview();

  @override
  State<_SliderDefaultPreview> createState() => _SliderDefaultPreviewState();
}

class _SliderDefaultPreviewState extends State<_SliderDefaultPreview> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: KasySlider(
        value: _value,
        label: 'Volume',
        valueText: '${(_value * 100).round()}%',
        tooltip: (v) => '${(v * 100).round()}%',
        onChanged: (v) => setState(() => _value = v),
      ),
    );
  }
}

class _SliderMarksPreview extends StatefulWidget {
  const _SliderMarksPreview();

  @override
  State<_SliderMarksPreview> createState() => _SliderMarksPreviewState();
}

class _SliderMarksPreviewState extends State<_SliderMarksPreview> {
  double _value = 50;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: KasySlider(
        value: _value,
        max: 100,
        divisions: 10,
        label: 'Quality',
        valueText: '${_value.round()}%',
        tooltip: (v) => '${v.round()}%',
        marks: const ['0%', '20%', '50%', '80%', '100%'],
        onChanged: (v) => setState(() => _value = v),
      ),
    );
  }
}

class _SliderRangePreview extends StatefulWidget {
  const _SliderRangePreview();

  @override
  State<_SliderRangePreview> createState() => _SliderRangePreviewState();
}

class _SliderRangePreviewState extends State<_SliderRangePreview> {
  RangeValues _values = const RangeValues(50, 250);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: KasyRangeSlider(
        values: _values,
        max: 300,
        label: 'Price range',
        valueText: '\$${_values.start.round()} – \$${_values.end.round()}',
        tooltip: (v) => '\$${v.round()}',
        onChanged: (v) => setState(() => _values = v),
      ),
    );
  }
}

// ─── Separator preview ──────────────────────────────────────────────────────

Widget _separatorVariantRow(
  BuildContext context,
  String label,
  KasySeparatorVariant variant,
) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: KasySpacing.smd),
        KasySeparator(variant: variant),
      ],
    );

Widget _buildSeparatorVariants(BuildContext context) => SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _separatorVariantRow(context, 'Primary', KasySeparatorVariant.primary),
          const SizedBox(height: KasySpacing.lg),
          _separatorVariantRow(
            context,
            'Secondary',
            KasySeparatorVariant.secondary,
          ),
          const SizedBox(height: KasySpacing.lg),
          _separatorVariantRow(
            context,
            'Tertiary',
            KasySeparatorVariant.tertiary,
          ),
        ],
      ),
    );

Widget _buildSeparatorText(BuildContext context) => const SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KasySeparator(label: 'OR'),
          SizedBox(height: KasySpacing.xl),
          KasySeparator(
            variant: KasySeparatorVariant.secondary,
            label: 'CONTINUE WITH',
          ),
          SizedBox(height: KasySpacing.xl),
          KasySeparator(variant: KasySeparatorVariant.tertiary, label: 'AND'),
        ],
      ),
    );

Widget _buildSeparatorVertical(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Three vertical rules of increasing weight, side by side, each with a
        // centred "OR" label — the HeroUI vertical anatomy (line · text · line).
        SizedBox(
          height: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _verticalSeparatorCell(
                context,
                'Primary',
                KasySeparatorVariant.primary,
              ),
              const SizedBox(width: KasySpacing.xxl),
              _verticalSeparatorCell(
                context,
                'Secondary',
                KasySeparatorVariant.secondary,
              ),
              const SizedBox(width: KasySpacing.xxl),
              _verticalSeparatorCell(
                context,
                'Tertiary',
                KasySeparatorVariant.tertiary,
              ),
            ],
          ),
        ),
        const SizedBox(height: KasySpacing.xl),
        // Real toolbar usage: actions split by plain vertical hairlines.
        SizedBox(
          height: 22,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit', style: context.textTheme.bodyMedium),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: KasySpacing.md),
                child: KasySeparator(
                  orientation: KasySeparatorOrientation.vertical,
                  variant: KasySeparatorVariant.secondary,
                ),
              ),
              Text('Share', style: context.textTheme.bodyMedium),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: KasySpacing.md),
                child: KasySeparator(
                  orientation: KasySeparatorOrientation.vertical,
                  variant: KasySeparatorVariant.secondary,
                ),
              ),
              Text('Delete', style: context.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );

Widget _verticalSeparatorCell(
  BuildContext context,
  String label,
  KasySeparatorVariant variant,
) =>
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: KasySeparator(
            orientation: KasySeparatorOrientation.vertical,
            variant: variant,
            label: 'OR',
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ],
    );

// ─── CloseButton preview ────────────────────────────────────────────────────

/// The three HeroUI states stacked (default / hover / focus), exactly as the
/// Figma sheet presents them. Hover and focus are static renders of the real
/// look (the live button reacts to mouse/keyboard); the default cell is the
/// real interactive [KasyCloseButton].
Widget _buildCloseButtonStates(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _closeStateRow(context, 'Default', KasyCloseButton(onPressed: () {})),
        const SizedBox(height: KasySpacing.lg),
        _closeStateRow(
          context,
          'Hover',
          _StaticCloseGlyph(bg: context.colors.neutralHover),
        ),
        const SizedBox(height: KasySpacing.lg),
        _closeStateRow(
          context,
          'Focus',
          _StaticCloseGlyph(bg: context.colors.neutral, focused: true),
        ),
        const SizedBox(height: KasySpacing.xl),
        _closeStateRow(context, 'Disabled', const KasyCloseButton()),
      ],
    );

/// A labelled row: state name on the left, the close button on the right —
/// mirrors the Figma states column.
Widget _closeStateRow(BuildContext context, String label, Widget glyph) =>
    SizedBox(
      width: 220,
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.muted),
            ),
          ),
          const Spacer(),
          glyph,
        ],
      ),
    );

/// Static visual of the close glyph for the hover/focus showcase cells, built
/// from the same tokens as [KasyCloseButton] so the showcase can't drift.
class _StaticCloseGlyph extends StatelessWidget {
  const _StaticCloseGlyph({required this.bg, this.focused = false});

  final Color bg;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: focused
            ? <BoxShadow>[
                // Outer primary ring, then a hair-line gap in the canvas colour
                // — same construction as KasyFocusRing.
                BoxShadow(color: c.primary, spreadRadius: 3),
                BoxShadow(color: c.background, spreadRadius: 1.5),
              ]
            : null,
      ),
      child: Icon(KasyIcons.close, size: 16, color: c.onSurface),
    );
  }
}

Widget _buildCloseButtonContext(BuildContext context) => SizedBox(
      width: 300,
      child: KasyCard(
        child: Padding(
          padding: const EdgeInsets.all(KasySpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: context.textTheme.titleSmall,
                    ),
                  ),
                  KasyCloseButton(onPressed: () {}),
                ],
              ),
              const SizedBox(height: KasySpacing.sm),
              Text(
                'You have 3 unread messages in your inbox.',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.colors.muted),
              ),
            ],
          ),
        ),
      ),
    );

// ─── LinkButton preview ─────────────────────────────────────────────────────

/// A labelled row: state name on the left, the link on the right — mirrors the
/// Figma states column (default / hover / focus / disabled).
Widget _linkStateRow(BuildContext context, String label, Widget link) =>
    SizedBox(
      width: 260,
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.muted),
            ),
          ),
          const Spacer(),
          link,
        ],
      ),
    );

Widget _buildLinkStates(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linkStateRow(
          context,
          'Default',
          KasyLink(
            label: 'Call to action',
            icon: KasyIcons.northEast,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: KasySpacing.lg),
        _linkStateRow(context, 'Hover', const _StaticLink(hovered: true)),
        const SizedBox(height: KasySpacing.lg),
        _linkStateRow(context, 'Focus', const _StaticLink(focused: true)),
        const SizedBox(height: KasySpacing.lg),
        _linkStateRow(
          context,
          'Disabled',
          const KasyLink(label: 'Call to action', icon: KasyIcons.northEast),
        ),
      ],
    );

Widget _buildLinkWithIcon(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KasyLink(
          label: 'View documentation',
          icon: KasyIcons.northEast,
          onPressed: () {},
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyLink(label: 'Learn more', onPressed: () {}),
      ],
    );

Widget _buildLinkContext(BuildContext context) => SizedBox(
      width: 320,
      child: KasyCard(
        child: Padding(
          padding: const EdgeInsets.all(KasySpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Storage almost full', style: context.textTheme.titleSmall),
              const SizedBox(height: KasySpacing.xs),
              Text(
                'You have used 95% of your plan. Upgrade for more space.',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.colors.muted),
              ),
              const SizedBox(height: KasySpacing.smd),
              KasyLink(
                label: 'See plans',
                icon: KasyIcons.northEast,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

/// Static render of the link's hover / focus look for the showcase, built from
/// the same tokens as [KasyLink] so the showcase can't drift.
class _StaticLink extends StatelessWidget {
  const _StaticLink({this.hovered = false, this.focused = false});

  final bool hovered;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final TextStyle textStyle =
        (context.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: c.onSurface,
      decoration: TextDecoration.underline,
      decorationColor: c.onSurface,
      decorationThickness: 1.2,
    );

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Call to action', style: textStyle),
        const SizedBox(width: 2),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            KasyIcons.northEast,
            size: 14,
            color: c.onSurface.withValues(alpha: hovered ? 1.0 : 0.6),
          ),
        ),
      ],
    );

    if (hovered) row = Opacity(opacity: 0.8, child: row);
    if (focused) {
      row = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: <BoxShadow>[
            BoxShadow(color: c.primary, spreadRadius: 3),
            BoxShadow(color: c.background, spreadRadius: 1.5),
          ],
        ),
        child: row,
      );
    }
    return row;
  }
}

// ─── ToggleButton preview ───────────────────────────────────────────────────

Widget _buildToggleFilled(BuildContext context) => const _ToggleDemo(
      variant: KasyToggleButtonVariant.filled,
      items: <({IconData? icon, String? label})>[
        (label: 'Bold', icon: null),
        (label: 'Italic', icon: null),
        (label: 'Underline', icon: null),
      ],
      initial: <int>{0},
    );

Widget _buildToggleGhost(BuildContext context) => const _ToggleDemo(
      variant: KasyToggleButtonVariant.ghost,
      items: <({IconData? icon, String? label})>[
        (label: 'Daily', icon: null),
        (label: 'Weekly', icon: null),
        (label: 'Monthly', icon: null),
      ],
      single: true,
      initial: <int>{1},
    );

Widget _buildToggleSizes(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _toggleSizeCell(context, 'Small', KasyToggleButtonSize.sm),
        const SizedBox(width: KasySpacing.xl),
        _toggleSizeCell(context, 'Medium', KasyToggleButtonSize.md),
        const SizedBox(width: KasySpacing.xl),
        _toggleSizeCell(context, 'Large', KasyToggleButtonSize.lg),
      ],
    );

/// One size column: the toggle (same label across sizes, so only the height
/// changes) above a muted size caption.
Widget _toggleSizeCell(
  BuildContext context,
  String caption,
  KasyToggleButtonSize size,
) =>
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleDemo(
          variant: KasyToggleButtonVariant.filled,
          size: size,
          items: const <({IconData? icon, String? label})>[
            (label: 'Toggle', icon: null),
          ],
          single: true,
          initial: const <int>{0},
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(
          caption,
          style: context.textTheme.bodySmall
              ?.copyWith(color: context.colors.muted),
        ),
      ],
    );

Widget _buildToggleIconOnly(BuildContext context) => const _ToggleDemo(
      variant: KasyToggleButtonVariant.filled,
      items: <({IconData? icon, String? label})>[
        (label: null, icon: KasyIcons.favorite),
        (label: null, icon: KasyIcons.star),
        (label: null, icon: KasyIcons.notification),
      ],
      initial: <int>{1},
    );

Widget _buildToggleContext(BuildContext context) => SizedBox(
      width: 320,
      child: KasyCard(
        child: Padding(
          padding: const EdgeInsets.all(KasySpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'View',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.colors.muted),
              ),
              const SizedBox(height: KasySpacing.sm),
              const _ToggleDemo(
                variant: KasyToggleButtonVariant.ghost,
                items: <({IconData? icon, String? label})>[
                  (label: 'List', icon: null),
                  (label: 'Grid', icon: null),
                ],
                single: true,
                initial: <int>{0},
              ),
            ],
          ),
        ),
      ),
    );

/// Stateful showcase that actually toggles, so the preview reflects real
/// selection behaviour. [single] makes it a single-select group (radio-like);
/// otherwise each toggle is independent.
class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo({
    required this.items,
    required this.variant,
    this.size = KasyToggleButtonSize.md,
    this.single = false,
    this.initial = const <int>{},
  });

  final List<({String? label, IconData? icon})> items;
  final KasyToggleButtonVariant variant;
  final KasyToggleButtonSize size;
  final bool single;
  final Set<int> initial;

  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  late final Set<int> _selected = <int>{...widget.initial};

  void _onChanged(int index, bool value) {
    setState(() {
      if (widget.single) {
        _selected
          ..clear()
          ..add(index);
        return;
      }
      if (value) {
        _selected.add(index);
      } else {
        _selected.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KasySpacing.sm,
      runSpacing: KasySpacing.sm,
      children: [
        for (int i = 0; i < widget.items.length; i++)
          KasyToggleButton(
            label: widget.items[i].label,
            icon: widget.items[i].icon,
            variant: widget.variant,
            size: widget.size,
            selected: _selected.contains(i),
            onChanged: (v) => _onChanged(i, v),
          ),
      ],
    );
  }
}

// ─── ToggleButtonGroup preview ──────────────────────────────────────────────

const List<KasyToggleButtonItem> _kViewItems = <KasyToggleButtonItem>[
  KasyToggleButtonItem(label: 'Day'),
  KasyToggleButtonItem(label: 'Week'),
  KasyToggleButtonItem(label: 'Month'),
];

const List<KasyToggleButtonItem> _kFormatItems = <KasyToggleButtonItem>[
  KasyToggleButtonItem(label: 'Bold'),
  KasyToggleButtonItem(label: 'Italic'),
  KasyToggleButtonItem(label: 'Underline'),
];

Widget _buildToggleGroupSegmented(BuildContext context) => const _ToggleGroupDemo(
      items: _kViewItems,
      selectionMode: KasyToggleGroupSelection.single,
      initial: <int>{0},
    );

Widget _buildToggleGroupMulti(BuildContext context) => const _ToggleGroupDemo(
      items: _kFormatItems,
      selectionMode: KasyToggleGroupSelection.multiple,
      initial: <int>{0, 2},
    );

Widget _buildToggleGroupDetached(BuildContext context) => const _ToggleGroupDemo(
      items: _kViewItems,
      selectionMode: KasyToggleGroupSelection.single,
      isAttached: false,
      initial: <int>{1},
    );

Widget _buildToggleGroupVertical(BuildContext context) => const _ToggleGroupDemo(
      items: _kViewItems,
      selectionMode: KasyToggleGroupSelection.single,
      orientation: Axis.vertical,
      initial: <int>{0},
    );

/// Stateful wrapper so selection actually moves in the preview.
class _ToggleGroupDemo extends StatefulWidget {
  const _ToggleGroupDemo({
    required this.items,
    required this.selectionMode,
    this.isAttached = true,
    this.orientation = Axis.horizontal,
    this.initial = const <int>{},
  });

  final List<KasyToggleButtonItem> items;
  final KasyToggleGroupSelection selectionMode;
  final bool isAttached;
  final Axis orientation;
  final Set<int> initial;

  @override
  State<_ToggleGroupDemo> createState() => _ToggleGroupDemoState();
}

class _ToggleGroupDemoState extends State<_ToggleGroupDemo> {
  late Set<int> _selected = <int>{...widget.initial};

  @override
  Widget build(BuildContext context) {
    // Centre so the group receives loose constraints and hugs its content
    // (the preview hands builders a full-width tight box, which would otherwise
    // stretch the segmented pill and leave trailing empty space).
    return Center(
      child: KasyToggleButtonGroup(
        items: widget.items,
        selected: _selected,
        selectionMode: widget.selectionMode,
        isAttached: widget.isAttached,
        orientation: widget.orientation,
        onChanged: (next) => setState(() => _selected = next),
      ),
    );
  }
}

// ─── Tag preview ────────────────────────────────────────────────────────────

Widget _tagCaption(BuildContext context, String label, Widget tag) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tag,
        const SizedBox(height: KasySpacing.sm),
        Text(
          label,
          style: context.textTheme.bodySmall
              ?.copyWith(color: context.colors.muted),
        ),
      ],
    );

Widget _buildTagSizes(BuildContext context) => Wrap(
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _tagCaption(
          context,
          'sm',
          const KasyTag(label: 'Label', size: KasyTagSize.sm),
        ),
        _tagCaption(
          context,
          'md',
          const KasyTag(label: 'Label'),
        ),
        _tagCaption(
          context,
          'lg',
          const KasyTag(label: 'Label', size: KasyTagSize.lg),
        ),
      ],
    );

Widget _buildTagVariants(BuildContext context) => Wrap(
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.lg,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _tagCaption(context, 'neutral', const KasyTag(label: 'Label')),
        // Surface tags read against a tinted panel (their use case).
        _tagCaption(
          context,
          'surface',
          Container(
            padding: const EdgeInsets.all(KasySpacing.smd),
            decoration: BoxDecoration(
              color: context.colors.neutral,
              borderRadius: BorderRadius.circular(KasyRadius.md),
            ),
            child: const KasyTag(
              label: 'Label',
              variant: KasyTagVariant.surface,
            ),
          ),
        ),
      ],
    );

Widget _buildTagStates(BuildContext context) => Wrap(
      spacing: KasySpacing.md,
      runSpacing: KasySpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        KasyTag(label: 'Default', onPressed: () {}),
        KasyTag(label: 'Selected', selected: true, onPressed: () {}),
        KasyTag(label: 'Removable', onRemove: () {}),
        const KasyTag(label: 'Disabled', enabled: false),
      ],
    );

// ─── TagGroup preview ───────────────────────────────────────────────────────

Widget _buildTagGroupSelectable(BuildContext context) =>
    const _TagGroupSelectableDemo();

Widget _buildTagGroupRemovable(BuildContext context) =>
    const _TagGroupRemovableDemo();

Widget _buildTagGroupLabelled(BuildContext context) => const SizedBox(
      width: 320,
      child: KasyTagGroup(
        label: 'Skills',
        required: true,
        description: 'Pick the ones that apply.',
        selectionMode: KasyTagSelection.none,
        tags: [
          KasyTagData('Design'),
          KasyTagData('Flutter'),
          KasyTagData('Firebase'),
        ],
      ),
    );

Widget _buildTagGroupOverflow(BuildContext context) => const SizedBox(
      width: 320,
      child: KasyTagGroup(
        selectionMode: KasyTagSelection.none,
        maxVisible: 3,
        tags: [
          KasyTagData('Design'),
          KasyTagData('Flutter'),
          KasyTagData('Firebase'),
          KasyTagData('Supabase'),
          KasyTagData('REST'),
        ],
      ),
    );

class _TagGroupSelectableDemo extends StatefulWidget {
  const _TagGroupSelectableDemo();

  @override
  State<_TagGroupSelectableDemo> createState() =>
      _TagGroupSelectableDemoState();
}

class _TagGroupSelectableDemoState extends State<_TagGroupSelectableDemo> {
  Set<int> _selected = <int>{0, 2};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: KasyTagGroup(
        label: 'Filters',
        selected: _selected,
        onSelectionChanged: (next) => setState(() => _selected = next),
        tags: const [
          KasyTagData('All'),
          KasyTagData('Active'),
          KasyTagData('Archived'),
          KasyTagData('Draft'),
        ],
      ),
    );
  }
}

class _TagGroupRemovableDemo extends StatefulWidget {
  const _TagGroupRemovableDemo();

  @override
  State<_TagGroupRemovableDemo> createState() => _TagGroupRemovableDemoState();
}

class _TagGroupRemovableDemoState extends State<_TagGroupRemovableDemo> {
  List<String> _tags = <String>['Design', 'Flutter', 'Firebase', 'REST'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: KasyTagGroup(
        label: 'Tags',
        description: 'Tap × to remove.',
        selectionMode: KasyTagSelection.none,
        onRemove: (i) => setState(() => _tags = <String>[..._tags]..removeAt(i)),
        tags: <KasyTagData>[
          for (final String t in _tags) KasyTagData(t),
        ],
      ),
    );
  }
}

// ─── Surface preview ────────────────────────────────────────────────────────

Widget _surfaceSwatch(
  BuildContext context,
  String label,
  KasySurfaceVariant variant,
) =>
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: KasySurface(variant: variant),
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(
          label,
          style: context.textTheme.bodySmall
              ?.copyWith(color: context.colors.muted),
        ),
      ],
    );

Widget _buildSurfaceVariants(BuildContext context) => Wrap(
      spacing: KasySpacing.lg,
      runSpacing: KasySpacing.lg,
      alignment: WrapAlignment.center,
      children: [
        _surfaceSwatch(context, 'transparent', KasySurfaceVariant.transparent),
        _surfaceSwatch(context, 'default', KasySurfaceVariant.defaultSurface),
        _surfaceSwatch(context, 'secondary', KasySurfaceVariant.secondary),
        _surfaceSwatch(context, 'tertiary', KasySurfaceVariant.tertiary),
      ],
    );

Widget _buildSurfaceNested(BuildContext context) => SizedBox(
      width: 300,
      child: KasySurface(
        padding: const EdgeInsets.all(KasySpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Default surface', style: context.textTheme.titleSmall),
            const SizedBox(height: KasySpacing.smd),
            KasySurface(
              variant: KasySurfaceVariant.secondary,
              padding: const EdgeInsets.all(KasySpacing.md),
              child: Text(
                'Secondary nested inside, for a clear visual hierarchy.',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.colors.muted),
              ),
            ),
          ],
        ),
      ),
    );

// ─── Tooltip preview ─────────────────────────────────────────────────────────

Widget _tooltipTarget(BuildContext context, String label) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.smd,
        vertical: KasySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(KasyRadius.sm),
        border: Border.all(color: context.colors.outline.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: context.textTheme.bodyMedium),
    );

Widget _buildTooltipPlacements(BuildContext context) => Wrap(
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.xl,
      alignment: WrapAlignment.center,
      children: <Widget>[
        KasyTooltip(
          message: 'Top tooltip',
          child: _tooltipTarget(context, 'Top'),
        ),
        KasyTooltip(
          message: 'Bottom tooltip',
          placement: KasyTooltipPlacement.bottom,
          child: _tooltipTarget(context, 'Bottom'),
        ),
        KasyTooltip(
          message: 'Left tooltip',
          placement: KasyTooltipPlacement.left,
          child: _tooltipTarget(context, 'Left'),
        ),
        KasyTooltip(
          message: 'Right tooltip',
          placement: KasyTooltipPlacement.right,
          child: _tooltipTarget(context, 'Right'),
        ),
      ],
    );

Widget _buildTooltipInverse(BuildContext context) => Wrap(
      spacing: KasySpacing.xl,
      runSpacing: KasySpacing.xl,
      alignment: WrapAlignment.center,
      children: <Widget>[
        KasyTooltip(
          message: 'Default tooltip',
          child: _tooltipTarget(context, 'Default'),
        ),
        KasyTooltip(
          message: 'Inverse tooltip',
          inverse: true,
          child: _tooltipTarget(context, 'Inverse'),
        ),
      ],
    );

Widget _buildTooltipNoArrow(BuildContext context) => KasyTooltip(
      message: 'Tooltip without arrow',
      showArrow: false,
      child: _tooltipTarget(context, 'No arrow'),
    );

// ─── SocialAuthButton preview ───────────────────────────────────────────────

String _appleIcon(BuildContext context) => context.isDark
    ? 'assets/icons/apple_white.svg'
    : 'assets/icons/apple_black.svg';

Widget _buildSocialAuthRow(BuildContext context) => Row(
      children: <Widget>[
        Expanded(
          child: KasySocialAuthButton(
            label: 'Google',
            iconAsset: 'assets/icons/google.svg',
            onPressed: () {},
          ),
        ),
        const SizedBox(width: KasySpacing.sm),
        Expanded(
          child: KasySocialAuthButton(
            label: 'Apple',
            iconAsset: _appleIcon(context),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: KasySpacing.sm),
        Expanded(
          child: KasySocialAuthButton(
            label: 'Facebook',
            iconAsset: 'assets/icons/facebook.svg',
            onPressed: () {},
          ),
        ),
      ],
    );

Widget _buildSocialAuthLabeled(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        KasySocialAuthButton(
          label: 'Continue with Google',
          iconAsset: 'assets/icons/google.svg',
          showLabel: true,
          onPressed: () {},
        ),
        const SizedBox(height: KasySpacing.smd),
        KasySocialAuthButton(
          label: 'Continue with Apple',
          iconAsset: _appleIcon(context),
          showLabel: true,
          onPressed: () {},
        ),
      ],
    );

Widget _buildSocialAuthDisabled(BuildContext context) => Row(
      children: <Widget>[
        const Expanded(
          child: KasySocialAuthButton(
            label: 'Google',
            iconAsset: 'assets/icons/google.svg',
            onPressed: null,
          ),
        ),
        const SizedBox(width: KasySpacing.sm),
        Expanded(
          child: KasySocialAuthButton(
            label: 'Apple',
            iconAsset: _appleIcon(context),
            onPressed: null,
          ),
        ),
      ],
    );

// ─── ScrollShadow preview ───────────────────────────────────────────────────

Widget _scrollList(BuildContext context, {EdgeInsets? padding}) => ListView(
      padding: padding ?? EdgeInsets.zero,
      children: <Widget>[
        for (int i = 1; i <= 12; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KasySpacing.smd),
            child: Text('List item $i', style: context.textTheme.bodyMedium),
          ),
      ],
    );

Widget _buildScrollShadowVertical(BuildContext context) => SizedBox(
      width: 280,
      height: 220,
      child: KasyScrollShadow(child: _scrollList(context)),
    );

Widget _buildScrollShadowInSurface(BuildContext context) => SizedBox(
      width: 280,
      height: 220,
      child: KasySurface(
        padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
        child: KasyScrollShadow(
          inSurface: true,
          type: KasyScrollShadowType.blur,
          child: _scrollList(context),
        ),
      ),
    );

Widget _buildScrollShadowHorizontal(BuildContext context) => SizedBox(
      width: 300,
      height: 64,
      child: KasyScrollShadow(
        axis: Axis.horizontal,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for (int i = 1; i <= 10; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
                child: Center(
                  child: Text('Item $i', style: context.textTheme.bodyMedium),
                ),
              ),
          ],
        ),
      ),
    );

// ─── Label preview ──────────────────────────────────────────────────────────

/// One field block: a standalone [KasyLabel] above a label-less [KasyTextField],
/// proving the standalone label matches the field's own label exactly.
Widget _labelField(
  BuildContext context, {
  required Widget label,
  required Widget field,
}) =>
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        const SizedBox(height: KasySpacing.sm),
        field,
      ],
    );

Widget _buildLabelBasic(BuildContext context) => SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _labelField(
            context,
            label: const KasyLabel(
              'Username',
              tooltip: 'Letters, numbers and underscores only.',
            ),
            field: const KasyTextField(hint: 'Choose a username'),
          ),
          const SizedBox(height: KasySpacing.xl),
          _labelField(
            context,
            label: const KasyLabel('Password', required: true),
            field: const KasyTextField(
              hint: 'Create a password',
              contentType: KasyTextFieldContentType.password,
            ),
          ),
        ],
      ),
    );

Widget _buildLabelStates(BuildContext context) => SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _labelField(
            context,
            label: const KasyLabel('Confirm password', isInvalid: true),
            field: const KasyTextField(
              isInvalid: true,
              errorText: 'Passwords do not match',
              contentType: KasyTextFieldContentType.password,
            ),
          ),
          const SizedBox(height: KasySpacing.xl),
          _labelField(
            context,
            label: const KasyLabel(
              'Subscription plan',
              enabled: false,
              tooltip: 'Change your plan from billing settings.',
            ),
            field: const KasyTextField(hint: 'Premium', enabled: false),
          ),
        ],
      ),
    );

// ─── Description preview ────────────────────────────────────────────────────

Widget _buildDescription(BuildContext context) => const SizedBox(
      width: 300,
      child: KasyDescription(
        'We will never share your email with anyone else.',
      ),
    );

Widget _buildDescriptionContext(BuildContext context) => const SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KasyLabel('Email address'),
          SizedBox(height: KasySpacing.sm),
          KasyTextField(hint: 'you@example.com'),
          SizedBox(height: KasySpacing.xs),
          KasyDescription('We will use this to send order updates.'),
        ],
      ),
    );

// ─── FieldError preview ─────────────────────────────────────────────────────

Widget _buildFieldError(BuildContext context) => const SizedBox(
      width: 300,
      child: KasyFieldError('Please enter a valid email address.'),
    );

Widget _buildFieldErrorContext(BuildContext context) => const SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KasyLabel('Email address', isInvalid: true),
          SizedBox(height: KasySpacing.sm),
          KasyTextField(isInvalid: true, hint: 'you@example.com'),
          SizedBox(height: KasySpacing.xs),
          KasyFieldError('Please enter a valid email address.'),
        ],
      ),
    );

// ─── NumberField preview ────────────────────────────────────────────────────

Widget _buildNumberFieldDefault(BuildContext context) => const SizedBox(
      width: 280,
      child: _NumberFieldDemo(
        label: 'Amount',
        description: 'Description text',
        initial: 1,
      ),
    );

Widget _buildNumberFieldBounded(BuildContext context) => const SizedBox(
      width: 280,
      child: _NumberFieldDemo(
        label: 'Quantity',
        description: 'Between 0 and 10.',
        initial: 0,
        min: 0,
        max: 10,
      ),
    );

Widget _buildNumberFieldError(BuildContext context) => const SizedBox(
      width: 280,
      child: _NumberFieldDemo(
        label: 'Amount',
        initial: 100,
        isInvalid: true,
        errorText: 'Only 10 left in stock',
      ),
    );

Widget _buildNumberFieldDisabled(BuildContext context) => const SizedBox(
      width: 280,
      child: KasyNumberField(
        label: 'Amount',
        description: 'Description text',
        value: 1,
        enabled: false,
      ),
    );

/// Stateful wrapper so the steppers and typing actually move the value in the
/// preview.
class _NumberFieldDemo extends StatefulWidget {
  const _NumberFieldDemo({
    required this.label,
    required this.initial,
    this.description,
    this.errorText,
    this.isInvalid = false,
    this.min,
    this.max,
  });

  final String label;
  final int initial;
  final String? description;
  final String? errorText;
  final bool isInvalid;
  final int? min;
  final int? max;

  @override
  State<_NumberFieldDemo> createState() => _NumberFieldDemoState();
}

class _NumberFieldDemoState extends State<_NumberFieldDemo> {
  late int _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return KasyNumberField(
      label: widget.label,
      description: widget.description,
      errorText: widget.errorText,
      isInvalid: widget.isInvalid,
      value: _value,
      min: widget.min,
      max: widget.max,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

// ─── Skeleton preview ─────────────────────────────────────────────────────────

const String _kUnsplashCard =
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4'
    '?w=600&q=80&fit=crop';

class _SkeletonCardPreview extends StatefulWidget {
  const _SkeletonCardPreview();

  @override
  State<_SkeletonCardPreview> createState() => _SkeletonCardPreviewState();
}

class _SkeletonCardPreviewState extends State<_SkeletonCardPreview> {
  KasySkeletonAnimation _mode = KasySkeletonAnimation.shimmer;
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCard(context),
        const SizedBox(height: KasySpacing.lg),
        _buildControls(context),
      ],
    );
  }

  // ── Card ───────────────────────────────────────────────────────────────────
  // Stack + AnimatedOpacity: both cards are in the layout simultaneously,
  // so the column height never changes → controls below never shift.

  Widget _buildCard(BuildContext context) {
    return Stack(
      children: [
        // Real card — always rendered so the image preloads.
        AnimatedOpacity(
          opacity: _loading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: const _RealCardContent(),
        ),
        // Skeleton — fades out on top.
        IgnorePointer(
          ignoring: !_loading,
          child: AnimatedOpacity(
            opacity: _loading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            child: KasySkeletonGroup(
              animation: _mode,
              child: const _SkeletonCardContent(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Controls ───────────────────────────────────────────────────────────────

  Widget _buildControls(BuildContext context) {
    return _SkeletonControls(
      mode: _mode,
      loading: _loading,
      onModeChanged: (m) => setState(() => _mode = m),
      onLoadingChanged: (v) => setState(() => _loading = v),
    );
  }
}

// ── Skeleton card content ──────────────────────────────────────────────────────
// Layout mirrors _RealCardContent exactly so the Stack height stays constant.

class _SkeletonCardContent extends StatelessWidget {
  const _SkeletonCardContent();

  @override
  Widget build(BuildContext context) {
    return const KasyCard(
      child: Padding(
        padding: EdgeInsets.all(KasySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ① Author row
            Row(
              children: [
                KasySkeleton.circle(size: 40),
                SizedBox(width: KasySpacing.smd),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KasySkeleton(width: 120, height: 13),
                      SizedBox(height: KasySpacing.xs),
                      KasySkeleton(width: 80, height: 11),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: KasySpacing.smd),
            // ② Image placeholder
            KasySkeleton(
              width: double.infinity,
              height: 180,
              borderRadius: BorderRadius.all(Radius.circular(KasyRadius.md)),
            ),
            SizedBox(height: KasySpacing.smd),
            // ③ Caption lines  (3 lines ≈ same height as real Text)
            KasySkeleton(width: double.infinity, height: 11),
            SizedBox(height: KasySpacing.xs),
            KasySkeleton(width: double.infinity, height: 11),
            SizedBox(height: KasySpacing.xs),
            KasySkeleton(width: 160, height: 11),
            SizedBox(height: KasySpacing.md),
            // ④ Action buttons
            Row(
              children: [
                KasySkeleton(
                  width: 88,
                  height: 34,
                  borderRadius: BorderRadius.all(Radius.circular(KasyRadius.sm)),
                ),
                SizedBox(width: KasySpacing.sm),
                KasySkeleton(
                  width: 88,
                  height: 34,
                  borderRadius: BorderRadius.all(Radius.circular(KasyRadius.sm)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Real card content ──────────────────────────────────────────────────────────

class _RealCardContent extends StatelessWidget {
  const _RealCardContent();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return KasyCard(
      child: Padding(
        padding: const EdgeInsets.all(KasySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ① Author row
            Row(
              children: [
                const KasyAvatar(
                  size: KasyAvatarSize.small,
                  initials: 'AJ',
                ),
                const SizedBox(width: KasySpacing.smd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alex Johnson',
                        style: context.kasyTextTheme.cardTitle.copyWith(
                          color: c.onSurface,
                        ),
                      ),
                      Text(
                        '@alexjohnson · 2h ago',
                        style: context.kasyTextTheme.cardSubtitle.copyWith(
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: KasySpacing.smd),
            // ② Photo — full-width, rounded, sits between header and caption
            ClipRRect(
              borderRadius: KasyRadius.mdBorderRadius,
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: Image.network(
                  _kUnsplashCard,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return ColoredBox(
                      color: c.surfaceNeutralSoft,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: c.primary,
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => ColoredBox(
                    color: c.surfaceNeutralSoft,
                    child: Center(
                      child: Icon(KasyIcons.gallery, size: 32, color: c.muted),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: KasySpacing.smd),
            // ③ Caption
            Text(
              'Breathtaking view from the summit trail in Patagonia. '
              'Golden hour light made every single step worth it.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: c.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: KasySpacing.md),
            // ④ Action buttons
            Row(
              children: [
                KasyButton(
                  label: 'Like',
                  icon: KasyIcons.favorite,
                  variant: KasyButtonVariant.neutral,
                  size: KasyButtonSize.small,
                  onPressed: () {},
                ),
                const SizedBox(width: KasySpacing.sm),
                KasyButton(
                  label: 'Share',
                  icon: KasyIcons.share,
                  variant: KasyButtonVariant.neutral,
                  size: KasyButtonSize.small,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared skeleton controls ─────────────────────────────────────────────────

class _SkeletonControls extends StatelessWidget {
  const _SkeletonControls({
    required this.mode,
    required this.loading,
    required this.onModeChanged,
    required this.onLoadingChanged,
  });

  final KasySkeletonAnimation mode;
  final bool loading;
  final ValueChanged<KasySkeletonAnimation> onModeChanged;
  final ValueChanged<bool> onLoadingChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return KasyCard(
      variant: KasyCardVariant.outlined,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: KasySpacing.smd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              'Animation',
              style: context.kasyTextTheme.sectionLabel.copyWith(
                color: c.muted,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: KasySpacing.sm),
            // Mode buttons
            Row(
              children: KasySkeletonAnimation.values.map((m) {
                final selected = mode == m;
                final label = switch (m) {
                  KasySkeletonAnimation.shimmer => 'Shimmer',
                  KasySkeletonAnimation.pulse => 'Pulse',
                  KasySkeletonAnimation.none => 'None',
                };
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: m != KasySkeletonAnimation.none
                          ? KasySpacing.xs
                          : 0,
                    ),
                    child: KasyButton(
                      label: label,
                      variant: selected
                          ? KasyButtonVariant.primary
                          : KasyButtonVariant.neutral,
                      size: KasyButtonSize.small,
                      onPressed: () => onModeChanged(m),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: KasySpacing.smd),
            Divider(
              height: 1,
              thickness: 1,
              color: c.outline.withValues(alpha: 0.28),
            ),
            const SizedBox(height: KasySpacing.smd),
            // Loading toggle row
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KasyRadius.sm),
                  ),
                  child: Icon(KasyIcons.refresh, size: 16, color: c.primary),
                ),
                const SizedBox(width: KasySpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loading',
                        style: context.textTheme.titleMedium
                            ?.copyWith(color: c.onSurface),
                      ),
                      Text(
                        'Toggle skeleton loading state',
                        style: context.kasyTextTheme.caption.copyWith(
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                KasySwitch(value: loading, onChanged: onLoadingChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List skeleton preview ────────────────────────────────────────────────────

class _SkeletonListPreview extends StatefulWidget {
  const _SkeletonListPreview();

  @override
  State<_SkeletonListPreview> createState() => _SkeletonListPreviewState();
}

class _SkeletonListPreviewState extends State<_SkeletonListPreview> {
  KasySkeletonAnimation _mode = KasySkeletonAnimation.shimmer;
  bool _loading = true;

  static const List<({String title, String subtitle, IconData icon, Color color})>
      _kItems = [
    (
      title: 'Notifications',
      subtitle: 'Push, email and in-app alerts',
      icon: KasyIcons.notification,
      color: Color(0xFF5C6BC0),
    ),
    (
      title: 'Privacy',
      subtitle: 'Manage data and permissions',
      icon: KasyIcons.privacy,
      color: Color(0xFF26A69A),
    ),
    (
      title: 'Appearance',
      subtitle: 'Theme, font size and display',
      icon: KasyIcons.palette,
      color: Color(0xFFFFA726),
    ),
    (
      title: 'Storage',
      subtitle: 'Cache, media and backups',
      icon: KasyIcons.packageOutline,
      color: Color(0xFFEF5350),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildList(context),
        const SizedBox(height: KasySpacing.lg),
        _SkeletonControls(
          mode: _mode,
          loading: _loading,
          onModeChanged: (m) => setState(() => _mode = m),
          onLoadingChanged: (v) => setState(() => _loading = v),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return Stack(
      children: [
        // Real list — always rendered
        AnimatedOpacity(
          opacity: _loading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: _buildRealList(context),
        ),
        // Skeleton — fades out
        IgnorePointer(
          ignoring: !_loading,
          child: AnimatedOpacity(
            opacity: _loading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            child: KasySkeletonGroup(
              animation: _mode,
              child: _buildSkeletonList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return KasyCard(
      child: Column(
        children: List.generate(_kItems.length, (i) {
          return _SkeletonListRow(index: i, isLast: i == _kItems.length - 1);
        }),
      ),
    );
  }

  Widget _buildRealList(BuildContext context) {
    final c = context.colors;

    return KasyCard(
      child: Column(
        children: List.generate(_kItems.length, (i) {
          final item = _kItems[i];
          final isLast = i == _kItems.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KasySpacing.md,
                  vertical: KasySpacing.smd,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.14),
                        borderRadius: KasyRadius.smBorderRadius,
                      ),
                      child: Icon(item.icon, size: 20, color: item.color),
                    ),
                    const SizedBox(width: KasySpacing.smd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: context.kasyTextTheme.rowTitle.copyWith(
                              color: c.onSurface,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            style: context.kasyTextTheme.cardSubtitle.copyWith(
                              color: c.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      KasyIcons.chevronRight,
                      size: 18,
                      color: c.muted,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: KasySpacing.md + 44 + KasySpacing.smd,
                  color: context.colors.outline.withValues(alpha: 0.22),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Skeleton list row ──────────────────────────────────────────────────────────

class _SkeletonListRow extends StatelessWidget {
  const _SkeletonListRow({required this.index, required this.isLast});

  final int index;
  final bool isLast;

  // Vary subtitle widths per row for a realistic look.
  static const List<double> _subtitleWidths = [160, 140, 170, 130];

  @override
  Widget build(BuildContext context) {
    final subtitleW = _subtitleWidths[index % _subtitleWidths.length];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.md,
            vertical: KasySpacing.smd,
          ),
          child: Row(
            children: [
              const KasySkeleton(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.all(Radius.circular(KasyRadius.sm)),
              ),
              const SizedBox(width: KasySpacing.smd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KasySkeleton(width: double.infinity, height: 13),
                    const SizedBox(height: KasySpacing.xs),
                    KasySkeleton(width: subtitleW, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: KasySpacing.md + 44 + KasySpacing.smd,
            color: context.colors.outline.withValues(alpha: 0.22),
          ),
      ],
    );
  }
}

// ─── Text skeleton preview ────────────────────────────────────────────────────

class _SkeletonTextPreview extends StatefulWidget {
  const _SkeletonTextPreview();

  @override
  State<_SkeletonTextPreview> createState() => _SkeletonTextPreviewState();
}

class _SkeletonTextPreviewState extends State<_SkeletonTextPreview> {
  KasySkeletonAnimation _mode = KasySkeletonAnimation.shimmer;
  bool _loading = true;

  static const String _kParagraph =
      'The new productivity dashboard makes it easy to track daily tasks '
      'and goals. You can customize widgets and set smart reminders.';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildContent(context),
        const SizedBox(height: KasySpacing.lg),
        _SkeletonControls(
          mode: _mode,
          loading: _loading,
          onModeChanged: (m) => setState(() => _mode = m),
          onLoadingChanged: (v) => setState(() => _loading = v),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Stack(
      children: [
        // Real text — always rendered to fix the height.
        AnimatedOpacity(
          opacity: _loading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: _buildRealText(context),
        ),
        // Skeleton lines on top.
        IgnorePointer(
          ignoring: !_loading,
          child: AnimatedOpacity(
            opacity: _loading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            child: KasySkeletonGroup(
              animation: _mode,
              child: const _SkeletonTextBlock(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealText(BuildContext context) {
    return Text(
      _kParagraph,
      style: context.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: context.colors.onSurface,
      ),
    );
  }
}

// ── Skeleton text block ────────────────────────────────────────────────────────
// Three lines mimicking a paragraph: 100% → ~68% → ~42% width.

class _SkeletonTextBlock extends StatelessWidget {
  const _SkeletonTextBlock();

  @override
  Widget build(BuildContext context) {
    // Line height matches real Text(fontSize:16, height:1.6) → 25.6px per line.
    // Bone height 14px + gap 11px ≈ 25px between baselines.
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KasySkeleton(width: double.infinity, height: 14),
        SizedBox(height: 11),
        KasySkeleton(width: double.infinity, height: 14),
        SizedBox(height: 11),
        KasySkeleton(width: double.infinity, height: 14),
        SizedBox(height: 11),
        KasySkeleton(width: double.infinity, height: 14),
        SizedBox(height: 11),
        KasySkeleton(width: 160, height: 14),
      ],
    );
  }
}

// ─── Profile skeleton preview ─────────────────────────────────────────────────

class _SkeletonProfilePreview extends StatefulWidget {
  const _SkeletonProfilePreview();

  @override
  State<_SkeletonProfilePreview> createState() =>
      _SkeletonProfilePreviewState();
}

class _SkeletonProfilePreviewState extends State<_SkeletonProfilePreview> {
  KasySkeletonAnimation _mode = KasySkeletonAnimation.shimmer;
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildContent(context),
        const SizedBox(height: KasySpacing.lg),
        _SkeletonControls(
          mode: _mode,
          loading: _loading,
          onModeChanged: (m) => setState(() => _mode = m),
          onLoadingChanged: (v) => setState(() => _loading = v),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _loading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: _buildRealProfile(context),
        ),
        IgnorePointer(
          ignoring: !_loading,
          child: AnimatedOpacity(
            opacity: _loading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            child: KasySkeletonGroup(
              animation: _mode,
              child: const _SkeletonProfileBlock(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealProfile(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        // Avatar
        const KasyAvatar(
          size: KasyAvatarSize.large,
          initials: 'AJ',
        ),
        const SizedBox(height: KasySpacing.smd),
        // Name
        Text(
          'Alex Johnson',
          style: context.textTheme.headlineSmall?.copyWith(
            color: c.onSurface,
          ),
        ),
        const SizedBox(height: KasySpacing.xs),
        // Handle
        Text(
          '@alexjohnson',
          style: context.kasyTextTheme.cardSubtitle.copyWith(
            color: c.muted,
          ),
        ),
        const SizedBox(height: KasySpacing.smd),
        // Bio
        Text(
          'Product designer & outdoor enthusiast. Building tools that help people do more with less.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: c.onSurface,
            height: 1.5,
          ),
        ),
        const SizedBox(height: KasySpacing.md),
        // Stats row
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatCell(label: 'Posts', value: '142'),
            _StatDivider(),
            _StatCell(label: 'Followers', value: '8.4k'),
            _StatDivider(),
            _StatCell(label: 'Following', value: '310'),
          ],
        ),
        const SizedBox(height: KasySpacing.md),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KasyButton(
              label: 'Follow',
              size: KasyButtonSize.small,
              onPressed: () {},
            ),
            const SizedBox(width: KasySpacing.sm),
            KasyButton(
              label: 'Message',
              icon: KasyIcons.message,
              variant: KasyButtonVariant.neutral,
              size: KasyButtonSize.small,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KasySpacing.md),
      child: Column(
        children: [
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: c.onSurface,
            ),
          ),
          Text(
            label,
            style: context.kasyTextTheme.caption.copyWith(
              color: c.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  // ignore: unused_element
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: context.colors.outline.withValues(alpha: 0.35),
    );
  }
}

// ── Skeleton profile block ─────────────────────────────────────────────────────

class _SkeletonProfileBlock extends StatelessWidget {
  const _SkeletonProfileBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Avatar circle
        KasySkeleton.circle(size: 70),
        SizedBox(height: KasySpacing.smd),
        // Name
        KasySkeleton(width: 140, height: 18),
        SizedBox(height: KasySpacing.xs),
        // Handle
        KasySkeleton(width: 96, height: 12),
        SizedBox(height: KasySpacing.smd),
        // Bio lines
        KasySkeleton(width: double.infinity, height: 12),
        SizedBox(height: KasySpacing.xs),
        KasySkeleton(width: double.infinity, height: 12),
        SizedBox(height: KasySpacing.xs),
        KasySkeleton(width: 180, height: 12),
        SizedBox(height: KasySpacing.md),
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SkeletonStatCell(),
            SizedBox(width: KasySpacing.xl),
            _SkeletonStatCell(),
            SizedBox(width: KasySpacing.xl),
            _SkeletonStatCell(),
          ],
        ),
        SizedBox(height: KasySpacing.md),
        // Buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KasySkeleton(
              width: 88,
              height: 34,
              borderRadius: BorderRadius.all(Radius.circular(KasyRadius.sm)),
            ),
            SizedBox(width: KasySpacing.sm),
            KasySkeleton(
              width: 110,
              height: 34,
              borderRadius: BorderRadius.all(Radius.circular(KasyRadius.sm)),
            ),
          ],
        ),
      ],
    );
  }
}

class _SkeletonStatCell extends StatelessWidget {
  const _SkeletonStatCell();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KasySkeleton(width: 36, height: 16),
        SizedBox(height: KasySpacing.xs),
        KasySkeleton(width: 52, height: 10),
      ],
    );
  }
}

// ─── Grid skeleton preview ────────────────────────────────────────────────────

const List<String> _kGridImages = [
  'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=400&q=75&fit=crop',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&q=75&fit=crop',
  'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=400&q=75&fit=crop',
  'https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=400&q=75&fit=crop',
];

const List<({String title, String subtitle})> _kGridItems = [
  (title: 'Golden Dunes', subtitle: 'Sahara, Morocco'),
  (title: 'Forest Path', subtitle: 'British Columbia'),
  (title: 'Autumn Maple', subtitle: 'Kyoto, Japan'),
  (title: 'Waterfall', subtitle: 'Plitvice, Croatia'),
];

class _SkeletonGridPreview extends StatefulWidget {
  const _SkeletonGridPreview();

  @override
  State<_SkeletonGridPreview> createState() => _SkeletonGridPreviewState();
}

class _SkeletonGridPreviewState extends State<_SkeletonGridPreview> {
  KasySkeletonAnimation _mode = KasySkeletonAnimation.shimmer;
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildContent(context),
        const SizedBox(height: KasySpacing.lg),
        _SkeletonControls(
          mode: _mode,
          loading: _loading,
          onModeChanged: (m) => setState(() => _mode = m),
          onLoadingChanged: (v) => setState(() => _loading = v),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _loading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: _buildRealGrid(context),
        ),
        IgnorePointer(
          ignoring: !_loading,
          child: AnimatedOpacity(
            opacity: _loading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            child: KasySkeletonGroup(
              animation: _mode,
              child: const _SkeletonGrid(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealGrid(BuildContext context) {
    final c = context.colors;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: KasySpacing.sm,
      mainAxisSpacing: KasySpacing.sm,
      childAspectRatio: 1.05,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(_kGridItems.length, (i) {
        final item = _kGridItems[i];
        final url = _kGridImages[i];
        return KasyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return ColoredBox(
                        color: c.surfaceNeutralSoft,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: c.primary,
                            strokeWidth: 2,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: c.surfaceNeutralSoft,
                      child: Center(
                        child: Icon(
                          KasyIcons.gallery,
                          size: 28,
                          color: c.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Text
              Padding(
                padding: const EdgeInsets.all(KasySpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: context.kasyTextTheme.cardTitle.copyWith(
                        color: c.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: context.kasyTextTheme.cardSubtitle.copyWith(
                        color: c.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Skeleton grid ──────────────────────────────────────────────────────────────

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: KasySpacing.sm,
      mainAxisSpacing: KasySpacing.sm,
      childAspectRatio: 1.05,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _SkeletonGridCell(subtitleWidth: 72),
        _SkeletonGridCell(subtitleWidth: 88),
        _SkeletonGridCell(subtitleWidth: 80),
        _SkeletonGridCell(subtitleWidth: 76),
      ],
    );
  }
}

class _SkeletonGridCell extends StatelessWidget {
  const _SkeletonGridCell({required this.subtitleWidth});

  final double subtitleWidth;

  @override
  Widget build(BuildContext context) {
    return KasyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image block — fills the card above the text area
          const Expanded(
            child: KasySkeleton(
              width: double.infinity,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(KasyRadius.xl),
              ),
              height: double.infinity,
            ),
          ),
          // Text area
          Padding(
            padding: const EdgeInsets.all(KasySpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KasySkeleton(width: double.infinity, height: 12),
                const SizedBox(height: 4),
                KasySkeleton(width: subtitleWidth, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SwipeAction — wrap any tile so the user can swipe it to reveal an action
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildSwipeActionDestructive(BuildContext context) =>
    const _SwipeActionPreview(tone: KasySwipeActionTone.destructive);

Widget _buildSwipeActionNeutral(BuildContext context) =>
    const _SwipeActionPreview(
      tone: KasySwipeActionTone.neutral,
      icon: Icons.archive_outlined,
    );

Widget _buildSwipeActionWithConfirm(BuildContext context) =>
    const _SwipeActionPreview(
      tone: KasySwipeActionTone.destructive,
      useConfirm: true,
    );

class _SwipeActionPreview extends StatefulWidget {
  final KasySwipeActionTone tone;
  final IconData? icon;
  final bool useConfirm;

  const _SwipeActionPreview({
    required this.tone,
    this.icon,
    this.useConfirm = false,
  });

  @override
  State<_SwipeActionPreview> createState() => _SwipeActionPreviewState();
}

class _SwipeActionPreviewState extends State<_SwipeActionPreview> {
  late List<_SwipePreviewItem> _items = _initial();

  List<_SwipePreviewItem> _initial() => List.generate(
        4,
        (i) => _SwipePreviewItem(
          id: i,
          title: 'Item ${i + 1}',
          subtitle: 'Swipe left to ${widget.useConfirm ? 'try to ' : ''}remove',
        ),
      );

  void _reset() => setState(() => _items = _initial());

  Future<bool> _confirm() async {
    bool confirmed = false;
    await showKasyConfirmDialog(
      context,
      title: 'Remove item?',
      message: 'This is just a preview — nothing is actually deleted.',
      cancelLabel: 'Cancel',
      confirmLabel: 'Remove',
      destructive: true,
      onConfirm: () => confirmed = true,
    );
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(KasySpacing.lg),
        child: Column(
          children: [
            Text(
              'All items removed',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KasySpacing.sm),
            KasyButton(
              label: 'Reset preview',
              variant: KasyButtonVariant.outline,
              onPressed: _reset,
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in _items)
          widget.useConfirm
              ? KasySwipeAction.withConfirm(
                  key: ValueKey('swipe_confirm_${item.id}'),
                  onDismissed: () =>
                      setState(() => _items.removeWhere((i) => i.id == item.id)),
                  confirm: _confirm,
                  tone: widget.tone,
                  icon: widget.icon ?? KasyIcons.trash,
                  child: _SwipePreviewTile(item: item),
                )
              : KasySwipeAction(
                  key: ValueKey('swipe_${item.id}'),
                  onDismissed: () =>
                      setState(() => _items.removeWhere((i) => i.id == item.id)),
                  tone: widget.tone,
                  icon: widget.icon ?? KasyIcons.trash,
                  child: _SwipePreviewTile(item: item),
                ),
      ],
    );
  }
}

class _SwipePreviewItem {
  final int id;
  final String title;
  final String subtitle;
  const _SwipePreviewItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });
}

class _SwipePreviewTile extends StatelessWidget {
  final _SwipePreviewItem item;
  const _SwipePreviewTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KasySpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.outline, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.surfaceNeutralSoft,
              borderRadius: BorderRadius.circular(KasyRadius.md),
            ),
            child: Icon(KasyIcons.assistant, color: context.colors.onSurface),
          ),
          const SizedBox(width: KasySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: context.textTheme.bodyMedium),
                Text(
                  item.subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar — standalone inline calendar (KasyCalendar)
// ─────────────────────────────────────────────────────────────────────────────

/// Calendars carry a fixed Figma width (288 for a single month). The preview
/// surface stretches its child, so each example is top-centered to keep the
/// calendar at its natural width instead of edge-to-edge.
Widget _centeredCalendar(Widget child) => Align(
      alignment: Alignment.topCenter,
      child: child,
    );

// ── Present: the default calendar, focused on the current month ──────────────

Widget _buildCalendarPresent(BuildContext context) =>
    const _CalendarPresentPreview();

class _CalendarPresentPreview extends StatefulWidget {
  const _CalendarPresentPreview();

  @override
  State<_CalendarPresentPreview> createState() =>
      _CalendarPresentPreviewState();
}

class _CalendarPresentPreviewState extends State<_CalendarPresentPreview> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return _centeredCalendar(
      KasyCalendar(
        value: _date,
        onChanged: (d) => setState(() => _date = d),
        locale: _datePickerLocaleForApp(context),
      ),
    );
  }
}

// ── Future: opens a few months ahead for navigating upcoming dates ───────────

Widget _buildCalendarFuture(BuildContext context) =>
    const _CalendarFuturePreview();

class _CalendarFuturePreview extends StatefulWidget {
  const _CalendarFuturePreview();

  @override
  State<_CalendarFuturePreview> createState() => _CalendarFuturePreviewState();
}

class _CalendarFuturePreviewState extends State<_CalendarFuturePreview> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return _centeredCalendar(
      KasyCalendar(
        value: _date,
        onChanged: (d) => setState(() => _date = d),
        // Start three months ahead — the "future" calendar type.
        initialMonth: DateTime(now.year, now.month + 3),
        locale: _datePickerLocaleForApp(context),
      ),
    );
  }
}

// ── Years: opens directly on the year picker grid ────────────────────────────

Widget _buildCalendarYears(BuildContext context) =>
    const _CalendarYearsPreview();

class _CalendarYearsPreview extends StatefulWidget {
  const _CalendarYearsPreview();

  @override
  State<_CalendarYearsPreview> createState() => _CalendarYearsPreviewState();
}

class _CalendarYearsPreviewState extends State<_CalendarYearsPreview> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return _centeredCalendar(
      KasyCalendar(
        value: _date,
        onChanged: (d) => setState(() => _date = d),
        initialView: KasyCalendarView.year,
        locale: _datePickerLocaleForApp(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar — event indicator dots (markedDates)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildCalendarEvents(BuildContext context) =>
    const _CalendarEventsPreview();

class _CalendarEventsPreview extends StatefulWidget {
  const _CalendarEventsPreview();

  @override
  State<_CalendarEventsPreview> createState() => _CalendarEventsPreviewState();
}

class _CalendarEventsPreviewState extends State<_CalendarEventsPreview> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    // A handful of "event" days in the current month so the indicator dots are
    // always visible regardless of when the preview is opened.
    final DateTime now = DateTime.now();
    final Set<DateTime> events = {
      for (final int day in const [3, 9, 16, 17, 24])
        DateTime(now.year, now.month, day),
    };
    return _centeredCalendar(
      KasyCalendar(
        value: _date,
        onChanged: (d) => setState(() => _date = d),
        markedDates: events,
        locale: _datePickerLocaleForApp(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar — range selection (start + end)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildCalendarRange(BuildContext context) =>
    const _CalendarRangePreview();

class _CalendarRangePreview extends StatefulWidget {
  const _CalendarRangePreview();

  @override
  State<_CalendarRangePreview> createState() => _CalendarRangePreviewState();
}

class _CalendarRangePreviewState extends State<_CalendarRangePreview> {
  KasyDateRange? _stay;

  @override
  Widget build(BuildContext context) {
    return _centeredCalendar(
      KasyCalendar(
        selectionMode: KasyDateSelectionMode.range,
        range: _stay,
        onRangeChanged: (r) => setState(() => _stay = r),
        locale: _datePickerLocaleForApp(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar — time selection (editable hour : minute AM/PM segments)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildCalendarTime(BuildContext context) => const _CalendarTimePreview();

class _CalendarTimePreview extends StatefulWidget {
  const _CalendarTimePreview();

  @override
  State<_CalendarTimePreview> createState() => _CalendarTimePreviewState();
}

class _CalendarTimePreviewState extends State<_CalendarTimePreview> {
  DateTime? _date;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 30);

  @override
  Widget build(BuildContext context) {
    return _centeredCalendar(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live calendar with the editable time row — type, tab or ↑/↓ to
          // edit; the hover/focus states show by interacting with the segments.
          KasyCalendar(
            value: _date,
            onChanged: (d) => setState(() => _date = d),
            showTime: true,
            time: _time,
            onTimeChanged: (t) => setState(() => _time = t),
            timeZoneLabel: 'EDT',
            locale: _datePickerLocaleForApp(context),
          ),
          const SizedBox(height: KasySpacing.xl),
          // Reference sheet for every time-value state (Figma _CalendarTimeValue).
          const _CalendarTimeStatesReference(),
        ],
      ),
    );
  }
}

/// Documents the six time-value states from Figma (default, filled, hover,
/// focus, invalid, inv. focus). The live states are interaction-driven on the
/// calendar above; this sheet lays them out for reference. Small enough to fit
/// a phone width (six compact cells, wraps if needed).
class _CalendarTimeStatesReference extends StatelessWidget {
  const _CalendarTimeStatesReference();

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: KasySpacing.md,
      runSpacing: KasySpacing.md,
      children: [
        _cell(context, 'default', textColor: c.muted),
        _cell(context, 'filled', textColor: c.onSurface),
        _cell(context, 'hover', textColor: c.onSurface, bg: c.neutralHover),
        _cell(context, 'focus',
            textColor: c.primarySoftForeground, bg: c.primarySoft),
        _cell(context, 'invalid', textColor: c.error),
        _cell(context, 'inv. focus', textColor: c.error, bg: c.dangerSoft),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    String label, {
    required Color textColor,
    Color? bg,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.muted,
          ),
        ),
        const SizedBox(height: KasySpacing.xs),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '10',
            style: context.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar — top + bottom content (the composed Figma "CalendarPopover")
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildCalendarComposed(BuildContext context) =>
    const _CalendarComposedPreview();

class _CalendarComposedPreview extends StatefulWidget {
  const _CalendarComposedPreview();

  @override
  State<_CalendarComposedPreview> createState() =>
      _CalendarComposedPreviewState();
}

class _CalendarComposedPreviewState extends State<_CalendarComposedPreview> {
  KasyDateRange? _range;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 30);
  Set<int> _scope = {0};
  int _preset = 0;

  @override
  Widget build(BuildContext context) {
    return _centeredCalendar(
      KasyCalendar(
        selectionMode: KasyDateSelectionMode.range,
        range: _range,
        onRangeChanged: (r) => setState(() => _range = r),
        showTime: true,
        time: _time,
        onTimeChanged: (t) => setState(() => _time = t),
        timeZoneLabel: 'EDT',
        locale: _datePickerLocaleForApp(context),
        // Top content: a Today / Week / Month scope toggle.
        topContent: KasyToggleButtonGroup(
          size: KasyToggleButtonSize.sm,
          expand: true,
          items: const [
            KasyToggleButtonItem(label: 'Today'),
            KasyToggleButtonItem(label: 'Week'),
            KasyToggleButtonItem(label: 'Month'),
          ],
          selected: _scope,
          onChanged: (s) => setState(() => _scope = s),
        ),
        // Bottom content: quick range presets as tags.
        bottomContent: Wrap(
          spacing: KasySpacing.sm,
          runSpacing: KasySpacing.sm,
          children: [
            for (int i = 0; i < 3; i++)
              KasyTag(
                label: const ['Exact dates', '1 day', '2 days'][i],
                selected: _preset == i,
                onPressed: () => setState(() => _preset = i),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar — mobile (drag handle, bottom-sheet style)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildCalendarMobile(BuildContext context) =>
    const _CalendarMobilePreview();

class _CalendarMobilePreview extends StatefulWidget {
  const _CalendarMobilePreview();

  @override
  State<_CalendarMobilePreview> createState() => _CalendarMobilePreviewState();
}

class _CalendarMobilePreviewState extends State<_CalendarMobilePreview> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return _centeredCalendar(
      KasyCalendar(
        value: _date,
        onChanged: (d) => setState(() => _date = d),
        // Drag handle on top — the "mobile" type, as presented in a sheet.
        showDragHandle: true,
        locale: _datePickerLocaleForApp(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar — min / max bounds (out-of-range days fade out)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildCalendarBounded(BuildContext context) =>
    const _CalendarBoundedPreview();

class _CalendarBoundedPreview extends StatefulWidget {
  const _CalendarBoundedPreview();

  @override
  State<_CalendarBoundedPreview> createState() =>
      _CalendarBoundedPreviewState();
}

class _CalendarBoundedPreviewState extends State<_CalendarBoundedPreview> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return _centeredCalendar(
      KasyCalendar(
        value: _date,
        onChanged: (d) => setState(() => _date = d),
        // Only the window around today is selectable; everything else fades.
        minDate: now.subtract(const Duration(days: 5)),
        maxDate: now.add(const Duration(days: 12)),
        locale: _datePickerLocaleForApp(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar — multi-month (2 or 3 months side by side)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildCalendarMultiMonth(BuildContext context) =>
    const _CalendarMultiMonthPreview();

class _CalendarMultiMonthPreview extends StatefulWidget {
  const _CalendarMultiMonthPreview();

  @override
  State<_CalendarMultiMonthPreview> createState() =>
      _CalendarMultiMonthPreviewState();
}

class _CalendarMultiMonthPreviewState
    extends State<_CalendarMultiMonthPreview> {
  KasyDateRange? _stay;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool fitsTwoMonths = kIsWeb && width >= _kMultiMonthMinWidth2;
    final bool fitsThreeMonths = kIsWeb && width >= _kMultiMonthMinWidth3;

    if (!fitsTwoMonths) {
      return _MultiMonthUnavailableNotice();
    }

    // Multi-month is wider than the preview frame on some breakpoints; allow a
    // horizontal scroll so it never overflows the showcase surface.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: KasyCalendar(
        selectionMode: KasyDateSelectionMode.range,
        range: _stay,
        onRangeChanged: (r) => setState(() => _stay = r),
        monthsToShow: fitsThreeMonths ? 3 : 2,
        locale: _datePickerLocaleForApp(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DatePicker — Presentations
// ─────────────────────────────────────────────────────────────────────────────

/// Maps the running app's locale onto a [KasyDatePickerLocale] preset so the
/// preview demonstrates the same regional defaults (month names, week start,
/// date format) the user would see in their own app.
KasyDatePickerLocale _datePickerLocaleForApp(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'es':
      return KasyDatePickerLocale.es;
    case 'pt':
      return KasyDatePickerLocale.pt;
    default:
      return KasyDatePickerLocale.en;
  }
}

Widget _buildDatePickerPresentations(BuildContext context) =>
    const _DatePickerPresentationsPreview();

class _DatePickerPresentationsPreview extends StatefulWidget {
  const _DatePickerPresentationsPreview();

  @override
  State<_DatePickerPresentationsPreview> createState() =>
      _DatePickerPresentationsPreviewState();
}

class _DatePickerPresentationsPreviewState
    extends State<_DatePickerPresentationsPreview> {
  DateTime? _popoverDate;
  DateTime? _dialogDate;
  DateTime? _sheetDate;

  @override
  Widget build(BuildContext context) {
    final KasyDatePickerLocale locale = _datePickerLocaleForApp(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyDatePicker(
          label: 'Popover',
          placeholder: 'Choose a date',
          value: _popoverDate,
          onChanged: (d) => setState(() => _popoverDate = d),
          presentation: KasyDatePickerPresentation.popover,
          locale: locale,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyDatePicker(
          label: 'Dialog',
          placeholder: 'Choose a date',
          value: _dialogDate,
          onChanged: (d) => setState(() => _dialogDate = d),
          presentation: KasyDatePickerPresentation.dialog,
          locale: locale,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyDatePicker(
          label: 'Bottom sheet',
          placeholder: 'Choose a date',
          value: _sheetDate,
          onChanged: (d) => setState(() => _sheetDate = d),
          presentation: KasyDatePickerPresentation.bottomSheet,
          locale: locale,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DatePicker — Range selection (Airbnb-style start + end)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildDatePickerRange(BuildContext context) =>
    const _DatePickerRangePreview();

class _DatePickerRangePreview extends StatefulWidget {
  const _DatePickerRangePreview();

  @override
  State<_DatePickerRangePreview> createState() =>
      _DatePickerRangePreviewState();
}

class _DatePickerRangePreviewState extends State<_DatePickerRangePreview> {
  KasyDateRange? _stay;
  KasyDateRange? _project;

  @override
  Widget build(BuildContext context) {
    final KasyDatePickerLocale locale = _datePickerLocaleForApp(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Classic stay-style picker: tap a check-in date, then a check-out
        // date. The calendar keeps the start highlighted while waiting for
        // the end, then auto-closes after the second tap.
        KasyDatePicker(
          label: 'Stay',
          placeholder: 'Check-in  ->  Check-out',
          description: 'Tap a start date, then an end date.',
          selectionMode: KasyDateSelectionMode.range,
          range: _stay,
          onRangeChanged: (r) => setState(() => _stay = r),
          locale: locale,
        ),
        const SizedBox(height: KasySpacing.lg),
        // Dialog presentation of the same range mode — handy on smaller
        // screens where the popover may not have enough room.
        KasyDatePicker(
          label: 'Project window (dialog)',
          placeholder: 'Pick start  ->  end',
          selectionMode: KasyDateSelectionMode.range,
          range: _project,
          onRangeChanged: (r) => setState(() => _project = r),
          presentation: KasyDatePickerPresentation.dialog,
          locale: locale,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DatePicker — Multi-month (2 or 3 months side by side, Airbnb desktop look)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildDatePickerMultiMonth(BuildContext context) =>
    const _DatePickerMultiMonthPreview();

class _DatePickerMultiMonthPreview extends StatefulWidget {
  const _DatePickerMultiMonthPreview();

  @override
  State<_DatePickerMultiMonthPreview> createState() =>
      _DatePickerMultiMonthPreviewState();
}

// Breakpoints for the multi-month preview. Below the 2-month threshold the
// preview shows an explanation card instead of the calendars — picking dates
// across 2 or 3 grids only makes sense on canvases wide enough to lay them
// out side by side.
const double _kMultiMonthMinWidth2 = 620;
const double _kMultiMonthMinWidth3 = 920;

class _DatePickerMultiMonthPreviewState
    extends State<_DatePickerMultiMonthPreview> {
  KasyDateRange? _stay;
  DateTime? _single;

  @override
  Widget build(BuildContext context) {
    // Multi-month is a desktop/wide-tablet pattern. On native iOS/Android and
    // narrow web viewports we don't have horizontal room to lay 2–3 month
    // grids side by side, so the preview shows a notice instead.
    final double width = MediaQuery.sizeOf(context).width;
    final bool fitsTwoMonths = kIsWeb && width >= _kMultiMonthMinWidth2;
    final bool fitsThreeMonths = kIsWeb && width >= _kMultiMonthMinWidth3;

    if (!fitsTwoMonths) {
      return _MultiMonthUnavailableNotice();
    }

    final KasyDatePickerLocale locale = _datePickerLocaleForApp(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fitsThreeMonths) ...[
          // 3-month layout combined with range selection — the classic
          // Airbnb / Booking desktop pattern for picking a stay.
          KasyDatePicker(
            label: '3 months  +  range',
            placeholder: 'Check-in  ->  Check-out',
            description:
                'Pass monthsToShow: 3 to opt in. Best on wide canvases.',
            selectionMode: KasyDateSelectionMode.range,
            range: _stay,
            onRangeChanged: (r) => setState(() => _stay = r),
            monthsToShow: 3,
            locale: locale,
          ),
          const SizedBox(height: KasySpacing.lg),
        ],
        // 2-month layout in single-date mode — useful when there's enough
        // horizontal room but you still want one tap to commit.
        KasyDatePicker(
          label: '2 months  +  single date',
          placeholder: 'Pick a date',
          value: _single,
          onChanged: (d) => setState(() => _single = d),
          monthsToShow: 2,
          locale: locale,
        ),
      ],
    );
  }
}

/// Friendly placeholder shown when the multi-month preview is opened on a
/// viewport too narrow for the layout (native mobile, narrow web). Surfacing
/// this instead of hiding the variant keeps the design-system docs honest:
/// the feature exists, it just isn't appropriate on small canvases.
class _MultiMonthUnavailableNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Container(
      padding: const EdgeInsets.all(KasySpacing.lg),
      decoration: BoxDecoration(
        color: c.avatarFallbackFill,
        borderRadius: BorderRadius.circular(KasyRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(KasyIcons.info, size: 18, color: c.primary),
              const SizedBox(width: KasySpacing.sm),
              Expanded(
                child: Text(
                  'Multi-month works best on wide screens',
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KasySpacing.sm),
          Text(
            'The 2 and 3-month layouts need room to render side by side, so '
            'they are previewed only on web at tablet width or larger. On '
            'mobile breakpoints and native iOS/Android the picker stays at '
            'a single month — opt in by passing monthsToShow: 2 or 3 from '
            'your own desktop screens.',
            style: context.textTheme.bodyMedium?.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DatePicker — Variants (filled, no backdrop, no suffix, no focus border)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildDatePickerVariants(BuildContext context) =>
    const _DatePickerVariantsPreview();

class _DatePickerVariantsPreview extends StatefulWidget {
  const _DatePickerVariantsPreview();

  @override
  State<_DatePickerVariantsPreview> createState() =>
      _DatePickerVariantsPreviewState();
}

class _DatePickerVariantsPreviewState
    extends State<_DatePickerVariantsPreview> {
  DateTime? _filledDate;
  DateTime? _flatDate;
  DateTime? _noBarrierDate;
  DateTime? _noSuffixDate;
  DateTime? _noFocusDate;

  @override
  Widget build(BuildContext context) {
    final KasyDatePickerLocale locale = _datePickerLocaleForApp(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filled / flat surface — matches KasyTextField.secondary, useful on
        // backgrounds where the default drop shadow feels heavy.
        KasyDatePicker(
          label: 'Filled (no shadow)',
          placeholder: 'Choose a date',
          value: _filledDate,
          onChanged: (d) => setState(() => _filledDate = d),
          variant: KasyTextFieldVariant.secondary,
          locale: locale,
        ),
        const SizedBox(height: KasySpacing.lg),
        // Flat — surface fill + hairline border, no shadow (KasyTextField.flat).
        KasyDatePicker(
          label: 'Flat (no shadow)',
          placeholder: 'Choose a date',
          value: _flatDate,
          onChanged: (d) => setState(() => _flatDate = d),
          variant: KasyTextFieldVariant.flat,
          locale: locale,
        ),
        const SizedBox(height: KasySpacing.lg),
        // Popover without the dimmed backdrop — feels lighter / tooltip-like.
        KasyDatePicker(
          label: 'No backdrop',
          placeholder: 'Choose a date',
          description: 'Popover floats over the page without a dimmed scrim.',
          value: _noBarrierDate,
          onChanged: (d) => setState(() => _noBarrierDate = d),
          showBarrier: false,
          locale: locale,
        ),
        const SizedBox(height: KasySpacing.lg),
        // No calendar icon in the suffix slot.
        KasyDatePicker(
          label: 'No suffix icon',
          placeholder: 'Choose a date',
          value: _noSuffixDate,
          onChanged: (d) => setState(() => _noSuffixDate = d),
          showSuffix: false,
          locale: locale,
        ),
        const SizedBox(height: KasySpacing.lg),
        // Disables the blue focus outline while the calendar is open — quieter
        // affordance for very dense forms.
        KasyDatePicker(
          label: 'No focus border',
          placeholder: 'Choose a date',
          value: _noFocusDate,
          onChanged: (d) => setState(() => _noFocusDate = d),
          focusBorder: false,
          locale: locale,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DatePicker — Date formats
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildDatePickerFormats(BuildContext context) =>
    const _DatePickerFormatsPreview();

const List<String> _kEnglishMonthsLong = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _longUsFormat(DateTime d) =>
    '${_kEnglishMonthsLong[d.month - 1]} ${d.day}, ${d.year}';

class _DatePickerFormatsPreview extends StatefulWidget {
  const _DatePickerFormatsPreview();

  @override
  State<_DatePickerFormatsPreview> createState() =>
      _DatePickerFormatsPreviewState();
}

// Each tab maps to one preset (or to the "Auto" / "Custom" entries). The
// `format` field is null for the two non-preset entries; the build method
// branches on those.
class _DatePickerFormatOption {
  const _DatePickerFormatOption({
    required this.label,
    required this.description,
    this.format,
    this.useAppLocale = false,
    this.customFormat,
  });

  final String label;
  final String description;
  final KasyDateFormat? format;
  final bool useAppLocale;
  final String Function(DateTime)? customFormat;
}

const List<_DatePickerFormatOption> _kDatePickerFormatOptions = [
  _DatePickerFormatOption(
    label: 'Auto',
    description: 'Follows the active app language (US, South American, …).',
    useAppLocale: true,
  ),
  _DatePickerFormatOption(
    label: 'US',
    description: 'MM / DD / YYYY — United States.',
    format: KasyDateFormat.us,
  ),
  _DatePickerFormatOption(
    label: 'South American',
    description: 'DD / MM / YYYY — South America, UK, Spain, Portugal.',
    format: KasyDateFormat.southAmerican,
  ),
  _DatePickerFormatOption(
    label: 'European',
    description: 'DD.MM.YYYY — Germany, Austria, Switzerland.',
    format: KasyDateFormat.european,
  ),
  _DatePickerFormatOption(
    label: 'ISO 8601',
    description: 'YYYY-MM-DD — international standard.',
    format: KasyDateFormat.iso,
  ),
  _DatePickerFormatOption(
    label: 'East Asian',
    description: 'YYYY / MM / DD — Japan, China, Korea.',
    format: KasyDateFormat.eastAsian,
  ),
  _DatePickerFormatOption(
    label: 'Custom',
    description: 'Any layout via the formatDate callback (long form here).',
    customFormat: _longUsFormat,
  ),
];

class _DatePickerFormatsPreviewState extends State<_DatePickerFormatsPreview> {
  int _tab = 0;
  DateTime _date = DateTime(2026, 5, 12);

  @override
  Widget build(BuildContext context) {
    final _DatePickerFormatOption option = _kDatePickerFormatOptions[_tab];
    final KasyDatePickerLocale appLocale = _datePickerLocaleForApp(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Secondary (underline) variant keeps the format switcher visually
        // light on phones — pill tabs were too bulky for a switch with many
        // labels and hug mode lets the row scroll horizontally when needed.
        KasyTabs(
          tabs: [
            for (final o in _kDatePickerFormatOptions) o.label,
          ],
          selectedIndex: _tab,
          onTabSelected: (i) => setState(() => _tab = i),
          variant: KasyTabsVariant.secondary,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyDatePicker(
          label: option.label,
          description: option.description,
          value: _date,
          onChanged: (d) => setState(() => _date = d),
          locale: option.useAppLocale ? appLocale : KasyDatePickerLocale.en,
          dateFormat: option.format,
          formatDate: option.customFormat,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DatePicker — Field states
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildDatePickerFieldStates(BuildContext context) =>
    const _DatePickerFieldStatesPreview();

const List<String> _kEnglishMonthAbbrev = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _abbrevFormat(DateTime d) =>
    '${_kEnglishMonthAbbrev[d.month - 1]} ${d.day}, ${d.year}';

class _DatePickerFieldStatesPreview extends StatefulWidget {
  const _DatePickerFieldStatesPreview();

  @override
  State<_DatePickerFieldStatesPreview> createState() =>
      _DatePickerFieldStatesPreviewState();
}

class _DatePickerFieldStatesPreviewState
    extends State<_DatePickerFieldStatesPreview> {
  DateTime? _deadline;
  DateTime? _shipDate;
  final DateTime _disabledDate = DateTime(2026, 6, 15);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyDatePicker(
          label: 'Deadline',
          placeholder: 'Select a deadline',
          showRequiredIndicator: true,
          description: 'Required for the project timeline.',
          value: _deadline,
          onChanged: (d) => setState(() => _deadline = d),
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyDatePicker(
          label: 'Ship date',
          placeholder: 'Choose a date',
          errorText: 'Please select a valid ship date.',
          value: _shipDate,
          onChanged: (d) => setState(() => _shipDate = d),
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyDatePicker(
          label: 'Disabled date',
          enabled: false,
          value: _disabledDate,
          formatDate: _abbrevFormat,
          description: 'The date cannot be changed when the order is locked.',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DropDown — single-select dropdown (HeroUI "Select")
// ─────────────────────────────────────────────────────────────────────────────

const List<KasyDropDownItem<String>> _kDropDownStates = [
  KasyDropDownItem(value: 'fl', label: 'Florida'),
  KasyDropDownItem(value: 'de', label: 'Delaware'),
  KasyDropDownItem(value: 'tx', label: 'Texas'),
  KasyDropDownItem(value: 'ca', label: 'California'),
  KasyDropDownItem(value: 'ny', label: 'New York'),
  KasyDropDownItem(value: 'wy', label: 'Wyoming'),
];

// A longer list so the searchable dropdown has something to filter.
const List<KasyDropDownItem<String>> _kDropDownStatesLong = [
  KasyDropDownItem(value: 'al', label: 'Alabama'),
  KasyDropDownItem(value: 'az', label: 'Arizona'),
  KasyDropDownItem(value: 'ca', label: 'California'),
  KasyDropDownItem(value: 'co', label: 'Colorado'),
  KasyDropDownItem(value: 'de', label: 'Delaware'),
  KasyDropDownItem(value: 'fl', label: 'Florida'),
  KasyDropDownItem(value: 'ga', label: 'Georgia'),
  KasyDropDownItem(value: 'il', label: 'Illinois'),
  KasyDropDownItem(value: 'ma', label: 'Massachusetts'),
  KasyDropDownItem(value: 'nv', label: 'Nevada'),
  KasyDropDownItem(value: 'ny', label: 'New York'),
  KasyDropDownItem(value: 'oh', label: 'Ohio'),
  KasyDropDownItem(value: 'tx', label: 'Texas'),
  KasyDropDownItem(value: 'wa', label: 'Washington'),
  KasyDropDownItem(value: 'wy', label: 'Wyoming'),
];

Widget _buildDropDownBasic(BuildContext context) => const _DropDownBasicPreview();

class _DropDownBasicPreview extends StatefulWidget {
  const _DropDownBasicPreview();

  @override
  State<_DropDownBasicPreview> createState() => _DropDownBasicPreviewState();
}

class _DropDownBasicPreviewState extends State<_DropDownBasicPreview> {
  String? _state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyDropDown<String>(
          label: 'State',
          hint: 'Select one',
          showRequiredIndicator: true,
          value: _state,
          items: _kDropDownStates,
          onChanged: (v) => setState(() => _state = v),
        ),
      ],
    );
  }
}

Widget _buildDropDownRich(BuildContext context) => const _DropDownRichPreview();

class _DropDownRichPreview extends StatefulWidget {
  const _DropDownRichPreview();

  @override
  State<_DropDownRichPreview> createState() => _DropDownRichPreviewState();
}

class _DropDownRichPreviewState extends State<_DropDownRichPreview> {
  String? _action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyDropDown<String>(
          label: 'Quick action',
          hint: 'Pick an action',
          leadingIcon: KasyIcons.idea,
          value: _action,
          items: const [
            KasyDropDownItem(
              value: 'new',
              label: 'New file',
              icon: KasyIcons.add,
              subtitle: 'Create a new file',
            ),
            KasyDropDownItem(
              value: 'copy',
              label: 'Copy link',
              icon: KasyIcons.copy,
              subtitle: 'Copy a shareable link',
            ),
            KasyDropDownItem(
              value: 'settings',
              label: 'Settings',
              icon: KasyIcons.settings,
              subtitle: 'Manage file permissions',
            ),
          ],
          onChanged: (v) => setState(() => _action = v),
        ),
      ],
    );
  }
}

Widget _buildDropDownMulti(BuildContext context) => const _DropDownMultiPreview();

class _DropDownMultiPreview extends StatefulWidget {
  const _DropDownMultiPreview();

  @override
  State<_DropDownMultiPreview> createState() => _DropDownMultiPreviewState();
}

class _DropDownMultiPreviewState extends State<_DropDownMultiPreview> {
  final Set<String> _selected = <String>{'fl', 'tx'};
  // Off by default (like the menu's "Should Close On Select"): multi-select
  // keeps the panel open while picking. On → a pick also closes the panel.
  bool _closeOnSelect = false;

  @override
  Widget build(BuildContext context) {
    // Real height so the toggle sits near the bottom, not crowding the field.
    final double viewportHeight = MediaQuery.sizeOf(context).height;
    final double frameHeight = (viewportHeight - 260).clamp(320.0, 520.0);
    return SizedBox(
      height: frameHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          KasyDropDown<String>.multiple(
            label: 'States',
            hint: 'Select states',
            values: _selected,
            items: _kDropDownStates,
            closeOnSelect: _closeOnSelect,
            // Up to two: show the labels; beyond that, a compact count.
            multiSummary: (List<KasyDropDownItem<String>> selected) =>
                selected.length <= 2
                ? selected
                      .map((KasyDropDownItem<String> i) => i.label)
                      .join(', ')
                : '${selected.length} selected',
            onSelectionChanged: (Set<String> next) => setState(() {
              _selected
                ..clear()
                ..addAll(next);
            }),
          ),
          const Spacer(flex: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Close on select',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      'Toggle whether picking an option closes the panel',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              KasySwitch(
                value: _closeOnSelect,
                onChanged: (v) => setState(() => _closeOnSelect = v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildDropDownSearchable(BuildContext context) =>
    const _DropDownSearchablePreview();

class _DropDownSearchablePreview extends StatefulWidget {
  const _DropDownSearchablePreview();

  @override
  State<_DropDownSearchablePreview> createState() =>
      _DropDownSearchablePreviewState();
}

class _DropDownSearchablePreviewState
    extends State<_DropDownSearchablePreview> {
  String? _state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyDropDown<String>(
          label: 'State',
          hint: 'Select one',
          searchable: true,
          searchHint: 'Search states',
          value: _state,
          items: _kDropDownStatesLong,
          onChanged: (String v) => setState(() => _state = v),
        ),
      ],
    );
  }
}

Widget _buildDropDownStates(BuildContext context) =>
    const _DropDownStatesPreview();

class _DropDownStatesPreview extends StatefulWidget {
  const _DropDownStatesPreview();

  @override
  State<_DropDownStatesPreview> createState() => _DropDownStatesPreviewState();
}

class _DropDownStatesPreviewState extends State<_DropDownStatesPreview> {
  String? _invalid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pre-selected value.
        KasyDropDown<String>(
          label: 'Selected',
          hint: 'Select one',
          value: 'ca',
          items: _kDropDownStates,
          onChanged: (_) {},
        ),
        const SizedBox(height: KasySpacing.lg),
        // Invalid + error text.
        KasyDropDown<String>(
          label: 'Required',
          hint: 'Select one',
          showRequiredIndicator: true,
          isInvalid: _invalid == null,
          errorText: _invalid == null ? 'Please choose a state.' : null,
          value: _invalid,
          items: _kDropDownStates,
          onChanged: (v) => setState(() => _invalid = v),
        ),
        const SizedBox(height: KasySpacing.lg),
        // Disabled trigger.
        const KasyDropDown<String>(
          label: 'Disabled',
          hint: 'Locked',
          enabled: false,
          items: _kDropDownStates,
          onChanged: null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kbd — keyboard shortcut key caps
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildKbdShortcuts(BuildContext context) {
  return const Center(
    child: Wrap(
      spacing: KasySpacing.md,
      runSpacing: KasySpacing.md,
      alignment: WrapAlignment.center,
      children: [
        KasyKbd(keyLabel: 'K'),
        KasyKbd(keyLabel: 'K', shortcut: KasyKbdShortcut.windows),
        KasyKbd(keyLabel: 'C', shortcut: KasyKbdShortcut.ctrl),
        KasyKbd(keyLabel: 'D', shortcut: KasyKbdShortcut.option),
        KasyKbd(keyLabel: 'P', shortcut: KasyKbdShortcut.shift),
        KasyKbd(keyLabel: 'Esc', shortcut: KasyKbdShortcut.key),
      ],
    ),
  );
}

Widget _buildKbdVariants(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _kbdVariantRow(context, 'Filled', KasyKbdVariant.filled),
        const SizedBox(height: KasySpacing.lg),
        _kbdVariantRow(context, 'Light', KasyKbdVariant.light),
      ],
    ),
  );
}

Widget _kbdVariantRow(
  BuildContext context,
  String label,
  KasyKbdVariant variant,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(color: context.colors.muted),
      ),
      const SizedBox(height: KasySpacing.sm),
      Wrap(
        spacing: KasySpacing.sm,
        alignment: WrapAlignment.center,
        children: [
          KasyKbd(keyLabel: 'K', variant: variant),
          KasyKbd(keyLabel: 'P', shortcut: KasyKbdShortcut.shift, variant: variant),
          KasyKbd(keyLabel: 'C', shortcut: KasyKbdShortcut.ctrl, variant: variant),
        ],
      ),
    ],
  );
}

Widget _buildKbdInContext(BuildContext context) {
  final KasyColors c = context.colors;
  // A search-row affordance: a hint with the shortcut tucked on the right —
  // the most common place a Kbd shows up in an app shell.
  return Center(
    child: Container(
      width: 280,
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(KasyRadius.md),
        border: Border.all(color: c.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(KasyIcons.search, size: 18, color: c.muted),
          const SizedBox(width: KasySpacing.sm),
          Expanded(
            child: Text(
              'Search',
              style: context.textTheme.bodyMedium?.copyWith(color: c.muted),
            ),
          ),
          const KasyKbd(keyLabel: 'K'),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Breadcrumbs — hierarchical navigation trail
// ─────────────────────────────────────────────────────────────────────────────

/// Breadcrumb trails can outgrow a phone width, so each row scrolls
/// horizontally instead of overflowing the showcase surface.
Widget _scrollableBreadcrumbs(Widget child) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: child,
    );

Widget _buildBreadcrumbsLevels(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _scrollableBreadcrumbs(
          const KasyBreadcrumbs(items: [
            KasyBreadcrumbItem('Home'),
            KasyBreadcrumbItem('Breadcrumbs'),
          ]),
        ),
        const SizedBox(height: KasySpacing.lg),
        _scrollableBreadcrumbs(
          const KasyBreadcrumbs(items: [
            KasyBreadcrumbItem('Home'),
            KasyBreadcrumbItem('Version 3'),
            KasyBreadcrumbItem('Breadcrumbs'),
          ]),
        ),
        const SizedBox(height: KasySpacing.lg),
        _scrollableBreadcrumbs(
          const KasyBreadcrumbs(items: [
            KasyBreadcrumbItem('Home'),
            KasyBreadcrumbItem('Version 3'),
            KasyBreadcrumbItem('Components'),
            KasyBreadcrumbItem('Breadcrumbs'),
          ]),
        ),
      ],
    ),
  );
}

Widget _buildBreadcrumbsInteractive(BuildContext context) =>
    const _BreadcrumbsInteractivePreview();

class _BreadcrumbsInteractivePreview extends StatefulWidget {
  const _BreadcrumbsInteractivePreview();

  @override
  State<_BreadcrumbsInteractivePreview> createState() =>
      _BreadcrumbsInteractivePreviewState();
}

class _BreadcrumbsInteractivePreviewState
    extends State<_BreadcrumbsInteractivePreview> {
  // Full path; tapping a level "navigates" by trimming the trail to that level.
  static const List<String> _fullPath = [
    'Home',
    'Version 3',
    'Components',
    'Breadcrumbs',
  ];
  int _depth = _fullPath.length;

  @override
  Widget build(BuildContext context) {
    final List<String> visible = _fullPath.sublist(0, _depth);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _scrollableBreadcrumbs(
            KasyBreadcrumbs(
              items: [
                for (int i = 0; i < visible.length; i++)
                  KasyBreadcrumbItem(
                    visible[i],
                    onTap: () => setState(() => _depth = i + 1),
                  ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.lg),
          Text(
            _depth == _fullPath.length
                ? 'Tap any level to navigate up'
                : 'Navigated to "${visible.last}"',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
            ),
          ),
          if (_depth < _fullPath.length) ...[
            const SizedBox(height: KasySpacing.sm),
            KasyLink(
              label: 'Reset',
              onPressed: () => setState(() => _depth = _fullPath.length),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TimePicker previews
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildTimePickerPresentations(BuildContext context) =>
    const _TimePickerPresentationsPreview();

class _TimePickerPresentationsPreview extends StatefulWidget {
  const _TimePickerPresentationsPreview();

  @override
  State<_TimePickerPresentationsPreview> createState() =>
      _TimePickerPresentationsPreviewState();
}

class _TimePickerPresentationsPreviewState
    extends State<_TimePickerPresentationsPreview> {
  TimeOfDay? _popoverTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay? _dialogTime;
  TimeOfDay? _sheetTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyTimePicker(
          label: 'Popover',
          placeholder: 'Choose a time',
          value: _popoverTime,
          onChanged: (time) => setState(() => _popoverTime = time),
          presentation: KasyTimePickerPresentation.popover,
          use24HourFormat: false,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTimePicker(
          label: 'Dialog',
          placeholder: 'Choose a time',
          value: _dialogTime,
          onChanged: (time) => setState(() => _dialogTime = time),
          presentation: KasyTimePickerPresentation.dialog,
          use24HourFormat: false,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTimePicker(
          label: 'Bottom sheet',
          placeholder: 'Choose a time',
          value: _sheetTime,
          onChanged: (time) => setState(() => _sheetTime = time),
          presentation: KasyTimePickerPresentation.bottomSheet,
          use24HourFormat: false,
        ),
      ],
    );
  }
}

Widget _buildTimePickerInterval(BuildContext context) =>
    const _TimePickerIntervalPreview();

class _TimePickerIntervalPreview extends StatefulWidget {
  const _TimePickerIntervalPreview();

  @override
  State<_TimePickerIntervalPreview> createState() =>
      _TimePickerIntervalPreviewState();
}

class _TimePickerIntervalPreviewState extends State<_TimePickerIntervalPreview> {
  TimeOfDay? _departure = const TimeOfDay(hour: 0, minute: 0);

  @override
  Widget build(BuildContext context) {
    return KasyTimePicker(
      label: 'Departure (24h, 5 min steps)',
      placeholder: 'Select a time',
      description: 'Local airport time zone.',
      value: _departure,
      onChanged: (time) => setState(() => _departure = time),
      use24HourFormat: true,
      minuteInterval: 5,
    );
  }
}

Widget _buildTimePickerCustomFormat(BuildContext context) =>
    const _TimePickerCustomFormatPreview();

class _TimePickerCustomFormatPreview extends StatefulWidget {
  const _TimePickerCustomFormatPreview();

  @override
  State<_TimePickerCustomFormatPreview> createState() =>
      _TimePickerCustomFormatPreviewState();
}

String _friendlyTimeFormat(TimeOfDay time) {
  final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final String period = time.period == DayPeriod.am ? 'in the morning' : 'in the afternoon';
  if (time.hour == 12 && time.minute == 0) return 'Noon';
  if (time.hour == 0 && time.minute == 0) return 'Midnight';
  final String minute =
      time.minute == 0 ? '' : ':${time.minute.toString().padLeft(2, '0')}';
  return '$hour$minute $period';
}

class _TimePickerCustomFormatPreviewState
    extends State<_TimePickerCustomFormatPreview> {
  TimeOfDay? _customTime;

  @override
  Widget build(BuildContext context) {
    return KasyTimePicker(
      label: 'Custom formatTime',
      placeholder: 'Choose a time',
      value: _customTime,
      onChanged: (time) => setState(() => _customTime = time),
      use24HourFormat: false,
      formatTime: _friendlyTimeFormat,
    );
  }
}

Widget _buildTimePickerVariants(BuildContext context) =>
    const _TimePickerVariantsPreview();

class _TimePickerVariantsPreview extends StatefulWidget {
  const _TimePickerVariantsPreview();

  @override
  State<_TimePickerVariantsPreview> createState() =>
      _TimePickerVariantsPreviewState();
}

class _TimePickerVariantsPreviewState extends State<_TimePickerVariantsPreview> {
  TimeOfDay? _filledTime;
  TimeOfDay? _flatTime;
  TimeOfDay? _noBarrierTime;
  TimeOfDay? _noSuffixTime;
  TimeOfDay? _noFocusTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyTimePicker(
          label: 'Filled (no shadow)',
          placeholder: 'Choose a time',
          value: _filledTime,
          onChanged: (time) => setState(() => _filledTime = time),
          variant: KasyTextFieldVariant.secondary,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTimePicker(
          label: 'Flat (no shadow)',
          placeholder: 'Choose a time',
          value: _flatTime,
          onChanged: (time) => setState(() => _flatTime = time),
          variant: KasyTextFieldVariant.flat,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTimePicker(
          label: 'No backdrop',
          placeholder: 'Choose a time',
          description: 'Popover floats over the page without a dimmed scrim.',
          value: _noBarrierTime,
          onChanged: (time) => setState(() => _noBarrierTime = time),
          showBarrier: false,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTimePicker(
          label: 'No suffix icon',
          placeholder: 'Choose a time',
          value: _noSuffixTime,
          onChanged: (time) => setState(() => _noSuffixTime = time),
          showSuffix: false,
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTimePicker(
          label: 'No focus border',
          placeholder: 'Choose a time',
          value: _noFocusTime,
          onChanged: (time) => setState(() => _noFocusTime = time),
          focusBorder: false,
        ),
      ],
    );
  }
}

Widget _buildTimePickerFieldStates(BuildContext context) =>
    const _TimePickerFieldStatesPreview();

class _TimePickerFieldStatesPreview extends StatefulWidget {
  const _TimePickerFieldStatesPreview();

  @override
  State<_TimePickerFieldStatesPreview> createState() =>
      _TimePickerFieldStatesPreviewState();
}

class _TimePickerFieldStatesPreviewState
    extends State<_TimePickerFieldStatesPreview> {
  TimeOfDay? _reminderTime;
  TimeOfDay? _cutoffTime;
  final TimeOfDay _disabledTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyTimePicker(
          label: 'Reminder',
          placeholder: 'Pick a reminder time',
          showRequiredIndicator: true,
          description: 'Required to schedule the notification.',
          value: _reminderTime,
          onChanged: (time) => setState(() => _reminderTime = time),
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTimePicker(
          label: 'Cutoff',
          placeholder: 'Choose a time',
          errorText: 'Please select a valid cutoff time.',
          value: _cutoffTime,
          onChanged: (time) => setState(() => _cutoffTime = time),
        ),
        const SizedBox(height: KasySpacing.lg),
        KasyTimePicker(
          label: 'Disabled time',
          enabled: false,
          value: _disabledTime,
          description: 'The time cannot be changed when the schedule is locked.',
        ),
      ],
    );
  }
}
