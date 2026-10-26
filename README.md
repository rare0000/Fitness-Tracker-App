# FitBalance

A fitness and nutrition tracking app I built for my bachelor's degree project using **Flutter and Dart**.

I wanted to make something that brings food tracking and workout planning together. Instead of just counting calories, the idea was to let someone log what they eat, look back at their nutrition over the week, and get exercise suggestions based on that information.

It's a working **prototype**, not a finished commercial app. The interface is in Lithuanian.

## What you can do in the app

- **Log meals:** Find foods in the built-in catalogue, enter a portion in grams, and add it to your food diary.
- **Track nutrition:** See calories, protein, carbs, fats, and some vitamins and minerals.
- **Look at your week:** Check nutrition summaries, spot possible gaps compared with reference targets, and see suggested foods.
- **Get workout ideas:** The app uses rules based on logged nutrition data to suggest exercises, with descriptions and animations.
- **Follow your progress:** Browse previous days and weekly summaries.
- **Keep your data:** Entries are stored locally, and the profile screen includes an export/import recovery-code option.

The app starts with a seven-day food-logging period so it can build up enough history for a weekly overview.

## Built with

- **Flutter & Dart** for the mobile app
- **Riverpod** for state management
- **GoRouter** for navigation
- **Shared Preferences** for local storage
- **Lottie** for exercise animations
- **Kotlin / Gradle** for the Android project setup

I organized the code into presentation, domain, and data layers to keep different parts of the app separate.

## Screenshots

I still need to add screenshots of the app here. The most useful screens to show would be the home page, food diary, workout suggestions, weekly progress, and profile.

<!-- Once screenshots are added to the screenshots folder, link them here. -->

## How to run it

You'll need the [Flutter SDK](https://docs.flutter.dev/get-started/install) and either an Android emulator or a connected Android phone.

1. Clone or download this repository and open its folder.
2. Install the dependencies:

   ```bash
   flutter pub get
   ```

3. Start an emulator or connect your phone, then run:

   ```bash
   flutter run
   ```

If Flutter isn't set up yet, `flutter doctor` can help you find what's missing. I haven't tested a fresh build on another computer, so some setup adjustments might be needed.

## A few things to know

This was made for a university project, so there are still things I'd like to improve. The workout suggestions are **rule-based, not AI-generated**, and the nutrition targets are general reference values rather than medical advice. The app stores data on the device; it doesn't use an online account or cloud database.

If I continue developing it, I'd like to add more personalized goals, support for physical limitations, a larger food catalogue, and better testing.

## About the project

Built as my bachelor's degree project in **Programming and Information Technology**.
