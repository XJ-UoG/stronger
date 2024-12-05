//
//  WorkoutView.swift
//  stronger
//
//  Created by Tan Xin Jie on 5/12/24.
//

import SwiftUI

struct WorkoutView: View {
    let workout: Workout
    
    var body: some View {
        VStack {
            Text("Item at \(workout.timestamp!, formatter: workoutTimeFormatter)")
                .font(.title)
            if let exercises = workout.exercises as? Set<Exercise> {
                ForEach(Array(exercises), id: \.self) { exercise in
                    HStack {
                        Text(exercise.name ?? "Unnamed Exercise")
                        Text("\(exercise.weight ?? "?") kg")
                        Text("\(exercise.reps ?? "?") reps")
                    }
                }
            } else {
                Text("No exercises found")
            }
        }
        .padding()
    }
}

#Preview {
    let viewContext = PersistenceController.preview.container.viewContext
    let newWorkout = Workout(context: viewContext)
    newWorkout.timestamp = Date()
    newWorkout.name = "Workout"
    let exercise1 = Exercise(context: viewContext)
    exercise1.name = "Push-Ups"
    exercise1.reps = "15"
    exercise1.weight = "0"
    newWorkout.addToExercises(exercise1)
    return WorkoutView(workout: newWorkout)
}
