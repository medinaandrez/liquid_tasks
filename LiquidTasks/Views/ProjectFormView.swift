import SwiftUI
import SwiftData

struct ProjectFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var projectToEdit: Project?
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var isCompleted: Bool = false
    
    @Query private var areas: [Area]
    @State private var selectedArea: Area?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Bloque de Detalles
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalles")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        TextField("Nombre del Proyecto", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                        
                        TextField("Notas (opcional)", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Bloque de Organización
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Organización")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text("Área")
                            Spacer()
                            Picker("Área", selection: $selectedArea) {
                                Text("Ninguna").tag(Area?.none)
                                ForEach(areas) { area in
                                    Text(area.title).tag(Area?.some(area))
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                        
                        if projectToEdit != nil {
                            Divider()
                            Toggle("Proyecto Completado (Archivar)", isOn: $isCompleted)
                                .tint(.green)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                }
                .padding()
            }
            // Fondo general para simular "Liquid Glass"
            .background(
                LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle(projectToEdit == nil ? "Nuevo Proyecto" : "Editar Proyecto")
            .onAppear {
                if let project = projectToEdit {
                    title = project.title
                    notes = project.notes
                    selectedArea = project.area
                    isCompleted = project.isCompleted
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
                        saveProject()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 350)
        #endif
    }
    
    private func saveProject() {
        if let project = projectToEdit {
            project.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            project.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            project.area = selectedArea
            project.isCompleted = isCompleted
        } else {
            let newProject = Project(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                isCompleted: isCompleted
            )
            newProject.area = selectedArea
            modelContext.insert(newProject)
        }
        dismiss()
    }
}
