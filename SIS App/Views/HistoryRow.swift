//
//  HistoryRow.swift
//  SIS App
//
//  Created by Wang Yunze on 25/11/20.
//

import SwiftUI

private let ICON_SIZE: CGFloat = 25

struct HistoryRow: View {
    /// This will be called whenever the date is updated
    /// The first argument is the new date, and the second argument is the old date
    /// The return value will determine if the date is actually updated or not
    /// If the return is true, the date will be updated to the new date
    /// If not, it will remain at the old date
    typealias DateUpdateCallback = (Date, Date) -> SessionInvalidError?

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var session: CheckInSession
    var showTiming = true
    var showTarget = true

    @Binding var currentlySelectedSession: CheckInSession?

    var editable = false
    var onTargetPressed: (() -> Void)?
    var onCheckInDateUpdate: DateUpdateCallback?
    var onCheckOutDateUpdate: DateUpdateCallback?

    @State private var checkInDate: Date
    @State private var checkOutDate: Date
    @State private var previousCheckInDate: Date?
    @State private var previousCheckOutDate: Date?

    @State private var showingErrorAlert: Bool
    @State private var currentError: SessionInvalidError?

    init(session: CheckInSession, showTiming: Bool = true, showTarget: Bool = true) {
        self.session = session
        self.showTiming = showTiming
        self.showTarget = showTarget

        _checkInDate = .init(initialValue: self.session.checkedIn)
        _checkOutDate = .init(initialValue: self.session.checkedOut!)
        // Force unwrapping because if this is to appear in history, they must have already checked out
        _previousCheckInDate = .init(initialValue: nil)
        _previousCheckOutDate = .init(initialValue: nil)

        _showingErrorAlert = .init(initialValue: false)
        _currentError = .init(initialValue: nil)

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
        onCheckInDateUpdate: @escaping DateUpdateCallback,
        onCheckOutDateUpdate: @escaping DateUpdateCallback
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
        HStack(spacing: 20) {
            if showTarget {
                Image({ () -> String in
                    if let roomTarget = session.target as? Room {
                        return roomTarget.iconName

                    } else if session.target is Block {
                        return "block"
                    }

                    return ""
                }())
                    .resizable()
                    .frame(width: ICON_SIZE * 2, height: ICON_SIZE * 2)
            }
            VStack(alignment: .leading) {
                if showTarget {
                    HStack {
                        if let roomTarget = session.target as? Room {
                            HistoryRowItem(
                                iconName: nil,
                                text: RoomParentInfo.getParent(of: roomTarget)
                            )
                            Text("-")
                            HistoryRowItem(
                                iconName: nil,
                                text: session.target.name
                            )
                        } else if let blockTarget = session.target as? Block {
                            HistoryRowItem(iconName: nil, text: blockTarget.name)
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
                            .background(colorScheme == .light ? Color(white: 0.95) : Color(white: 0.1))
                            .cornerRadius(7)
                    }
                }

                if showTiming {
                    if editable {
                        HStack {
                            Image("time")
                                .resizable()
                                .frame(width: 25, height: 25)

                            DatePicker(
                                "Check In Time",
                                selection: $checkInDate,
                                displayedComponents: [.hourAndMinute]
                            )
                            .labelsHidden()
                            .onChange(of: checkInDate) { [checkInDate] newValue in
                                currentlySelectedSession = session
                                if let error = onCheckInDateUpdate?(newValue, checkInDate) {
                                    self.checkInDate = checkInDate
                                    // FIXME: Alert not showing up
                                    self.currentError = error
                                    self.showingErrorAlert = true
                                    print("🤔 showingErrorAlert: \(self.showingErrorAlert), currentError: \(String(describing: currentError))")
                                    print("🤔 error: \(error.rawValue)")
                                }
                            }
                            HStack(spacing: 0) {
                                Circle()
                                    .fill(Constants.blueGradient.stops[0].color)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 1)
                                Rectangle()
                                    .fill(LinearGradient(gradient: Constants.blueGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 50, height: 5)
                                Circle()
                                    .stroke(Constants.blueGradient.stops[0].color)
                                    .frame(width: 10, height: 10)
                                    .offset(x: -1)
                            }
                            DatePicker(
                                "Check Out Time",
                                selection: $checkOutDate,
                                displayedComponents: [.hourAndMinute]
                            )
                            .labelsHidden()
                            .onChange(of: checkOutDate) { [checkOutDate] newValue in
                                currentlySelectedSession = session
                                if let error = onCheckOutDateUpdate?(newValue, checkOutDate) {
                                    self.checkOutDate = checkOutDate
                                    // FIXME: Alert not showing up
                                    self.currentError = error
                                    self.showingErrorAlert = true
                                    print("🤔 showingErrorAlert: \(self.showingErrorAlert), currentError: \(String(describing: currentError))")
                                    print("🤔 error: \(error.rawValue)")
                                }
                            }
                            .alert(isPresented: $showingErrorAlert) {
                                Alert(
                                    title: Text("Whoops!"),
                                    message: Text(currentError?.rawValue ?? "An unknown error occurred"),
                                    dismissButton: .default(Text("Ok"))
                                )
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
    var iconName: String?
    var text: String
    var font: Font = .body

    var body: some View {
        HStack {
            if let iconName = iconName {
                Image(iconName)
                    .resizable()
                    .frame(width: ICON_SIZE, height: ICON_SIZE)
            }

            Text(text)
                .font(font)
                .multilineTextAlignment(.leading)
        }
    }
}
