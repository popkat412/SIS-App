//
//  NavigationState.swift
//  SIS App
//
//  Created by Wang Yunze on 25/11/20.
//

import Foundation

/// This is so we can programtically navigate to places.
/// Most of it is from AppDelegate or SceneDelegate when receiving
/// deeplinks from widgets or notification taps
class NavigationState: ObservableObject {
    /// The currently on tabbar tab
    @Published var tabbarSelection: Tab = .home {
        /// This here is needed because I couldn't get `onAppear` to work on HistoryView
        didSet {
            if tabbarSelection == .history {
                NotificationCenter.default.post(name: .didSwitchToHistoryView, object: nil)
            }
        }
    }
}

/// The tabbar tabs. In TabView, we need to remember to set the tag to this.
enum Tab: Hashable {
    case home, history
}
