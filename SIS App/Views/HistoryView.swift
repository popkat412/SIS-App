//
//  HistoryView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var checkInManager: CheckInManager

    @State private var showingEditRoomScreen = false
    
    var body: some View {
        return NavigationView {
            List {
                ForEach(checkInManager.getCheckInSessions()) { day in
                    Section(header: Text("\(day.formattedDate)")) {
                        ForEach(day.sessions) { session in
                            HistoryRow(
                                session: session,
                                editable: true,
                                onTargetPressed: {
                                    showingEditRoomScreen = true
                                },
                                onCheckInDateUpdate: { newCheckInDate in
                                    checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: session.newSessionWith(checkedIn: newCheckInDate)
                                    )
                                },
                                onCheckOutDateUpdate: { newCheckOutDate in
                                    checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: session.newSessionWith(checkedOut: newCheckOutDate)
                                    )
                                }
                            )
                            .popover(isPresented: $showingEditRoomScreen) {
                                ChooseRoomView(onRoomSelection: { room in
                                    showingEditRoomScreen = false

                                    var newSession = session
                                    newSession.target = room
                                    checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: newSession
                                    )
                                }, onBackButtonPressed: {
                                    showingEditRoomScreen = false
                                })
                            }
                        }
                        .onDelete { offsets in
                            // TODO: Test if this actually works
                            // Need to wait until checkInManager and CoreData is implemented
                            for index in offsets {
                                checkInManager.deleteCheckInSession(id: day.sessions[index].id)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetListStyle()) // Must set this, if not addign the EditButton() ruins how the list looks
            .navigationBarTitle("History")
            .navigationBarItems(trailing: EditButton())
        }
      
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(CheckInManager())
    }
}


struct HistoryRowItem: View {
    var iconName: String
    var text: String
    var font: Font = .body
    
    var body: some View {
        HStack {
            Image(iconName)
                .resizable()
                .frame(width: 25, height: 25)
            
            Text(text)
                .font(font)
                .multilineTextAlignment(.leading)
        }
    }
}

struct HistoryRow: View {
    var session: CheckInSession
    var showTiming = true
    var showTarget = true
    
    var editable = false
    var onTargetPressed: (() -> ())? = nil
    var onCheckInDateUpdate: ((Date) -> ())? = nil
    var onCheckOutDateUpdate: ((Date) -> ())? = nil
    
    @State private var checkInDate: Date
    @State private var checkOutDate: Date
    
    init(session: CheckInSession, showTiming: Bool = true, showTarget: Bool = true) {
        self.session = session
        self.showTiming = showTiming
        self.showTarget = showTarget
        
        self._checkInDate = .init(initialValue: self.session.checkedIn)
        self._checkOutDate = .init(initialValue: self.session.checkedOut!)
            // Force unwrapping because if this is to appear in history, they must have already checked out
        
        self.editable = false
        self.onTargetPressed = nil
        self.onCheckInDateUpdate = nil
        self.onCheckOutDateUpdate = nil
    }
    
    init(
        session: CheckInSession, showTiming: Bool = true, showTarget: Bool = true,
        editable: Bool,
        onTargetPressed: @escaping (() -> ()),
        onCheckInDateUpdate: @escaping ((Date) -> ()),
        onCheckOutDateUpdate: @escaping ((Date) -> ())
    ) {
        self.init(session: session, showTiming: showTiming, showTarget: showTarget)
        
        if editable {
            self.editable = true
            self.onTargetPressed = onTargetPressed
            self.onCheckInDateUpdate = onCheckInDateUpdate
            self.onCheckOutDateUpdate = onCheckOutDateUpdate
        }
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            if showTiming {
                if editable {
                    HStack() {
                        Image("time")
                            .resizable()
                            .frame(width: 25, height: 25)
                        
                        DatePicker(
                            selection: $checkInDate,
                            displayedComponents: [.hourAndMinute],
                            label: { EmptyView() }
                        )
                        .labelsHidden()
                        Text("-")
                        DatePicker(
                            selection: $checkOutDate,
                            displayedComponents: [.hourAndMinute],
                            label: { EmptyView() }
                        )
                        .labelsHidden()
                    }
                } else {
                    HistoryRowItem(
                        iconName: "time",
                        text: session.formattedTiming,
                        font: .system(size: 20)
                    )
                }
            }
            
            if showTarget {
                HStack {
                    if let roomTarget = session.target as? Room {
                        HistoryRowItem(
                            iconName: "block",
                            text: RoomParentInfo.getParent(of: roomTarget)
                        )
                        HistoryRowItem(
                            iconName: "room",
                            text: session.target.name
                        )
                    } else if let blockTarget = session.target as? Block {
                        HistoryRowItem(iconName: "block", text: blockTarget.name)
                    }
                }
                .onTapGesture {
                    onTargetPressed?()
                }
                .conditionalModifier(editable) {
                    $0
                        .foregroundColor(.blue)
                        .padding(7)
                        .background(Color(white: 0.95))
                        .cornerRadius(7)
                }
            }
        }
    }
}
