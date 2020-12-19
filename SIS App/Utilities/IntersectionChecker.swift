//
//  IntersectionChecker.swift
//  SIS App
//
//  Created by Wang Yunze on 29/11/20.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

struct IntersectionChecker {
    private static var db: Firestore!

    /// This is to avoid duplicate checking
    private static var processedDocumentIds: [String] {
        get {
            UserDefaults(suiteName: Constants.appGroupIdentifier)?.array(forKey: Constants.kProcessedDocumentIds) as? [String] ?? []
        }
        set {
            UserDefaults(suiteName: Constants.appGroupIdentifier)!.setValue(newValue, forKey: Constants.kProcessedDocumentIds)
        }
    }

    /// Call this as soon as possible when the app starts to listen for updates
    static func `init`() {
        db = Firestore.firestore()
        db.collection(Constants.uploadedHistoryCollection).addSnapshotListener(snapshotListener)

        // testIntersection() // For testing only
    }

    /// Checks if two histories have intersected (i.e. same place, same time).
    /// The algorighm runs in O(n^2) time.
    /// Basically checks every session in B for ever session in A,
    /// and if they are same place with intersection,
    /// append that to the result
    static func checkIntersection(a: [CheckInSession], b: [CheckInSession]) -> [Intersection] {
        var intersections = [Intersection]()
        for sessionA in a {
            for sessionB in b {
                if isEssentiallySamePlace(a: sessionA.target, b: sessionB.target) {
                    if let intersection = sessionA.checkIntersection(with: sessionB) {
                        intersections.append(Intersection(dateInterval: intersection, target: sessionA.target.name))
                    }
                }
            }
        }

        return intersections
    }

    /// Checkes for intersections within a single array of CheckInSessions.
    /// This is to prevent user from editing history such that they check into 2 different places at the same time
    static func checkIntersection(sessions: [CheckInSession]) -> [DateInterval] {
        // 1. sort sessions by start date
        let sortedSessions = sessions.sorted { $0.checkedIn < $1.checkedIn }

        guard var previousEndTime = sessions.first?.checkedOut else { return [] }

        var results = [DateInterval]()

        for (idx, session) in sortedSessions.enumerated() {
            if idx == 0 { continue }

            // 2. For every session, check if the start date is more than previous end date
            // If its more, then ok, if it's less, there's an intersection
            if session.checkedIn < previousEndTime {
                // Force unwrapping here because unless my algo is wrong,
                // there should confirm be a intersection
                results.append(session.checkIntersection(with: sortedSessions[idx - 1])!)
            }

            guard let checkedOut = session.checkedOut else { return [] }
            previousEndTime = checkedOut
        }

        return results
    }

    /// This is called whenever there is a change in Firestore
    private static func snapshotListener(snapshot: QuerySnapshot?, error: Error?) {
        print("🔥 snapshot listener")

        if let error = error {
            print("🔥 error in snapshot listener: \(error)")
            return
        }

        if let snapshot = snapshot {
            for change in snapshot.documentChanges {
                print("🔥 processedDocumentIds: \(processedDocumentIds)")
                if processedDocumentIds.contains(change.document.documentID) { continue }
                processedDocumentIds.append(change.document.documentID)

                print("🔥 change: \(change.document.data())")
                if change.type == .added {
                    change.document.reference.collection(Constants.historyCollectionForEachDocument).getDocuments { sessionsSnapshot, error in

                        if let error = error {
                            print("🔥 error in history for newest document: \(error)")
                            return
                        }

                        print("🔥 sample document data: \(String(describing: sessionsSnapshot?.documents.first?.data()))")

                        // TODO: Change all this force unwrapping to prevent app from crashing in production
                        dealWithFirestoreData(
                            UserUploadedData(
                                userId: change.document["userId"] as! String,
                                dateAdded: (change.document["dateAdded"] as! Timestamp).dateValue(),
                                history: sessionsSnapshot?.documents.map {
                                    let data = $0.data()
                                    print("🔥 data: \(data)")
                                    return CheckInSession(
                                        checkedIn: (data["checkedIn"] as! Timestamp).dateValue(),
                                        checkedOut: (data["checkedOut"] as! Timestamp).dateValue(),
                                        target: DataProvider.getTarget(id: data["target"] as! String) ?? UnknownCheckInTarget(),
                                        id: UUID(uuidString: $0.documentID) ?? UUID()
                                    )
                                } ?? []
                            )
                        )
                    }
                }
            }
        }
    }

    // MARK: Helper functions

    /// This deals with the firestore data by checking if there is an intersection
    /// And if there is, send a email warning the user that they have come into contact
    private static func dealWithFirestoreData(_ data: UserUploadedData) {
        print("🔥 dealing with firestore data: \(data)")

        guard data.userId != Auth.auth().currentUser?.uid else { return }

        let intersection = checkIntersection(
            a: FileUtility.getDataFromJsonFile(filename: Constants.savedSessionsFilename, dataType: [CheckInSession].self) ?? [],
            b: data.history
        )
        print("🔥 intersection: \(intersection)")

        if !intersection.isEmpty {
            // Ono came into contact with infected person
            /*
             let fakeIntersections = [
                 Intersection(dateInterval: DateInterval(start: Date(), duration: 60), target: "Test Target 1"),
                 Intersection(dateInterval: DateInterval(start: Date()+61, end: Date()+61+60), target: "Test Target 2"
                 )
             ]*/
            EmailHelper.sendWarningEmail(data: intersection) { error in
                if let error = error {
                    print("🔥 error sending warning email: \(error)")
                    return
                }

                print("🔥 successfully sent warning email")
            }
        }
    }

