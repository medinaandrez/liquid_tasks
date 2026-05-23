import SwiftUI
import SwiftData

struct SpaceFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var spaceToEdit: Space?
    
    @State private var title: String = ""
    @State private var selectedColorHex: String = "#007AFF"
    @State private var selectedIconName: String = "folder.fill"
    
    @AppStorage("appTheme") private var appTheme: String = "classic"
    
    // Premium color palette for custom Spaces
    let colors = [
        "#007AFF", // Blue
        "#34C759", // Green
        "#FF9500", // Orange
        "#FF3B30", // Red
        "#AF52DE", // Purple
        "#FF2D55", // Pink
        "#30B0C7", // Teal
        "#5856D6", // Indigo
        "#FFCC00", // Yellow
        "#8E8E93"  // Slate/Gray
    ]
    
    // Selected custom SF Symbols
    let icons = [
        "briefcase.fill",
        "house.fill",
        "graduationcap.fill",
        "book.closed.fill",
        "cart.fill",
        "heart.fill",
        "folder.fill",
        "gearshape.fill",
        "globe",
        "gamecontroller.fill",
        "leaf.fill",
        "airplane"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Input de Nombre
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalles")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        TextField("Nombre del Espacio", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Selector de Color
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color del Espacio")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                            ForEach(colors, id: \.self) { hex in
                                Button {
                                    withAnimation(.interactiveSpring) {
                                        selectedColorHex = hex
                                    }
                                } label: {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColorHex == hex ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                        .shadow(radius: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Selector de Icono
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icono del Espacio")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIconName = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIconName == icon ? Color(hex: selectedColorHex).opacity(0.2) : Color.white.opacity(0.05))
                                        .foregroundStyle(selectedIconName == icon ? Color(hex: selectedColorHex) : Color.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedIconName == icon ? Color(hex: selectedColorHex) : Color.clear, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
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
                Group {
                    if let currentTheme = AppTheme(rawValue: appTheme) {
                        currentTheme.detailGradient
                    } else {
                        LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    }
                }
                .ignoresSafeArea()
            )
            .navigationTitle(spaceToEdit == nil ? "Nuevo Espacio" : "Editar Espacio")
            .onAppear {
                if let space = spaceToEdit {
                    title = space.title
                    selectedColorHex = space.colorHex.isEmpty ? "#007AFF" : space.colorHex
                    selectedIconName = space.iconName.isEmpty ? "folder.fill" : space.iconName
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
                        saveSpace()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 350, minHeight: 400)
        #endif
    }
    
    private func saveSpace() {
        if let space = spaceToEdit {
            space.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            space.colorHex = selectedColorHex
            space.iconName = selectedIconName
        } else {
            let newSpace = Space(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                iconName: selectedIconName,
                colorHex: selectedColorHex
            )
            modelContext.insert(newSpace)
        }
        dismiss()
    }
}
