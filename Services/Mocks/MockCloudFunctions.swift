//
//  MockCloudFunctions.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Concrete mock gateway simulating cloud function edge executions.
class MockCloudFunctions: CloudFunctionsProtocol {
    // MARK: - Methods
    func callExternalAPI(endpoint: String, parameters: [String: Any]) async throws -> [String: Any] {
        try await Task.sleep(nanoseconds: 800_000_000) // Simulasi loading API
        return [
            "id": "motion_001",
            "title": "Dewan ini akan mewajibkan kuota berbasis gender di parlemen",
            "category": "Politik & Sosial"
        ]
    }
    
    func triggerCronScheduler() async throws {
        print("Mock: Triggered background cron job to cancel empty rooms.")
    }
}
