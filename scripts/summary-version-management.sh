#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# ActionLibrary: Version Management — promotion box
# ═══════════════════════════════════════════════════════════════════════════════
# States what was promoted and why, in one ruled box: the promotion type, the
# marker that decided it (label, title or commit message), every VERSION file
# that moved with its before/after, and whether the result was committed and
# pushed. The "why" matters here — a surprise major bump is the question this
# box exists to answer without a trip into the log.
#
# Bounded: the per-file table shows at most NEXUS_CHANGE_ROWS rows and then says
# how many it left out.
#
# Environment: PROMOTION_TYPE, PROMOTION_SOURCE, PROMOTION_REASON, CHANGES,
#   PREVIOUS_VERSION, NEW_VERSION, COMMITTED, PUSHED, PUSH_CHANGES, and the
#   *_OUTCOME step outcomes from action.yml.
# Line endings MUST stay LF.
# ═══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

# shellcheck source=scripts/nexus-summary.sh
. "$(dirname "$0")/nexus-summary.sh"

NEXUS_CHANGE_ROWS="${NEXUS_CHANGE_ROWS:-20}"

promotion_type="${PROMOTION_TYPE:-}"
changes="${CHANGES:-}"
resolve_outcome="${RESOLVE_OUTCOME:-}"
promote_outcome="${PROMOTE_OUTCOME:-}"

nexus_box_begin "Version Management" "version-management"

if nexus_box_failure; then
  nexus_box_status fail "no version was promoted"
elif [ "$resolve_outcome" = "failure" ]; then
  nexus_box_status fail "could not resolve a promotion type"
elif [ "$promote_outcome" = "failure" ]; then
  nexus_box_status fail "promotion failed"
elif [ "${COMMITTED:-false}" = "true" ] && [ "${PUSHED:-false}" = "true" ]; then
  nexus_box_status ok "${promotion_type:-version} promoted, committed and pushed"
elif [ "${COMMITTED:-false}" = "true" ]; then
  nexus_box_status ok "${promotion_type:-version} promoted and committed (push withheld)"
elif [ "$promote_outcome" = "success" ]; then
  nexus_box_status warn "nothing to commit - VERSION file(s) already at the target version"
else
  nexus_box_status skip "did not run"
fi

nexus_box_row "Promotion type" "${promotion_type:-(unresolved)}"
nexus_box_row "Decided by" "${PROMOTION_SOURCE:-(unresolved)}"
nexus_box_row "Reason" "${PROMOTION_REASON:-(none recorded)}"
if [ -n "${PREVIOUS_VERSION:-}" ] || [ -n "${NEW_VERSION:-}" ]; then
  nexus_box_row "Version" "${PREVIOUS_VERSION:-?} -> ${NEW_VERSION:-?}"
fi
nexus_box_row "Committed" "${COMMITTED:-false}"
if [ "${PUSH_CHANGES:-true}" = "false" ]; then
  nexus_box_row "Pushed" "false (push_changes=false; the caller owns the push)"
else
  nexus_box_row "Pushed" "${PUSHED:-false}"
fi

if [ -n "$changes" ]; then
  changes_file="${NEXUS_TMP}/version-changes.txt"
  printf '%s\n' "$changes" | sed '/^[[:space:]]*$/d' > "$changes_file"
  total="$(wc -l < "$changes_file" | tr -d ' ')"
  nexus_box_row "VERSION files promoted" "$total"

  table_file="${NEXUS_TMP}/version-changes-table.md"
  {
    echo "| VERSION file | Before | After |"
    echo "| --- | --- | --- |"
  } > "$table_file"
  head -n "$NEXUS_CHANGE_ROWS" "$changes_file" | while IFS= read -r line; do
    file_part="${line%%:*}"
    move_part="${line#*: }"
    before="${move_part%% -> *}"
    after="${move_part##* -> }"
    printf '| %s | %s | %s |\n' "$file_part" "$before" "$after" >> "$table_file"
  done
  if [ "$total" -gt "$NEXUS_CHANGE_ROWS" ]; then
    printf '\n> %s further file(s) promoted and omitted here; the commit lists them all.\n' \
      "$(( total - NEXUS_CHANGE_ROWS ))" >> "$table_file"
  fi
  nexus_box_note "**Promoted files**"
  nexus_box_table_file "$table_file"
fi

nexus_box_end
