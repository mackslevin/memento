//
//  WidgetApp.swift
//  WidgetApp
//
//  Created by Roscoe Rubin-Rottenberg on 6/9/24.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), placeholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var placeholder: Bool = false
}

struct MementoWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    @Query(
        FetchDescriptor<Item>(predicate: #Predicate {$0.viewed == false}),
        animation: .snappy
    ) var items: [Item]


    
    var body: some View {
        if let item = items.randomElement() {
            switch family {
            case .systemSmall:
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        if let data = item.metadata?.siteImage, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        Text(item.metadata?.title ?? item.link)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.primary)
                    }
                    Text(item.note ?? "")
                        .font(.subheadline)
                    HStack {
                        Button(intent: ItemViewedIntent(item: item), label: {
                            Image(systemName: "book")
                        })
                            .clipShape(Circle())
                        Button(intent: DeleteItemIntent(item: item), label: {Image(systemName: "trash")})
                            .clipShape(Circle())
                    }
                }
                .transition(.push(from: .bottom))
                .widgetURL(item.url)
            
            default:
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        if let data = item.metadata?.siteImage, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        Text(item.metadata?.title ?? item.link)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.primary)
                    }
                    Text(item.note ?? "")
                        .font(.subheadline)
                    HStack {
                        Button(intent: ItemViewedIntent(item: item), label: {
                            Image(systemName: "book")
                        })
                            .clipShape(Circle())
                        Button(intent: DeleteItemIntent(item: item), label: {Image(systemName: "trash")})
                            .clipShape(Circle())
                    }
                }
                .transition(.push(from: .bottom))
                .widgetURL(item.url)
            }
        } else if entry.placeholder == true {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Image("EmptyItem")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .frame(height: 65)
                        .shadow(radius: 2)
                    Text("Memento")
                        .bold()
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.primary)
                }
                HStack {
                    Button(action: {}, label: {
                        Image(systemName: "book")
                    })
                    Button(action: {}, label: {Image(systemName: "xmark")})
                }
            }
        } else {
            Text("There are no unviewed items.")
                .multilineTextAlignment(.center)
        }
        
    }
}

struct MementoWidget: Widget {
    let modelContainer = ConfigureModelContainer()
    let kind: String = "MementoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MementoWidgetEntryView(entry: entry)
                .modelContainer(modelContainer)
                .containerBackground(.fill.tertiary, for: .widget)
        }
#if os(watchOS)
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline])
#else
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline,
                            .systemSmall, .systemMedium, .systemLarge])
#endif
    }
}

#Preview(as: .systemSmall) {
    MementoWidget()
} timeline: {
    SimpleEntry(date: .now)
    SimpleEntry(date: .now)
}
