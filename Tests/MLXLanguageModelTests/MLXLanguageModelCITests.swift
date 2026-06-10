import Foundation
import Testing

@testable import AnyLanguageModel

#if MLX
@Suite("MLXLanguageModel CI", .enabled(if: MLXTestEnvironment.shouldRun), .serialized)
struct MLXLanguageModelCITests {
    private let modelId = ProcessInfo.processInfo.environment["MLX_TEST_MODEL_ID"]
        ?? "mlx-community/Qwen3-0.6B-4bit"

    private var shortOptions: GenerationOptions {
        GenerationOptions(temperature: 0.2, maximumResponseTokens: 32)
    }

    @Test("basic generation returns non-empty text")
    func basicGeneration() async throws {
        await MLXLanguageModel.removeAllFromCache()

        let model = MLXLanguageModel(modelId: modelId)
        let session = LanguageModelSession(model: model)

        let response = try await session.respond(
            to: "Reply with one short friendly sentence.",
            options: shortOptions
        )

        let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(!text.isEmpty)
        #expect(text.count > 3)
        #expect(model.isAvailable)
    }

    @Test("streaming yields at least one non-empty chunk")
    func streamingGeneration() async throws {
        let model = MLXLanguageModel(modelId: modelId)
        let session = LanguageModelSession(model: model)

        var chunks: [String] = []
        for try await partial in session.streamResponse(
            to: "Count from 1 to 5, separated by commas.",
            options: shortOptions
        ) {
            let text = partial.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                chunks.append(text)
            }
        }

        #expect(!chunks.isEmpty)
    }

    @Test("same session supports sequential turns")
    func sequentialTurnsSameSession() async throws {
        let model = MLXLanguageModel(modelId: modelId)
        let session = LanguageModelSession(model: model)

        let first = try await session.respond(
            to: "Remember this word: kiwi.",
            options: shortOptions
        )
        let second = try await session.respond(
            to: "Reply with one short sentence.",
            options: shortOptions
        )

        #expect(!first.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        #expect(!second.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    @Test("same session rejects concurrent generation")
    func rejectsConcurrentGenerationForSameSession() async throws {
        let model = MLXLanguageModel(modelId: modelId)
        let session = LanguageModelSession(model: model)

        let stream = session.streamResponse(
            to: "Count from 1 to 200 with one number per line.",
            options: GenerationOptions(temperature: 0.2, maximumResponseTokens: 192)
        )

        do {
            _ = try await session.respond(
                to: "This second request should be rejected while the stream is active.",
                options: shortOptions
            )
            Issue.record("Expected same-session concurrent generation to throw.")
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .concurrentRequests:
                break
            default:
                Issue.record("Expected .concurrentRequests, got \\(error)")
            }
        } catch {
            Issue.record("Expected GenerationError.concurrentRequests, got \\(error)")
        }

        for try await _ in stream {
            break
        }
    }

    @Test("different sessions can generate independently")
    func differentSessionsCanGenerateIndependently() async throws {
        let model = MLXLanguageModel(modelId: modelId)
        let sessionA = LanguageModelSession(model: model)
        let sessionB = LanguageModelSession(model: model)

        async let first = sessionA.respond(
            to: "Say hello in one short sentence.",
            options: shortOptions
        )
        async let second = sessionB.respond(
            to: "Say goodbye in one short sentence.",
            options: shortOptions
        )

        let outputs = try await [first.content, second.content]
        #expect(outputs.count == 2)
        #expect(outputs.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
    }

    @Test("stream cancellation releases session for later generation")
    func streamCancellationReleasesSession() async throws {
        let model = MLXLanguageModel(modelId: modelId)
        let session = LanguageModelSession(model: model)

        let stream = session.streamResponse(
            to: "Count slowly from 1 to 100.",
            options: GenerationOptions(temperature: 0.2, maximumResponseTokens: 128)
        )

        for try await _ in stream {
            break
        }

        let response = try await session.respond(
            to: "Now say done.",
            options: shortOptions
        )

        #expect(!response.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    @Test("cache can be cleared and model can generate again")
    func cacheClearThenGenerateAgain() async throws {
        let model = MLXLanguageModel(modelId: modelId)

        let firstSession = LanguageModelSession(model: model)
        let first = try await firstSession.respond(
            to: "Say alpha.",
            options: shortOptions
        )

        await model.removeFromCache()

        let secondSession = LanguageModelSession(model: model)
        let second = try await secondSession.respond(
            to: "Say beta.",
            options: shortOptions
        )

        #expect(!first.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        #expect(!second.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    @Test("invalid model id fails cleanly")
    func invalidModelIdFailsCleanly() async throws {
        let model = MLXLanguageModel(modelId: "mlx-community/does-not-exist-mlx-language-model-ci-test")
        await model.removeFromCache()

        let session = LanguageModelSession(model: model)
        await #expect(throws: Error.self) {
            _ = try await session.respond(
                to: "Hello",
                options: GenerationOptions(maximumResponseTokens: 8)
            )
        }

        #expect(!model.isAvailable)
    }
}

private enum MLXTestEnvironment {
    static let shouldRun: Bool = {
        if ProcessInfo.processInfo.environment["ENABLE_MLX_TESTS"] == nil {
            return false
        }

        #if arch(arm64)
        return true
        #else
        return false
        #endif
    }()
}
#endif
