import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserModel?

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    init() {
        self.userSession = Auth.auth().currentUser
        fetchUserRole()
    }

    // MARK: - Register
    func register(email: String, password: String, fullName: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) {
            [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
            }

            guard let user = result?.user else { return }

            // PERBAIKAN 1: Menyesuaikan dengan parameter UserModel di dokumenmu
            let newUser = UserModel(
                id: user.uid,
                name: fullName,
                email: email,
                role: .debater,
                isActive: true,
                createdAt: Date()
            )

            // PERBAIKAN 2: Simpan manual pakai Dictionary (TANPA FirebaseFirestoreSwift)
            let userData: [String: Any] = [
                "id": newUser.id,
                "name": newUser.name,
                "email": newUser.email,
                "role": "DEBATER",
                "isActive": newUser.isActive,
                "createdAt": Timestamp(date: newUser.createdAt),
            ]

            self.db.collection("users").document(user.uid).setData(userData) {
                error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Gagal menyimpan data pengguna."
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.userSession = user
                        self.currentUser = newUser
                        self.isLoading = false
                    }
                }
            }
        }
    }

    // MARK: - Login
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) {
            [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
            }

            self.userSession = result?.user
            self.fetchUserRole()
        }
    }

    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch Role & Data (Mapping Manual)
    func fetchUserRole() {
        guard let uid = userSession?.uid else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }

        // PENTING: Gunakan addSnapshotListener agar perubahan Role real-time!
        db.collection("users").document(uid).addSnapshotListener {
            [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = snapshot?.data(),
                    let id = data["id"] as? String,
                    let name = data["name"] as? String,
                    let email = data["email"] as? String
                {

                    let roleStr = data["role"] as? String ?? "DEBATER"
                    let role = UserRole(rawValue: roleStr) ?? .debater
                    let isActive = data["isActive"] as? Bool ?? true
                    let createdAt =
                        (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

                    self?.currentUser = UserModel(
                        id: id,
                        name: name,
                        email: email,
                        role: role,
                        isActive: isActive,
                        createdAt: createdAt
                    )
                }
            }
        }
    }
}
