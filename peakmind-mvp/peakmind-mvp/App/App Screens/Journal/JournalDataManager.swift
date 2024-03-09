import Foundation
import SwiftUI
import Firebase

class JournalDataManager: ObservableObject {
    @Published var journalEntries: [JournalEntry] = []
    private let defaults = UserDefaults.standard
    private let journalKey = "journalEntries"
    
    init() {
        journalEntries = loadJournalEntries()
    }
    
    func addJournalEntry(_ entry: JournalEntry) {
        
        journalEntries.append(entry)
        saveJournalEntries()
    }
    
    func deleteJournalEntry(at indexSet: IndexSet) {
        journalEntries.remove(atOffsets: indexSet)
        saveJournalEntries()
    }
    
    func updateJournalEntry(_ updatedEntry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            journalEntries[index] = updatedEntry
            saveJournalEntries()
        }
    }
    
    func loadJournalEntries() -> [JournalEntry] {
        if let savedEntries = defaults.data(forKey: journalKey),
           let decodedEntries = try? JSONDecoder().decode([JournalEntry].self, from: savedEntries) {
            return decodedEntries
        }
        return []
    }
    
    func saveJournalEntries() {
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            defaults.set(encoded, forKey: journalKey)
        }
    }
}
