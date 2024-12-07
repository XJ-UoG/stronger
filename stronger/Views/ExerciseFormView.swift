//
//  ExerciseFormView.swift
//  stronger
//
//  Created by Tan Xin Jie on 6/12/24.
//

import SwiftUI

struct ExerciseFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var existingExerciseName: String = ""
    @State private var newExerciseName: String = ""
    @Binding var isPresentForm:  Bool

    var addExerciseToWorkout: (String) -> Void

    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: []
    ) private var exercises: FetchedResults<Exercise>
    
    
    var body: some View {
        VStack {
            Form {
                Section (header: Text("Existing")) {
                    Picker("Selected: ", selection: $existingExerciseName) {
                        let exerciseNames = Array(Set(exercises.compactMap { $0.name }))
                        // Map exercises into set of exercises names
                        ForEach(exerciseNames, id: \.self) { name in
                            Text(name)
                        }
                    }
                    .onAppear {
                        if let firstName = exercises.first?.name {
                            existingExerciseName = firstName
                        }
                    }
                    Button(action: {
                        addExerciseToWorkout(existingExerciseName)
                        isPresentForm = false
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                Section (header: Text("New")) {
                    TextField("New Exercise", text: $newExerciseName)
                    Button(action: {
                        addExerciseToWorkout(newExerciseName)
                        isPresentForm = false
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ExerciseFormView(
        isPresentForm: .constant(true),
        addExerciseToWorkout: { name in
            print("Added \(name) exercise")
        }
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
