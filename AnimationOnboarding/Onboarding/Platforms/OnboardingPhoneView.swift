//
//  OnboardingPhoneView.swift
//  AnimationOnboarding
//

import SwiftUI

/// iPhone layout: a phone mockup that zooms toward each feature, with copy and controls
/// floating on a fading panel at the bottom.
struct OnboardingPhoneView: View {
    let items: [OnboardingItem]
    let onFinish: (OnboardingResult) -> Void

    @State private var panelHeight: CGFloat = 220

    var body: some View {
        OnboardingFlow(items: items, onFinish: onFinish) { context in
            ZStack(alignment: .bottom) {
                device(context)
                    .padding(.top, 64)
                    .padding(.horizontal, 36)
                    .padding(.bottom, panelHeight + 8)

                bottomPanel(context)
            }
            .overlay(alignment: .top) {
                OnboardingTopBar(context: context)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            .background(.background)
        }
    }

    private func device(_ context: OnboardingContext) -> some View {
        OnboardingDeviceFrame(
            aspectRatio: context.configuration.phoneScreenAspectRatio,
            cornerRatio: 0.14,
            bezelRatio: 0.03
        ) {
            OnboardingScreenshotPager(context: context)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        .onboardingDeviceZoom(context)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func bottomPanel(_ context: OnboardingContext) -> some View {
        VStack(spacing: 16) {
            OnboardingTextPager(context: context)
            OnboardingPageIndicator(
                count: context.items.count,
                index: context.index,
                tint: context.configuration.textColor
            )
            OnboardingPrimaryButton(context: context)
                .padding(.horizontal, 14)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { panelHeight = $0 }
        .background {
            // Fades the zoomed device out behind the copy so the text stays readable
            // in both light and dark mode.
            VStack(spacing: 0) {
                Rectangle().fill(.background).mask {
                    LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                }
                .frame(height: 56)
                Rectangle().fill(.background)
            }
            .padding(.top, -56)
            .ignoresSafeArea()
        }
    }
}

#Preview("iPhone") {
    OnboardingPhoneView(items: OnboardingItem.mockPhone) { print($0) }
}

#Preview("iPhone – dismissable, tinted") {
    var configuration = OnboardingConfiguration()
    configuration.tint = .orange
    configuration.allowsDismiss = true
    return OnboardingPhoneView(items: OnboardingItem.mockPhone) { print($0) }
        .onboardingConfiguration(configuration)
}
