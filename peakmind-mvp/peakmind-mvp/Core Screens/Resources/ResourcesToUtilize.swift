import SwiftUI

struct ResourcesToUtilize: View {
    var body: some View {
        ZStack {
            // Background with Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Spacer()
                
                // Title
                Text("Resources")
                    .font(.custom("SFProText-Heavy", size: 32))
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
                    .padding(.leading, 36)
                
                // Informative text
                Text("If you are experiencing a mental health emergency, please call 911. All resources listed take you to the organization's website.")
                    .font(.custom("SFProText-Bold", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    //.padding(.leading, 20)

                
                // Resource Buttons
                VStack(spacing: 13) {
                    LinkButton(title: "988 Suicide and Crisis Hotline", url: "https://988lifeline.org/")
                    LinkButton(title: "Crisis Text Line", url: "https://www.crisistextline.org/")
                    LinkButton(title: "NEDA", url: "https://www.nationaleatingdisorders.org/get-help/")
                    LinkButton(title: "National Domestic Violence Hotline", url: "https://www.thehotline.org/")
                    LinkButton(title: "Mental Health America Helpline", url: "https://www.mhanational.org/")
                    LinkButton(title: "SAMHSA Helpline", url: "https://www.samhsa.gov/find-help/national-helpline")
                    LinkButton(title: "Veteran Crisis Hotline", url: "https://www.veteranscrisisline.net/")
                }
                .padding(.horizontal, 20) // Align buttons with equal padding on both sides
                
                Spacer()
            }
        }
    }
}

struct LinkButton: View {
    var title: String
    var url: String

    var body: some View {
        Button(action: {
            openLink(urlString: url)
        }) {
            HStack {
                // Text left-aligned and supporting multiple lines
                Text(title)
                    .foregroundColor(.white)
                    .font(.custom("SFProText-Bold", size: 18))
                    .multilineTextAlignment(.leading) // Align both lines to the left
                    .lineLimit(nil) // Allow multiple lines if needed
                    .padding(.leading, 20)
                
                Spacer() // Push the arrow to the right
                
                // Arrow on the right side
                Image(systemName: "arrow.right")
                    .foregroundColor(Color(hex: "b0e8ff")!)
                    .padding(.trailing, 20)
            }
            .frame(width: 340, height: 65) // Wider and taller buttons
            .background(Color(hex: "0b1953")!)
            .cornerRadius(12)
            .padding(.horizontal, 10) // Equal padding on both sides
        }
    }

    func openLink(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

struct ResourcesToUtilize_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesToUtilize()
    }
}
