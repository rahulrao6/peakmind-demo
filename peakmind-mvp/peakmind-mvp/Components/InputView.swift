//
//  InputView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    var isPickerField = false
    var pickerOptions = ["Option 1", "Option 2"]
    
    var body: some View {
            
            if isSecureField {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .foregroundColor(Color(.black))
                        .fontWeight(.semibold)
                        .font(.footnote)
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 18))
                }
                
            } else if isPickerField {
                HStack {
                    Text(title)
                        .foregroundColor(Color(.black))
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                    Spacer()
                    Picker(title, selection: $text) {
                        ForEach(pickerOptions, id: \.self) {
                            Text($0)
                                .font(.footnote) 
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .foregroundColor(Color(.black))
                        .fontWeight(.semibold)
                        .font(.footnote)
                    TextField(placeholder, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 18))
                }
                
            }
            
            
        
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "name@rajdjagirdar.com")
}
