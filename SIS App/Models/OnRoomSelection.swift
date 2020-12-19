//
//  OnRoomSelection.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import Foundation
import SwiftUI

/// This exists as the simplest solution I could think of to easily pass data done multiple child views
/// Without the need to keep passing it down one by one as parameters.
/// I could instead just set the environment and read from the environemnt from anywhere below that view in the hierachy
struct OnTargetSelectionKey: EnvironmentKey {
    static var defaultValue: OnTargetSelection = { target in
        print("default check into \(target)")
    }
}

extension EnvironmentValues {
    var onTargetSelection: OnTargetSelection {
        get { self[OnTargetSelectionKey.self] }
        set { self[OnTargetSelectionKey.self] = newValue }
    }
}
