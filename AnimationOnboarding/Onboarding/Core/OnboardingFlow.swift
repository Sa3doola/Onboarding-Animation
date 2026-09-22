//
//  OnboardingFlow.swift
//  AnimationOnboarding
//

import SwiftUI

/// Everything a layout needs to render the current state and drive navigation.
struct OnboardingContext {
    let items: [OnboardingItem]
    let index: Int
    let animation: Animation
    let zoomAnimation: Animation
    let reduceMotion: Bool
    let configuration: OnboardingConfiguration

    let advance: () -> Void
    let goBack: () -> Void
    let skip: () -> Void

    var item: OnboardingItem { items[index] }
    var isFirst: Bool { index == 0 }
    var isLast: Bool { index == items.count - 1 }
    /// On the first page the back button becomes a close button (if dismissing is allowed).
    var showsBackButton: Bool { !isFirst || configuration.allowsDismiss }
    var showsSkipButton: Bool { configuration.allowsSkip && !isLast }
    /// Zoom is decorative, so it is dropped when Reduce Motion is on.
    var zoom: OnboardingZoom { reduceMotion ? .none : item.zoom }
}

/// Owns the page index and the navigation rules shared by every platform layout:
/// completion/skip/dismiss callbacks, haptics, hardware-keyboard arrows and swipes.
///
/// Build a custom layout by passing your own `content` closure.
struct OnboardingFlow<Content: View>: View {
    let items: [OnboardingItem]
    let onFinish: (OnboardingResult) -> Void
    @ViewBuilder let content: (OnboardingContext) -> Content

    @Environment(\.onboardingConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var index = 0
    @State private var didFinish = false

    var body: some View {
        if items.isEmpty {
            // Nothing to show: finish immediately instead of crashing on `items[0]`.
            Color.clear.onAppear { finish(.completed) }
        } else {
            let context = makeContext()
            content(context)
                .background { keyboardShortcuts(context) }
                #if !os(macOS)
                .simultaneousGesture(swipeGesture, isEnabled: configuration.allowsSwipe)
                #endif
                .sensoryFeedback(.selection, trigger: index) { _, _ in configuration.hapticsEnabled }
                .accessibilityAction(.escape) { if context.showsBackButton { goBack() } }
        }
    }

    private var animation: Animation {
        reduceMotion ? .easeInOut(duration: 0.25) : configuration.animation
    }

    private func makeContext() -> OnboardingContext {
        // Guards against `items` shrinking while the flow is on screen.
        let safeIndex = min(index, items.count - 1)
        return OnboardingContext(
            items: items,
            index: safeIndex,
            animation: animation,
            zoomAnimation: reduceMotion ? animation : configuration.zoomAnimation,
            reduceMotion: reduceMotion,
            configuration: configuration,
            advance: advance,
            goBack: goBack,
            skip: { finish(.skipped(pageIndex: safeIndex)) }
        )
    }

    private func advance() {
        if index >= items.count - 1 {
            finish(.completed)
        } else {
            withAnimation(animation) { index += 1 }
        }
    }

    private func goBack() {
        if index == 0 {
            if configuration.allowsDismiss { finish(.dismissed) }
        } else {
            withAnimation(animation) { index -= 1 }
        }
    }

    /// Ensures the callback fires once, even if the user double-taps "Get Started".
    private func finish(_ result: OnboardingResult) {
        guard !didFinish else { return }
        didFinish = true
        onFinish(result)
    }

    #if !os(macOS)
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                // Pages flow right-to-left in RTL languages, so flip the swipe direction.
                let dx = value.translation.width * (layoutDirection == .rightToLeft ? -1 : 1)
                // Ignore mostly-vertical drags.
                guard abs(dx) > 60, abs(dx) > abs(value.translation.height) else { return }
                if dx < 0 {
                    // Swiping past the last page shouldn't silently complete onboarding.
                    if index < items.count - 1 { advance() }
                } else if index > 0 {
                    goBack()
                }
            }
    }
    #endif

    /// Invisible buttons so arrow keys work on iPad/Mac with a hardware keyboard.
    private func keyboardShortcuts(_ context: OnboardingContext) -> some View {
        let isRTL = layoutDirection == .rightToLeft
        return ZStack {
            Button("Next page") { if !context.isLast { advance() } }
                .keyboardShortcut(isRTL ? .leftArrow : .rightArrow, modifiers: [])
            Button("Previous page") { if !context.isFirst { goBack() } }
                .keyboardShortcut(isRTL ? .rightArrow : .leftArrow, modifiers: [])
        }
        .opacity(0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
