import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

/// Suffix for the screen-only [DeviceIdentifier] variant (frame hidden).
const String kasyScreenOnlySuffix = '-screen-only';

bool kasyIsScreenOnlyDevice(DeviceInfo device) {
  return device.identifier.name.endsWith(kasyScreenOnlySuffix);
}

/// Rounded screen silhouette used when the device bezel is hidden.
///
/// Upstream mockups subtract the Dynamic Island / camera hole from the clip
/// path, which leaves a white gap in PNG exports. This variant keeps the same
/// viewport size and rounded screen corners, but drops the bezel and the hole.
DeviceInfo kasyScreenOnlyVariant(DeviceInfo device) {
  return device.copyWith(
    identifier: DeviceIdentifier(
      device.identifier.platform,
      device.identifier.type,
      '${device.identifier.name}$kasyScreenOnlySuffix',
    ),
    screenPath: kasyScreenOnlyPath(device),
  );
}

/// Corner radius that approximates the visible glass on each form factor.
double kasyScreenCornerRadius(DeviceInfo device) {
  final Size size = device.screenSize;
  return switch (device.identifier.type) {
    DeviceType.desktop || DeviceType.laptop => 12,
    DeviceType.tablet => size.shortestSide * 0.04,
    _ => device.identifier.platform == TargetPlatform.iOS
        ? size.width * 0.117
        : 28,
  };
}

Path kasyScreenOnlyPath(DeviceInfo device) {
  final Size size = device.screenSize;
  final double radius = kasyScreenCornerRadius(device);
  return Path()
    ..addRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
    );
}

/// All devices registered with [DevicePreview], including screen-only variants.
List<DeviceInfo> kasyAllPreviewDevices(List<DeviceInfo> baseDevices) {
  return <DeviceInfo>[
    ...baseDevices,
    ...baseDevices.map(kasyScreenOnlyVariant),
  ];
}
