import SwiftUI

struct JournalEntriesView: View {
    @EnvironmentObject var dataManager: JournalDataManager
    @State private var showingAddJournalEntryView = false

    var body: some View {
        NavigationView {
            ZStack {
                Color("UIColor.systemGroupedBackground").edgesIgnoringSafeArea(.all)

                if dataManager.journalEntries.isEmpty {
                    EmptyStateView()
                } else {
                    entriesList
                }
                
                addButton
            }
            .navigationTitle("Journal Entries")
            .sheet(isPresented: $showingAddJournalEntryView) {
                JournalView().environmentObject(dataManager)
            }
        }
    }

    private var entriesList: some View {
        List {
            ForEach(dataManager.journalEntries.sorted { $0.date > $1.date }, id: \.id) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry).environmentObject(dataManager)) {
                    JournalEntryCard(entry: entry)
                }
            }
            .onDelete(perform: deleteItem)
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showingAddJournalEntryView = true
                }) {
                    Image("AddButton")                         
                        .resizable()
                        .frame(width: 60, height: 60)
                        .shadow(radius: 10)
                }
                .padding()
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let entry = dataManager.journalEntries.sorted { $0.date > $1.date }[index]
            if let entryIndex = dataManager.journalEntries.firstIndex(where: { $0.id == entry.id }) {
                dataManager.journalEntries.remove(at: entryIndex)
            }
        }
    }
}



struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "note.text")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .opacity(0.5)
            Text("No journal entries yet")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
}


struct JournalEntryCard: View {
    var entry: JournalEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            moodIcon
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color(UIColor.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    private var moodIcon: some View {
        Image(systemName: entry.moodDetails.iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(Color(entry.moodDetails.color))
            .background(Circle().fill(Color.white))
            .shadow(radius: 2)
    }
}
