import SwiftUI
import SwiftData
import Charts

struct DailyFocus: Identifiable {
    var id = UUID()
    var date: Date
    var minutes: Double
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "E"
        return formatter.string(from: date).capitalized
    }
}

struct SpaceFocus: Identifiable {
    var id = UUID()
    var spaceTitle: String
    var colorHex: String
    var minutes: Double
}

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \FocusSession.timestamp) private var sessions: [FocusSession]
    @Query private var tasks: [Task]
    
    @AppStorage("appTheme") private var appTheme: String = "classic"
    @AppStorage("glassmorphicEffects") private var glassmorphicEffects: Bool = true
    
    var currentTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .classic
    }
    
    // Group focus sessions for the last 7 days
    var last7DaysFocus: [DailyFocus] {
        var results: [DailyFocus] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for i in (0..<7).reversed() {
            guard let targetDate = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            // Sum minutes for focus sessions completed on this calendar day
            let daySessions = sessions.filter {
                calendar.isDate($0.timestamp, inSameDayAs: targetDate) && $0.isCompleted
            }
            
            let totalSeconds = daySessions.reduce(0.0) { $0 + $1.duration }
            let totalMinutes = totalSeconds / 60.0
            
            results.append(DailyFocus(date: targetDate, minutes: totalMinutes))
        }
        
        return results
    }
    
    // Group focus sessions by Space
    var spaceFocusData: [SpaceFocus] {
        var breakdown: [String: (color: String, seconds: Double)] = [:]
        
        for session in sessions.filter({ $0.isCompleted }) {
            let key = session.spaceTitle
            let current = breakdown[key] ?? (color: session.spaceColorHex, seconds: 0.0)
            breakdown[key] = (color: current.color, seconds: current.seconds + session.duration)
        }
        
        return breakdown.map { key, value in
            SpaceFocus(
                spaceTitle: key,
                colorHex: value.color,
                minutes: value.seconds / 60.0
            )
        }.sorted { $0.minutes > $1.minutes }
    }
    
    // Calculate focus streak (days in a row with at least 1 completed focus session)
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Extract unique calendar days where a session was completed, sorted descending
        let completedDates = Set(sessions.filter({ $0.isCompleted }).map { calendar.startOfDay(for: $0.timestamp) })
        let sortedDates = completedDates.sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var streak = 0
        var targetDate = today
        
        // If they did nothing today, check if the streak was alive yesterday
        if !completedDates.contains(today) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
            if completedDates.contains(yesterday) {
                targetDate = yesterday
            } else {
                return 0 // Streak broken
            }
        }
        
        while completedDates.contains(targetDate) {
            streak += 1
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: targetDate) else { break }
            targetDate = nextDate
        }
        
        return streak
    }
    
    var totalFocusMinutes: Double {
        sessions.filter({ $0.isCompleted }).reduce(0.0) { $0 + $1.duration } / 60.0
    }
    
    var averageFocusMinutes: Double {
        let dailyData = last7DaysFocus
        let total = dailyData.reduce(0.0) { $0 + $1.minutes }
        return total / Double(dailyData.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Card 1: Racha de Enfoque (Glassmorphic)
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                                .frame(width: 56, height: 56)
                                .shadow(color: .orange.opacity(0.4), radius: 6)
                            
                            Image(systemName: "flame.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Racha de Enfoque")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("\(currentStreak) Días Seguidos")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        
                        if currentStreak > 0 {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundStyle(.yellow)
                                .symbolEffect(.bounce, options: .repeating)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Fila de Métricas Clave
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        // Total Minutos
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tiempo Total")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f min", totalFocusMinutes))
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("enfocados")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
                        
                        // Sesiones Totales
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Sesiones")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(sessions.filter({ $0.isCompleted }).count)")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("bloques pomodoro")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
                    }
                    
                    // Card 2: Historial Últimos 7 Días (Chart)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tiempo de Enfoque (Últimos 7 Días)")
                            .font(.headline)
                        
                        if sessions.isEmpty {
                            HStack {
                                Spacer()
                                Text("Aún no has completado sesiones de enfoque.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 24)
                                Spacer()
                            }
                        } else {
                            Chart {
                                ForEach(last7DaysFocus) { day in
                                    BarMark(
                                        x: .value("Día", day.dayName),
                                        y: .value("Minutos", day.minutes)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: currentTheme.previewColors,
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .cornerRadius(6)
                                }
                            }
                            .frame(height: 180)
                            .chartYAxis {
                                AxisMarks(format: Decimal.FormatStyle.Percent.percent.scale(1.0)) // simple formatting
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Card 3: Distribución por Espacios (Donut Chart)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Distribución por Espacios")
                            .font(.headline)
                        
                        if spaceFocusData.isEmpty {
                            HStack {
                                Spacer()
                                Text("No hay datos de distribución espacial.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 24)
                                Spacer()
                            }
                        } else {
                            HStack(spacing: 24) {
                                Chart {
                                    ForEach(spaceFocusData) { item in
                                        SectorMark(
                                            angle: .value("Tiempo", item.minutes),
                                            innerRadius: .ratio(0.6),
                                            angularInset: 1.5
                                        )
                                        .foregroundStyle(Color(hex: item.colorHex))
                                    }
                                }
                                .frame(width: 140, height: 140)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(spaceFocusData) { item in
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(Color(hex: item.colorHex))
                                                .frame(width: 10, height: 10)
                                            Text(item.spaceTitle)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.primary)
                                            Spacer()
                                            Text(String(format: "%.0f m", item.minutes))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                }
                .padding()
            }
            .background(
                currentTheme.detailGradient
                    .ignoresSafeArea()
            )
            .navigationTitle("Analíticas de Enfoque")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 450, minHeight: 600)
        #endif
    }
}
