// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environments.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Environment implements DiagnosticableTreeMixin {

// Name of the environment (dev, prod, ...) just for debug purpose
 String get name;/// Url of your backend API / or Supabase URL / or Firebase Functions region
 String get backendUrl;/// RevenueCat API key for Android
/// (only if you want to use in-app purchases with RevenueCat)
 String? get revenueCatAndroidApiKey;/// RevenueCat API key for iOS
/// (only if you want to use in-app purchases with RevenueCat)
 String? get revenueCatIOSApiKey;/// this is used to open the app store page of your app for reviews
 String? get appStoreId;// ─── Ads (AdMob) ────────────────────────────────────────────────────────
// Real ad unit ids, per platform and format. Leave null to fall back to
// Google's test ids in non-release builds (see [AdTestUnitIds]); set the
// real ids before shipping a release build. Only used if the ads module is
// enabled.
 String? get androidBannerAdUnitId; String? get iOSBannerAdUnitId; String? get androidInterstitialAdUnitId; String? get iOSInterstitialAdUnitId; String? get androidRewardedAdUnitId; String? get iOSRewardedAdUnitId; String? get androidRewardedInterstitialAdUnitId; String? get iOSRewardedInterstitialAdUnitId;/// Environment variable to handle Mixpanel analytics
/// You can get it from https://mixpanel.com
 String? get mixpanelToken;/// The default authentication mode of the app (anonymous or authRequired)
/// See [AuthenticationMode]
 AuthenticationMode get authenticationMode;
/// Create a copy of Environment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvironmentCopyWith<Environment> get copyWith => _$EnvironmentCopyWithImpl<Environment>(this as Environment, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Environment'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('backendUrl', backendUrl))..add(DiagnosticsProperty('revenueCatAndroidApiKey', revenueCatAndroidApiKey))..add(DiagnosticsProperty('revenueCatIOSApiKey', revenueCatIOSApiKey))..add(DiagnosticsProperty('appStoreId', appStoreId))..add(DiagnosticsProperty('androidBannerAdUnitId', androidBannerAdUnitId))..add(DiagnosticsProperty('iOSBannerAdUnitId', iOSBannerAdUnitId))..add(DiagnosticsProperty('androidInterstitialAdUnitId', androidInterstitialAdUnitId))..add(DiagnosticsProperty('iOSInterstitialAdUnitId', iOSInterstitialAdUnitId))..add(DiagnosticsProperty('androidRewardedAdUnitId', androidRewardedAdUnitId))..add(DiagnosticsProperty('iOSRewardedAdUnitId', iOSRewardedAdUnitId))..add(DiagnosticsProperty('androidRewardedInterstitialAdUnitId', androidRewardedInterstitialAdUnitId))..add(DiagnosticsProperty('iOSRewardedInterstitialAdUnitId', iOSRewardedInterstitialAdUnitId))..add(DiagnosticsProperty('mixpanelToken', mixpanelToken))..add(DiagnosticsProperty('authenticationMode', authenticationMode));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Environment&&(identical(other.name, name) || other.name == name)&&(identical(other.backendUrl, backendUrl) || other.backendUrl == backendUrl)&&(identical(other.revenueCatAndroidApiKey, revenueCatAndroidApiKey) || other.revenueCatAndroidApiKey == revenueCatAndroidApiKey)&&(identical(other.revenueCatIOSApiKey, revenueCatIOSApiKey) || other.revenueCatIOSApiKey == revenueCatIOSApiKey)&&(identical(other.appStoreId, appStoreId) || other.appStoreId == appStoreId)&&(identical(other.androidBannerAdUnitId, androidBannerAdUnitId) || other.androidBannerAdUnitId == androidBannerAdUnitId)&&(identical(other.iOSBannerAdUnitId, iOSBannerAdUnitId) || other.iOSBannerAdUnitId == iOSBannerAdUnitId)&&(identical(other.androidInterstitialAdUnitId, androidInterstitialAdUnitId) || other.androidInterstitialAdUnitId == androidInterstitialAdUnitId)&&(identical(other.iOSInterstitialAdUnitId, iOSInterstitialAdUnitId) || other.iOSInterstitialAdUnitId == iOSInterstitialAdUnitId)&&(identical(other.androidRewardedAdUnitId, androidRewardedAdUnitId) || other.androidRewardedAdUnitId == androidRewardedAdUnitId)&&(identical(other.iOSRewardedAdUnitId, iOSRewardedAdUnitId) || other.iOSRewardedAdUnitId == iOSRewardedAdUnitId)&&(identical(other.androidRewardedInterstitialAdUnitId, androidRewardedInterstitialAdUnitId) || other.androidRewardedInterstitialAdUnitId == androidRewardedInterstitialAdUnitId)&&(identical(other.iOSRewardedInterstitialAdUnitId, iOSRewardedInterstitialAdUnitId) || other.iOSRewardedInterstitialAdUnitId == iOSRewardedInterstitialAdUnitId)&&(identical(other.mixpanelToken, mixpanelToken) || other.mixpanelToken == mixpanelToken)&&(identical(other.authenticationMode, authenticationMode) || other.authenticationMode == authenticationMode));
}


