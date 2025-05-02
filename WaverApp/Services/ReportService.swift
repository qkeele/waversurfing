//
//  ReportService.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation
import Supabase

class ReportService: ObservableObject {
    private let client = SupabaseService.shared.client
    
    // ✅ Fetch ALL reports from Supabase
    func fetchAllReports() async throws -> [Report] {
        return try await client
            .from("reports")
            .select()
            .execute()
            .value
    }
    
    func addReport(forUser userId: UUID, spotId: UUID, rating: Int, height: Int, crowd: Int, comment: String?, visibility: String?) async throws {
        let newReport = Report(
            id: UUID(),
            user_id: userId,
            spot_id: spotId,
            rating: rating,
            height: height,
            crowd: crowd,
            comment: comment,
            timestamp: Date(), 
            visibility: visibility
        )

        try await client
            .from("reports")
            .insert(newReport)
            .execute()
    }
    
    func fetchReportsForUser(userId: UUID) async throws -> [Report] {
        let responseData = try await client
            .from("reports")
            .select("id, user_id, spot_id, rating, height, crowd, comment, timestamp::text") // ✅ Force timestamp to text
            .eq("user_id", value: userId)
            .order("timestamp", ascending: false)
            .execute()
            .data

        let reports = try Report.decoder.decode([Report].self, from: responseData) // ✅ Use custom decoder
        return reports
    }
    
    func fetchLastReportForUser(userId: UUID) async throws -> Report? {
        let responseData = try await client
            .from("reports")
            .select("id, user_id, spot_id, rating, height, crowd, comment, timestamp::text")
            .eq("user_id", value: userId)
            .order("timestamp", ascending: false)
            .limit(1)
            .execute()
            .data

        let reports = try Report.decoder.decode([Report].self, from: responseData)
        return reports.first
    }
    
    func canUserSubmitReport(userId: UUID) async throws -> Bool {
        guard let lastReport = try await fetchLastReportForUser(userId: userId) else {
            return true // ✅ No previous report, allow submission
        }

        // ✅ `lastReport.timestamp` is already a Date, no conversion needed
        return Date().timeIntervalSince(lastReport.timestamp) >= 1800
    }
    
    func fetchReportsForSpotToday(spotId: UUID) async throws -> [Report] {
        // ✅ Get today's date at midnight
        let today = Calendar.current.startOfDay(for: Date())

        // ✅ Define a DateFormatter to match "yyyy-MM-dd HH:mm:ss"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // ✅ Matches Supabase format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC consistency

        let todayString = formatter.string(from: today) // ✅ Convert to string format

        let responseData = try await client
            .from("reports")
            .select("id, user_id, spot_id, rating, height, crowd, comment, timestamp::text")
            .eq("spot_id", value: spotId)
            .gte("timestamp", value: todayString)
            .order("timestamp", ascending: false)
            .execute()
            .data

        let reports = try Report.decoder.decode([Report].self, from: responseData)
        return reports
    }
    
    func fetchFriendReports(authId: UUID) async throws -> [Report] {
        let client = SupabaseService.shared.client

        // Format today’s date (UTC midnight)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let todayString = formatter.string(from: Calendar.current.startOfDay(for: Date()))

        // Step 1: Get all friend user_ids for this auth_id
        let friendResponse = try await client
            .rpc("get_accepted_friends", params: ["user_id": authId.uuidString])
            .execute()

        struct FriendUser: Decodable { let id: UUID }
        let friendUsers = try JSONDecoder().decode([FriendUser].self, from: friendResponse.data)
        let friendUserIds = friendUsers.map { $0.id }

        guard !friendUserIds.isEmpty else { return [] }

        // Step 2: Query reports for all those friends
        let response = try await client
            .from("reports")
            .select("id, user_id, spot_id, rating, height, crowd, comment, timestamp::text, visibility")
            .in("user_id", values: friendUserIds)
            .gte("timestamp", value: todayString)
            .order("timestamp", ascending: false)
            .execute()

        return try Report.decoder.decode([Report].self, from: response.data)
    }
}
