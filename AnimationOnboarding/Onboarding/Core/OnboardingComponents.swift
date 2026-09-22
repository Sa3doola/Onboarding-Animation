//
//  OnboardingComponents.swift
//  AnimationOnboarding
//

import SwiftUI

// MARK: - Page indicator

struct OnboardingPageIndicator: View {
    let count: Int
    let index: Int
    var tint: Color = .primary

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { page in
                let isActive = page == index
                Capsule()
                    .fill(tint.opacity(isActive ? 1 : 0.3))
                    .frame(width: isActive ? 25 : 6, height: 6)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Page \(index + 1) of \(count)")
    }
}

// MARK: - Title + subtitle pager

/// Stacks every page's copy so the height never jumps, and animates between them.
struct OnboardingTextPager: View {
    enum Style {
        /// Pages slide horizontally with a blur (iPhone, iPad).
        case slide
        /// Pages cross-fade in place (Mac, where the device animates instead).
        case fade
    }

    let context: OnboardingContext
    var style: Style = .slide
    var titleFont: Font = .title2
    var subtitleFont: Font = .callout
    var alignment: HorizontalAlignment = .center

    var body: some View {
        ZStack {
            ForEach(Array(context.items.enumerated()), id: \.element.id) { page, item in
                let isActive = page == context.index
                let offsetFactor = style == .slide && !context.reduceMotion ? CGFloat(page - context.index) : 0

                VStack(alignment: alignment, spacing: 8) {
                    Text(item.title)
                        .font(titleFont)
                        .fontWeight(.semibold)
                        .foregroundStyle(context.configuration.textColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(item.subtitle)
                        .font(subtitleFont)
                        .fontWeight(.medium)
                        .foregroundStyle(context.configuration.textColor.secondary)
                        .lineLimit(3)
                }
                .multilineTextAlignment(textAlignment)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
                .visualEffect { content, proxy in
                    content.offset(x: offsetFactor * proxy.size.width)
                }
                .blur(radius: isActive || context.reduceMotion ? 0 : 20)
                .opacity(isActive ? 1 : 0)
                .accessibilityHidden(!isActive)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var textAlignment: TextAlignment {
        switch alignment {
        case .leading: .leading
        case .trailing: .trailing
        default: .center
        }
    }
}

// MARK: - Buttons

struct OnboardingPrimaryButton: View {
    let context: OnboardingContext
    var maxWidth: CGFloat = 320

    var body: some View {
        let configuration = context.configuration
        Button(action: context.advance) {
            Text(context.isLast ? configuration.getStartedTitle : configuration.continueTitle)
                .fontWeight(.semibold)
                .foregroundStyle(configuration.buttonForeground)
                .contentTransition(.interpolate)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
        .buttonStyle(.glassProminent)
        .tint(configuration.tint)
        .controlSize(.large)
        .frame(maxWidth: maxWidth)
        .keyboardShortcut(.defaultAction)
        .animation(context.animation, value: context.isLast)
    }
}

/// Circular back button; becomes a close button on the first page when dismissing is allowed.
struct OnboardingBackButton: View {
    let context: OnboardingContext

    var body: some View {
        Button(action: context.goBack) {
            Image(systemName: context.isFirst ? "xmark" : "chevron.backward")
                .font(.body.weight(.semibold))
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel(context.isFirst ? "Close" : "Back")
        .keyboardShortcut(context.isFirst ? .cancelAction : nil)
    }
}

/// Back/close button on the leading side and Skip on the trailing side.
struct OnboardingTopBar: View {
    let context: OnboardingContext
    var showsBackButton = true

    var body: some View {
        HStack {
            if showsBackButton && context.showsBackButton {
                OnboardingBackButton(context: context)
                    .transition(.opacity.combined(with: .scale(0.8)))
            }

            Spacer(minLength: 0)

            if context.showsSkipButton {
                Button(context.configuration.skipTitle, action: context.skip)
                    .fontWeight(.medium)
                    .buttonStyle(.glass)
                    .transition(.opacity.combined(with: .scale(0.8)))
            }
        }
        .animation(context.animation, value: context.index)
    }
}

// MARK: - Screenshots

/// All screenshots side by side inside a clipped screen; the active one slides into view.
/// On iPad `zoomsInside` scales the active screenshot within the screen instead of the device.
struct OnboardingScreenshotPager: View {
    let context: OnboardingContext
    var spacing: CGFloat = 12
    var zoomsInside: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                ForEach(Array(context.items.enumerated()), id: \.element.id) { page, item in
                    let isActive = page == context.index
                    let zoom = isActive && zoomsInside ? context.zoom : .none

                    item.screenshot
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .animation(context.zoomAnimation) {
                            $0.scaleEffect(zoom.scale, anchor: zoom.clampedAnchor)
                        }
                        .clipped()
                        .offset(x: CGFloat(page - context.index) * (size.width + spacing))
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

// MARK: - Device frames

/// A simple device mockup: a black bezel with a thin highlight around a rounded screen.
struct OnboardingDeviceFrame<Screen: View>: View {
    let aspectRatio: CGFloat
    /// Screen corner radius as a fraction of the screen width.
    var cornerRatio: CGFloat
    /// Bezel thickness as a fraction of the screen width.
    var bezelRatio: CGFloat
    @ViewBuilder var screen: Screen

    var body: some View {
        Color.clear
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let radius = width * cornerRatio
                    let bezel = max(width * bezelRatio, 4)
                    let screenShape = RoundedRectangle(cornerRadius: radius, style: .continuous)
                    let bodyShape = RoundedRectangle(cornerRadius: radius + bezel, style: .continuous)

                    screen
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .background(.black)
                        .clipShape(screenShape)
                        .padding(bezel)
                        .background(.black, in: bodyShape)
                        .overlay {
                            bodyShape.strokeBorder(.gray.opacity(0.45), lineWidth: 1.5)
                        }
                        .padding(-bezel)
                }
            }
    }
}

// MARK: - Zoom

extension View {
    /// Scales the whole device toward the active page's zoom anchor, using the
    /// configuration's zoom animation (independent of the page-change animation).
    func onboardingDeviceZoom(_ context: OnboardingContext) -> some View {
        let zoom = context.zoom
        return animation(context.zoomAnimation) {
            $0.scaleEffect(zoom.scale, anchor: zoom.anchor)
        }
    }
}
