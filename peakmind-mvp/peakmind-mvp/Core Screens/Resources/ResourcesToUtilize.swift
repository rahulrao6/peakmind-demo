import SwiftUI

struct ResourcesToUtilize: View {
    var body: some View {
        ZStack {
            // Background
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            VStack {
                // Title
                Text("Resources to Utilize")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                // Resource Box
                VStack(spacing: 20) {
                    // Placeholder Buttons
                    LinkButton(title: "Resource 1", urlPlaceholder: "Link 1")
                    LinkButton(title: "Resource 2", urlPlaceholder: "Link 2")
                    LinkButton(title: "Resource 3", urlPlaceholder: "Link 3")
                    LinkButton(title: "Resource 4", urlPlaceholder: "Link 4")
                    LinkButton(title: "Resource 5", urlPlaceholder: "Link 5")
                    LinkButton(title: "Resource 6", urlPlaceholder: "Link 6")
                    LinkButton(title: "Resource 7", urlPlaceholder: "Link 7")
                    LinkButton(title: "Resource 8", urlPlaceholder: "Link 8")
                }
                .frame(width: 350, height: 600) // Increased width and height
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.bottom, 20)
                
                Spacer()
            }
        }
    }
}

struct LinkButton: View {
    var title: String
    var urlPlaceholder: String

    var body: some View {
        Button(action: {
            // Action for link navigation
            print("Navigate to \(urlPlaceholder)")
        }) {
            Text(title)
                .foregroundColor(.black)
                .frame(width: 320, height: 50) // Adjusted to fit new box dimensions
                .background(Color("Ice Blue"))
                .cornerRadius(25)
        }
    }
}

struct ResourcesToUtilize_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesToUtilize()
    }
}
