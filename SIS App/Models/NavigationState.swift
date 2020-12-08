//
//  NavigationState.swift
//  SIS App
//
//  Created by Wang Yunze on 25/11/20.
//

import Foundation

class NavigationState: ObservableObject {
    @Published var tabbarSelection: Tab = .home
    @Published var shouldShowSafariView: Bool = false
}

enum Tab: Hashable {
    case home, history
}
