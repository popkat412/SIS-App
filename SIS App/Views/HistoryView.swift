//
//  HistoryView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import FirebaseFirestore
import LocalAuthentication
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    @EnvironmentObject var userAuthManager: UserAuthManager

    @AppStorage(Constants.kDidAuthHistoryView, store: UserDefaults(suiteName: Constants.appGroupIdentifier)) var isAuthenticated: Bool = false

    @State private var showingEditRoomScreen = false
    @State private var currentlySelectedSession: CheckInSession? = nil

    @State private var alertItem: AlertItem?
    @State private var showingEnterPasswordAlert: Bool = false
    @State private var showingActivityIndicator: Bool = false

    var body: some View {
        VStack {
            if isAuthenticated {
                NavigationView {
                    ZStack {
                        List {
                            ForEach(checkInManager.getCheckInSessions()) { day in
                                Section(header: Text("\(day.formattedDate)")) {
                                    ForEach(day.sessions) { session in
                                        HistoryRow(
                                            session: session,
                                            editable: true,
                                            currentlySelectedSession: $currentlySelectedSession,
                                            onTargetPressed: {
                                                showingEditRoomScreen = true
                                            },
                                            onCheckInDateUpdate: onCheckInDateUpdate,
                                            onCheckOutDateUpdate: onCheckOutDateUpdate
                                        )
                                        .sheet(isPresented: $showingEditRoomScreen) {
                                            ChooseRoomView(onRoomSelection: { target in
                                                showingEditRoomScreen = false
                                                guard let currentlySelectedSession = currentlySelectedSession else { return }
                                                print("🗂 saving session: \(session)")
                                                checkInManager.updateCheckInSession(
                                                    id: currentlySelectedSession.id,
                                                    newSession: currentlySelectedSession.newSessionWith(target: target)
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
                        if showingActivityIndicator {
                            MyActivityIndicator()
                                .frame(width: Constants.activityIndicatorSize, height: Constants.activityIndicatorSize)
                        }
                    }
                    .listStyle(InsetListStyle()) // Must set this, if not adding the EditButton() ruins how the list looks
                    .navigationBarTitle("History")
                    .navigationBarItems(trailing: EditButton())
                    .alert(item: $alertItem, content: alertItemBuilder)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
//                            Button(action: {}) {
//                                HStack {
//                                    Text("Add")
//                                    Image(systemName: "plus")
//                                }
//                            }
                            Button(action: {
                                showTextFieldAlert(
                                    TextAlert(
                                        title: "Please enter the password",
                                        message: "You will have been given a one time password by the school",
                                        placeholder: "",
                                        isPassword: true, accept: "Ok", cancel: "Cancel",
                                        action: userEnteredOTP
                                    )
                                )
                            }) {
                                HStack {
                                    Text("Upload")
                                    Image(systemName: "square.and.arrow.up.on.square")
                                }
                            }
                        }
                    }
                }
                //                .alert(
                //                    isPresented: $showingEnterPasswordAlert,
                //                    TextAlert(
                //                        title: "Please enter the password",
                //                        message: "You will have been given a one time password by the school",
                //                        placeholder: "",
                //                        isPassword: true, accept: "Ok", cancel: "Cancel"
                //                    ) { result in
                //                        showingActivityIndicator = true
                //                        guard let result = result else { return }
                //                        checkOTP(password: result) { succeded, error in
                //                            if let error = error {
                //                                showingActivityIndicator = false
                //                                alertItem = MyErrorInfo(error).toAlertItem()
                //                                return
                //                            }
                //
                //                            if succeded {
                //                                uploadData { error in
                //                                    showingActivityIndicator = false
                //                                    if let error = error {
                //                                        alertItem = MyErrorInfo(error).toAlertItem()
                //                                        return
                //                                    }
                //
                //                                    alertItem = AlertItem(
                //                                        title: "Success!",
                //                                        message: "Your data has been successfully uploaded"
                //                                    )
                //                                }
                //                            } else {
                //                                showingActivityIndicator = false
                //                                alertItem = AlertItem(
                //                                    title: "Oops",
                //                                    message: "The password you entered is incorrect."
                //                                )
                //                            }
                //                        }
                //                    }
                //                )
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                Text("Not authenticated")
                Button("Try again", action: authenticate)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didSwitchToHistoryView)) { _ in
            print("🧑‍💻 switched to history view")
            if !isAuthenticated {
                authenticate()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            isAuthenticated = false
        }
    }

    // MARK: Helper functions

    /// Completion takes 2 arguments, `result` and `error`.
    /// `result` will be true if the password if correct, and all else false.
    /// `error` will only not be nil if there was a problem verifying the password.
    /// Note that `result` can be false even though error is `nil`, because the user might have entered the wrong password
    private func checkOTP(password: String, completion: @escaping (Bool, Error?) -> Void) {
        Firestore.firestore().collection(Constants.OTPCollection).whereField(Constants.isUsedDocumentField, isEqualTo: false).whereField(Constants.OTPDocumentField, isEqualTo: password).getDocuments { snapshot, error in

            if let error = error {
                completion(false, error)
                return
            }

            if let snapshot = snapshot {
                if snapshot.isEmpty { // OTP doesn't exisist
                    completion(false, nil)
                } else if snapshot.count > 1 { // multiple of the same OTPs exist, is a bug
                    completion(false, "Multiple of the same OTPs exists, this is a bug, please contact the deveolpers")
                } else { // everything good
                    // Mark OTP as completed
                    Firestore.firestore()
                        .collection(Constants.OTPCollection)
                        .document(snapshot.documents.first!.documentID)
                        .updateData(
                            [
                                Constants.isUsedDocumentField: true,
                                Constants.OTPDateUsedDocumentField: Timestamp(),
                            ]
                        ) { error in
                            if let error = error {
                                completion(false, error)
                            } else {
                                completion(true, nil)
                            }
                        }
                }
            }
        }
    }

    /// Uploads data to firebase
    private func uploadData(completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let batch = db.batch()

        let reference = db.collection(Constants.uploadedHistoryCollection).addDocument(data: [
            "dateAdded": Timestamp(),
            "userId": userAuthManager.user?.uid as Any,
        ])

        for checkInSession in checkInManager.checkInSessions {
            batch.setData(
                checkInSession.toFirebaseDictionary(),
                forDocument: reference
                    .collection(Constants.historyCollectionForEachDocument)
                    .document()
            )
        }

        batch.commit(completion: completion)
    }

    private func onCheckInDateUpdate(_ newCheckInDate: Date, _: Date) -> SessionInvalidError? {
        guard let currentlySelectedSession = currentlySelectedSession else { return nil }

        print("🗂 new check in date: \(newCheckInDate)")
        return checkInManager.updateCheckInSession(
            id: currentlySelectedSession.id,
            newSession: currentlySelectedSession.newSessionWith(checkedIn: newCheckInDate)
        )
    }

    private func onCheckOutDateUpdate(_ newCheckOutDate: Date, _: Date) -> SessionInvalidError? {
        guard let currentlySelectedSession = currentlySelectedSession else { return nil }

        print("🗂 new check out date: \(newCheckOutDate)")
        return checkInManager.updateCheckInSession(
            id: currentlySelectedSession.id,
            newSession: currentlySelectedSession.newSessionWith(checkedOut: newCheckOutDate)
        )
    }

    private func userEnteredOTP(_ result: String?) {
        showingActivityIndicator = true
        guard let result = result else { return }
        checkOTP(password: result) { succeded, error in
            if let error = error {
                showingActivityIndicator = false
                alertItem = MyErrorInfo(error).toAlertItem()
                return
            }

            if succeded {
                uploadData { error in
                    showingActivityIndicator = false
                    if let error = error {
                        alertItem = MyErrorInfo(error).toAlertItem()
                        return
                    }

                    alertItem = AlertItem(
                        title: "Success!",
                        message: "Your data has been successfully uploaded"
                    )
                }
            } else {
                showingActivityIndicator = false
                alertItem = AlertItem(
                    title: "Oops",
                    message: "The password you entered is incorrect."
                )
            }
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "To unlock your location history") { success, error in
                print("🧑‍💻 LA result: \(success)")
                DispatchQueue.main.async {
                    isAuthenticated = success
                }

                if let error = error { print("🧑‍💻 LA error: \(error)") }
            }
        } else {
            print("🧑‍💻 device doesn't support LA: \(String(describing: error))")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(CheckInManager())
    }
}
