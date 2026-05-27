import Foundation
import Combine

/// Coordinates the real-time sparring lobby state and matchmaking intents (UC02).
/// Safely manages solo and dual-slot team registrations inside British Parliamentary format constraints.
class SparringViewModel: ObservableObject {
    
    @Published var lobbyRooms: [SparringRoomModel] = []
    @Published var activeRoom: SparringRoomModel? = nil
    @Published var alertMessage: String? = nil
    @Published var errorMessage: String? = nil
    
    @Published var isShowingCreateRoom: Bool = false
    
    // Temporary Form Data
    @Published var formMotionCategory: String = "Hukum & Konstitusi"
    @Published var formScheduledTime: Date = Date().addingTimeInterval(3600)
    @Published var formMeetingLink: String = ""
    @Published var formSpecialNotes: String = ""
    @Published var formIsPrivate: Bool = false
    
    @Published var pendingRequests: [String: [ParticipantModel]] = [:]
    
    let currentUserId = "user_me"
    private let dbService: FirestoreServiceProtocol
    
    init(dbService: FirestoreServiceProtocol) {
        self.dbService = dbService
    }
    
    func listenToRoom(roomId: String) {
        let roomPublic = SparringRoomModel(
            id: "room_public_1", hostId: "user_mario_123", scheduledTime: Date().addingTimeInterval(7200),
            motionCategory: "Pendidikan", specialNotes: "Latihan BP standar NUDC. Wajib aktif kamera.",
            needAdjudicator: true, meetingLink: "https://zoom.us/j/dummy",
            accessType: .publicAccess, state: .preparing, participants: []
        )
        
        let roomPrivate = SparringRoomModel(
            id: "room_private_1", hostId: "user_keane_99", scheduledTime: Date().addingTimeInterval(86400),
            motionCategory: "Ekonomi & Bisnis", specialNotes: "Latihan internal tim delegasi fakultas.",
            needAdjudicator: true, meetingLink: "https://meet.google.com/dummy",
            accessType: .privateAccess, state: .preparing, participants: []
        )
        self.lobbyRooms = [roomPublic, roomPrivate]
    }
    
    func isUserInRoom(room: SparringRoomModel) -> Bool {
        return room.participants.contains(where: { $0.userId == currentUserId })
    }
    
    func isUserHost(room: SparringRoomModel) -> Bool {
        return room.hostId == currentUserId
    }
    
    func isUserPending(room: SparringRoomModel) -> Bool {
        return pendingRequests[room.id]?.contains(where: { $0.userId == currentUserId }) ?? false
    }
    
    func submitRoomForm() {
        guard !formMeetingLink.isEmpty else { self.errorMessage = "Meeting Link tidak boleh kosong."; return }
        
        let newRoom = SparringRoomModel(
            id: UUID().uuidString, hostId: self.currentUserId, scheduledTime: self.formScheduledTime,
            motionCategory: self.formMotionCategory, specialNotes: self.formSpecialNotes,
            needAdjudicator: true, meetingLink: self.formMeetingLink,
            accessType: self.formIsPrivate ? .privateAccess : .publicAccess,
            state: .preparing, participants: []
        )
        self.lobbyRooms.insert(newRoom, at: 0)
        self.isShowingCreateRoom = false
        self.alertMessage = "Ruang sparring berhasil dibuat!"
    }
    
    func requestJoin(roomId: String, role: RoleSlotType, isTeam: Bool) {
        guard let index = lobbyRooms.firstIndex(where: { $0.id == roomId }) else { return }
        let room = lobbyRooms[index]
        
        // Proteksi Kapasitas Maksimal BP (8 Slot Pembicara)
        if room.participants.count >= 8 {
            self.errorMessage = "Gagal bergabung: Ruangan sudah penuh."
            return
        }
        
        // Pendaftaran Tim butuh minimal 2 slot kosong
        if isTeam && room.participants.count > 6 {
            self.errorMessage = "Gagal bergabung: Sisa slot tidak cukup untuk satu tim penuh (butuh 2 slot)."
            return
        }
        
        let regMode: RegMode = isTeam ? .team : .solo
        let newParticipant = ParticipantModel(userId: currentUserId, roleSlot: role, regMode: regMode)
        let teammate = ParticipantModel(userId: "rekan_tim_anda", roleSlot: role, regMode: regMode)
        
        if room.accessType == .privateAccess {
            // Skenario Ruang Privat: Ditampung ke antrean pending
            var currentPending = pendingRequests[roomId] ?? []
            currentPending.append(newParticipant)
            if isTeam { currentPending.append(teammate) }
            pendingRequests[roomId] = currentPending
            
            self.alertMessage = "Permintaan bergabung dikirim! Menunggu persetujuan Host."
        } else {
            // Skenario Ruang Publik: Langsung memotong slot ruangan
            self.lobbyRooms[index].participants.append(newParticipant)
            if isTeam {
                self.lobbyRooms[index].participants.append(teammate)
                self.alertMessage = "Berhasil bergabung! 2 slot (Anda + Rekan) telah diamankan."
            } else {
                self.alertMessage = "Berhasil bergabung secara individu!"
            }
            self.errorMessage = nil
        }
    }
    
    func acceptRequest(roomId: String, participantId: String) {
        guard let roomIndex = lobbyRooms.firstIndex(where: { $0.id == roomId }) else { return }
        guard let pendingList = pendingRequests[roomId] else { return }
        
        // Ambil semua partisipan dari user tersebut (termasuk rekan setim jika mendaftar sebagai tim)
        let matchedRequests = pendingList.filter { $0.userId == participantId || $0.userId == "rekan_tim_anda" }
        
        for participant in matchedRequests {
            lobbyRooms[roomIndex].participants.append(participant)
        }
        
        // Bersihkan dari antrean pending
        pendingRequests[roomId]?.removeAll(where: { $0.userId == participantId || $0.userId == "rekan_tim_anda" })
        self.alertMessage = "Permintaan tim/individu berhasil disetujui masuk lobi."
    }
    
    func rejectRequest(roomId: String, participantId: String) {
        pendingRequests[roomId]?.removeAll(where: { $0.userId == participantId || $0.userId == "rekan_tim_anda" })
        self.alertMessage = "Permintaan bergabung ditolak."
    }
    
    func leaveRoom(roomId: String) {
        guard let index = lobbyRooms.firstIndex(where: { $0.id == roomId }) else { return }
        self.lobbyRooms[index].participants.removeAll(where: { $0.userId == self.currentUserId || $0.userId == "rekan_tim_anda" })
        self.alertMessage = "Kamu telah keluar dari ruang sparring."
    }
    
    func triggerStart(roomId: String) {
        guard let index = lobbyRooms.firstIndex(where: { $0.id == roomId }) else { return }
        self.lobbyRooms[index].state = .ongoing
    }
}
