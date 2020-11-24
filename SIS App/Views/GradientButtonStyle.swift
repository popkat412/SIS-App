//
//  GradientButtonStyle.swift
//  SIS App
//
//  Created by Wang Yunze on 24/11/20.
//

import Foundation
import SwiftUI

struct GradientButtonStyle: ButtonStyle  {
    var gradient: Gradient
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(8)
    }
}
