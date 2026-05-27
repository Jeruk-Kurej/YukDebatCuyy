//
//  CloudFunctionsProtocol.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Handles secure serverless execution blocks for proxying external APIs.
protocol CloudFunctionsProtocol {
    func callExternalAPI(endpoint: String, parameters: [String: Any]) async throws -> [String: Any]
    func triggerCronScheduler() async throws
}
