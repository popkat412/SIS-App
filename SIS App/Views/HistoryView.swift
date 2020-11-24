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
                                    print("new check in date: \(newCheckInDate)")
                                    checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: session.newSessionWith(checkedIn: newCheckInDate)
                                    )
                                },
                                onCheckOutDateUpdate: { newCheckOutDate in
                                    print("new check out date: \(newCheckOutDate)")
                                    checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: session.newSessionWith(checkedOut: newCheckOutDate)
                                    )
                                }
                            )
                            .popover(isPresented: $showingEditRoomScreen) {
                                ChooseRoomView(onRoomSelection: { room in
                                    showingEditRoomScreen = false

                                    checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: session.newSessionWith(target: room)
                                    )
                                }, onBackButtonPressed: {
                                    showingEditRoomScreen = false
                                })
                            }
                        }
                        .onDelete { offsets in
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
                            "Check In Time",
                            selection: $checkInDate,
                            in: PartialRangeThrough(checkOutDate),
                            displayedComponents: [.hourAndMinute]
                        )
                        .labelsHidden()
                        .onChange(of: checkInDate) { newValue in
                            onCheckInDateUpdate?(newValue)
                        }
                        DatePicker(
                            "Check Out Time",
                            selection: $checkOutDate,
                            in: PartialRangeFrom(checkInDate),
                            displayedComponents: [.hourAndMinute]
                        )
                        .labelsHidden()
                        .onChange(of: checkOutDate) { newValue in
                            onCheckOutDateUpdate?(newValue)
                        }
                        
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
