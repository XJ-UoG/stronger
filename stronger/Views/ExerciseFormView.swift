//
//  ExerciseFormView.swift
//  stronger
//
//  Created by Tan Xin Jie on 6/12/24.
//

import SwiftUI

struct ExerciseFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var exerciseName: String = ""
    @Binding var isPresentForm:  Bool

    var addExerciseToWorkout: (String) -> Void

    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: []
    ) private var exercises: FetchedResults<Exercise>
    
    
    var body: some View {
        VStack {
            Form {
                Section (header: Text("Exercise")) {
                    Picker("Selected: ", selection: $exerciseName) {
                        // Map exercises into set of exercises names
                        ForEach(Array(Set(exercises.compactMap { $0.name })), id: \.self) { name in
                            Text(name)
                        }
                    }
                    .onAppear {
                        if let firstName = exercises.first?.name {
                            exerciseName = firstName
                        }
                    }
                }
                
                Button(action: {
                    addExerciseToWorkout(exerciseName)
                    isPresentForm = false
                }) {
                    Label("Add Item", systemImage: "plus")
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
