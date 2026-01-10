//
//  AIService.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/5/26.
//

import Foundation
/*
struct AIDailySuggestion {
    let message: String
    let suggestedGoals: [String]
}

class AIService {

    private let apiKey = "YOUR_OPENAI_API_KEY"

    func getDailySuggestion(
        mood: Mood,
        adjustment: AdjustmentType,
        goals: [String]
    ) async throws -> AIDailySuggestion {

        let prompt = buildPrompt(
            mood: mood,
            adjustment: adjustment,
            goals: goals
        )

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.4
        ]

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        let content = response.choices.first?.message.content ?? ""

        return parseAIResponse(content)
    }
    
}
*/
