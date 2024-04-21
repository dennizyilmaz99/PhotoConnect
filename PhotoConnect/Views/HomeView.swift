import SwiftUI

struct HomeView: View {
    @State private var showModal: Bool = false
    
    var body: some View {
    VStack{
        VStack{
            Text("Flöde").font(.title).bold().frame(maxWidth: .infinity, alignment: .leading).padding()
        }
        Spacer()
        HStack{
            Button(action: {
                showModal = true
                        print("Upload button tapped")
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .background(Color.blue.opacity(0.5))
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                    }
            }.offset(y: -20)
        }.sheet(isPresented: $showModal) {
            ModalView()
        }
    }
}

private struct ModalView: View {
    var body: some View {
        VStack {
            Text("Lägg upp bild")
                .font(.title3).bold()
                .padding()
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
