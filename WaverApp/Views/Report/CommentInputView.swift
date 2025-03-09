//
//  CommentInputView.swift
//  Waver
//
//  Created by Quincy Keele on 2/21/25.
//

import SwiftUI

struct CommentInputView: View {
    @Binding var comment: String
    @FocusState private var isInputActive: Bool
    @Environment(\.scenePhase) private var scenePhase // Detects app lifecycle

    private let characterLimit = 1100
    private let lineBreakLimit = 12

    var body: some View {
        VStack(spacing: 8) {
            Text("Comment")
                .font(.headline)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                TextEditor(text: $comment)
                    .frame(height: 100)
                    .padding(12)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                    .focused($isInputActive)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(UIColor.separator), lineWidth: 0.5)
                    )
                    .keyboardType(.default)
                    .onChange(of: comment) { oldValue, newValue in
                        comment = enforceCommentLimits(newValue)
                    }

                Button {
                    isInputActive = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            // Character count display
            Text("\(comment.count)/\(characterLimit)")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .padding(.bottom, 8)
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isInputActive = true
                }
            }
        }
    }

    /// ✅ **Enforces character and line break limits**
    private func enforceCommentLimits(_ input: String) -> String {
        var newText = input

        // ✅ Limit character count to 2200
        if newText.count > characterLimit {
            newText = String(newText.prefix(characterLimit))
        }

        // ✅ Limit new line (`\n`) count to 25
        let lines = newText.components(separatedBy: "\n")
        if lines.count > lineBreakLimit {
            newText = lines.prefix(lineBreakLimit).joined(separator: "\n") // Keep first 25 lines
        }

        return newText
    }
}
