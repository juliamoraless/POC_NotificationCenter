import SwiftUI
import UserNotifications

struct ContentView: View {
    var pets = [
        Pet(name: "Mel 🐩"),
        Pet(name: "Bono 🐕"),
        Pet(name: "Kayla 🐕‍🦺") ]
        
    var body: some View {
        VStack {
            Text("Passear com os Pets")
                .font(.title2)
            ForEach(pets.indices, id: \.self) { index in
                CheckButton(pet: pets[index])
            }
        }
        .padding()
    }
}

struct CheckButton: View {
    @ObservedObject var pet: Pet
    
    var body: some View {
        HStack {
            Text(pet.name)
            Spacer()
            Button {
                postNotification(pet)
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(pet.isTapped ? .green : .red)
                    .frame(width: 70, height: 30)
                    .overlay(Text(pet.isTapped ? "Já fui" : "Não fui")
                        .foregroundStyle(.white)
                        .bold())
            }
        }
    }
    
    func postNotification(_ pet: Pet) {
        NotificationCenter.default.post(name: .changeButtonColor, object: nil, userInfo: ["petName": pet.name])
    }
}


class Pet: ObservableObject {
    var name: String
    @Published var isTapped: Bool = false
    
    init(name: String) {
        self.name = name
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeButton),
                                               name: .changeButtonColor,
                                               object: nil)
        
    }
    
    @objc func changeButton(_ notification: Notification) {
        if let petName = notification.userInfo?["petName"] as? String {
            if self.name == petName {
                self.isTapped.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
}
