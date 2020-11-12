//
//  CheckedInView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI

struct CheckedInView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    @State var clickedCheckOutButton = false
    @State var checkOutTime: Date?
    
    let checkedInGradient = Gradient(colors: [
        Color(red: 35/225, green: 122/225, blue: 87/225),
        Color(red: 9/225, green: 48/225, blue: 40/225)
    ])
    let checkedOutGradient = Gradient(colors: [
        Color(red: 67/255, green: 198/255, blue: 172/255),
        Color(red: 25/255, green: 22/255, blue: 84/255)
    ])
    
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: clickedCheckOutButton ? "square.and.arrow.up" : "square.and.arrow.down")
                .font(.system(size: 100))
                .foregroundColor(clickedCheckOutButton ? .blue : .green)
                .padding(.bottom, 10)
                .padding(.top, 20)
            Text(clickedCheckOutButton ? "Checked Out!" : "Checked In!")
                .font(.title)
                .padding(.bottom, 20)
            
            Text(clickedCheckOutButton ?
                    "You checked out of \(checkInManager.currentSession?.target.name ?? "") at \(checkOutTime!.formattedTime)" :
                    "You checked into \(checkInManager.currentSession?.target.name ?? "") at \(checkInManager.currentSession?.checkedIn.formattedTime ?? "")"
            )
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            
            Spacer()
            Button(action: {
                if clickedCheckOutButton {
                    checkInManager.checkOut()
                } else {
                    clickedCheckOutButton = true
                    checkOutTime = Date()
                }
            }, label: {
                Text(clickedCheckOutButton ? "Back to Home" : "Check Out")
                    .foregroundColor(.white)
            })
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(LinearGradient(gradient: clickedCheckOutButton ? checkedOutGradient :  checkedInGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
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
