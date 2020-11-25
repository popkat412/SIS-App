//
//  CheckedInView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI

struct CheckedInView: View {
    @EnvironmentObject var checkInManager: CheckInManager

    let checkedInGradient = Gradient(colors: [
        Color(red: 35 / 225, green: 122 / 225, blue: 87 / 225),
        Color(red: 9 / 225, green: 48 / 225, blue: 40 / 225),
    ])
    let checkedOutGradient = Gradient(colors: [
        Color(red: 67 / 255, green: 198 / 255, blue: 172 / 255),
        Color(red: 25 / 255, green: 22 / 255, blue: 84 / 255),
    ])

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: checkInManager.isCheckedIn ? "square.and.arrow.down" : "square.and.arrow.up")
                .font(.system(size: 100))
                .foregroundColor(checkInManager.isCheckedIn ? .green : .blue)
                .padding(.bottom, 10)
                .padding(.top, 20)
            Text(checkInManager.isCheckedIn ? "Checked In!" : "Checked Out!")
                .font(.title)
                .padding(.bottom, 20)

            Text(checkInManager.isCheckedIn ?
                "You checked into \(checkInManager.currentSession?.target.name ?? "") at \(checkInManager.currentSession?.checkedIn.formattedTime ?? "")" :
                "You checked out of \(checkInManager.currentSession?.target.name ?? "") at \(Date().formattedTime)"
            )
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding()

            Spacer()
            Button(action: {
                if !checkInManager.isCheckedIn {
                    checkInManager.showCheckedInScreen = false
                } else {
                    checkInManager.checkOut(shouldUpdateUI: false)
                }
            }, label: {
                Text(checkInManager.isCheckedIn ? "Check Out" : "Back to Home")
                    .foregroundColor(.white)
            })
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(LinearGradient(gradient: checkInManager.isCheckedIn ? checkedInGradient : checkedOutGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
    }
}

struct CheckedInView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CheckedInView()
                .environmentObject(CheckInManager())
        }
    }
}
