//
//  NavigationState.swift
//  SIS App
//
//  Created by Wang Yunze on 25/11/20.
//

import Foundation

class NavigationState: ObservableObject {
    @Published var tabbarSelection: Tab = .home
}

enum Tab: Hashable {
    case home, history
}