@override
int get hashCode => Object.hash(runtimeType,name,backendUrl,revenueCatAndroidApiKey,revenueCatIOSApiKey,appStoreId,androidBannerAdUnitId,iOSBannerAdUnitId,androidInterstitialAdUnitId,iOSInterstitialAdUnitId,androidRewardedAdUnitId,iOSRewardedAdUnitId,androidRewardedInterstitialAdUnitId,iOSRewardedInterstitialAdUnitId,mixpanelToken,authenticationMode);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Environment(name: $name, backendUrl: $backendUrl, revenueCatAndroidApiKey: $revenueCatAndroidApiKey, revenueCatIOSApiKey: $revenueCatIOSApiKey, appStoreId: $appStoreId, androidBannerAdUnitId: $androidBannerAdUnitId, iOSBannerAdUnitId: $iOSBannerAdUnitId, androidInterstitialAdUnitId: $androidInterstitialAdUnitId, iOSInterstitialAdUnitId: $iOSInterstitialAdUnitId, androidRewardedAdUnitId: $androidRewardedAdUnitId, iOSRewardedAdUnitId: $iOSRewardedAdUnitId, androidRewardedInterstitialAdUnitId: $androidRewardedInterstitialAdUnitId, iOSRewardedInterstitialAdUnitId: $iOSRewardedInterstitialAdUnitId, mixpanelToken: $mixpanelToken, authenticationMode: $authenticationMode)';
}


}

/// @nodoc
abstract mixin class $EnvironmentCopyWith<$Res>  {
  factory $EnvironmentCopyWith(Environment value, $Res Function(Environment) _then) = _$EnvironmentCopyWithImpl;
@useResult
$Res call({
 String name, String backendUrl, String? revenueCatAndroidApiKey, String? revenueCatIOSApiKey, String? appStoreId, String? androidBannerAdUnitId, String? iOSBannerAdUnitId, String? androidInterstitialAdUnitId, String? iOSInterstitialAdUnitId, String? androidRewardedAdUnitId, String? iOSRewardedAdUnitId, String? androidRewardedInterstitialAdUnitId, String? iOSRewardedInterstitialAdUnitId, String? mixpanelToken, AuthenticationMode authenticationMode
});




}
/// @nodoc
class _$EnvironmentCopyWithImpl<$Res>
    implements $EnvironmentCopyWith<$Res> {
  _$EnvironmentCopyWithImpl(this._self, this._then);

  final Environment _self;
  final $Res Function(Environment) _then;

/// Create a copy of Environment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? backendUrl = null,Object? revenueCatAndroidApiKey = freezed,Object? revenueCatIOSApiKey = freezed,Object? appStoreId = freezed,Object? androidBannerAdUnitId = freezed,Object? iOSBannerAdUnitId = freezed,Object? androidInterstitialAdUnitId = freezed,Object? iOSInterstitialAdUnitId = freezed,Object? androidRewardedAdUnitId = freezed,Object? iOSRewardedAdUnitId = freezed,Object? androidRewardedInterstitialAdUnitId = freezed,Object? iOSRewardedInterstitialAdUnitId = freezed,Object? mixpanelToken = freezed,Object? authenticationMode = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,backendUrl: null == backendUrl ? _self.backendUrl : backendUrl // ignore: cast_nullable_to_non_nullable
as String,revenueCatAndroidApiKey: freezed == revenueCatAndroidApiKey ? _self.revenueCatAndroidApiKey : revenueCatAndroidApiKey // ignore: cast_nullable_to_non_nullable
as String?,revenueCatIOSApiKey: freezed == revenueCatIOSApiKey ? _self.revenueCatIOSApiKey : revenueCatIOSApiKey // ignore: cast_nullable_to_non_nullable
as String?,appStoreId: freezed == appStoreId ? _self.appStoreId : appStoreId // ignore: cast_nullable_to_non_nullable
as String?,androidBannerAdUnitId: freezed == androidBannerAdUnitId ? _self.androidBannerAdUnitId : androidBannerAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSBannerAdUnitId: freezed == iOSBannerAdUnitId ? _self.iOSBannerAdUnitId : iOSBannerAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidInterstitialAdUnitId: freezed == androidInterstitialAdUnitId ? _self.androidInterstitialAdUnitId : androidInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSInterstitialAdUnitId: freezed == iOSInterstitialAdUnitId ? _self.iOSInterstitialAdUnitId : iOSInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidRewardedAdUnitId: freezed == androidRewardedAdUnitId ? _self.androidRewardedAdUnitId : androidRewardedAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSRewardedAdUnitId: freezed == iOSRewardedAdUnitId ? _self.iOSRewardedAdUnitId : iOSRewardedAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidRewardedInterstitialAdUnitId: freezed == androidRewardedInterstitialAdUnitId ? _self.androidRewardedInterstitialAdUnitId : androidRewardedInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSRewardedInterstitialAdUnitId: freezed == iOSRewardedInterstitialAdUnitId ? _self.iOSRewardedInterstitialAdUnitId : iOSRewardedInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,mixpanelToken: freezed == mixpanelToken ? _self.mixpanelToken : mixpanelToken // ignore: cast_nullable_to_non_nullable
as String?,authenticationMode: null == authenticationMode ? _self.authenticationMode : authenticationMode // ignore: cast_nullable_to_non_nullable
as AuthenticationMode,
  ));
}

}


