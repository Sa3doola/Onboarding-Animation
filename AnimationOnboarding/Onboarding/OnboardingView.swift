//
//  OnboardingView.swift
//  AnimationOnboarding
//

import SwiftUI

/// Picks the right onboarding layout for the current device.
///
///     OnboardingView(content: myContent) { result in
///         analytics.log(result)
///     }
struct OnboardingView: View {
    let content: OnboardingContent
    let onFinish: (OnboardingResult) -> Void

    var body: some View {
        #if os(macOS)
        OnboardingMacView(items: content.mac, onFinish: onFinish)
        #elseif os(visionOS)
        OnboardingPadView(items: content.pad, onFinish: onFinish)
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            OnboardingPadView(items: content.pad, onFinish: onFinish)
        } else {
            OnboardingPhoneView(items: content.phone, onFinish: onFinish)
        }
        #endif
    }
}

// MARK: - Automatic presentation

extension View {
    /// Presents onboarding whenever `store.needsOnboarding` is true, and records the result.
    ///
    /// - iOS / iPadOS: shown as a full-screen cover.
    /// - macOS: opens the `OnboardingWindow` scene, which must be declared in your `App`
    ///   with the same store (it shows `content.mac` from that scene).
    func onboarding(
        store: OnboardingStore,
        content: OnboardingContent,
        onFinish: ((OnboardingResult) -> Void)? = nil
    ) -> some View {
        modifier(OnboardingPresenter(store: store, content: content, onFinish: onFinish))
    }
}

private struct OnboardingPresenter: ViewModifier {
    let store: OnboardingStore
    let content: OnboardingContent
    let onFinish: ((OnboardingResult) -> Void)?

    #if os(macOS)
    @Environment(\.openWindow) private var openWindow

    func body(content: Content) -> some View {
        content.onChange(of: store.needsOnboarding, initial: true) { _, needsOnboarding in
            if needsOnboarding { openWindow(id: OnboardingWindow.id) }
        }
    }
    #else
    func body(content view: Content) -> some View {
        let isPresented = Binding(get: { store.needsOnboarding }, set: { _ in })
        #if os(iOS)
        view.fullScreenCover(isPresented: isPresented) { onboarding }
        #else
        view.sheet(isPresented: isPresented) { onboarding }
        #endif
    }

    private var onboarding: some View {
        OnboardingView(content: content) { result in
            store.finish(with: result)
            onFinish?(result)
        }
        .interactiveDismissDisabled()
    }
    #endif
}

// MARK: - macOS window

#if os(macOS)
/// A borderless, draggable window that hosts the Mac onboarding.
///
///     OnboardingWindow(store: store, items: content.mac)
struct OnboardingWindow: Scene {
    static let id = "onboarding"

    let store: OnboardingStore
    let items: [OnboardingItem]
    var onFinish: ((OnboardingResult) -> Void)? = nil

    var body: some Scene {
        Window("Welcome", id: Self.id) {
            OnboardingWindowRoot(items: items) { result in
                store.finish(with: result)
                onFinish?(result)
            }
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        // The main window opens at the same moment; keep onboarding in front of it.
        .windowLevel(.floating)
        .restorationBehavior(.disabled)
        .windowBackgroundDragBehavior(.enabled)
        .defaultWindowPlacement { _, _ in WindowPlacement(.center) }
        // Opened on demand by `.onboarding(store:content:)`, never automatically at launch.
        .defaultLaunchBehavior(.suppressed)
    }
}

private struct OnboardingWindowRoot: View {
    let items: [OnboardingItem]
    let onFinish: (OnboardingResult) -> Void
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        OnboardingMacView(items: items) { result in
            onFinish(result)
            dismissWindow(id: OnboardingWindow.id)
        }
        .contentShape(.rect)
        .gesture(WindowDragGesture())
    }
}
#endif
