#!/bin/bash
# tests/test_commands.sh — Tests automatisés pour system-utilities

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMANDS_DIR="$PROJECT_DIR/commands"

# Compteurs
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Fonctions
test_pass() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}[PASS]${NC} $1"
}

test_fail() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}[FAIL]${NC} $1"
}

# ========================
#   Tests
# ========================

echo "=== Tests de system-utilities ==="
echo

# Test 1: Toutes les commandes existent
echo "--- Verification des fichiers ---"
for cmd in create_project django_collab deploy_project backup_db check_project migrate_project run_tests; do
    if [[ -x "$COMMANDS_DIR/$cmd" ]]; then
        test_pass "$cmd existe et est executable"
    else
        test_fail "$cmd manquant ou non executable"
    fi
done

# Test 2: Toutes les librairies existent
echo
echo "--- Verification des librairies ---"
for lib in common.sh python.sh git.sh database.sh; do
    if [[ -f "$PROJECT_DIR/lib/$lib" ]]; then
        test_pass "$lib existe"
    else
        test_fail "$lib manquant"
    fi
done

# Test 3: Les commandes ont --help
echo
echo "--- Tests --help ---"
for cmd in create_project django_collab deploy_project backup_db check_project migrate_project run_tests; do
    OUTPUT=$("$COMMANDS_DIR/$cmd" --help 2>&1 || true)
    if echo "$OUTPUT" | grep -q "Usage:"; then
        test_pass "$cmd --help affiche l'aide"
    else
        test_fail "$cmd --help ne fonctionne pas"
    fi
done

# Test 4: Les commandes ont --version
echo
echo "--- Tests --version ---"
for cmd in create_project django_collab deploy_project backup_db check_project migrate_project run_tests; do
    OUTPUT=$("$COMMANDS_DIR/$cmd" --version 2>&1 || true)
    if echo "$OUTPUT" | grep -q "[0-9]\.[0-9]\.[0-9]"; then
        test_pass "$cmd --version affiche la version"
    else
        test_fail "$cmd --version ne fonctionne pas"
    fi
done

# Test 5: Syntaxe bash valide
echo
echo "--- Verification syntaxe ---"
for cmd in create_project django_collab deploy_project backup_db check_project migrate_project run_tests; do
    if bash -n "$COMMANDS_DIR/$cmd" 2>/dev/null; then
        test_pass "$cmd a une syntaxe valide"
    else
        test_fail "$cmd a des erreurs de syntaxe"
    fi
done

for lib in common.sh python.sh git.sh database.sh; do
    if bash -n "$PROJECT_DIR/lib/$lib" 2>/dev/null; then
        test_pass "$lib a une syntaxe valide"
    else
        test_fail "$lib a des erreurs de syntaxe"
    fi
done

# Test 6: Completions
echo
echo "--- Verification des completions ---"
if [[ -f "$PROJECT_DIR/completions/system-utilities.bash" ]]; then
    test_pass "Fichier de completions existe"
else
    test_fail "Fichier de completions manquant"
fi

# ========================
#   Resume
# ========================
echo
echo "=== Resume ==="
echo "Tests total : $TESTS_TOTAL"
echo -e "Reussis    : ${GREEN}$TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "Echoues    : ${RED}$TESTS_FAILED${NC}"
    exit 1
else
    echo "Echoues    : 0"
    exit 0
fi
