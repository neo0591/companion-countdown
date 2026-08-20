import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

/// 主屏小组件：「还剩 X 天」，每日自动推进
/// 数据源：App Group UserDefaults（与 App 同源，companion-countdown 共享）
struct CompanionTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> CompanionEntry {
        CompanionEntry(date: Date(), petName: "毛孩子", remainingDays: 335, referenceDays: 335)
    }

    func getSnapshot(in context: Context, completion: @escaping (CompanionEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CompanionEntry>) -> Void) {
        let entry = currentEntry()
        // 生成未来 7 天的条目，让「还剩 X 天」每日自动 -1
        var entries: [CompanionEntry] = []
        let calendar = Calendar.current
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: Date()) {
                let adjusted = entry.advanced(byDays: day, on: date)
                entries.append(adjusted)
            }
        }
        let nextMidnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }

    private func currentEntry() -> CompanionEntry {
        let defaults = UserDefaults(suiteName: "group.com.companion.countdown")
        let today = Calendar.current.startOfDay(for: Date())

        guard
            let data = defaults?.data(forKey: "widgetPet"),
            let snapshot = try? JSONDecoder().decode(PetSnapshot.self, from: data)
        else {
            return CompanionEntry(date: today, petName: "我的毛孩子", remainingDays: 0, referenceDays: 0)
        }

        let reference = snapshot.species.referenceYears[snapshot.size] ?? 15
        let referenceDays = reference * 365
        let accompanied = CompanionCalculator.accompaniedDays(birthday: snapshot.birthday, now: Date())
        let remaining = max(0, referenceDays - accompanied)

        return CompanionEntry(
            date: today,
            petName: snapshot.name,
            remainingDays: remaining,
            referenceDays: referenceDays
        )
    }
}

// MARK: - Entry

struct CompanionEntry: TimelineEntry {
    let date: Date
    let petName: String
    let remainingDays: Int
    let referenceDays: Int

    func advanced(byDays days: Int, on date: Date) -> CompanionEntry {
        CompanionEntry(
            date: date,
            petName: petName,
            remainingDays: max(0, remainingDays - days),
            referenceDays: referenceDays
        )
    }
}

// MARK: - View

struct CompanionWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: CompanionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "pawprint.fill")
                    .font(.caption)
                Text(entry.petName)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
            }
            .foregroundStyle(.white.opacity(0.75))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(entry.remainingDays)")
                    .font(.system(size: 34, weight: .heavy))
                Text("天")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(.white)

            Text("还剩 · 今天多陪它一会儿")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Theme.starfieldTop, Theme.starfieldBottom],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}

// MARK: - Widget

struct CompanionCountdownWidget: Widget {
    let kind = "CompanionCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CompanionTimelineProvider()) { entry in
            CompanionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("陪伴剩余")
        .description("还剩多少天，好好陪它。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
