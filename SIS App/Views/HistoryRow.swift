//
//  HistoryRow.swift
//  SIS App
//
//  Created by Wang Yunze on 25/11/20.
//

import SwiftUI

struct HistoryRow: View {
    var session: CheckInSession
    var showTiming = true
    var showTarget = true

    @Binding var currentlySelectedSession: CheckInSession?

    var editable = false
    var onTargetPressed: (() -> Void)?
    var onCheckInDateUpdate: ((Date) -> Void)?
    var onCheckOutDateUpdate: ((Date) -> Void)?

    @State private var checkInDate: Date
    @State private var checkOutDate: Date

    init(session: CheckInSession, showTiming: Bool = true, showTarget: Bool = true) {
        self.session = session
        self.showTiming = showTiming
        self.showTarget = showTarget

        _checkInDate = .init(initialValue: self.session.checkedIn)
        _checkOutDate = .init(initialValue: self.session.checkedOut!) // Force unwrapping because if this is to appear in history, they must have already checked out
        _currentlySelectedSession = .constant(nil)

        editable = false
        onTargetPressed = nil
        onCheckInDateUpdate = nil
        onCheckOutDateUpdate = nil
    }

    init(
        session: CheckInSession, showTiming: Bool = true, showTarget: Bool = true,
        editable: Bool,
        currentlySelectedSession: Binding<CheckInSession?>? = nil,
        onTargetPressed: @escaping (() -> Void),
        onCheckInDateUpdate: @escaping ((Date) -> Void),
        onCheckOutDateUpdate: @escaping ((Date) -> Void)
    ) {
        self.init(session: session, showTiming: showTiming, showTarget: showTarget)

        if editable {
            self.editable = true
            _currentlySelectedSession = currentlySelectedSession ?? .constant(nil)
            self.onTargetPressed = onTargetPressed
            self.onCheckInDateUpdate = onCheckInDateUpdate
            self.onCheckOutDateUpdate = onCheckOutDateUpdate
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if showTiming {
                if editable {
                    HStack {
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
                            currentlySelectedSession = session
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
                            currentlySelectedSession = session
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
                    currentlySelectedSession = session
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

struct HistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRow(session: CheckInSession(
            checkedIn: Date(), target: Block("Test")
        ))
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