    // TODO: Add this as function/operator on CheckInTarget
    /// Checks if the two CheckInTargets are essentially the same place.
    /// This is because some targets, like Rooms, are more specific than Blocks
    private static func isEssentiallySamePlace(a: CheckInTarget, b: CheckInTarget) -> Bool {
        if type(of: a) == type(of: b) {
            return a.id == b.id
        } else if a is Room, b is Block {
            return RoomParentInfo.getParent(of: a as! Room) == b.name
        } else if a is Block, b is Room {
            return RoomParentInfo.getParent(of: b as! Room) == a.name
        }

        return false
    }

    private static func testIntersection() {
        // For testing only (note, didn't specify id in room init() means id is "0000")

        // ------ [[ isEssentiallySamePlace ]] ------- //
        print("🧪 isEssentiallySamePlace: \(isEssentiallySamePlace(a: Room("A", id: "A"), b: Room("A", id: "A")))")
        print("🧪 isEssentiallySamePlace: \(isEssentiallySamePlace(a: Room("A", id: "A"), b: Room("B", id: "B")))")
        print("🧪 isEssentiallySamePlace: \(isEssentiallySamePlace(a: Block("Test Block"), b: Room("A")))")

        // ------ [[ checkIntersection ]] ------- //
        let resultA = checkIntersection(a: [
            CheckInSession(checkedIn: Date(), checkedOut: Date() + 60, target: Room("A", id: "A")),
            CheckInSession(checkedIn: Date() + 61, checkedOut: Date() + 121, target: Room("B", id: "B")),
        ], b: [
            CheckInSession(checkedIn: Date(), checkedOut: Date() + 60, target: Room("A", id: "A")),
            CheckInSession(checkedIn: Date() + 61, checkedOut: Date() + 121, target: Room("B", id: "B")),
        ])
        // Expected: [2020-12-07 15:15:36 +0000 to 2020-12-07 15:16:36 +0000, 2020-12-07 15:16:37 +0000 to 2020-12-07 15:17:37 +0000]
        // Note: The exact timing might differ because Date() gets current time
        // What we're actually looking out for is that both check in sessions matched
        print("🧪 checkIntersection: \(resultA)")

        let resultB = checkIntersection(a: [
            CheckInSession(checkedIn: Date(), checkedOut: Date() + 60, target: Room("A")),
            CheckInSession(checkedIn: Date() + 61, checkedOut: Date() + 121, target: Room("B")),
        ], b: [
            CheckInSession(checkedIn: Date(), checkedOut: Date() + 60, target: Block("Test Block")),
            CheckInSession(checkedIn: Date() + 61, checkedOut: Date() + 121, target: Room("B")),
        ])
        // Expected: [2020-12-07 15:15:36 +0000 to 2020-12-07 15:16:36 +0000, 2020-12-07 15:16:37 +0000 to 2020-12-07 15:17:37 +0000]
        // Note: The exact timing might differ because Date() gets current time
        // What we're actually looking out for is that both check in sessions matched
        print("🧪 checkIntersection: \(resultB)")

        let resultC = checkIntersection(a: [
            CheckInSession(checkedIn: Date(), checkedOut: Date() + 60, target: Room("A")),
            CheckInSession(checkedIn: Date() + 61, checkedOut: Date() + 121, target: Room("B")),
        ], b: [
            CheckInSession(checkedIn: Date(), checkedOut: Date() + 60, target: Block("Some Block")),
            CheckInSession(checkedIn: Date() + 61, checkedOut: Date() + 121, target: Room("ABC", id: "ABC")),
        ])
        // Expected: []
        // What we're actually looking out for is that none of the check in sessions matched
        print("🧪 checkIntersection: \(resultC)")

        let resultD = checkIntersection(a: [
            CheckInSession(checkedIn: Date(), checkedOut: Date() + 60, target: Room("A")),
            CheckInSession(checkedIn: Date() + 61, checkedOut: Date() + 121, target: Room("B")),
        ], b: [
            CheckInSession(checkedIn: Date() + 1000, checkedOut: Date() + 1000 + 60, target: Room("A")),
            CheckInSession(checkedIn: Date() + 1000 + 60 + 1, checkedOut: Date() + 1000 + 60 + 1 + 60, target: Room("B")),
        ])
        // Expected: []
        // What we're actually looking out for is that none of the check in sessions matched
        print("🧪 checkIntersection: \(resultD)")
    }
}

/// This should be the same intersection as the cloud function accepts
struct Intersection: Codable {
    var start: Date
    var end: Date
    var target: String

    init(start: Date, end: Date, target: String) {
        self.start = start
        self.end = end
        self.target = target
    }

    init(dateInterval: DateInterval, target: String) {
        start = dateInterval.start
        end = dateInterval.end
        self.target = target
    }
}
