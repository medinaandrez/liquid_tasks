import SwiftUI
import SwiftData

struct SpaceFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var spaceToEdit: Space?
    
    @State private var title: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
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
                    
                }
                .padding()
            }
            .background(
                LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle(spaceToEdit == nil ? "Nuevo Espacio" : "Editar Espacio")
            .onAppear {
                if let space = spaceToEdit {
                    title = space.title
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
        .frame(minWidth: 350, minHeight: 200)
        #endif
    }
    
    private func saveSpace() {
        if let space = spaceToEdit {
            space.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            let newSpace = Space(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            modelContext.insert(newSpace)
        }
        dismiss()
    }
}
