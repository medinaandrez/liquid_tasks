import SwiftUI
import SwiftData

struct TagFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var tagToEdit: Tag?
    
    @State private var name: String = ""
    @State private var colorHex: String = "#FF3B30" // Default Red
    
    private let predefinedColors: [(name: String, hex: String)] = [
        ("Rojo", "#FF3B30"),
        ("Naranja", "#FF9500"),
        ("Amarillo", "#FFCC00"),
        ("Verde", "#34C759"),
        ("Menta", "#00C7BE"),
        ("Cian", "#32ADE6"),
        ("Azul", "#007AFF"),
        ("Índigo", "#5856D6"),
        ("Púrpura", "#AF52DE"),
        ("Rosa", "#FF2D55")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalles")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        TextField("Nombre de la Etiqueta", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text("Selecciona un color")
                            Spacer()
                            Picker("Color", selection: $colorHex) {
                                ForEach(predefinedColors, id: \.hex) { color in
                                    HStack {
                                        Circle()
                                            .fill(Color(hex: color.hex))
                                            .frame(width: 16, height: 16)
                                        Text(color.name)
                                    }.tag(color.hex)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                }
                .padding()
            }
            .background(
                LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle(tagToEdit == nil ? "Nueva Etiqueta" : "Editar Etiqueta")
            .onAppear {
                if let tag = tagToEdit {
                    name = tag.name
                    colorHex = tag.colorHex
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTag()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 350, minHeight: 280)
        #endif
    }
    
    private func saveTag() {
        if let tag = tagToEdit {
            tag.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            tag.colorHex = colorHex
        } else {
            let newTag = Tag(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                colorHex: colorHex
            )
            modelContext.insert(newTag)
        }
        dismiss()
    }
}

// Extension to convert Hex to Color simply
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
