//
//  SISAppWidget.swift
//  SISAppWidget
//
//  Created by Wang Yunze on 20/11/20.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            blocks: DataProvider.placeholderBlocks
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            blocks: DataProvider.placeholderBlocks
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("⌚️ rebuding timeline")
        var entries: [SimpleEntry]!

        if let currentSession = FileUtility.getDataFromJsonFile(filename: Constants.currentSessionFilename, dataType: CheckInSession.self) {
            entries = [
                SimpleEntry(date: Date(), checkInSession: currentSession)
            ]
        } else {
            entries = [
                SimpleEntry(date: Date(), blocks: DataProvider.placeholderBlocks)
            ]
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isCheckedIn: Bool
    let blocks: [Block]?
    let checkInSession: CheckInSession?

    init(date: Date, blocks: [Block]) {
        self.date = date
        self.isCheckedIn = false
        self.blocks = blocks
        self.checkInSession = nil
    }

    init(date: Date, checkInSession: CheckInSession) {
        self.date = date
        self.isCheckedIn = true
        self.blocks = nil
        self.checkInSession = checkInSession
    }
}

struct SISAppWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if !entry.isCheckedIn {
                VStack(alignment: .leading) {
                Text("Click to check in:")
                    .padding([.top, .leading])

                HStack {
                    ForEach(0..<4) { i in
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
                                .background(
                                    ContainerRelativeShape()
                                        .fill(Color.blue)
                            )
                        }
                    }
                }
                .padding()
                }
            } else {
                VStack {
                    Text("Checked in to: ")
                        + Text("\(entry.checkInSession!.target.name)")
                            .fontWeight(.bold)
                        + Text(" at ")
                        + Text("\(entry.checkInSession!.checkedIn.formattedTime)")
                            .fontWeight(.bold)

                    Link(destination: getCheckoutDeeplinkURL()) {
                        Button(action: {}) {
                            Text("Check Out")
                        }
                        .buttonStyle(GradientButtonStyle(gradient: Constants.checkedInGradient))
                        .padding(.top)
                    }
                }
                .padding()
            }
        }
    }

    private func getDeeplinkURL(forIdx index: Int) -> URL {
        var urlComponents = URLComponents(string: Constants.baseURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.blockURLParameterName, value: entry.blocks![index].name)
        ]
        return urlComponents.url!
    }

    private func getCheckoutDeeplinkURL() -> URL {
        let url = URL(string: Constants.checkoutURLName, relativeTo: URL(string: Constants.baseURLString)!)!
        print("check out deeplink: \(url)")
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
//            entry: SimpleEntry(
//                date: Date(),
//                blocks: DataProvider.placeholderBlocks
//            )
            entry: SimpleEntry(
                date: Date(),
                checkInSession: CheckInSession(
                    checkedIn: Date(),
                    target: Block(name: "Test Block")
                )
            )
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
