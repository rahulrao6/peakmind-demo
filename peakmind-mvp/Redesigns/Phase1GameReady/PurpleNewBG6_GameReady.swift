import SwiftUI
import UIKit
// Custom TextView with toolbar and clear background
struct TextViewWithToolbar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isFocused: Bool
    var onTap: () -> Void
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWithToolbar
        init(_ parent: TextViewWithToolbar) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor(named: "PurpleTextColor") // Set to PurpleTextColor
            }
            parent.onTap() // Notify when editing begins to set the focused field
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.lightGray
            }
        }
        @objc func doneButtonTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        // Add the toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        // Flexible space to move the Done button to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneButtonTapped))
        toolbar.items = [flexibleSpace, doneButton] // Done button is now on the right
        textView.inputAccessoryView = toolbar
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear // Make the background clear
        textView.textColor = text.isEmpty ? UIColor.lightGray : UIColor(named: "PurpleTextColor") // Set text color to PurpleTextColor
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        } else {
            textView.text = text
            textView.textColor = UIColor(named: "PurpleTextColor") // Set to PurpleTextColor
        }
        // Adjust padding for left and right
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24) // Added extra padding on left and right
        textView.textContainer.lineBreakMode = .byWordWrapping // Ensure text wraps within the box
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = text.isEmpty ? UIColor.lightGray : UIColor(named: "PurpleTextColor") // Set text color to PurpleTextColor
    }
}
// Main View
struct P6_1: View {
    var closeAction: (String) -> Void
    @State private var negativeThought: String = ""
    @State private var positiveThought: String = ""
    @State private var navigateToNextScreen = false
    @State private var isKeyboardVisible: Bool = false
    @State private var currentIndex: Int = 0
    @State private var visibleText: String = ""
    @State private var isTypingCompleted: Bool = false
    @State private var focusedField: String? = nil
    let introText = """
    Let’s flip negative thoughts into something more positive. This exercise will help you challenge and reframe the way you think.
    Start by picking a recent negative thought (e.g., “I never get anything right”). Reframe the thought to be more positive (e.g., “I may not be perfect, but I’m learning and improving all the time.”).
    """
    var areBothTextFieldsFilled: Bool {
        return !negativeThought.isEmpty && !positiveThought.isEmpty
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("PurpleNewBG")
                    .resizable()
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 36) {
                    Spacer()
                        .frame(height: 10)
                    Text("Reframe Exercise")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("PurpleTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                            )
                        ScrollViewReader { proxy in
                            ScrollView {
                                Text(visibleText)
                                    .font(.custom("SFProText-Medium", size: 16))
                                    .foregroundColor(Color("PurpleTextColor"))
                                    .multilineTextAlignment(.leading)
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .onChange(of: visibleText) { _ in
                                        withAnimation {
                                            proxy.scrollTo("end", anchor: .bottom)
                                        }
                                    }
                                Color.clear.frame(height: 1).id("end")
                            }
                        }
                        .onAppear {
                            typeText()
                        }
                    }
                    .frame(height: geometry.size.height * 0.3)
                    .padding(.horizontal, 20)
                    VStack(spacing: 12) {
                        ThoughtTextEditor(
                            text: $negativeThought,
                            placeholder: " Negative Thought",
                            isFocused: focusedField == "negative" && isKeyboardVisible,
                            onTap: { focusedField = "negative" }
                        )
                        ThoughtTextEditor(
                            text: $positiveThought,
                            placeholder: " Positive Thought",
                            isFocused: focusedField == "positive" && isKeyboardVisible,
                            onTap: { focusedField = "positive" }
                        )
                    }
                    .padding(.horizontal, 20)
                    Button(action: {
                        closeAction("Negative Thought: \(negativeThought) | Positive Thought: \(positiveThought)")
                    }) {
                        Text("Continue")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: areBothTextFieldsFilled ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0)
                    }
                    .padding(.top, 16)
                    .disabled(!areBothTextFieldsFilled)
                    .background(
                        NavigationLink(
                            destination: CauseEffectView(),
                            isActive: $navigateToNextScreen,
                            label: { EmptyView() }
                        )
                    )
                    Spacer()
                }
                .padding(.horizontal)
                .onAppear {
                    setupKeyboardObservers()
                }
            }
        }
    }
    private func typeText() {
        visibleText = ""
        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if charIndex < introText.count {
                let index = introText.index(introText.startIndex, offsetBy: charIndex)
                visibleText.append(introText[index])
                charIndex += 1
            } else {
                timer.invalidate()
                isTypingCompleted = true
            }
        }
    }
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            isKeyboardVisible = true
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            isKeyboardVisible = false
        }
    }
}
// ThoughtTextEditor using TextViewWithToolbar with toolbar and Done button
struct ThoughtTextEditor: View {
    @Binding var text: String
    var placeholder: String
    var isFocused: Bool
    var onTap: () -> Void
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                )
                .frame(height: isFocused ? 90 : 70) // Dynamically adjust height based on focus
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.leading, 16)
                    .padding(.top, 20)
            }
            TextViewWithToolbar(text: $text, placeholder: placeholder, isFocused: isFocused) {
                onTap()
            }
            .padding(EdgeInsets(top: 10, leading: -8, bottom: 12, trailing: -10)) // Adjusted padding to start a little from left and end to the right
            .frame(maxHeight: isFocused ? 90 : 70) // Keep the text editor height inside the gradient box
        }
    }
}
struct ReframeExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ReframeExerciseView()
    }
}
