//
//  ActivityIndicator.swift
//  SIS App
//
//  Created by Wang Yunze on 2/12/20.
//

import SwiftUI

struct MyActivityIndicator: View {
    let style = StrokeStyle(lineWidth: 6, lineCap: .round)
    let color1 = Color.gray
    let color2 = Color.gray.opacity(0.5)

    @State var animate = false

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(gradient: .init(colors: [color1, color2]), center: .center),
                    style: style
                )
                .rotationEffect(Angle(degrees: animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
        }
        .onAppear {
            animate.toggle()
        }
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        MyActivityIndicator()
            .frame(width: 60, height: 60)
    }
}
