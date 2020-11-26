//
//  OnRoomSelection.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import Foundation
import SwiftUI

struct OnRoomSelectionKey: EnvironmentKey {
    static var defaultValue: (Room) -> Void = { room in
        print("default check into \(room)")
    }
}

extension EnvironmentValues {
    var onRoomSelection: (Room) -> Void {
        get { self[OnRoomSelectionKey.self] }
        set { self[OnRoomSelectionKey.self] = newValue }
    }
}
