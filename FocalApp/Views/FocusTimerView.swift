import SwiftUI
import SwiftData
import Combine

struct WaveShape: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat
    var phase: CGFloat
    
    var animatableData: Double {
        get { Double(phase) }
        set { phase = CGFloat(newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let progressHeight = height * (1 - progress)
        
        path.move(to: CGPoint(x: 0, y: progressHeight))
        
        for x in stride(from: 0, to: width + 1, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * 2 * .pi + phase)
            let y = progressHeight + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct FocusTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Space.creationDate) private var spaces: [Space]
    
    @AppStorage("appTheme") private var appTheme: String = "classic"
    @AppStorage("glassmorphicEffects") private var glassmorphicEffects: Bool = true
    
    // States for Timer
    @State private var timeRemaining: TimeInterval = 25 * 60
    @State private var totalDuration: TimeInterval = 25 * 60
    @State private var isRunning = false
    @State private var timerMode: Mode = .focus
    @State private var selectedSpaceId: UUID?
    
    // Wave animation phase
    @State private var wavePhase: CGFloat = 0
    
    enum Mode {
        case focus
        case shortBreak
        case longBreak
        
        var name: String {
            switch self {
            case .focus: return "Enfoque"
            case .shortBreak: return "Descanso Corto"
            case .longBreak: return "Descanso Largo"
            }
        }
    }
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let waveTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var currentTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .classic
    }
    
    var selectedSpace: Space? {
        spaces.first(where: { $0.id == selectedSpaceId })
    }
    
    var themeColor: Color {
        if let colorHex = selectedSpace?.colorHex, !colorHex.isEmpty {
            return Color(hex: colorHex)
        }
        return currentTheme.previewColors.first ?? .blue
    }
    
    var progress: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return CGFloat(1.0 - (timeRemaining / totalDuration))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // Segmented Selector para modos
                Picker("Modo de Enfoque", selection: $timerMode) {
                    Text("Focus (25m)").tag(Mode.focus)
                    Text("Corto (5m)").tag(Mode.shortBreak)
                    Text("Largo (15m)").tag(Mode.longBreak)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: timerMode) { _ in
                    resetTimer()
                }
                
                // Selector de Espacio
                HStack {
                    Text("Espacio Activo:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Picker("Espacio", selection: $selectedSpaceId) {
                        Text("General").tag(UUID?.none)
                        ForEach(spaces) { space in
                            Label {
                                Text(space.title)
                            } icon: {
                                Image(systemName: space.iconName.isEmpty ? "folder.fill" : space.iconName)
                                    .foregroundStyle(Color(hex: space.colorHex.isEmpty ? "#007AFF" : space.colorHex))
                            }
                            .tag(UUID?.some(space.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(themeColor)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.1), lineWidth: 1))
                
                Spacer()
                
                // Reloj Circular Líquido
                ZStack {
                    // Círculo de Fondo
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 12)
                        .frame(width: 240, height: 240)
                    
                    // Wave Líquida dentro del círculo
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: 228, height: 228)
                        .overlay(
                            WaveShape(progress: progress, waveHeight: isRunning ? 8 : 4, phase: wavePhase)
                                .fill(
                                    LinearGradient(
                                        colors: [themeColor.opacity(0.6), themeColor.opacity(0.3)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(Circle())
                        )
                        .shadow(color: themeColor.opacity(0.3), radius: 10)
                    
                    // Anillo de progreso brillante
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [themeColor, themeColor.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.linear(duration: 1.0), value: timeRemaining)
                    
                    // Tiempo Numérico
                    VStack(spacing: 4) {
                        Text(timeString(time: timeRemaining))
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundStyle(.primary)
                        
                        Text(timerMode.name)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .kerning(1.5)
                    }
                }
                .frame(width: 260, height: 260)
                
                Spacer()
                
                // Controles de Acción
                HStack(spacing: 24) {
                    // Botón Reset
                    Button {
                        resetTimer()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .frame(width: 56, height: 56)
                            .background(.thinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    
                    // Botón Play/Pause
                    Button {
                        withAnimation {
                            isRunning.toggle()
                        }
                        #if os(iOS)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        #endif
                    } label: {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 76, height: 76)
                            .background(
                                LinearGradient(
                                    colors: [themeColor, themeColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: themeColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    // Botón Cerrar
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .frame(width: 56, height: 56)
                            .background(.thinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 24)
                
            }
            .padding()
            .background(
                currentTheme.detailGradient
                    .ignoresSafeArea()
            )
            .navigationTitle("Pomodoro Líquido")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onReceive(timer) { _ in
                guard isRunning else { return }
                
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    // Completado!
                    completeSession()
                }
            }
            .onReceive(waveTimer) { _ in
                if isRunning {
                    wavePhase += 0.15
                } else {
                    wavePhase += 0.05
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 500)
        #endif
    }
    
    private func resetTimer() {
        isRunning = false
        switch timerMode {
        case .focus:
            timeRemaining = 25 * 60
        case .shortBreak:
            timeRemaining = 5 * 60
        case .longBreak:
            timeRemaining = 15 * 60
        }
        totalDuration = timeRemaining
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func completeSession() {
        isRunning = false
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
        
        // Log Focus Session if it's a focus mode (breaks are not focus time)
        if timerMode == .focus {
            let session = FocusSession(
                duration: totalDuration,
                spaceTitle: selectedSpace?.title ?? "General",
                spaceColorHex: selectedSpace?.colorHex ?? "#007AFF"
            )
            modelContext.insert(session)
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving focus session: \(error)")
            }
        }
        
        resetTimer()
    }
}
