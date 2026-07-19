# Rode o app — Flutter escolhe o primeiro dispositivo disponível
# Uso: make run | make run-ios | make run-android | make run-web
# Hot reload: pressione 'r' no terminal enquanto o app roda
# run-ios/run-android: mostra lista de dispositivos — selecione iPhone, simulador ou Android

DEFINES := \
  --dart-define=ENV=dev \
  --dart-define=BACKEND_URL=https://ocrpybzdjrcldvlpgccw.supabase.co \
  --dart-define=SUPABASE_TOKEN=https://ocrpybzdjrcldvlpgccw.supabase.co \
  --dart-define=RC_ANDROID_API_KEY=YOUR_REVENUECAT_ANDROID_KEY \
  --dart-define=RC_IOS_API_KEY=YOUR_REVENUECAT_IOS_KEY \
  --dart-define=MIXPANEL_TOKEN=YOUR_MIXPANEL_TOKEN \
  --dart-define=AI_CHAT_ENDPOINT=https://ocrpybzdjrcldvlpgccw.supabase.co/functions/v1/ai-chat

.PHONY: run run-ios run-android run-web release-ios

run:
	flutter run $(DEFINES)

run-ios:
	flutter run $(DEFINES)

run-android:
	flutter run $(DEFINES)

run-web:
	flutter run -d chrome $(DEFINES)

# Release iOS na App Store (requer: kasy ios configure)
release-ios:
	bash scripts/release-ios.sh
