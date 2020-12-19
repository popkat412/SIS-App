//
//  MyTextFieldStyle.swift
//  SIS App
//
//  Created by Wang Yunze on 3/12/20.
//

import Foundation
import SwiftUI
import SwiftUIX

struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(.horizontal)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(white: 0.7), lineWidth: 2)
            )
    }
}
