# UI design brief: short-news app for India (Android first)

## 1. Product
A mobile app that shows important news from all over India as short swipeable cards. Each card has a photo, a headline and a summary of about 60 words. The reader swipes up for the next story and can tap through to the original article. Working name: "News App" (placeholder; do not copy any existing app's name, logo or branding).

**Audience:** Indian smartphone users, 18 to 45, reading quickly on the go, many on mid-range Android phones and slow networks. **Languages:** English and Hindi (Devanagari) from day one; more Indian languages later, so layouts must handle longer words and taller scripts.

## 2. Platform and deliverables
- Android first (Material 3), design at 360x800 and 412x915. iOS later.
- Figma file with: a style guide page, a component page, and all screens in **light and dark** mode.
- Use Figma styles/variables for colours, type and spacing so developers can map them to Flutter (ColorScheme, TextTheme).
- Clickable prototype of the main flow (welcome > feed > swipe > read full story > save).
- Exported assets: app icon (1024x1024 and adaptive icon), splash, any illustrations (SVG).
- Real photos and realistic sample content in mockups. No lorem ipsum, no grey boxes.

## 3. Look and feel
Editorial, calm, trustworthy, fast. Photo-led cards with strong visual hierarchy: photo first, then headline, then summary. Plenty of whitespace, minimal chrome, one accent colour. It should feel like a premium newspaper app, not a generic template.

Starting palette (designer may refine, keep contrast WCAG AA):
- Light: background #F6F3EC, surface #FFFFFF, text #14181F, muted text #4F5666, border #E1DBCD, accent red #C5301F, link teal #0E6B66.
- Dark: background #0F1217, surface #181C23, text #F2EFE8, muted #A9B0BD, border #2A303A, accent #FF8A78, link #5CC8C0.

Type: serif for headlines (suggest Libre Baskerville), clean sans for UI and summaries (suggest DM Sans), Noto Serif / Sans Devanagari for Hindi. Provide a type scale including a Hindi variant. Spacing on a 4 pt grid. Corner radii 12 / 20 / pill. Touch targets at least 44 px. Icons: one consistent outline set, no emoji.

## 4. Screens
1. **Splash and welcome:** logo, tagline, pick language (English / Hindi), pick home state, breaking-news alerts toggle, "Get started".
2. **Feed (main screen):** top bar (logo, state chip, search icon); horizontally scrolling category chips; one full-height story card at a time: large photo, category tag, source name, time, headline (max 3 lines), summary (about 60 words), "Read full story" link, save and share buttons. Swipe up for next, down for previous. Show a subtle hint on first launch. Pull to refresh at the top. Bottom nav: Feed, Discover, Saved, Settings.
3. **Discover:** the 12 categories (Top Stories, India, World, Business, Politics, Sports, Entertainment, Technology, Science, Health, Education, Startups) as attractive tiles with icon or image; state and city picker below.
4. **Search:** search field, filters (language, category), results list with thumbnails, recent searches, empty and no-results states.
5. **Saved:** list of bookmarked stories, works offline, swipe or tap to remove, empty state with illustration.
6. **Settings:** language, appearance (system / light / dark), text size, notifications (breaking news, daily digest time), home state, privacy policy, feedback, app version.
7. **Article reader:** in-app browser for the publisher's page with source name and domain, progress bar, share, save, open in browser.
8. **Breaking news notification** (Android notification design) and a **home-screen widget** (optional).

## 5. States to design for every screen
Loading (skeleton cards), empty, offline banner (showing cached stories), error with retry, image-failed placeholder, long headline and long Hindi text, small text and large text sizes.

## 6. Rules
- Always show the source name and a link to the original article on every card.
- Respect the 60-word summary length; the card must not scroll.
- Accessible: AA contrast, labels for icon buttons, works with large system fonts and screen readers.
- Keep it light: avoid heavy shadows, gradients and animations that slow low-end phones.
- Motion: card swipe is a quick vertical slide (about 250 ms); save gives a small bookmark fill animation.

## 7. Please deliver feedback options
Offer two visual directions for the feed card (for example photo-top and full-bleed photo with overlaid headline) so we can pick one before the rest is finished.
