//
//  CheckedInView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI

struct CheckedInView: View {
    @EnvironmentObject var checkInManager: CheckInManager

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

            Text(checkInManager.isCheckedIn
                ? "You checked into \(checkInManager.currentSession?.target.name ?? "") at \(checkInManager.currentSession?.checkedIn.formattedTime ?? "")"
                // TODO: This doesn't work becuase currentSession will be nil
                : "You checked out of \(checkInManager.currentSession?.target.name ?? "") at \(Date().formattedTime)")
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
                .buttonStyle(
                    GradientButtonStyle(
                        gradient: checkInManager.isCheckedIn
                            ? Constants.checkedInGradient
                            : Constants.checkedOutGradient
                    )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
    }
}

struct CheckedInView_Previews: PreviewProvider {
    static var previews: some View {
        let checkInManager = CheckInManager()
        checkInManager.checkIn(to: Block("Test"))

        return Group {
            CheckedInView()
                .environmentObject(checkInManager)
        }
    }
}
