//
//  EvaluationViewModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation
import Combine

/// Handles adjudicator scoring logic and validation (UC04).
/// Encapsulates BP standard validations to prevent invalid data pollution in the database.
class EvaluationViewModel: ObservableObject {
    
    @Published var errorMessage: String? = nil
    @Published var isSubmissionSuccessful: Bool = false
    
    private let dbService: FirestoreServiceProtocol
    
    // Dependency Injection
    init(dbService: FirestoreServiceProtocol) {
        self.dbService = dbService
    }
    
    func submitScore(evaluationId: String, score: Int, feedback: String) {
        // Strategy 1: Validation rejection (Business Rule)
        guard score >= 50 && score <= 100 else {
            self.errorMessage = "Ditolak: Skor debat format BP harus berada di rentang 50 hingga 100."
            return
        }
        
        // Strategy 2: Proceed with authorized upload
        Task {
            do {
                let data: [String: Any] = ["score": score, "feedback": feedback]
                try await dbService.saveDocument(collection: "evaluations", documentId: evaluationId, data: data)
                
                DispatchQueue.main.async {
                    self.isSubmissionSuccessful = true
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Gagal mengirim evaluasi: \(error.localizedDescription)"
                }
            }
        }
    }
}
