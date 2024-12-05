//
//  ContentView.swift
//  stronger
//
//  Created by Tan Xin Jie on 6/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var categories = [
        Category(name: "Category 1", items: ["Item 1", "Item 2"]),
        Category(name: "Category 2", items: ["Item 3", "Item 4"]),
        Category(name: "Category 3", items: ["Item 5", "Item 6"])
    ]
    
    var body: some View {
        List {
            ForEach(categories.indices, id: \.self) { categoryIndex in
                Section(header: Text(categories[categoryIndex].name)) {
                    ForEach(categories[categoryIndex].items, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete { offsets in
                        deleteItem(at: offsets, in: categoryIndex)
                    }
                }
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet, in categoryIndex: Int) {
        print(categories[categoryIndex].name)
        categories[categoryIndex].items.remove(atOffsets: offsets)
    }
}

struct Category {
    var name: String
    var items: [String]
}


#Preview {
    ContentView()
}