/// Adds pattern-matching-related methods to [Environment].
extension EnvironmentPatterns on Environment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DevEnvironment value)?  dev,TResult Function( ProdEnvironment value)?  prod,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DevEnvironment() when dev != null:
return dev(_that);case ProdEnvironment() when prod != null:
return prod(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DevEnvironment value)  dev,required TResult Function( ProdEnvironment value)  prod,}){
final _that = this;
switch (_that) {
case DevEnvironment():
return dev(_that);case ProdEnvironment():
return prod(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DevEnvironment value)?  dev,TResult? Function( ProdEnvironment value)?  prod,}){
final _that = this;
switch (_that) {
case DevEnvironment() when dev != null:
return dev(_that);case ProdEnvironment() when prod != null:
return prod(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String name,  String backendUrl,  String? revenueCatAndroidApiKey,  String? revenueCatIOSApiKey,  String? appStoreId,  String? androidBannerAdUnitId,  String? iOSBannerAdUnitId,  String? androidInterstitialAdUnitId,  String? iOSInterstitialAdUnitId,  String? androidRewardedAdUnitId,  String? iOSRewardedAdUnitId,  String? androidRewardedInterstitialAdUnitId,  String? iOSRewardedInterstitialAdUnitId,  String? mixpanelToken,  AuthenticationMode authenticationMode)?  dev,TResult Function( String name,  String backendUrl,  String? revenueCatAndroidApiKey,  String? revenueCatIOSApiKey,  String? androidBannerAdUnitId,  String? iOSBannerAdUnitId,  String? androidInterstitialAdUnitId,  String? iOSInterstitialAdUnitId,  String? androidRewardedAdUnitId,  String? iOSRewardedAdUnitId,  String? androidRewardedInterstitialAdUnitId,  String? iOSRewardedInterstitialAdUnitId,  String? appStoreId,  String? sentryDsn,  String? mixpanelToken,  AuthenticationMode authenticationMode)?  prod,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DevEnvironment() when dev != null:
return dev(_that.name,_that.backendUrl,_that.revenueCatAndroidApiKey,_that.revenueCatIOSApiKey,_that.appStoreId,_that.androidBannerAdUnitId,_that.iOSBannerAdUnitId,_that.androidInterstitialAdUnitId,_that.iOSInterstitialAdUnitId,_that.androidRewardedAdUnitId,_that.iOSRewardedAdUnitId,_that.androidRewardedInterstitialAdUnitId,_that.iOSRewardedInterstitialAdUnitId,_that.mixpanelToken,_that.authenticationMode);case ProdEnvironment() when prod != null:
return prod(_that.name,_that.backendUrl,_that.revenueCatAndroidApiKey,_that.revenueCatIOSApiKey,_that.androidBannerAdUnitId,_that.iOSBannerAdUnitId,_that.androidInterstitialAdUnitId,_that.iOSInterstitialAdUnitId,_that.androidRewardedAdUnitId,_that.iOSRewardedAdUnitId,_that.androidRewardedInterstitialAdUnitId,_that.iOSRewardedInterstitialAdUnitId,_that.appStoreId,_that.sentryDsn,_that.mixpanelToken,_that.authenticationMode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String name,  String backendUrl,  String? revenueCatAndroidApiKey,  String? revenueCatIOSApiKey,  String? appStoreId,  String? androidBannerAdUnitId,  String? iOSBannerAdUnitId,  String? androidInterstitialAdUnitId,  String? iOSInterstitialAdUnitId,  String? androidRewardedAdUnitId,  String? iOSRewardedAdUnitId,  String? androidRewardedInterstitialAdUnitId,  String? iOSRewardedInterstitialAdUnitId,  String? mixpanelToken,  AuthenticationMode authenticationMode)  dev,required TResult Function( String name,  String backendUrl,  String? revenueCatAndroidApiKey,  String? revenueCatIOSApiKey,  String? androidBannerAdUnitId,  String? iOSBannerAdUnitId,  String? androidInterstitialAdUnitId,  String? iOSInterstitialAdUnitId,  String? androidRewardedAdUnitId,  String? iOSRewardedAdUnitId,  String? androidRewardedInterstitialAdUnitId,  String? iOSRewardedInterstitialAdUnitId,  String? appStoreId,  String? sentryDsn,  String? mixpanelToken,  AuthenticationMode authenticationMode)  prod,}) {final _that = this;
switch (_that) {
case DevEnvironment():
return dev(_that.name,_that.backendUrl,_that.revenueCatAndroidApiKey,_that.revenueCatIOSApiKey,_that.appStoreId,_that.androidBannerAdUnitId,_that.iOSBannerAdUnitId,_that.androidInterstitialAdUnitId,_that.iOSInterstitialAdUnitId,_that.androidRewardedAdUnitId,_that.iOSRewardedAdUnitId,_that.androidRewardedInterstitialAdUnitId,_that.iOSRewardedInterstitialAdUnitId,_that.mixpanelToken,_that.authenticationMode);case ProdEnvironment():
return prod(_that.name,_that.backendUrl,_that.revenueCatAndroidApiKey,_that.revenueCatIOSApiKey,_that.androidBannerAdUnitId,_that.iOSBannerAdUnitId,_that.androidInterstitialAdUnitId,_that.iOSInterstitialAdUnitId,_that.androidRewardedAdUnitId,_that.iOSRewardedAdUnitId,_that.androidRewardedInterstitialAdUnitId,_that.iOSRewardedInterstitialAdUnitId,_that.appStoreId,_that.sentryDsn,_that.mixpanelToken,_that.authenticationMode);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String name,  String backendUrl,  String? revenueCatAndroidApiKey,  String? revenueCatIOSApiKey,  String? appStoreId,  String? androidBannerAdUnitId,  String? iOSBannerAdUnitId,  String? androidInterstitialAdUnitId,  String? iOSInterstitialAdUnitId,  String? androidRewardedAdUnitId,  String? iOSRewardedAdUnitId,  String? androidRewardedInterstitialAdUnitId,  String? iOSRewardedInterstitialAdUnitId,  String? mixpanelToken,  AuthenticationMode authenticationMode)?  dev,TResult? Function( String name,  String backendUrl,  String? revenueCatAndroidApiKey,  String? revenueCatIOSApiKey,  String? androidBannerAdUnitId,  String? iOSBannerAdUnitId,  String? androidInterstitialAdUnitId,  String? iOSInterstitialAdUnitId,  String? androidRewardedAdUnitId,  String? iOSRewardedAdUnitId,  String? androidRewardedInterstitialAdUnitId,  String? iOSRewardedInterstitialAdUnitId,  String? appStoreId,  String? sentryDsn,  String? mixpanelToken,  AuthenticationMode authenticationMode)?  prod,}) {final _that = this;
switch (_that) {
case DevEnvironment() when dev != null:
return dev(_that.name,_that.backendUrl,_that.revenueCatAndroidApiKey,_that.revenueCatIOSApiKey,_that.appStoreId,_that.androidBannerAdUnitId,_that.iOSBannerAdUnitId,_that.androidInterstitialAdUnitId,_that.iOSInterstitialAdUnitId,_that.androidRewardedAdUnitId,_that.iOSRewardedAdUnitId,_that.androidRewardedInterstitialAdUnitId,_that.iOSRewardedInterstitialAdUnitId,_that.mixpanelToken,_that.authenticationMode);case ProdEnvironment() when prod != null:
return prod(_that.name,_that.backendUrl,_that.revenueCatAndroidApiKey,_that.revenueCatIOSApiKey,_that.androidBannerAdUnitId,_that.iOSBannerAdUnitId,_that.androidInterstitialAdUnitId,_that.iOSInterstitialAdUnitId,_that.androidRewardedAdUnitId,_that.iOSRewardedAdUnitId,_that.androidRewardedInterstitialAdUnitId,_that.iOSRewardedInterstitialAdUnitId,_that.appStoreId,_that.sentryDsn,_that.mixpanelToken,_that.authenticationMode);case _:
  return null;

}
}

}

