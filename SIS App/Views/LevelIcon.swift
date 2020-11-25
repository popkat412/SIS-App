//
//  LevelIcon.swift
//  SIS App
//
//  Created by Wang Yunze on 10/11/20.
//

import SwiftUI

struct LevelIcon: View {
    var level: Int  
    
    var body: some View {
        let levelColor = LevelColors.getColor(for: level)
        ZStack {
            Circle()
                .fill(levelColor.background)
            Text("L\(level)")
                .foregroundColor(levelColor.text)
        }
        .frame(width: 30, height: 30, alignment: .center)
    }
}

struct LevelIcon_Previews: PreviewProvider {
    static var previews: some View {
        LevelIcon(level: 1)
    }
}
