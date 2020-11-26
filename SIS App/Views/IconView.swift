//
//  IconView.swift
//  SIS App
//
//  Created by Wang Yunze on 25/11/20.
//

import SwiftUI

struct IconView: View {
    let iconName: String

    init(_ iconName: String) {
        self.iconName = iconName
    }

    var body: some View {
        Image(iconName)
            .resizable()
            .frame(width: 25, height: 25)
    }
}

struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        IconView("classroom")
    }
}
