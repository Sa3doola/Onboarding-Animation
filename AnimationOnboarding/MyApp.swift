import SwiftUI


let onBoardingItems: [OnboardingItem] = [
    .init(
        id: 0,
        title: "Welcome to macOs 26",
        subtitle: "Introducing to new design with liquid glass",
        screenShot: ""
    ),
    .init(
        id: 1,
        title: "New Menu Bar",
        subtitle: "Introducing to new design with liquid glass",
        screenShot: "",
        zoomScale: 1.8,
        zoomAnchor: .init(x: 1, y: -0.1)
    ),
    .init(
        id: 2,
        title: "Personalized Home Screen",
        subtitle: "Make your Mac truly yours by\nadding and arranging widgets.",
        screenShot: "",
        zoomScale: 1.8,
        zoomAnchor: .init(x: 0, y: -0.1)
    ),
    .init(
        id: 3,
        title: "All New Spotlight Search",
        subtitle: "FInd what you need instantly with\npowerful, intuitive search tools.",
        screenShot: "",
        zoomScale: 1.6,
        zoomAnchor: .init(x: 0.5, y: 1.1)
    ),
    .init(
        id: 4,
        title: "Customize Menu Bar Controls",
        subtitle: "Arrange and tweak controls\nfor a menu bar that adapts to you.",
        screenShot: "NSImag",
        zoomScale: 1,
        zoomAnchor: .init(x: 0.5, y: 0.5)
    )
]

@main struct MyApp: App {
    
    
    var body: some Scene {
        OnBoardingWindow(items: onBoardingItems) {
            
        } onSkip: {
            print("onSkip")
        } onCompltete: {
            print("onCompelete")
        }

    }
}


