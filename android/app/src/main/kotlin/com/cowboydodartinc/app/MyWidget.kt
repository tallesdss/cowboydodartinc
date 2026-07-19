package com.cowboydodartinc.app

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontStyle
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import java.util.Locale

class MyWidgetWidget : GlanceAppWidget() {

  // Recompose when the user resizes the widget so the layout can adapt
  // between small (no "+", no quote) and large (everything visible).
  override val sizeMode: SizeMode = SizeMode.Exact

  override val stateDefinition: GlanceStateDefinition<*>?
    get() = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent {
      GlanceContent(context, currentState())
    }
  }

  @Composable
  private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
    val prefs = currentState.preferences
    val storedGreeting = prefs.getString("greeting", "") ?: ""
    val storedTitle = prefs.getString("title", "") ?: ""
    val planText = prefs.getString("planText", "") ?: ""
    val isPro = prefs.getString("isPro", "false") == "true"
    val quote = prefs.getString("quote", "") ?: ""
    val quoteAuthor = prefs.getString("quoteAuthor", "") ?: ""

    // Fallback used when Flutter has not pushed data yet — first install
    // before the app opens. Keeps the widget from rendering blank in the
    // gallery preview.
    val defaults = defaultStrings()
    val greeting = storedGreeting.ifEmpty { defaults.greeting }
    val title = storedTitle.ifEmpty { defaults.hello }

    val size = LocalSize.current
    // "Narrow" covers both the true small widget and the tall-but-narrow
    // single-column shape — both get the tightest sentence count.
    val isSmall = size.width < 240.dp
    // We show N COMPLETE sentences from the quote (split on "\n" — which is
    // how the i18n JSON separates the four sentences). Truncating per
    // sentence avoids the ugly "…" mid-word that lineLimit alone produces.
    //   height < 180dp        → no quote.
    //   narrow column         → 1 sentence (just the first one).
    //   wide + short          → 2 sentences.
    //   wide + medium height  → 3 sentences.
    //   wide + tall           → 4 sentences + bold author.
    val showQuote = size.height >= 180.dp
    val numSentences = when {
      isSmall -> 1
      size.height < 240.dp -> 2
      size.height < 300.dp -> 3
      else -> 4
    }
    val showQuoteAuthor = !isSmall && size.height >= 300.dp
    val sentences = quote.split("\n").filter { it.isNotBlank() }
    val displayQuote = sentences.take(numSentences).joinToString("\n")
    // Each sentence is short enough to wrap to 2 lines on narrow widgets,
    // so a 2x cap covers the worst case without slicing the last sentence.
    val quoteMaxLines = numSentences * 2

    // Brand colors. The pure-Compose colors (whiteSubtle, whiteQuote,
    // whiteVerySubtle) are foreground tints used by the live widget only,
    // so they stay inline. The gold pulls from res/values/colors.xml to keep
    // a single source of truth shared with the XML drawables.
    val white = Color.White
    val whiteSubtle = Color(red = 1f, green = 1f, blue = 1f, alpha = 0.55f)
    val whiteQuote = Color(red = 1f, green = 1f, blue = 1f, alpha = 0.65f)
    val whiteVerySubtle = Color(red = 1f, green = 1f, blue = 1f, alpha = 0.45f)
    val gold = Color(ContextCompat.getColor(context, R.color.widget_pro_gold))

    // The gradient lives in its own Image at the bottom of the stack rather
    // than as `.background(ImageProvider(...))`, because in some Glance
    // versions the latter ends up rendered ABOVE the content — the widget
    // shows just the gradient, no text. The explicit Image+Column layering
    // here is deterministic.
    Box(
      modifier = GlanceModifier
        .fillMaxSize()
        .clickable(actionRunCallback<OpenAppAction>()),
    ) {
      Image(
        provider = ImageProvider(R.drawable.widget_gradient_inner),
        contentDescription = null,
        contentScale = ContentScale.FillBounds,
        modifier = GlanceModifier.fillMaxSize(),
      )
      Column(
        modifier = GlanceModifier.fillMaxSize().padding(16.dp),
      ) {
        Text(
          text = greeting,
          style = TextStyle(
            color = ColorProvider(whiteSubtle),
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
          ),
        )
        Text(
          text = title,
          style = TextStyle(
            color = ColorProvider(white),
            fontSize = if (isSmall) 20.sp else 24.sp,
            fontWeight = FontWeight.Bold,
          ),
          modifier = GlanceModifier.padding(top = 4.dp),
        )
        if (showQuote && displayQuote.isNotEmpty()) {
          Text(
            text = displayQuote,
            style = TextStyle(
              color = ColorProvider(whiteQuote),
              fontSize = 15.sp,
              fontWeight = FontWeight.Normal,
              fontStyle = FontStyle.Italic,
            ),
            maxLines = quoteMaxLines,
            modifier = GlanceModifier.padding(top = 12.dp),
          )
          if (showQuoteAuthor && quoteAuthor.isNotEmpty()) {
            // Author goes on its own line, right-aligned and bold, so the
            // quote reads as a quote and the attribution is visually distinct.
            Row(
              modifier = GlanceModifier
                .fillMaxWidth()
                .padding(top = 4.dp),
              horizontalAlignment = Alignment.End,
            ) {
              Text(
                text = quoteAuthor,
                style = TextStyle(
                  color = ColorProvider(whiteQuote),
                  fontSize = 13.sp,
                  fontWeight = FontWeight.Bold,
                ),
              )
            }
          }
        }
        Spacer(modifier = GlanceModifier.defaultWeight())
        Row(
          modifier = GlanceModifier.fillMaxWidth(),
          verticalAlignment = Alignment.CenterVertically,
        ) {
          // Empty planText hides the pill (used in logged-out state).
          if (planText.isNotEmpty()) {
            PlanPill(
              isPro = isPro,
              planText = planText,
              gold = gold,
              whiteVerySubtle = whiteVerySubtle,
            )
          }
          // Small intentionally drops the "+" so the layout breathes —
          // the pill sits flush left like the original design.
          if (!isSmall) {
            Spacer(modifier = GlanceModifier.defaultWeight())
            Image(
              provider = ImageProvider(R.drawable.widget_add_button),
              contentDescription = "Add",
              modifier = GlanceModifier
                .size(34.dp)
                .clickable(actionRunCallback<OpenAppAction>()),
            )
          }
        }
      }
    }
  }

  @Composable
  private fun PlanPill(
    isPro: Boolean,
    planText: String,
    gold: Color,
    whiteVerySubtle: Color,
  ) {
    if (isPro) {
      Box(
        modifier = GlanceModifier
          .background(ImageProvider(R.drawable.widget_pro_pill_bg))
          .padding(horizontal = 10.dp, vertical = 5.dp),
      ) {
        Text(
          text = "⭐ $planText",
          style = TextStyle(
            color = ColorProvider(gold),
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
          ),
        )
      }
    } else {
      Box(
        modifier = GlanceModifier
          .background(ImageProvider(R.drawable.widget_plan_pill_bg))
          .padding(horizontal = 10.dp, vertical = 5.dp),
      ) {
        Text(
          text = planText,
          style = TextStyle(
            color = ColorProvider(whiteVerySubtle),
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
          ),
        )
      }
    }
  }

  // Fallback used ONLY in the brief window between the widget being placed and
  // the Flutter app pushing real values. Keep this dead simple — the
  // time-aware greeting in three languages lives on the Dart side
  // (home_widget_mywidget_service.dart::_greeting). Duplicating that logic
  // here was a maintenance trap when adding new locales.
  private data class DefaultStrings(val greeting: String, val hello: String)

  private fun defaultStrings(): DefaultStrings = when (Locale.getDefault().language) {
    "pt" -> DefaultStrings(greeting = "Olá", hello = "Bem-vindo!")
    "es" -> DefaultStrings(greeting = "Hola", hello = "¡Bienvenido!")
    else -> DefaultStrings(greeting = "Hello", hello = "Welcome!")
  }
}
