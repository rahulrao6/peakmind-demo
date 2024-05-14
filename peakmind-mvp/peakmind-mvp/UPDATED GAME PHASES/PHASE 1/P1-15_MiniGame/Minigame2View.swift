//
//  Minigame2View.swift
//  peakmind-mvp
//
//  Created by James Wilson on 4/7/24.
//

import SwiftUI

struct Minigame2View: View {
    @State private var word: String = "Peace"
    @State private var targetWord: [String] = Array("Hello".uppercased()).map(String.init)
    
    @State private var customKeyColors: [String: Color] = [:]
    @State private var boxColors: [[Color]] = Array(repeating: Array(repeating: Color.gray.opacity(0.3), count: 5), count: 6)
    @State private var letters: [String] = []
    @State private var row: Int = 0
    
    @State private var allRows: [[String]] = [[]]
    
    @State var showsWonAlert = false
    @State var showsLostAlert = false
    
    @State var wonAlertText = "Wow u won"
    @State var lostAlertText = "Wow u LOST! the word was hello"
    var closeAction: () -> Void

    var body: some View {
        ZStack {
            // Background
            Image("MainBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                // Title
                Text("PeakMind WORDLE")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                VStack {
                    WordGameView(boxColors: $boxColors, letters: $letters, row: $row, allRows: $allRows)
                }
                .padding(.bottom, 30)
                Spacer()
                VStack {
                    CustomKeyboardView(checkAnswer: self.checkAnswer, keyColors: $customKeyColors, currentLetters: $letters)
                        .padding(.leading)
                }
                .background(Color
                    .gray.opacity(0.7))
                .padding(.top, 30)
            }
            
        }.onAppear{
            for number in 0...4 {
                boxColors[row][number] = Color.gray.opacity(0.8)
            }
        }
        .alert(isPresented: $showsWonAlert) {
            Alert(
                title: Text(wonAlertText),
                message: nil, // Optional: you can add a message if needed
                primaryButton: .default(Text("Back to Map"), action: {
                    // This code will be executed when the "Perform Action" button is tapped
                    closeAction()
                }),
                secondaryButton: .cancel(Text("Close")) // This button will simply dismiss the alert
            )
        }

    }
    
    func arrToStr (wordArray: [String]) -> String {
        var userWord = ""
        for character in wordArray {
            userWord.append(character)
        }
        return userWord
    }
    
    func checkWordExists(wordArray: [String]) -> Bool {
        var userWord = arrToStr(wordArray: wordArray)
        
        guard let filePath = Bundle.main.path(forResource: "words", ofType: "txt") else {
            print("File not found.")
            return false
        }
        
        do {
            let fileContents = try String(contentsOfFile: filePath)
            
            let wordsArray = fileContents.components(separatedBy: .newlines)
            
            return wordsArray.contains(where: { $0.caseInsensitiveCompare(userWord) == .orderedSame })
        } catch {
            print("An error occurred: \(error)")
            return false
        }
    }
    
    func checkAnswer() {
        if letters.count == 5 {
            if checkWordExists(wordArray: letters) {
                var guessResult = Array(repeating: "Absent", count: letters.count)
                var targetCopy = targetWord
                for (index, letter) in letters.enumerated() {
                    if letter == targetWord[index] {
                        guessResult[index] = "Correct"
                        boxColors[row][index] = .green
                        targetCopy[index] = ""
                    }
                }
                
                for (index, letter) in letters.enumerated() {
                    if guessResult[index] == "Absent",
                       let foundIndex = targetCopy.firstIndex(of: letter), targetCopy[foundIndex] != "" {
                        guessResult[index] = "Present"
                        boxColors[row][index] = .yellow
                        targetCopy[foundIndex] = ""
                    } else if guessResult[index] == "Absent" {
                        boxColors[row][index] = .gray
                    }
                }
                
                
                for letter in Set(letters) {
                    if targetWord.contains(letter) {
                        customKeyColors[letter] = .yellow
                    } else {
                        customKeyColors[letter] = .gray
                    }
                }
                for (index, letter) in letters.enumerated() {
                    if targetWord[index] == letter {                    customKeyColors[letter] = .green
                    }
                }
                
                if guessResult.allSatisfy({ $0 == "Correct" }) {
                    print("Guessed correctly!")
                    wonAlertText = "Nice! You guessed the answer in " + String(allRows.count + 1) + " guesses!"
                    showsWonAlert = true
                    return
                }
                
                if allRows.count > row {
                    allRows[row] = letters
                } else {
                    allRows.append(letters)
                }
                
                if row < boxColors.count - 1 {
                    row += 1
                    letters.removeAll()
                    for number in 0...4 {
                        boxColors[row][number] = Color.gray.opacity(0.8)
                    }
                } else {
                    print("Game Over!")
                    showsWonAlert = true
                    wonAlertText = "Close one! The word was "+word
                }
            } else {
                showsWonAlert = true
                wonAlertText = arrToStr(wordArray: letters) + " is not a word!"
            }
        }
    }
}

