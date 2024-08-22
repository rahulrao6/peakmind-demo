//
//  FontChecker.swift
//  peakmind-mvp
//
//  Created by ZA on 8/21/24.
//

import SwiftUI

struct FontListView: View {
    var body: some View {
        List {
            ForEach(UIFont.familyNames.sorted(), id: \.self) { familyName in
                Section(header: Text(familyName).font(.headline)) {
                    ForEach(UIFont.fontNames(forFamilyName: familyName).sorted(), id: \.self) { fontName in
                        Text(fontName)
                            .font(.custom(fontName, size: 16))
                    }
                }
            }
        }
    }
}

struct FontListView_Previews: PreviewProvider {
    static var previews: some View {
        FontListView()
    }
}
