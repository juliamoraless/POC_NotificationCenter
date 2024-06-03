import SwiftUI
import UserNotifications

struct ContentView: View {
    @State var pets = [
        Pet(name: "Mel 🐩", description: "Tem medo de pássaros!"),
        Pet(name: "Bono 🐕", description: "Cuidado com gatos!"),
        Pet(name: "Kayla 🐕‍🦺", description: "Adora fazer amizades!") ]
    
    var body: some View {
        VStack {
            Text("Notificação Pets")
                .font(.title2)
            ForEach($pets.indices, id: \.self) { index in
                Toggle(pets[index].name, isOn: $pets[index].notificate)
            }
        }
        .padding()
    }
}

class Pet {
    var name: String
    var description: String
    var notificate: Bool = false {
        willSet {
            if newValue {
                requestNotificationAuthorization()
                checkNotificationAuthorization()
            }
        }
    }
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permissão para notificações concedida com sucesso!")
            } else if let error {
                print("Erro ao solicitar permissão para notificações:", error.localizedDescription)
            }
        }
    }
    
    func checkNotificationAuthorization() {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .authorized:
                        print("Permissão para notificações foi concedida.")
                        self.scheduleNotfication(name: self.name, description: self.description)
                    case .denied:
                        print("Permissão para notificações foi negada. Vá em configurações e autorize por favor.")
                    case .notDetermined:
                        print("Permissão está sendo solicitada")
                        self.scheduleNotfication(name: self.name, description: self.description)
                    case .provisional:
                        print("Permissão para notificações concedida de forma provisória.")
                    case .ephemeral:
                        print("case unUsed")
                    @unknown default:
                        print("Caso desconhecido.")
                    }
                }
            }
    
    func scheduleNotfication(name: String, description: String) {
        
            let content = UNMutableNotificationContent()
            content.title = "Hora de passear com \(name)"
            content.subtitle = description
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        
    }
    
    
}

#Preview {
    ContentView()
}
