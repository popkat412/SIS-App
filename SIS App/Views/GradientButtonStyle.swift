//
//  GradientButtonStyle.swift
//  SIS App
//
//  Created by Wang Yunze on 24/11/20.
//

import Foundation
import SwiftUI

struct GradientButtonStyle: ButtonStyle {
    var gradient: Gradient

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .conditionalModifier(configuration.isPressed) {
                        $0
                            .overlay(Color(.sRGB, white: 1, opacity: 0.5))
                    }
            )
            .cornerRadius(8)
    }
}

struct GradientButtonStyle_Preview: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("Button")
        }
        .buttonStyle(GradientButtonStyle(gradient: Constants.blueGradient))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
