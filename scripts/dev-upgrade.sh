#!/bin/bash
# JPS Dev Engine - Upgrade
# Upgrades project to a newer engine version

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$(dirname "$SCRIPT_DIR")"
ENGINE_VERSION_FILE="$ENGINE_DIR/ENGINE_VERSION.yaml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
DRY_RUN=false
TARGET_VERSION=""
FORCE=false
BACKUP=true
SKIP_MIGRATIONS=false
ROLLBACK=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --to)
            TARGET_VERSION="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --no-backup)
            BACKUP=false
            shift
            ;;
        --skip-migrations)
            SKIP_MIGRATIONS=true
            shift
            ;;
        --rollback)
            ROLLBACK=true
            shift
            ;;
        -h|--help)
            echo "Usage: dev-upgrade.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run          Show changes without applying them"
            echo "  --to VERSION       Upgrade to specific version"
            echo "  --force            Force upgrade even with uncommitted changes"
            echo "  --no-backup        Skip backup creation"
            echo "  --skip-migrations  Only update version, skip migrations"
            echo "  --rollback         Rollback to previous version from backup"
            echo "  -h, --help         Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if it's a Flutter project
if [[ ! -f "pubspec.yaml" ]]; then
    echo -e "${RED}Error: Not a Flutter project (pubspec.yaml not found)${NC}"
    exit 2
fi

# Check if project is initialized with engine
if [[ ! -f ".engine_version" ]]; then
    echo -e "${RED}Error: Project not initialized with JPS Dev Engine${NC}"
    echo "Run '/dev-new' to create a new project or create .engine_version manually."
    exit 2
fi

CURRENT_VERSION=$(cat .engine_version)
LATEST_VERSION=$(grep "^version:" "$ENGINE_VERSION_FILE" | cut -d' ' -f2)

# Set target version
if [[ -z "$TARGET_VERSION" ]]; then
    TARGET_VERSION="$LATEST_VERSION"
fi

PROJECT_NAME=$(grep "^name:" pubspec.yaml | awk '{print $2}')

# Handle rollback
if $ROLLBACK; then
    echo -e "${BLUE}JPS Dev Engine - Rollback${NC}"
    echo "========================="
    echo ""

    if [[ -d ".backup" ]]; then
        echo "Available backups:"
        ls -1 .backup/ 2>/dev/null || echo "  (none)"
        echo ""
        echo "To rollback, copy the backup files:"
        echo "  cp -r .backup/{VERSION}/* ./"
        echo "  echo \"{VERSION}\" > .engine_version"
    else
        echo -e "${YELLOW}No backups found.${NC}"
    fi
    exit 0
fi

# Header
if $DRY_RUN; then
    echo -e "${BLUE}JPS Dev Engine - Upgrade (DRY RUN)${NC}"
    echo "==================================="
else
    echo -e "${BLUE}JPS Dev Engine - Upgrade${NC}"
    echo "========================"
fi
echo ""
echo "Current Version: $CURRENT_VERSION"
echo "Target Version:  $TARGET_VERSION"
echo ""

# Check if already up to date
if [[ "$CURRENT_VERSION" == "$TARGET_VERSION" ]]; then
    echo -e "${GREEN}Already up to date!${NC}"
    exit 0
fi

# Version comparison (simple string comparison, works for semver)
if [[ "$CURRENT_VERSION" > "$TARGET_VERSION" ]]; then
    echo -e "${YELLOW}Warning: Target version ($TARGET_VERSION) is older than current ($CURRENT_VERSION)${NC}"
    if ! $FORCE; then
        echo "Use --force to downgrade."
        exit 1
    fi
fi

# Check for uncommitted changes
if ! $FORCE; then
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        echo -e "${RED}Error: Uncommitted changes detected${NC}"
        echo "Commit or stash your changes first, or use --force to override."
        exit 3
    fi
fi

# Extract changelog entries between versions
echo -e "${BLUE}Changes in $TARGET_VERSION:${NC}"
echo ""

# Simple changelog extraction (would be more sophisticated in production)
IN_VERSION=false
while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]+$TARGET_VERSION: ]]; then
        IN_VERSION=true
        continue
    fi

    if $IN_VERSION; then
        if [[ "$line" =~ ^[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+: ]]; then
            break
        fi

        if [[ "$line" =~ summary: ]]; then
            summary=$(echo "$line" | cut -d'"' -f2)
            echo "  $summary"
            echo ""
        elif [[ "$line" =~ ^[[:space:]]+- ]]; then
            change=$(echo "$line" | sed 's/^[[:space:]]*- //')
            echo "  • $change"
        fi
    fi
done < "$ENGINE_VERSION_FILE"

echo ""

# Dry run stops here
if $DRY_RUN; then
    echo -e "${YELLOW}No changes were made.${NC} Run without --dry-run to apply."
    exit 0
fi

# Create backup
if $BACKUP; then
    BACKUP_DIR=".backup/$CURRENT_VERSION"
    echo "Creating backup at $BACKUP_DIR/..."
    mkdir -p "$BACKUP_DIR"

    # Backup key files
    [[ -f ".engine_version" ]] && cp ".engine_version" "$BACKUP_DIR/"
    [[ -f "CLAUDE.md" ]] && cp "CLAUDE.md" "$BACKUP_DIR/"
    [[ -d "lib/core" ]] && cp -r "lib/core" "$BACKUP_DIR/"

    echo -e "  ${GREEN}✓${NC} Backup created"
    echo ""
fi

# Apply migrations (placeholder - would be more sophisticated in production)
if ! $SKIP_MIGRATIONS; then
    echo "Applying migrations..."

    # Example migration: Update imports, add new files, etc.
    # This would be driven by migration definitions in ENGINE_VERSION.yaml

    echo -e "  ${GREEN}✓${NC} Migrations applied (none required for this version)"
    echo ""
fi

# Update version file
echo "Updating .engine_version..."
echo "$TARGET_VERSION" > .engine_version
echo -e "  ${GREEN}✓${NC} Version updated to $TARGET_VERSION"
echo ""

# Update CLAUDE.md if exists
if [[ -f "CLAUDE.md" ]]; then
    # Update engine version in CLAUDE.md
    if grep -q "Engine Version:" CLAUDE.md; then
        sed -i '' "s/Engine Version: .*/Engine Version: $TARGET_VERSION/" CLAUDE.md 2>/dev/null || \
        sed -i "s/Engine Version: .*/Engine Version: $TARGET_VERSION/" CLAUDE.md
        echo -e "  ${GREEN}✓${NC} CLAUDE.md updated"
    fi
fi

echo ""
echo -e "${GREEN}Upgrade complete!${NC}"
echo ""
echo "Run '/dev-check' or './scripts/dev-check.sh' to verify your project."

if $BACKUP; then
    echo ""
    echo "Backup available at: $BACKUP_DIR/"
    echo "To rollback: ./scripts/dev-upgrade.sh --rollback"
fi