struct WordGameView: View {
    @Binding var boxColors: [[Color]]
    @Binding var letters: [String]
    @Binding var row: Int
    @Binding var allRows: [[String]]
    
    var body: some View {
        ForEach(0...5, id: \.self) { number in
            HStack {
                WordGameLineView(boxColors: $boxColors[number], letters: $letters, currentRow: $row, assignedRow: number, allRows: $allRows)
            }
        }
    }
}

struct WordGameLineView: View {
    @Binding var boxColors: [Color]
    @Binding var letters: [String]
    @Binding var currentRow: Int
    var assignedRow: Int
    @Binding var allRows: [[String]]
        
    var body: some View {
        ForEach(0...4, id: \.self) { number in
            if currentRow == assignedRow && letters.indices.contains(number) {
                Rectangle()
                    .fill(boxColors[number])
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text(letters[number])
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .font(.largeTitle)
                            .animation(.easeInOut)
                    )
                    .animation(.easeInOut)
                    .cornerRadius(10)
            } else if allRows.indices.contains(assignedRow) && allRows[assignedRow].indices.contains(number) {
                Rectangle()
                    .fill(boxColors[number])
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text(allRows[assignedRow][number])
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .font(.largeTitle)
                            .animation(.easeInOut)
                    )
                    .animation(.easeInOut)
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(boxColors[number])
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text("")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .font(.largeTitle)
                            .animation(.easeInOut)
                    )
                    .animation(.easeInOut)
                    .cornerRadius(10)
            }
        }
    }
}

struct CustomKeyboardView: View {
    let row1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
    let row2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
    let row3 = ["❌", "Z", "X", "C", "V", "B", "N", "M", "✅"]
        
    var checkAnswer : () -> ()

    @Binding var keyColors: [String: Color]
    @Binding var currentLetters: [String]

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let keyWidth = (screenWidth - (11 * 10)) / 10
            let keyHeight: CGFloat = 50

            VStack(spacing: 10) {
                keyboardRow(keys: row1, keyWidth: keyWidth, keyHeight: keyHeight)
                keyboardRow(keys: row2, keyWidth: keyWidth, keyHeight: keyHeight, leadingSpace: true)
                keyboardRow(keys: row3, keyWidth: keyWidth, keyHeight: keyHeight, leadingSpace: true)
            }
        }.padding(10)
    }

    private func keyboardRow(keys: [String], keyWidth: CGFloat, keyHeight: CGFloat, leadingSpace: Bool = false) -> some View {
        HStack(spacing: 10) {
            if leadingSpace {
                Spacer().frame(width: keyWidth / 4)
            }
            ForEach(keys, id: \.self) { key in
                Button(action: {
                    if key == "✅" {
                        self.checkAnswer()
                    } else if key == "🔙" {
                        if currentLetters.count > 0 {
                            currentLetters.removeLast()
                        }
                    } else {
                        if currentLetters.count < 5 {
                            currentLetters.append(key)
                        }
                    }
                }) {
                    Text(key)
                        .frame(width: keyWidth, height: keyHeight)
                        .background(keyColors[key] ?? Color.white.opacity(0.8))
                        .cornerRadius(5)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .animation(.easeInOut)
                }
            }
        }
    }

    // A function to set a custom color for a key
    private func setKeyColor(for key: String, with color: Color) {
        keyColors[key] = color
    }
}
//
//#Preview {
//    Minigame2View()
//}