/// @nodoc


class DevEnvironment extends Environment with DiagnosticableTreeMixin {
  const DevEnvironment({required this.name, required this.backendUrl, this.revenueCatAndroidApiKey, this.revenueCatIOSApiKey, this.appStoreId, this.androidBannerAdUnitId, this.iOSBannerAdUnitId, this.androidInterstitialAdUnitId, this.iOSInterstitialAdUnitId, this.androidRewardedAdUnitId, this.iOSRewardedAdUnitId, this.androidRewardedInterstitialAdUnitId, this.iOSRewardedInterstitialAdUnitId, this.mixpanelToken, required this.authenticationMode}): super._();
  

// Name of the environment (dev, prod, ...) just for debug purpose
@override final  String name;
/// Url of your backend API / or Supabase URL / or Firebase Functions region
@override final  String backendUrl;
/// RevenueCat API key for Android
/// (only if you want to use in-app purchases with RevenueCat)
@override final  String? revenueCatAndroidApiKey;
/// RevenueCat API key for iOS
/// (only if you want to use in-app purchases with RevenueCat)
@override final  String? revenueCatIOSApiKey;
/// this is used to open the app store page of your app for reviews
@override final  String? appStoreId;
// ─── Ads (AdMob) ────────────────────────────────────────────────────────
// Real ad unit ids, per platform and format. Leave null to fall back to
// Google's test ids in non-release builds (see [AdTestUnitIds]); set the
// real ids before shipping a release build. Only used if the ads module is
// enabled.
@override final  String? androidBannerAdUnitId;
@override final  String? iOSBannerAdUnitId;
@override final  String? androidInterstitialAdUnitId;
@override final  String? iOSInterstitialAdUnitId;
@override final  String? androidRewardedAdUnitId;
@override final  String? iOSRewardedAdUnitId;
@override final  String? androidRewardedInterstitialAdUnitId;
@override final  String? iOSRewardedInterstitialAdUnitId;
/// Environment variable to handle Mixpanel analytics
/// You can get it from https://mixpanel.com
@override final  String? mixpanelToken;
/// The default authentication mode of the app (anonymous or authRequired)
/// See [AuthenticationMode]
@override final  AuthenticationMode authenticationMode;

/// Create a copy of Environment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DevEnvironmentCopyWith<DevEnvironment> get copyWith => _$DevEnvironmentCopyWithImpl<DevEnvironment>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Environment.dev'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('backendUrl', backendUrl))..add(DiagnosticsProperty('revenueCatAndroidApiKey', revenueCatAndroidApiKey))..add(DiagnosticsProperty('revenueCatIOSApiKey', revenueCatIOSApiKey))..add(DiagnosticsProperty('appStoreId', appStoreId))..add(DiagnosticsProperty('androidBannerAdUnitId', androidBannerAdUnitId))..add(DiagnosticsProperty('iOSBannerAdUnitId', iOSBannerAdUnitId))..add(DiagnosticsProperty('androidInterstitialAdUnitId', androidInterstitialAdUnitId))..add(DiagnosticsProperty('iOSInterstitialAdUnitId', iOSInterstitialAdUnitId))..add(DiagnosticsProperty('androidRewardedAdUnitId', androidRewardedAdUnitId))..add(DiagnosticsProperty('iOSRewardedAdUnitId', iOSRewardedAdUnitId))..add(DiagnosticsProperty('androidRewardedInterstitialAdUnitId', androidRewardedInterstitialAdUnitId))..add(DiagnosticsProperty('iOSRewardedInterstitialAdUnitId', iOSRewardedInterstitialAdUnitId))..add(DiagnosticsProperty('mixpanelToken', mixpanelToken))..add(DiagnosticsProperty('authenticationMode', authenticationMode));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DevEnvironment&&(identical(other.name, name) || other.name == name)&&(identical(other.backendUrl, backendUrl) || other.backendUrl == backendUrl)&&(identical(other.revenueCatAndroidApiKey, revenueCatAndroidApiKey) || other.revenueCatAndroidApiKey == revenueCatAndroidApiKey)&&(identical(other.revenueCatIOSApiKey, revenueCatIOSApiKey) || other.revenueCatIOSApiKey == revenueCatIOSApiKey)&&(identical(other.appStoreId, appStoreId) || other.appStoreId == appStoreId)&&(identical(other.androidBannerAdUnitId, androidBannerAdUnitId) || other.androidBannerAdUnitId == androidBannerAdUnitId)&&(identical(other.iOSBannerAdUnitId, iOSBannerAdUnitId) || other.iOSBannerAdUnitId == iOSBannerAdUnitId)&&(identical(other.androidInterstitialAdUnitId, androidInterstitialAdUnitId) || other.androidInterstitialAdUnitId == androidInterstitialAdUnitId)&&(identical(other.iOSInterstitialAdUnitId, iOSInterstitialAdUnitId) || other.iOSInterstitialAdUnitId == iOSInterstitialAdUnitId)&&(identical(other.androidRewardedAdUnitId, androidRewardedAdUnitId) || other.androidRewardedAdUnitId == androidRewardedAdUnitId)&&(identical(other.iOSRewardedAdUnitId, iOSRewardedAdUnitId) || other.iOSRewardedAdUnitId == iOSRewardedAdUnitId)&&(identical(other.androidRewardedInterstitialAdUnitId, androidRewardedInterstitialAdUnitId) || other.androidRewardedInterstitialAdUnitId == androidRewardedInterstitialAdUnitId)&&(identical(other.iOSRewardedInterstitialAdUnitId, iOSRewardedInterstitialAdUnitId) || other.iOSRewardedInterstitialAdUnitId == iOSRewardedInterstitialAdUnitId)&&(identical(other.mixpanelToken, mixpanelToken) || other.mixpanelToken == mixpanelToken)&&(identical(other.authenticationMode, authenticationMode) || other.authenticationMode == authenticationMode));
}


