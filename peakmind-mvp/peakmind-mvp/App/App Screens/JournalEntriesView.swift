import SwiftUI
import Firebase

struct JournalEntriesView: View {
    @EnvironmentObject var dataManager: JournalDataManager
    @EnvironmentObject var viewModel : AuthViewModel
    @State var journalEntries: [JournalEntry] = []
    @State private var showingAddJournalEntryView = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)

                if journalEntries.isEmpty {
                    EmptyStateView() // Assumes definition elsewhere
                } else {
                    entriesList
                }
                
                addButton
            }
            .navigationTitle("Journal Entries")
            .onAppear{
                fetchJournalEntries()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
                fetchJournalEntries()
            }
            .sheet(isPresented: $showingAddJournalEntryView, onDismiss: {
                fetchJournalEntries()
            }) {
                JournalView().environmentObject(dataManager)
            }
        }
    }

    private var entriesList: some View {
        List {
            ForEach(journalEntries.sorted { $0.date > $1.date }, id: \.id) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    JournalEntryCard(entry: entry) // Assumes definition elsewhere
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
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                .padding()
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        guard let currentUser = viewModel.currentUser else {
            print("Current user not found.")
            return
        }
        
        let db = Firestore.firestore()
        
        offsets.forEach { index in
            let entry = journalEntries.sorted { $0.date > $1.date }[index]
            
            let entryRef = db.collection("users").document(currentUser.id).collection("journal_entries").document(entry.id)
            
            entryRef.delete { error in
                if let error = error {
                    print("Error deleting document: \(error)")
                } else {
                    // Remove the entry from the local array
                    if let entryIndex = journalEntries.firstIndex(where: { $0.id == entry.id }) {
                        journalEntries.remove(at: entryIndex)
                    }
                }
            }
        }
    }
    
    
    private func fetchJournalEntries() {
        guard let currentUser = viewModel.currentUser else {
            print("Current user not found.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.id).collection("journal_entries").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.journalEntries = documents.compactMap { document in
                do {
                    let entry = try document.data(as: JournalEntry.self)
                    return entry
                } catch {
                    print("Error decoding journal entry: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }}



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


