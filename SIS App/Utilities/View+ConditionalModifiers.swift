//
//  View+ConditionalModifiers.swift
//  SIS App
//
//  Created by Wang Yunze on 17/11/20.
//
// Stolen from https://medium.com/better-programming/conditionally-applying-view-modifiers-in-swiftui-c5541711eb41

import Foundation
import SwiftUI

extension View {
  @ViewBuilder func conditionalModifier<Content: View>(
    _ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
