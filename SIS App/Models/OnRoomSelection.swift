//
//  OnRoomSelection.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import Foundation
import SwiftUI

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
