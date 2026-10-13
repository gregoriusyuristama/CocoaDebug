#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="${ROOT_DIR}/CocoaDebug.xcodeproj"
SCHEME="CocoaDebug"
BUILD_DIR="${ROOT_DIR}/build"
DEVICE_ARCHIVE="${BUILD_DIR}/CocoaDebug-iOS.xcarchive"
SIMULATOR_ARCHIVE="${BUILD_DIR}/CocoaDebug-Simulator.xcarchive"
OUTPUT_XCFRAMEWORK="${BUILD_DIR}/CocoaDebug.xcframework"

rm -rf "${DEVICE_ARCHIVE}" "${SIMULATOR_ARCHIVE}" "${OUTPUT_XCFRAMEWORK}"
mkdir -p "${BUILD_DIR}"

xcodebuild archive \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -derivedDataPath "${BUILD_DIR}/DerivedData" \
  -destination "generic/platform=iOS" \
  -archivePath "${DEVICE_ARCHIVE}" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  CODE_SIGNING_ALLOWED=NO

xcodebuild archive \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -derivedDataPath "${BUILD_DIR}/DerivedData" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "${SIMULATOR_ARCHIVE}" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  'EXCLUDED_ARCHS[sdk=iphonesimulator*]=' \
  CODE_SIGNING_ALLOWED=NO

xcodebuild -create-xcframework \
  -framework "${DEVICE_ARCHIVE}/Products/Library/Frameworks/CocoaDebug.framework" \
  -framework "${SIMULATOR_ARCHIVE}/Products/Library/Frameworks/CocoaDebug.framework" \
  -output "${OUTPUT_XCFRAMEWORK}"

# Work around Swift's module/type name collision: the framework module and the
# public CocoaDebug class share a name, so emitted interfaces qualify sibling
# types as CocoaDebug.Type (which Swift resolves as the class). These are
# same-module types, so the qualification is unnecessary.
find "${OUTPUT_XCFRAMEWORK}" -name '*.swiftinterface' -exec perl -pi -e \
  's/\bCocoaDebug\.(?=(?:CocoaDebugSettings|WindowHelper|_SwiftLogHelper)\b)//g' {} +

echo "Created ${OUTPUT_XCFRAMEWORK}"
