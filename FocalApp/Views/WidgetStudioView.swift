import SwiftUI
import SwiftData

struct WidgetStudioView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("appTheme") private var appTheme: String = "classic"
    @AppStorage("glassmorphicEffects") private var glassmorphicEffects: Bool = true
    
    @State private var glassOpacity: Double = 0.8
    @State private var selectedSize: WidgetSize = .medium
    
    var currentTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .classic
    }
    
    enum WidgetSize: String, CaseIterable {
        case small = "Pequeño"
        case medium = "Mediano"
        case large = "Grande"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Controles de Personalización
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Configuración de Cristal (Widget)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        // Selector de tamaño
                        Picker("Tamaño del Widget", selection: $selectedSize) {
                            ForEach(WidgetSize.allCases, id: \.self) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Divider()
                        
                        // Slider de opacidad
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Transparencia del Vidrio")
                                Spacer()
                                Text("\(Int(glassOpacity * 100))%")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                            
                            Slider(value: $glassOpacity, in: 0.3...0.95, step: 0.05)
                                .tint(currentTheme.previewColors.first ?? .blue)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.15), lineWidth: 1))
                    
                    // Previsualización Física del Widget
                    VStack {
                        Text("Vista Previa en Pantalla")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                        
                        ZStack {
                            // Fondo simulado de pantalla (un hermoso wallpaper difuso)
                            LinearGradient(
                                colors: [Color(hex: "#1D2B64"), Color(hex: "#F8CDDA")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: 320, height: 320)
                            .cornerRadius(24)
                            .shadow(radius: 10)
                            
                            // El Widget simulado
                            simulatedWidget(size: selectedSize)
                                .transition(.scale.combined(with: .opacity))
                        }
                        .frame(width: 320, height: 320)
                    }
                    .padding(.vertical, 8)
                    
                    // Botón para copiar código de WidgetKit
                    Button {
                        copyWidgetCodeToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc.fill")
                            Text("Copiar Código Swift para WidgetKit")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: currentTheme.previewColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: (currentTheme.previewColors.first ?? .blue).opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    
                    Text("Pega este código en Xcode para crear una extensión de widget nativa en tu proyecto en un segundo.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                }
                .padding()
            }
            .background(
                currentTheme.detailGradient
                    .ignoresSafeArea()
            )
            .navigationTitle("Widget Studio")
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
        .frame(minWidth: 400, minHeight: 600)
        #endif
    }
    
    // Renders the simulated widget based on size selection
    @ViewBuilder
    private func simulatedWidget(size: WidgetSize) -> some View {
        let currentGradient = currentTheme.sidebarGradient
        
        ZStack {
            // Fondo degradado del widget con opacidad controlada
            currentGradient
                .opacity(0.8)
            
            // Efecto Glassmorphism
            Color.clear
                .background(.ultraThinMaterial)
                .opacity(glassOpacity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.25), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(
            widgetContent(size: size)
        )
        .frame(width: widgetWidth(size: size), height: widgetHeight(size: size))
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: size)
    }
    
    @ViewBuilder
    private func widgetContent(size: WidgetSize) -> some View {
        switch size {
        case .small:
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                    Spacer()
                    Text("Focal")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Text("Hoy")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("4 tareas pendientes")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(16)
            
        case .medium:
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                    Text("Focal App — Hoy")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("Racha: 3 🔥")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "circle")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Text("Revisar pautas de App Store")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "circle")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Text("Diseñar interfaz de Ajustes")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "circle")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Text("Estudiar SwiftData Avanzado")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            .padding(16)
            
        case .large:
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.yellow)
                    Text("Estadísticas y Espacios")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "timer")
                        .font(.caption)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Espacios y sus barras de progreso
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("💼 Trabajo")
                                .font(.caption2)
                            Spacer()
                            Text("80%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: 0.8)
                            .tint(Color(hex: "#5856D6"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("🏡 Personal")
                                .font(.caption2)
                            Spacer()
                            Text("40%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: 0.4)
                            .tint(Color(hex: "#FF2D55"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("🎓 Estudios")
                                .font(.caption2)
                            Spacer()
                            Text("100%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: 1.0)
                            .tint(Color(hex: "#FF9500"))
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Focus total hoy:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("75 min 🔥")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .padding(16)
        }
    }
    
    private func widgetWidth(size: WidgetSize) -> CGFloat {
        switch size {
        case .small: return 140
        case .medium: return 280
        case .large: return 280
        }
    }
    
    private func widgetHeight(size: WidgetSize) -> CGFloat {
        switch size {
        case .small: return 140
        case .medium: return 140
        case .large: return 280
        }
    }
    private func copyWidgetCodeToClipboard() {
        let code = """
//
//  FocalWidget.swift
//  FocalWidgetExtension
//
//  Creado por Focal App Widget Studio.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), streak: 3, pendingCount: 4)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), streak: 3, pendingCount: 4)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [SimpleEntry(date: Date(), streak: 3, pendingCount: 4)]
        let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(30 * 60)))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let pendingCount: Int
}

struct FocalWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Fondo Gradiente Liquid Glass con opacidad premium
            LinearGradient(
                colors: [Color(hex: "#1E3C72"), Color(hex: "#2A5298")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Color.clear
                .background(.ultraThinMaterial)
                .opacity(\(glassOpacity))
        }
        .overlay(
            VStack(alignment: .leading, spacing: 8) {
                if family == .systemSmall {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                        Spacer()
                        Text("Focal")
                            .font(.caption.bold())
                    }
                    Spacer()
                    Text("Hoy")
                        .font(.title2.bold())
                    Text("\\(entry.pendingCount) tareas")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                } else {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                        Text("Focal App")
                            .font(.caption.bold())
                        Spacer()
                        Text("Racha: \\(entry.streak) 🔥")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    Divider()
                        .background(Color.white.opacity(0.3))
                    Text("✓ Completar tareas diarias")
                        .font(.caption)
                    Text("○ Revisar pautas de App Store")
                        .font(.caption)
                    Spacer()
                }
            }
            .padding()
        )
    }
}

@main
struct FocalWidget: Widget {
    let kind: String = "FocalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                FocalWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                FocalWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Widget de Focal")
        .description("Visualiza tus tareas y racha de enfoque al instante.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
"""
        
        #if os(iOS)
        UIPasteboard.general.string = code
        #endif
        
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(code, forType: .string)
        #endif
    }
}
