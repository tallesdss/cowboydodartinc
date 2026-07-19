/// Result of inspecting [BiometricService.availableTypes()] for UX copy selection.
///
/// Fallback slots use the broader “mixed / unknown” strings in translations.
enum BiometricCopySlot {
  iosFaceOnly,
  iosFingerprintOnly,
  iosFaceAndFingerprint,

  /// OS did not classify sensors (yet) — use safe combined iOS wording.
  iosUndetermined,

  androidFaceOnly,
  androidFingerprintOnly,
  androidFaceAndFingerprint,

  /// Strong/weak iris-only or ambiguous — neutral Android copy.
  androidUndetermined,

  unsupported,
}
