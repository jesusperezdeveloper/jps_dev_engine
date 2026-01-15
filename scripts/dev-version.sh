#!/bin/bash
# JPS Dev Engine - Version Info
# Shows engine version and project comparison

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$(dirname "$SCRIPT_DIR")"
ENGINE_VERSION_FILE="$ENGINE_DIR/ENGINE_VERSION.yaml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
COMPARE=false
CHANGELOG=false
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --compare)
            COMPARE=true
            shift
            ;;
        --changelog)
            CHANGELOG=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        -h|--help)
            echo "Usage: dev-version.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --compare     Compare with current project version"
            echo "  --changelog   Show full changelog"
            echo "  --json        Output in JSON format"
            echo "  -h, --help    Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if ENGINE_VERSION.yaml exists
if [[ ! -f "$ENGINE_VERSION_FILE" ]]; then
    echo -e "${RED}Error: ENGINE_VERSION.yaml not found at $ENGINE_VERSION_FILE${NC}"
    exit 1
fi

# Parse YAML (simple parsing for our structure)
VERSION=$(grep "^version:" "$ENGINE_VERSION_FILE" | cut -d' ' -f2)
RELEASE_DATE=$(grep "^release_date:" "$ENGINE_VERSION_FILE" | cut -d' ' -f2)
FLUTTER_ARCH_VERSION=$(grep "flutter:" "$ENGINE_VERSION_FILE" | head -1 | awk '{print $2}')
MEMORY_EDITS=$(grep "memory_edits:" "$ENGINE_VERSION_FILE" | awk '{print $2}')

if $JSON_OUTPUT; then
    echo "{"
    echo "  \"version\": \"$VERSION\","
    echo "  \"release_date\": \"$RELEASE_DATE\","
    echo "  \"components\": {"
    echo "    \"flutter_architecture\": \"$FLUTTER_ARCH_VERSION\","
    echo "    \"memory_edits\": $MEMORY_EDITS"
    echo "  }"
    echo "}"
    exit 0
fi

# Standard output
echo -e "${BLUE}JPS Dev Engine${NC} v${GREEN}$VERSION${NC}"
echo -e "Released: $RELEASE_DATE"
echo ""
echo "Components:"
echo "  - Flutter Architecture: $FLUTTER_ARCH_VERSION"
echo "  - Memory Edits: $MEMORY_EDITS"

# Compare with project version if requested
if $COMPARE; then
    echo ""
    echo "---"

    PROJECT_VERSION_FILE=".engine_version"

    if [[ -f "$PROJECT_VERSION_FILE" ]]; then
        PROJECT_VERSION=$(cat "$PROJECT_VERSION_FILE")
        echo -e "Engine Version:  ${GREEN}$VERSION${NC}"
        echo -e "Project Version: ${BLUE}$PROJECT_VERSION${NC}"

        if [[ "$PROJECT_VERSION" == "$VERSION" ]]; then
            echo -e "Status: ${GREEN}Up to date${NC}"
        else
            echo -e "Status: ${YELLOW}Update available${NC}"
            echo ""
            echo "Run '/dev-upgrade' or './scripts/dev-upgrade.sh' to update."
        fi
    else
        echo -e "${YELLOW}No .engine_version found in current directory.${NC}"
        echo "This project may not be initialized with the engine."
        echo ""
        echo "Run '/dev-new' to create a new project or '/dev-check' to verify."
    fi
fi

# Show changelog if requested
if $CHANGELOG; then
    echo ""
    echo "---"
    echo -e "${BLUE}Changelog${NC}"
    echo ""

    # Extract changelog section (simplified)
    IN_CHANGELOG=false
    while IFS= read -r line; do
        if [[ "$line" == "changelog:" ]]; then
            IN_CHANGELOG=true
            continue
        fi

        if $IN_CHANGELOG; then
            # Stop at next top-level key
            if [[ "$line" =~ ^[a-z] && ! "$line" =~ ^[[:space:]] ]]; then
                break
            fi

            # Format version headers
            if [[ "$line" =~ ^[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+: ]]; then
                version=$(echo "$line" | tr -d ' :')
                echo -e "${GREEN}v$version${NC}"
            elif [[ "$line" =~ date: ]]; then
                date=$(echo "$line" | awk '{print $2}')
                echo "  Released: $date"
            elif [[ "$line" =~ summary: ]]; then
                summary=$(echo "$line" | cut -d'"' -f2)
                echo "  $summary"
                echo ""
            elif [[ "$line" =~ ^[[:space:]]+- ]]; then
                change=$(echo "$line" | sed 's/^[[:space:]]*- //')
                echo "    • $change"
            fi
        fi
    done < "$ENGINE_VERSION_FILE"
fi

exit 0
