//
//  EditSessionView.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import SwiftUI

struct EditSessionView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    
    @State var session: CheckInSession
    @State private var showingRoomPicker = false
    
    @Binding var showingEditSession: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button("Back") {
                    showingEditSession = false
                }
                Spacer()
                Text("Editing \(session.target.name)")
                Spacer()
                Button("Save") {
                    checkInManager.updateCheckInSession(session)
                    showingEditSession = false
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .edgesIgnoringSafeArea(.all)
            .padding()
            .background(Color(white: 0.9))
            Spacer()
            VStack {
                Button(action: {
                    showingRoomPicker = true
                }, label: {
                    ZStack {
                        Color(white: 0.9)
                        HistoryRow(session: session, showTiming: false)
                            .padding()
                    }
                    .frame(height: 60)
                    .border(Color.black)
                })
                
                Spacer()
                    .frame(height: 50)
                DatePicker("Checked In:", selection: $session.checkedIn)
                DatePicker("Checked Out:", selection: Binding($session.checkedOut)!)
            }
            .padding()
            Spacer()
        }
        .navigationBarTitle("Editing \(session.target.name)", displayMode: .inline)
        .sheet(isPresented: $showingRoomPicker) {
            ChooseRoomView {
                showingRoomPicker = false
            }
                .environment(\.onRoomSelection) { room in
                    print("on room selection from edit session view: \(room)")
                    self.showingRoomPicker = false
                    self.session.target = room
                }
        }
    }
}

struct EditSessionView_Previews: PreviewProvider {
    static var checkInManager = CheckInManager()
    static var previews: some View {
        EditSessionView(
            session: checkInManager.getCheckInSessions()[0].sessions[0],
            showingEditSession: .constant(true)
        )
        .environmentObject(checkInManager)
    }
}
