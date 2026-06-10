# Marten Audit Harness app build

| Field | Value |
| --- | --- |
| Date UTC | 2026-06-10 13:41:30 UTC |
| Runner | GitHub Actions 1000005311 |
| Runner OS | macOS |
| Runner arch | ARM64 |
| Machine | arm64 |
| Kernel | Darwin sjc20-cw714-10f4fbe9-04bc-4b8c-afa8-48d8a04e290f-06B9E524EF4A.local 25.4.0 Darwin Kernel Version 25.4.0: Thu Mar 19 19:29:33 PDT 2026; root:xnu-12377.101.15~1/RELEASE_ARM64_VMAPPLE arm64 |
| Swift | Apple Swift version 6.3.1 (swiftlang-6.3.1.1.2 clang-2100.0.123.102) |
| Xcode | Xcode 26.4.1 Build version 17E202  |

## App artifact

| Field | Value |
| --- | --- |
| App zip | MartenAuditHarness.app.zip |
| SHA256 | b23e7315dd282da7352859f691f2e7e73bc31549344dc311a077732a37e192cb |
| Bundle | MartenAuditHarness.app |
| Codesign | ad-hoc signed |
| Commit | d45a07b1a88ba19c47d84b179381e9b7577cf213 |
| Run | [27280487890](https://github.com/WostGit/MLXLanguageModel/actions/runs/27280487890) |

The app is a standalone macOS wrapper generated in CI. It includes deterministic Marten audit-method checks, a GUI, and a --ci-smoke mode validated during the workflow. It does not bundle model weights.
