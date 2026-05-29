import SwiftUI
import FirebaseCore
import FirebaseAuth // <-- INI KUNCI UTAMANYA AGAR SWIFT MENGENALI 'userSession'

// 1. Inisialisasi Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

// 2. Layar Pemilah Sesi (Switcher)
struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        Group {
            if authVM.userSession != nil {
                // Jika sedang login dan data role masih loading, tampilkan indikator
                if authVM.isLoading && authVM.currentUser == nil {
                    ZStack {
                        Color.bgCream.ignoresSafeArea()
                        ProgressView("Memuat Data Pengguna...")
                    }
                } else {
                    MainView()
                }
            } else {
                LoginView()
            }
        }
    }
}

// 3. Entry Point Aplikasi
@main
struct YukDebatCuyyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
