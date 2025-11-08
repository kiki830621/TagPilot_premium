#!/bin/bash
# validate_utf8_encoding.sh - UTF-8 Encoding Validation and Fix Script
# Following MP100: UTF-8 Encoding Standard
# =================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔍 MP100: UTF-8 Encoding Standard Validation Tool"
echo "=================================================="

# Configuration
BASE_DIR="/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts"
ISSUES_FOUND=0
FILES_CHECKED=0
FILES_FIXED=0

# Function to check and optionally fix encoding issues
check_file() {
    local file="$1"
    local fix_mode="$2"
    
    FILES_CHECKED=$((FILES_CHECKED + 1))
    
    # Check file encoding
    encoding=$(file -b --mime-encoding "$file")
    has_encoding_issue=false
    has_null_chars=false
    
    # Check for non-UTF-8 encoding
    if ! echo "$encoding" | grep -q "utf-8"; then
        if [ "$encoding" != "us-ascii" ]; then
            echo -e "${RED}ENCODING ISSUE:${NC} $file ($encoding)"
            has_encoding_issue=true
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        elif [ "$encoding" = "us-ascii" ]; then
            # US-ASCII is compatible with UTF-8 but should be explicitly UTF-8
            echo -e "${YELLOW}ENCODING NOTE:${NC} $file (US-ASCII - should be UTF-8)"
            has_encoding_issue=true
        fi
    fi
    
    # Check for null characters using od
    if od -c "$file" 2>/dev/null | grep -q "\\\\0"; then
        echo -e "${RED}NULL CHARACTER:${NC} $file"
        has_null_chars=true
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Fix issues if requested
    if [ "$fix_mode" = "fix" ] && ( [ "$has_encoding_issue" = true ] || [ "$has_null_chars" = true ] ); then
        echo -e "${BLUE}  → Fixing:${NC} $file"
        
        # Create backup
        backup_file="${file}.backup_$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup_file"
        
        # Remove null characters first
        if [ "$has_null_chars" = true ]; then
            tr -d '\000' < "$file" > "${file}.tmp"
            mv "${file}.tmp" "$file"
        fi
        
        # Convert to UTF-8 (this handles US-ASCII -> UTF-8 conversion)
        if [ "$has_encoding_issue" = true ]; then
            iconv -f "$encoding" -t UTF-8 "$file" > "${file}.tmp" 2>/dev/null
            if [ $? -eq 0 ]; then
                mv "${file}.tmp" "$file"
            else
                # Fallback: just ensure UTF-8 BOM is removed and line endings are correct
                sed -i '' 's/\r$//' "$file"  # Remove CRLF
                # Remove BOM if present
                if [ "$(head -c 3 "$file" | od -A n -t x1 | tr -d ' ')" = "efbbbf" ]; then
                    tail -c +4 "$file" > "${file}.tmp"
                    mv "${file}.tmp" "$file"
                fi
            fi
        fi
        
        # Verify the fix
        new_encoding=$(file -b --mime-encoding "$file")
        if echo "$new_encoding" | grep -q "utf-8\|us-ascii"; then
            echo -e "${GREEN}  ✅ Fixed:${NC} $file (now $new_encoding)"
            FILES_FIXED=$((FILES_FIXED + 1))
        else
            echo -e "${RED}  ❌ Fix failed:${NC} $file (still $new_encoding)"
            # Restore backup
            mv "$backup_file" "$file"
        fi
    fi
}

# Function to scan directory
scan_directory() {
    local dir="$1"
    local fix_mode="$2"
    
    echo "🔍 Scanning: $dir"
    
    find "$dir" -type f \( -name "*.R" -o -name "*.qmd" -o -name "*.yaml" -o -name "*.yml" -o -name "*.md" -o -name "*.txt" \) | while read file; do
        check_file "$file" "$fix_mode"
    done
}

# Main execution
if [ "$1" = "fix" ]; then
    echo -e "${YELLOW}🔧 Running in FIX mode - issues will be automatically corrected${NC}"
    echo -e "${YELLOW}   Backups will be created with timestamp suffix${NC}"
    echo ""
    scan_directory "$BASE_DIR" "fix"
elif [ "$1" = "check" ] || [ "$1" = "" ]; then
    echo -e "${BLUE}📊 Running in CHECK mode - issues will be reported only${NC}"
    echo ""
    scan_directory "$BASE_DIR" "check"
else
    echo "Usage: $0 [check|fix]"
    echo "  check  - Report encoding issues (default)"
    echo "  fix    - Fix encoding issues automatically"
    exit 1
fi

# Summary
echo ""
echo "📊 Summary"
echo "=========="
echo "Files checked: $FILES_CHECKED"
echo "Issues found: $ISSUES_FOUND"
if [ "$1" = "fix" ]; then
    echo "Files fixed: $FILES_FIXED"
fi

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ All files are MP100 compliant!${NC}"
    exit 0
else
    echo -e "${RED}❌ $ISSUES_FOUND encoding issues found${NC}"
    if [ "$1" != "fix" ]; then
        echo -e "${YELLOW}Run with 'fix' parameter to automatically correct issues${NC}"
    fi
    exit 1
fi