//
//  SpotService.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation
import SwiftUI

class SpotService: ObservableObject {
    private let client = SupabaseService.shared.client
    
    func getSpots(region: String, subRegion: String?, subSubRegion: String?, completion: @escaping ([Spot]) -> Void) {
            Task {
                do {
                    var query = client
                        .from("spots")
                        .select()
                        .eq("region", value: region)

                    if let subRegion = subRegion {
                        query = query.eq("sub_region", value: subRegion)
                    }
                    if let subSubRegion = subSubRegion {
                        query = query.eq("sub_sub_region", value: subSubRegion)
                    }

                    let spots: [Spot] = try await query.execute().value
                    completion(spots)
                } catch {
                    print("Error fetching spots: \(error)")
                    completion([])
                }
            }
        }
    
    func getSpotsByIds(_ spotIds: [UUID]) async throws -> [Spot] {
        guard !spotIds.isEmpty else { return [] }
        
        return try await client
            .from("spots")
            .select()
            .in("id", values: spotIds.map { $0.uuidString }) // Fetch spots matching IDs
            .execute()
            .value
    }
    
    // ✅ Fetch the spot name using a report ID
        func getSpotNameWithReportId(reportID: UUID) async throws -> String? {
            // Step 1: Get spot_id from reports table
            let reportResponse = try await client
                .from("reports")
                .select("spot_id")
                .eq("id", value: reportID)
                .single()
                .execute()

            // ✅ Decode response as JSON
            guard let reportData = try? JSONSerialization.jsonObject(with: reportResponse.data, options: []) as? [String: Any],
                  let spotIdString = reportData["spot_id"] as? String,
                  let spotId = UUID(uuidString: spotIdString) else {
                return nil
            }

            // Step 2: Get spot name from spots table
            let spotResponse = try await client
                .from("spots")
                .select("name")
                .eq("id", value: spotId)
                .single()
                .execute()

            // ✅ Decode spot response
            guard let spotData = try? JSONSerialization.jsonObject(with: spotResponse.data, options: []) as? [String: Any],
                  let spotName = spotData["name"] as? String else {
                return nil
            }

            return spotName
        }
}

