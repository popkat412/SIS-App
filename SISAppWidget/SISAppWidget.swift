//
//  SISAppWidget.swift
//  SISAppWidget
//
//  Created by Wang Yunze on 20/11/20.
//

import SwiftUI
import WidgetKit

// MARK: Timeline provider

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            blocks: DataProvider.placeholderBlocks
        )
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(
            date: Date(),
            blocks: DataProvider.placeholderBlocks
        )
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        print("⌚️ rebuding timeline")
        var entry = SimpleEntry(date: Date(), blocks: DataProvider.placeholderBlocks)

        if let currentSession = FileUtility.getDataFromJsonFile(filename: Constants.currentSessionFilename, dataType: CheckInSession.self) {
            entry = SimpleEntry(date: Date(), checkInSession: currentSession)
        } else {
            if let currentLocation = FileUtility.getDataFromJsonFile(filename: Constants.userLocationFilename, dataType: Location.self) {
                entry = SimpleEntry(date: Date(), blocks: DataProvider.getBlocks(userLocation: currentLocation.toCLLocation()))
            }
        }

        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: Widget entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isCheckedIn: Bool
    let blocks: [Block]?
    let checkInSession: CheckInSession?

    init(date: Date, blocks: [Block]) {
        self.date = date
        isCheckedIn = false
        self.blocks = blocks
        checkInSession = nil
    }

    init(date: Date, checkInSession: CheckInSession) {
        self.date = date
        isCheckedIn = true
        blocks = nil
        self.checkInSession = checkInSession
    }
}

struct SISAppWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily

    // MARK: Widget view

    var body: some View {
        VStack {
            if !entry.isCheckedIn {
                VStack(alignment: .leading) {
                    Text("Click to check in:")
                        .padding([.top, .leading])

                    HStack {
                        ForEach(0 ..< 4) { i in
                            Link(destination: getDeeplinkURL(forIdx: i)) {
                                Text("\(entry.blocks![i].shortName)")
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(
                                        entry
                                            .blocks![i]
                                            .shortName
                                            .components(separatedBy: " ")
                                            .count
                                    )
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .frame(width: 70, height: 70)
                                    .background(Color.blue)
                                    .cornerRadius(13)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                VStack {
                    let formattedText = Text("Checked in to: ")
                        + Text("\(entry.checkInSession!.target.name)")
                        .fontWeight(.bold)
                        + Text(" at ")
                        + Text("\(entry.checkInSession!.checkedIn.formattedTime)")
                        .fontWeight(.bold)

                    formattedText
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)

                    Link(destination: getCheckoutDeeplinkURL()) {
                        Button(action: {}) {
                            Text("Check Out")
                        }
                        .buttonStyle(GradientButtonStyle(gradient: Constants.greenGradient))
                        .padding()
                    }
                }
            }
            if widgetFamily == .systemLarge {
                Link(destination: getHistoryDeeplinkURL()) {
                    VStack(alignment: .leading) {
                        Spacer()

                        let history = FileUtility.getDataFromJsonFile(filename: Constants.savedSessionsFilename, dataType: [CheckInSession].self)?.sorted { $0.checkedIn > $1.checkedIn }

                        if let history = history {
                            Divider()
                            ForEach(0 ..< 2) { i in
                                if i < history.count {
                                    HistoryRow(session: history[i])
                                } else {
                                    Spacer()
                                        .frame(height: 50)
                                }
                                Divider()
                            }
                            .padding(.horizontal)
                        } else {
                            Text("History Unavaliable ☹️")
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: Helper functions

    private func getDeeplinkURL(forIdx index: Int) -> URL {
        var urlComponents = URLComponents(string: Constants.baseURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.blockURLParameterName, value: entry.blocks![index].name),
        ]
        return urlComponents.url!
    }

    private func getCheckoutDeeplinkURL() -> URL {
        let url = URL(string: Constants.checkoutURLName, relativeTo: Constants.baseURL)!
        print("check out deeplink: \(url)")
        return url
    }

    private func getHistoryDeeplinkURL() -> URL {
        let url = URL(string: Constants.historyURLName, relativeTo: Constants.baseURL)!
        print("history deeplink: \(url)")
        return url
    }
}

@main
struct SISAppWidget: Widget {
    let kind: String = "SISAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SISAppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("RI Safe Entry")
        .description("Check in / out easily with this widget")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct SISAppWidget_Previews: PreviewProvider {
    static var previews: some View {
        SISAppWidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                blocks: DataProvider.placeholderBlocks
            )
//            entry: SimpleEntry(
//                date: Date(),
//                checkInSession: CheckInSession(
//                    checkedIn: Date(),
//                    target: Block(name: "Test Block")
//                )
//            )
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
