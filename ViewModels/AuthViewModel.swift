import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Manages authentication states, user registration, and role-based access checks.
class AuthViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let db = Firestore.firestore()

    // MARK: - Initialization
    init() {
        self.userSession = Auth.auth().currentUser
        fetchUserRole()
    }

    // MARK: - Methods
    /// Registers a new user and creates their secure document in Firestore.
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

            let newUser = UserModel(
                id: user.uid,
                name: fullName,
                email: email,
                role: .debater,
                isActive: true,
                createdAt: Date()
            )

            let userData: [String: Any] = [
                "id": newUser.id, "name": newUser.name, "email": newUser.email,
                "role": "DEBATER", "isActive": newUser.isActive,
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

    /// Authenticates a user and retrieves their active roles.
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

    /// Signs the user out from Firebase Session securely.
    func logout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    /// Listens for real-time changes to the user's role (e.g., when approved as an Adjudicator).
    func fetchUserRole() {
        guard let uid = userSession?.uid else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }

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
