//
//  OnboardingPadView.swift
//  AnimationOnboarding
//

import SwiftUI

/// iPad layout. Landscape puts the device and the copy side by side; portrait stacks them.
/// Zoom happens *inside* the screen so it never collides with the copy, and a blurred copy
/// of the active screenshot tints the background.
struct OnboardingPadView: View {
    let items: [OnboardingItem]
    let onFinish: (OnboardingResult) -> Void

    var body: some View {
        OnboardingFlow(items: items, onFinish: onFinish) { context in
            GeometryReader { proxy in
                let isLandscape = proxy.size.width > proxy.size.height * 1.1

                Group {
                    if isLandscape {
                        landscape(context, size: proxy.size)
                    } else {
                        portrait(context, size: proxy.size)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .overlay(alignment: .top) {
                // Back lives next to Continue on iPad: it's easier to reach, and the top-leading
                // corner belongs to the window controls when the app runs in a window.
                OnboardingTopBar(context: context, showsBackButton: false)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
            }
            .background { backdrop(context) }
        }
    }

    // MARK: Layouts

    private func landscape(_ context: OnboardingContext, size: CGSize) -> some View {
        HStack(spacing: 56) {
            device(context)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 28) {
                OnboardingPageIndicator(
                    count: context.items.count,
                    index: context.index,
                    tint: context.configuration.textColor
                )
                OnboardingTextPager(
                    context: context,
                    titleFont: .largeTitle,
                    subtitleFont: .title3,
                    alignment: .leading
                )
                controls(context, maxWidth: 340)
            }
            .frame(width: min(size.width * 0.34, 420))
        }
        .padding(.horizontal, 56)
        .padding(.vertical, 80)
    }

    private func portrait(_ context: OnboardingContext, size: CGSize) -> some View {
        VStack(spacing: 40) {
            // The device takes whatever height the copy leaves and aspect-fits inside it,
            // so both portrait and landscape screenshots work.
            device(context)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 20) {
                OnboardingTextPager(context: context, titleFont: .largeTitle, subtitleFont: .title3)
                OnboardingPageIndicator(
                    count: context.items.count,
                    index: context.index,
                    tint: context.configuration.textColor
                )
                controls(context, maxWidth: 380)
            }
            .frame(maxWidth: 560)
        }
        .padding(.horizontal, 56)
        .padding(.top, 96)
        .padding(.bottom, 48)
    }

    // MARK: Pieces

    private func controls(_ context: OnboardingContext, maxWidth: CGFloat) -> some View {
        HStack(spacing: 12) {
            if context.showsBackButton {
                OnboardingBackButton(context: context)
                    .controlSize(.large)
                    .transition(.opacity.combined(with: .scale(0.8)))
            }
            OnboardingPrimaryButton(context: context, maxWidth: maxWidth)
        }
        .frame(maxWidth: maxWidth + 60)
        .animation(context.animation, value: context.showsBackButton)
    }

    private func device(_ context: OnboardingContext) -> some View {
        OnboardingDeviceFrame(
            aspectRatio: context.configuration.padScreenAspectRatio,
            cornerRatio: 0.03,
            bezelRatio: 0.025
        ) {
            OnboardingScreenshotPager(context: context, spacing: 24, zoomsInside: true)
        }
        .shadow(color: .black.opacity(0.25), radius: 40, y: 24)
    }

    private func backdrop(_ context: OnboardingContext) -> some View {
        ZStack {
            Rectangle().fill(.background)

            ForEach(Array(context.items.enumerated()), id: \.element.id) { page, item in
                item.screenshot
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 80)
                    .opacity(page == context.index ? 0.35 : 0)
            }
            .accessibilityHidden(true)
        }
        .clipped()
        .ignoresSafeArea()
    }
}

#Preview("iPad – landscape", traits: .landscapeLeft) {
    OnboardingPadView(items: OnboardingItem.mockPad) { print($0) }
}

#Preview("iPad – portrait", traits: .portrait) {
    OnboardingPadView(items: OnboardingItem.mockPad) { print($0) }
}
