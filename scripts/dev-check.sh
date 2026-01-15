#!/bin/bash
# JPS Dev Engine - Project Check
# Verifies project compliance with engine architecture

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Parse arguments
FIX_MODE=false
STRICT_MODE=false
JSON_OUTPUT=false
VERBOSE=false
PROJECT_PATH="."

while [[ $# -gt 0 ]]; do
    case $1 in
        --fix)
            FIX_MODE=true
            shift
            ;;
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: dev-check.sh [PROJECT_PATH] [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --fix       Attempt to fix issues automatically"
            echo "  --strict    Fail on warnings"
            echo "  --json      Output in JSON format"
            echo "  --verbose   Show detailed output"
            echo "  -h, --help  Show this help"
            exit 0
            ;;
        *)
            if [[ -d "$1" ]]; then
                PROJECT_PATH="$1"
            else
                echo "Unknown option or invalid path: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Helper functions
check_pass() {
    ((PASSED++))
    if ! $JSON_OUTPUT; then
        echo -e "  ${GREEN}✓${NC} $1"
    fi
}

check_fail() {
    ((FAILED++))
    if ! $JSON_OUTPUT; then
        echo -e "  ${RED}✗${NC} $1"
    fi
}

check_warn() {
    ((WARNINGS++))
    if ! $JSON_OUTPUT; then
        echo -e "  ${YELLOW}!${NC} $1"
    fi
}

# Change to project directory
cd "$PROJECT_PATH"

# Check if it's a Flutter project
if [[ ! -f "pubspec.yaml" ]]; then
    echo -e "${RED}Error: Not a Flutter project (pubspec.yaml not found)${NC}"
    exit 2
fi

PROJECT_NAME=$(grep "^name:" pubspec.yaml | awk '{print $2}')

if ! $JSON_OUTPUT; then
    echo -e "${BLUE}JPS Dev Engine - Project Check${NC}"
    echo "=============================="
    echo ""
    echo "Project: $PROJECT_NAME"

    if [[ -f ".engine_version" ]]; then
        ENGINE_VER=$(cat .engine_version)
        echo "Engine Version: $ENGINE_VER"
    fi
    echo ""
fi

# 1. Structure Check
if ! $JSON_OUTPUT; then
    echo -e "${BLUE}Structure Check:${NC}"
fi

# Required directories
REQUIRED_DIRS=("lib/core" "lib/data" "lib/domain" "lib/presentation/features")

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        check_pass "$dir/ exists"
    else
        check_fail "$dir/ missing"
        if $FIX_MODE; then
            mkdir -p "$dir"
            echo -e "    ${GREEN}→ Created${NC}"
        fi
    fi
done

echo ""

# 2. Features Analysis
if ! $JSON_OUTPUT; then
    echo -e "${BLUE}Features Analysis:${NC}"
fi

FEATURES_DIR="lib/presentation/features"
if [[ -d "$FEATURES_DIR" ]]; then
    for feature_dir in "$FEATURES_DIR"/*/; do
        if [[ -d "$feature_dir" ]]; then
            feature_name=$(basename "$feature_dir")

            if ! $JSON_OUTPUT; then
                echo "  $feature_name/"
            fi

            # Check layouts
            LAYOUTS_DIR="$feature_dir/layouts"
            LAYOUT_TYPES=("mobile" "tablet" "desktop")

            for layout in "${LAYOUT_TYPES[@]}"; do
                layout_file="$LAYOUTS_DIR/${feature_name}_${layout}_layout.dart"
                if [[ -f "$layout_file" ]]; then
                    check_pass "${layout}_layout.dart"
                else
                    check_fail "${layout}_layout.dart (MISSING)"
                    if $FIX_MODE; then
                        mkdir -p "$LAYOUTS_DIR"
                        # Generate template
                        cat > "$layout_file" << EOF
import 'package:flutter/material.dart';

class ${feature_name^}${layout^}Layout extends StatelessWidget {
  const ${feature_name^}${layout^}Layout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('${feature_name^} - ${layout^} Layout'),
      ),
    );
  }
}
EOF
                        echo -e "      ${GREEN}→ Generated from template${NC}"
                    fi
                fi
            done

            # Check for BLoC (optional but recommended)
            if [[ -d "$feature_dir/bloc" ]]; then
                check_pass "bloc/ found"
            else
                if $VERBOSE; then
                    check_warn "bloc/ not found (optional)"
                fi
            fi
        fi
    done
else
    check_warn "No features directory found"
fi

echo ""

# 3. State Management Check
if ! $JSON_OUTPUT; then
    echo -e "${BLUE}State Management:${NC}"
fi

# Check pubspec.yaml for state management packages
if grep -q "flutter_bloc:" pubspec.yaml 2>/dev/null; then
    check_pass "Using BLoC (flutter_bloc)"
else
    check_fail "flutter_bloc not found in dependencies"
fi

if grep -q "provider:" pubspec.yaml 2>/dev/null; then
    check_fail "Provider detected (NOT ALLOWED)"
else
    check_pass "No Provider detected"
fi

if grep -q "riverpod:" pubspec.yaml 2>/dev/null || grep -q "flutter_riverpod:" pubspec.yaml 2>/dev/null; then
    check_fail "Riverpod detected (NOT ALLOWED)"
else
    check_pass "No Riverpod detected"
fi

if grep -q "get:" pubspec.yaml 2>/dev/null || grep -q "getx:" pubspec.yaml 2>/dev/null; then
    check_fail "GetX detected (NOT ALLOWED)"
else
    check_pass "No GetX detected"
fi

echo ""

# 4. Summary
if ! $JSON_OUTPUT; then
    echo -e "${BLUE}Summary:${NC}"
    echo -e "  Passed:   ${GREEN}$PASSED${NC}"
    echo -e "  Failed:   ${RED}$FAILED${NC}"
    echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
    echo ""

    if [[ $FAILED -eq 0 ]] && ( ! $STRICT_MODE || [[ $WARNINGS -eq 0 ]] ); then
        echo -e "Status: ${GREEN}PASSED${NC}"
        exit 0
    else
        echo -e "Status: ${RED}FAILED${NC}"
        if [[ $FAILED -gt 0 ]]; then
            echo ""
            echo "Run with --fix to attempt automatic fixes."
        fi
        exit 1
    fi
else
    # JSON output
    echo "{"
    echo "  \"project\": \"$PROJECT_NAME\","
    echo "  \"passed\": $PASSED,"
    echo "  \"failed\": $FAILED,"
    echo "  \"warnings\": $WARNINGS,"
    if [[ $FAILED -eq 0 ]]; then
        echo "  \"status\": \"PASSED\""
    else
        echo "  \"status\": \"FAILED\""
    fi
    echo "}"

    if [[ $FAILED -gt 0 ]]; then
        exit 1
    fi
fi