@override
int get hashCode => Object.hash(runtimeType,name,backendUrl,revenueCatAndroidApiKey,revenueCatIOSApiKey,appStoreId,androidBannerAdUnitId,iOSBannerAdUnitId,androidInterstitialAdUnitId,iOSInterstitialAdUnitId,androidRewardedAdUnitId,iOSRewardedAdUnitId,androidRewardedInterstitialAdUnitId,iOSRewardedInterstitialAdUnitId,mixpanelToken,authenticationMode);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Environment.dev(name: $name, backendUrl: $backendUrl, revenueCatAndroidApiKey: $revenueCatAndroidApiKey, revenueCatIOSApiKey: $revenueCatIOSApiKey, appStoreId: $appStoreId, androidBannerAdUnitId: $androidBannerAdUnitId, iOSBannerAdUnitId: $iOSBannerAdUnitId, androidInterstitialAdUnitId: $androidInterstitialAdUnitId, iOSInterstitialAdUnitId: $iOSInterstitialAdUnitId, androidRewardedAdUnitId: $androidRewardedAdUnitId, iOSRewardedAdUnitId: $iOSRewardedAdUnitId, androidRewardedInterstitialAdUnitId: $androidRewardedInterstitialAdUnitId, iOSRewardedInterstitialAdUnitId: $iOSRewardedInterstitialAdUnitId, mixpanelToken: $mixpanelToken, authenticationMode: $authenticationMode)';
}


}

