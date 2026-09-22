//
//  OnboardingMacView.swift
//  AnimationOnboarding
//

import SwiftUI

/// Mac layout: a MacBook mockup that zooms toward each feature inside a floating,
/// rounded window. Present it with `OnboardingWindow` or embed it anywhere.
struct OnboardingMacView: View {
    let items: [OnboardingItem]
    let onFinish: (OnboardingResult) -> Void

    private let cornerRadius: CGFloat = 30
    private let macbookTint = Color(red: 0.75, green: 0.75, blue: 0.78)

    var body: some View {
        OnboardingFlow(items: items, onFinish: onFinish) { context in
            VStack(spacing: 0) {
                macBook(context)
                    .frame(height: 290)
                    .padding(.top, 48)
                    .compositingGroup()
                    .onboardingDeviceZoom(context)

                VStack(spacing: 20) {
                    OnboardingPageIndicator(
                        count: context.items.count,
                        index: context.index,
                        tint: context.configuration.textColor
                    )
                    OnboardingTextPager(
                        context: context,
                        style: .fade,
                        titleFont: .largeTitle,
                        subtitleFont: .title3
                    )
                    .blurPulse(trigger: context.index, radius: 15, isEnabled: !context.reduceMotion)

                    OnboardingPrimaryButton(context: context, maxWidth: 300)
                        .padding(.top, 4)
                }
                .padding(.top, 44)
                .padding(.horizontal, 48)
                .padding(.bottom, 32)
                .background { fadingBackground }
            }
            .overlay(alignment: .top) {
                OnboardingTopBar(context: context)
                    .controlSize(.small)
                    .padding(14)
            }
            .frame(width: 600)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.windowBackground)
                    .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
            }
        }
    }

    // MARK: MacBook mockup

    private let screenShape = ConcentricRectangle(
        topLeadingCorner: .concentric,
        topTrailingCorner: .concentric,
        bottomLeadingCorner: .fixed(0),
        bottomTrailingCorner: .fixed(0)
    )

    private func macBook(_ context: OnboardingContext) -> some View {
        ZStack {
            screenShape.fill(.black)

            // Cross-fade all screenshots so the swap happens under the blur, not before it.
            ZStack {
                ForEach(Array(context.items.enumerated()), id: \.element.id) { page, item in
                    item.screenshot
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(page == context.index ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .blurPulse(trigger: context.index, radius: 25, isEnabled: !context.reduceMotion)
            .clipShape(screenShape)
            .accessibilityHidden(true)

            bezel
        }
        .containerShape(.rect(cornerRadius: 5))
        .aspectRatio(context.configuration.macScreenAspectRatio, contentMode: .fit)
    }

    private var bezel: some View {
        ZStack(alignment: .top) {
            screenShape
                .stroke(macbookTint, lineWidth: 3)

            // Camera notch
            bottomRoundedShape(3)
                .fill(.black)
                .frame(width: 50, height: 8)
                .offset(y: 3.5)

            // Base
            bottomRoundedShape(5)
                .fill(macbookTint)
                .overlay(alignment: .top) {
                    bottomRoundedShape(2)
                        .fill(.black.opacity(0.3))
                        .frame(width: 80, height: 3)
                }
                .frame(height: 10)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, -35)
                .offset(y: 9)
        }
        .padding(-3)
    }

    private func bottomRoundedShape(_ radius: CGFloat) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            bottomLeadingRadius: radius,
            bottomTrailingRadius: radius,
            style: .continuous
        )
    }

    /// Covers the zoomed MacBook behind the copy.
    private var fadingBackground: some View {
        Rectangle()
            .fill(.windowBackground)
            .mask {
                LinearGradient(
                    stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .padding(.top, -30)
            .padding(.bottom, -50)
    }
}

private extension View {
    /// Blurs in and out once every time `trigger` changes.
    func blurPulse(trigger: Int, radius: CGFloat, isEnabled: Bool) -> some View {
        keyframeAnimator(initialValue: CGFloat.zero, trigger: trigger) { content, blur in
            content.blur(radius: isEnabled ? blur : 0)
        } keyframes: { _ in
            CubicKeyframe(radius, duration: 0.25)
            CubicKeyframe(0, duration: 0.25)
        }
    }
}

#Preview("Mac") {
    OnboardingMacView(items: OnboardingItem.mockMac) { print($0) }
        .padding(40)
}
