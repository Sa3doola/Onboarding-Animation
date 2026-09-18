//
//  ONboardingWindow.swift
//  MyApp
//
//  Created by Saad Sherif on 19/09/2026.
//

import SwiftUI

struct OnboardingItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let screenShot: String
    var zoomScale: CGFloat = 1
    var zoomAnchor: UnitPoint = .center
}


struct OnBoardingWindow: Scene {
    var items: [OnboardingItem]
    var onExit: () -> ()
    var onSkip: () -> ()
    var onCompltete: () -> ()
    
    var body: some Scene {
        WindowGroup("OnBoarding") {
            OnBoardingView(
                items: items,
                onExit: onExit,
                onSkip: onSkip,
                onCompltete: onCompltete
            )
            .contentShape(.rect)
            .gesture (WindowDragGesture())
        }
        .windowStyle(.plain)
        .restorationBehavior (.disabled)
        .windowBackgroundDragBehavior(.enabled)
    }
}

struct OnBoardingView: View {
    var items: [OnboardingItem]
    var onExit: () -> ()
    var onSkip: () -> ()
    var onCompltete: () -> ()
    var body: some View {
        VStack {
            Rectangle()
                .overlay {
                    ZStack {
//                        concentricShape
//                            .fill(.black)
                        BezelDesing()
                    }
                }
                .containerShape(.rect(cornerRadius: 5))
                .aspectRatio(screenRatio, contentMode: .fit)
                .frame(height: 290)
                .padding(.top, 10)
        }
        .padding(.vertical, 30)
        .frame(width: 600)
        .clipShape(.rect(cornerRadius: 30))
        .background {
            
        }
    }
    
    @ViewBuilder
    func BezelDesing() -> some View {
        ZStack(alignment: .top) {
            concentricShape
                .stroke(macbookTInt, lineWidth: 3)
            concentricShape
                .stroke(macbookTInt, lineWidth: 3)
            concentricShape
                .stroke(macbookTInt, lineWidth: 3)
            
            bottomOnlyCornerRadiusShape(3)
                .fill(.black)
                .frame(width: 50, height: 8)
                .offset(y: 3.5)
            
            bottomOnlyCornerRadiusShape(5)
                .fill(macbookTInt)
                .overlay(alignment: .top, content: {
                    bottomOnlyCornerRadiusShape(2)
                        .fill(.black.opacity(0.3))
                        .frame(width: 180, height: 3)
                })
                .frame(height: 10)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, -35)
                .offset(y: 9)
        }
    }
    
    var screenRatio: CGFloat {
        return 1.547
    }
    
    var macbookTInt: Color {
        return Color(red: 0.75,green: 0.75,blue: 0.78)
    }
    
    func bottomOnlyCornerRadiusShape(_ radius: CGFloat) -> AnyShape {
        return .init(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: radius,
                bottomTrailingRadius: radius,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
    }
    
    let concentricShape = ConcentricRectangle(
        topLeadingCorner: .concentric,
        topTrailingCorner: .concentric,
        bottomLeadingCorner: .fixed(0),
        bottomTrailingCorner: .fixed(0)
    )
}


#Preview {
    OnBoardingView(items: onBoardingItems) {
        
    } onSkip: {
        
    } onCompltete: {
        
    }

}