/// @nodoc
abstract mixin class $DevEnvironmentCopyWith<$Res> implements $EnvironmentCopyWith<$Res> {
  factory $DevEnvironmentCopyWith(DevEnvironment value, $Res Function(DevEnvironment) _then) = _$DevEnvironmentCopyWithImpl;
@override @useResult
$Res call({
 String name, String backendUrl, String? revenueCatAndroidApiKey, String? revenueCatIOSApiKey, String? appStoreId, String? androidBannerAdUnitId, String? iOSBannerAdUnitId, String? androidInterstitialAdUnitId, String? iOSInterstitialAdUnitId, String? androidRewardedAdUnitId, String? iOSRewardedAdUnitId, String? androidRewardedInterstitialAdUnitId, String? iOSRewardedInterstitialAdUnitId, String? mixpanelToken, AuthenticationMode authenticationMode
});




}
/// @nodoc
class _$DevEnvironmentCopyWithImpl<$Res>
    implements $DevEnvironmentCopyWith<$Res> {
  _$DevEnvironmentCopyWithImpl(this._self, this._then);

  final DevEnvironment _self;
  final $Res Function(DevEnvironment) _then;

/// Create a copy of Environment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? backendUrl = null,Object? revenueCatAndroidApiKey = freezed,Object? revenueCatIOSApiKey = freezed,Object? appStoreId = freezed,Object? androidBannerAdUnitId = freezed,Object? iOSBannerAdUnitId = freezed,Object? androidInterstitialAdUnitId = freezed,Object? iOSInterstitialAdUnitId = freezed,Object? androidRewardedAdUnitId = freezed,Object? iOSRewardedAdUnitId = freezed,Object? androidRewardedInterstitialAdUnitId = freezed,Object? iOSRewardedInterstitialAdUnitId = freezed,Object? mixpanelToken = freezed,Object? authenticationMode = null,}) {
  return _then(DevEnvironment(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,backendUrl: null == backendUrl ? _self.backendUrl : backendUrl // ignore: cast_nullable_to_non_nullable
as String,revenueCatAndroidApiKey: freezed == revenueCatAndroidApiKey ? _self.revenueCatAndroidApiKey : revenueCatAndroidApiKey // ignore: cast_nullable_to_non_nullable
as String?,revenueCatIOSApiKey: freezed == revenueCatIOSApiKey ? _self.revenueCatIOSApiKey : revenueCatIOSApiKey // ignore: cast_nullable_to_non_nullable
as String?,appStoreId: freezed == appStoreId ? _self.appStoreId : appStoreId // ignore: cast_nullable_to_non_nullable
as String?,androidBannerAdUnitId: freezed == androidBannerAdUnitId ? _self.androidBannerAdUnitId : androidBannerAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSBannerAdUnitId: freezed == iOSBannerAdUnitId ? _self.iOSBannerAdUnitId : iOSBannerAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidInterstitialAdUnitId: freezed == androidInterstitialAdUnitId ? _self.androidInterstitialAdUnitId : androidInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSInterstitialAdUnitId: freezed == iOSInterstitialAdUnitId ? _self.iOSInterstitialAdUnitId : iOSInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidRewardedAdUnitId: freezed == androidRewardedAdUnitId ? _self.androidRewardedAdUnitId : androidRewardedAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSRewardedAdUnitId: freezed == iOSRewardedAdUnitId ? _self.iOSRewardedAdUnitId : iOSRewardedAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidRewardedInterstitialAdUnitId: freezed == androidRewardedInterstitialAdUnitId ? _self.androidRewardedInterstitialAdUnitId : androidRewardedInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSRewardedInterstitialAdUnitId: freezed == iOSRewardedInterstitialAdUnitId ? _self.iOSRewardedInterstitialAdUnitId : iOSRewardedInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,mixpanelToken: freezed == mixpanelToken ? _self.mixpanelToken : mixpanelToken // ignore: cast_nullable_to_non_nullable
as String?,authenticationMode: null == authenticationMode ? _self.authenticationMode : authenticationMode // ignore: cast_nullable_to_non_nullable
as AuthenticationMode,
  ));
}


}

/// @nodoc


