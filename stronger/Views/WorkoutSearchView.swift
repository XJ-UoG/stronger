//
//  WorkoutSearchView.swift
//  stronger
//
//  Created by Tan Xin Jie on 9/12/24.
//

import SwiftUI

struct WorkoutSearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Workout>
    
    @State private var searchText: String = ""
    
    var body: some View {
        List {
            ForEach(groupWorkoutByDay(items), id: \.0) {
                daysAgo,
                groups in
                Section(header: Text("\(getDaysAgoString(daysAgo))")) {
                    ForEach(groups) { workout in
                        NavigationLink {
                            WorkoutView(workout: workout)
                        } label: {
                            VStack (alignment: .leading) {
                                Text(workout.name!)
                                    .font(.headline)
                                Text(workout.timestamp!, formatter: workoutTimeFormatter)
                                    .font(.footnote)
                                    .fontWeight(.thin)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Link Workout")
        .searchable(text: $searchText, prompt: "Workout Name")
    }
    
    // Group workouts by the numbers of days ago
    private func groupWorkoutByDay(_ workouts: FetchedResults<Workout>) -> [(Int, [Workout])] {
        let grouped = Dictionary(grouping: workouts) { workout in
            Int(workout.timestamp!.distance(to: Date()) / (24 * 60 * 60))
        }
        
        // Sort the grouped workouts by days ago, convert dictionary to tuple (required to be used with ForEach List)
        let sortedGroups = grouped.sorted { $0.key < $1.key }
        return sortedGroups
    }
    
    private func getDaysAgoString(_ input: Int) -> String {
        return input == 0 ? "Today" : input == 1 ? "Yesterday" : "\(input) days ago"
    }
}

#Preview {
    WorkoutSearchView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
