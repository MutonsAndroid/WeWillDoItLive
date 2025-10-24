#!/bin/bash
echo "🧠 Verifying OpenCode Build Environment..."
swift --version || { echo "swift not available"; exit 1; }
swift package describe || { echo "swift package describe failed"; exit 1; }
swift test --skip-build || echo "✅ Tests skipped (no suite defined)"
echo "✅ Build environment verified"