class ProdEnvironment extends Environment with DiagnosticableTreeMixin {
  const ProdEnvironment({required this.name, required this.backendUrl, this.revenueCatAndroidApiKey, this.revenueCatIOSApiKey, this.androidBannerAdUnitId, this.iOSBannerAdUnitId, this.androidInterstitialAdUnitId, this.iOSInterstitialAdUnitId, this.androidRewardedAdUnitId, this.iOSRewardedAdUnitId, this.androidRewardedInterstitialAdUnitId, this.iOSRewardedInterstitialAdUnitId, this.appStoreId, this.sentryDsn, this.mixpanelToken, required this.authenticationMode}): super._();
  

@override final  String name;
/// Url of your backend API / or Supabase URL / or Firebase Functions region
@override final  String backendUrl;
/// RevenueCat API key for Android
/// (only if you want to use in-app purchases with RevenueCat)
@override final  String? revenueCatAndroidApiKey;
/// RevenueCat API key for iOS
/// (only if you want to use in-app purchases with RevenueCat)
@override final  String? revenueCatIOSApiKey;
// ─── Ads (AdMob) ────────────────────────────────────────────────────────
// See the dev factory above for details. Set real ids for release builds.
@override final  String? androidBannerAdUnitId;
@override final  String? iOSBannerAdUnitId;
@override final  String? androidInterstitialAdUnitId;
@override final  String? iOSInterstitialAdUnitId;
@override final  String? androidRewardedAdUnitId;
@override final  String? iOSRewardedAdUnitId;
@override final  String? androidRewardedInterstitialAdUnitId;
@override final  String? iOSRewardedInterstitialAdUnitId;
/// this is used to open the app store page of your app for reviews
@override final  String? appStoreId;
/// Sentry is an error reporting tool that will help you to track errors in production
/// You can get it from https://sentry.io
/// by default sentry will read the SENTRY_DSN environment variable except for web
/// you can also setup it directly here. Prefer using environment variables
 final  String? sentryDsn;
/// Environment variable to handle Mixpanel analytics
/// You can get it from https://mixpanel.com
@override final  String? mixpanelToken;
/// The default authentication mode of the app (anonymous or authRequired)
/// See [AuthenticationMode]
@override final  AuthenticationMode authenticationMode;

/// Create a copy of Environment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProdEnvironmentCopyWith<ProdEnvironment> get copyWith => _$ProdEnvironmentCopyWithImpl<ProdEnvironment>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Environment.prod'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('backendUrl', backendUrl))..add(DiagnosticsProperty('revenueCatAndroidApiKey', revenueCatAndroidApiKey))..add(DiagnosticsProperty('revenueCatIOSApiKey', revenueCatIOSApiKey))..add(DiagnosticsProperty('androidBannerAdUnitId', androidBannerAdUnitId))..add(DiagnosticsProperty('iOSBannerAdUnitId', iOSBannerAdUnitId))..add(DiagnosticsProperty('androidInterstitialAdUnitId', androidInterstitialAdUnitId))..add(DiagnosticsProperty('iOSInterstitialAdUnitId', iOSInterstitialAdUnitId))..add(DiagnosticsProperty('androidRewardedAdUnitId', androidRewardedAdUnitId))..add(DiagnosticsProperty('iOSRewardedAdUnitId', iOSRewardedAdUnitId))..add(DiagnosticsProperty('androidRewardedInterstitialAdUnitId', androidRewardedInterstitialAdUnitId))..add(DiagnosticsProperty('iOSRewardedInterstitialAdUnitId', iOSRewardedInterstitialAdUnitId))..add(DiagnosticsProperty('appStoreId', appStoreId))..add(DiagnosticsProperty('sentryDsn', sentryDsn))..add(DiagnosticsProperty('mixpanelToken', mixpanelToken))..add(DiagnosticsProperty('authenticationMode', authenticationMode));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProdEnvironment&&(identical(other.name, name) || other.name == name)&&(identical(other.backendUrl, backendUrl) || other.backendUrl == backendUrl)&&(identical(other.revenueCatAndroidApiKey, revenueCatAndroidApiKey) || other.revenueCatAndroidApiKey == revenueCatAndroidApiKey)&&(identical(other.revenueCatIOSApiKey, revenueCatIOSApiKey) || other.revenueCatIOSApiKey == revenueCatIOSApiKey)&&(identical(other.androidBannerAdUnitId, androidBannerAdUnitId) || other.androidBannerAdUnitId == androidBannerAdUnitId)&&(identical(other.iOSBannerAdUnitId, iOSBannerAdUnitId) || other.iOSBannerAdUnitId == iOSBannerAdUnitId)&&(identical(other.androidInterstitialAdUnitId, androidInterstitialAdUnitId) || other.androidInterstitialAdUnitId == androidInterstitialAdUnitId)&&(identical(other.iOSInterstitialAdUnitId, iOSInterstitialAdUnitId) || other.iOSInterstitialAdUnitId == iOSInterstitialAdUnitId)&&(identical(other.androidRewardedAdUnitId, androidRewardedAdUnitId) || other.androidRewardedAdUnitId == androidRewardedAdUnitId)&&(identical(other.iOSRewardedAdUnitId, iOSRewardedAdUnitId) || other.iOSRewardedAdUnitId == iOSRewardedAdUnitId)&&(identical(other.androidRewardedInterstitialAdUnitId, androidRewardedInterstitialAdUnitId) || other.androidRewardedInterstitialAdUnitId == androidRewardedInterstitialAdUnitId)&&(identical(other.iOSRewardedInterstitialAdUnitId, iOSRewardedInterstitialAdUnitId) || other.iOSRewardedInterstitialAdUnitId == iOSRewardedInterstitialAdUnitId)&&(identical(other.appStoreId, appStoreId) || other.appStoreId == appStoreId)&&(identical(other.sentryDsn, sentryDsn) || other.sentryDsn == sentryDsn)&&(identical(other.mixpanelToken, mixpanelToken) || other.mixpanelToken == mixpanelToken)&&(identical(other.authenticationMode, authenticationMode) || other.authenticationMode == authenticationMode));
}


