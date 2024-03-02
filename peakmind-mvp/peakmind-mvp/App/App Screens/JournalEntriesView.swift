//
//  JournalEntriesView.swift
//  peakmind-mvp
//
//  Created by Rahul Rao on 3/1/24.
//

struct JournalEntriesView: View {
    @ObservedObject var dataManager: JournalDataManager

    var body: some View {
        NavigationView {
            List(dataManager.loadJournalEntries()) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    Text(entry.title)
                }
            }
            .navigationBarTitle("Journal Entries")
            .navigationBarItems(trailing: NavigationLink(destination: JournalView(dataManager: dataManager)) {
                Image(systemName: "plus")
            })
        }
    }
}
