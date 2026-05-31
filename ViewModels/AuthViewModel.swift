//
//  AuthViewModel.swift
//  YukDebatCuyy
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Manages user authentication state, registration, and user data fetching from Firestore.
class AuthViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserModel?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Private Properties

    private let db = Firestore.firestore()

    // MARK: - Initialization

    init() {
        self.userSession = Auth.auth().currentUser
        fetchUser()
    }

    // MARK: - Methods

    /// Logs in an existing user and fetches their profile data.
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) {
            [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                self?.userSession = result?.user
                self?.fetchUser()  // Wajib dipanggil agar UI Profil terisi
            }
        }
    }

    /// Registers a new user in Firebase Auth and creates a corresponding document in Firestore.
    func register(email: String, password: String, fullName: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) {
            [weak self] result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
                return
            }

            guard let uid = result?.user.uid else { return }

            // Persist user data to Firestore
            let userData: [String: Any] = [
                "id": uid,
                "name": fullName,
                "email": email,
                "role": UserRole.debater.rawValue,  // Default role
                "isActive": true,
                "createdAt": Timestamp(date: Date()),
            ]

            self?.db.collection("users").document(uid).setData(userData) {
                error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    self?.userSession = result?.user
                    self?.fetchUser()  // Tarik data langsung setelah register
                }
            }
        }
    }

    /// Signs out the user and clears local state.
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.userSession = nil
                self.currentUser = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage =
                    "Failed to log out: \(error.localizedDescription)"
            }
        }
    }

    /// Fetches the extended user profile from Firestore securely with real-time updates.
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).addSnapshotListener {
            [weak self] snapshot, error in
            DispatchQueue.main.async {
                // PENAMBAHAN LOGIKA KEAMANAN: Jika data di Firestore hilang/dihapus...
                guard let data = snapshot?.data() else {
                    print(
                        "Error: Document completely missing from Firestore for this UID."
                    )
                    self?.errorMessage =
                        "Sesi tidak valid atau data terhapus. Silakan Register ulang."
                    self?.logout()  // Paksa user keluar agar tidak stuck di loading screen!
                    return
                }

                self?.currentUser = UserModel(
                    id: uid,
                    name: data["name"] as? String ?? "YukDebat User",
                    email: data["email"] as? String ?? "",
                    role: UserRole(
                        rawValue: data["role"] as? String ?? "DEBATER"
                    ) ?? .debater,
                    isActive: data["isActive"] as? Bool ?? true,
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
                        ?? Date()
                )

                if self?.currentUser?.isActive == false {
                    self?.errorMessage =
                        "Akun Anda telah ditangguhkan (Suspend) oleh Administrator."
                    self?.logout()
                }
            }
        }
    }
}