@override
int get hashCode => Object.hash(runtimeType,name,backendUrl,revenueCatAndroidApiKey,revenueCatIOSApiKey,androidBannerAdUnitId,iOSBannerAdUnitId,androidInterstitialAdUnitId,iOSInterstitialAdUnitId,androidRewardedAdUnitId,iOSRewardedAdUnitId,androidRewardedInterstitialAdUnitId,iOSRewardedInterstitialAdUnitId,appStoreId,sentryDsn,mixpanelToken,authenticationMode);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Environment.prod(name: $name, backendUrl: $backendUrl, revenueCatAndroidApiKey: $revenueCatAndroidApiKey, revenueCatIOSApiKey: $revenueCatIOSApiKey, androidBannerAdUnitId: $androidBannerAdUnitId, iOSBannerAdUnitId: $iOSBannerAdUnitId, androidInterstitialAdUnitId: $androidInterstitialAdUnitId, iOSInterstitialAdUnitId: $iOSInterstitialAdUnitId, androidRewardedAdUnitId: $androidRewardedAdUnitId, iOSRewardedAdUnitId: $iOSRewardedAdUnitId, androidRewardedInterstitialAdUnitId: $androidRewardedInterstitialAdUnitId, iOSRewardedInterstitialAdUnitId: $iOSRewardedInterstitialAdUnitId, appStoreId: $appStoreId, sentryDsn: $sentryDsn, mixpanelToken: $mixpanelToken, authenticationMode: $authenticationMode)';
}


}

/// @nodoc
abstract mixin class $ProdEnvironmentCopyWith<$Res> implements $EnvironmentCopyWith<$Res> {
  factory $ProdEnvironmentCopyWith(ProdEnvironment value, $Res Function(ProdEnvironment) _then) = _$ProdEnvironmentCopyWithImpl;
@override @useResult
$Res call({
 String name, String backendUrl, String? revenueCatAndroidApiKey, String? revenueCatIOSApiKey, String? androidBannerAdUnitId, String? iOSBannerAdUnitId, String? androidInterstitialAdUnitId, String? iOSInterstitialAdUnitId, String? androidRewardedAdUnitId, String? iOSRewardedAdUnitId, String? androidRewardedInterstitialAdUnitId, String? iOSRewardedInterstitialAdUnitId, String? appStoreId, String? sentryDsn, String? mixpanelToken, AuthenticationMode authenticationMode
});




}
/// @nodoc
class _$ProdEnvironmentCopyWithImpl<$Res>
    implements $ProdEnvironmentCopyWith<$Res> {
  _$ProdEnvironmentCopyWithImpl(this._self, this._then);

  final ProdEnvironment _self;
  final $Res Function(ProdEnvironment) _then;

/// Create a copy of Environment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? backendUrl = null,Object? revenueCatAndroidApiKey = freezed,Object? revenueCatIOSApiKey = freezed,Object? androidBannerAdUnitId = freezed,Object? iOSBannerAdUnitId = freezed,Object? androidInterstitialAdUnitId = freezed,Object? iOSInterstitialAdUnitId = freezed,Object? androidRewardedAdUnitId = freezed,Object? iOSRewardedAdUnitId = freezed,Object? androidRewardedInterstitialAdUnitId = freezed,Object? iOSRewardedInterstitialAdUnitId = freezed,Object? appStoreId = freezed,Object? sentryDsn = freezed,Object? mixpanelToken = freezed,Object? authenticationMode = null,}) {
  return _then(ProdEnvironment(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,backendUrl: null == backendUrl ? _self.backendUrl : backendUrl // ignore: cast_nullable_to_non_nullable
as String,revenueCatAndroidApiKey: freezed == revenueCatAndroidApiKey ? _self.revenueCatAndroidApiKey : revenueCatAndroidApiKey // ignore: cast_nullable_to_non_nullable
as String?,revenueCatIOSApiKey: freezed == revenueCatIOSApiKey ? _self.revenueCatIOSApiKey : revenueCatIOSApiKey // ignore: cast_nullable_to_non_nullable
as String?,androidBannerAdUnitId: freezed == androidBannerAdUnitId ? _self.androidBannerAdUnitId : androidBannerAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSBannerAdUnitId: freezed == iOSBannerAdUnitId ? _self.iOSBannerAdUnitId : iOSBannerAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidInterstitialAdUnitId: freezed == androidInterstitialAdUnitId ? _self.androidInterstitialAdUnitId : androidInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSInterstitialAdUnitId: freezed == iOSInterstitialAdUnitId ? _self.iOSInterstitialAdUnitId : iOSInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidRewardedAdUnitId: freezed == androidRewardedAdUnitId ? _self.androidRewardedAdUnitId : androidRewardedAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSRewardedAdUnitId: freezed == iOSRewardedAdUnitId ? _self.iOSRewardedAdUnitId : iOSRewardedAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,androidRewardedInterstitialAdUnitId: freezed == androidRewardedInterstitialAdUnitId ? _self.androidRewardedInterstitialAdUnitId : androidRewardedInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,iOSRewardedInterstitialAdUnitId: freezed == iOSRewardedInterstitialAdUnitId ? _self.iOSRewardedInterstitialAdUnitId : iOSRewardedInterstitialAdUnitId // ignore: cast_nullable_to_non_nullable
as String?,appStoreId: freezed == appStoreId ? _self.appStoreId : appStoreId // ignore: cast_nullable_to_non_nullable
as String?,sentryDsn: freezed == sentryDsn ? _self.sentryDsn : sentryDsn // ignore: cast_nullable_to_non_nullable
as String?,mixpanelToken: freezed == mixpanelToken ? _self.mixpanelToken : mixpanelToken // ignore: cast_nullable_to_non_nullable
as String?,authenticationMode: null == authenticationMode ? _self.authenticationMode : authenticationMode // ignore: cast_nullable_to_non_nullable
as AuthenticationMode,
  ));
}


}

// dart format on
