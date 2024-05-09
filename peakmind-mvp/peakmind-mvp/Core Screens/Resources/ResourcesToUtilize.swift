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
                    LinkButton(title: "SAMSHA Helpline", urlPlaceholder: "https://www.samhsa.gov/find-help/national-helpline")
                    LinkButton(title: "988 Suicide and Crisis Hotline", urlPlaceholder: "https://988lifeline.org/")
                    LinkButton(title: "Crisis Text Line", urlPlaceholder: "https://www.crisistextline.org/")
                    LinkButton(title: "Veteran Crisis Hotline", urlPlaceholder: "https://www.veteranscrisisline.net/")
                    LinkButton(title: "National Domestic Violence Hotline", urlPlaceholder: "https://www.thehotline.org/")
                    LinkButton(title: "Disaster Distress Hotline", urlPlaceholder: "https://www.cdc.gov/disasters/psa/disasterdistresshotline.html#:~:text=The%20Disaster%20Distress%20Helpline%20(1,%2D800%2D985%2D5990.")
                    LinkButton(title: "NEDA", urlPlaceholder: "https://www.nationaleatingdisorders.org/get-help/")
                    LinkButton(title: "Mental Health America Helpline", urlPlaceholder: "https://www.mhanational.org/")
                }
                .frame(width: 350, height: 600) // Increased width and height
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.bottom, 20)
                
                // Emergency Text
                Text("If you have a genuine emergency, call 911")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .padding(.bottom, 20) // Adds space below the text

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
