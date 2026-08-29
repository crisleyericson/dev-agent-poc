#!/usr/bin/env bash
set -uo pipefail

STAGE=""
PROMPT=""
OUTPUT=""
MODEL=""
FALLBACK_MODEL=""
TIMEOUT=600
MAX_ATTEMPTS=3

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stage)
      STAGE="$2"
      shift 2
      ;;
    --prompt)
      PROMPT="$2"
      shift 2
      ;;
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --fallback-model)
      FALLBACK_MODEL="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --attempts)
      MAX_ATTEMPTS="$2"
      shift 2
      ;;
    *)
      echo "::error::Argumento desconhecido: $1"
      exit 2
      ;;
  esac
done

if [[ -z "$STAGE" || -z "$PROMPT" || -z "$OUTPUT" || -z "$MODEL" ]]; then
  echo "::error::Parâmetros obrigatórios: --stage --prompt --output --model"
  exit 2
fi

if [[ ! -f "$PROMPT" ]]; then
  echo "::error::Prompt não encontrado: $PROMPT"
  exit 2
fi

for ATTEMPT in $(seq 1 "$MAX_ATTEMPTS"); do
  CURRENT_MODEL="$MODEL"

  if [[ -n "$FALLBACK_MODEL" && "$ATTEMPT" -eq "$MAX_ATTEMPTS" ]]; then
    CURRENT_MODEL="$FALLBACK_MODEL"
  fi

  echo "=== ${STAGE} attempt ${ATTEMPT}/${MAX_ATTEMPTS} using ${CURRENT_MODEL} ==="

  SAFE_STAGE="$(printf '%s' "$STAGE" | tr '[:upper:]' '[:lower:]')"
  ATTEMPT_LOG="/tmp/opencode-${SAFE_STAGE}-attempt-${ATTEMPT}.jsonl"
  ATTEMPT_ERR="/tmp/opencode-${SAFE_STAGE}-attempt-${ATTEMPT}.stderr"

  rm -f "$ATTEMPT_LOG" "$ATTEMPT_ERR"

  set +e

  timeout --signal=TERM --kill-after=15s "$TIMEOUT" \
    opencode run \
      --model "$CURRENT_MODEL" \
      --format json \
      "$(cat "$PROMPT")" \
    2> >(tee "$ATTEMPT_ERR" >&2) \
    | tee "$ATTEMPT_LOG"

  EXIT_CODE=${PIPESTATUS[0]}

  set -e

  if [[ "$EXIT_CODE" -eq 0 ]]; then
    cp "$ATTEMPT_LOG" "$OUTPUT"
    echo "${STAGE} concluído no attempt ${ATTEMPT}"
    exit 0
  fi

  RETRY_REASON=""

  if [[ "$EXIT_CODE" -eq 124 ]]; then
    RETRY_REASON="TIMEOUT"
  elif grep -Eiq \
    '(^|[^0-9])(429|502|503|504)([^0-9]|$)|busy|capacity|rate[ _-]?limit' \
    "$ATTEMPT_LOG" "$ATTEMPT_ERR"; then
    RETRY_REASON="TRANSIENT_PROVIDER"
  fi

  if [[ -z "$RETRY_REASON" ]]; then
    echo "::error::${STAGE} falhou com erro não transitório (exit code ${EXIT_CODE})"
    exit "$EXIT_CODE"
  fi

  echo "::warning::${STAGE} attempt ${ATTEMPT} falhou: ${RETRY_REASON} (exit code ${EXIT_CODE})"

  if [[ "$ATTEMPT" -eq "$MAX_ATTEMPTS" ]]; then
    echo "::error::${STAGE} esgotou ${MAX_ATTEMPTS} tentativas. Último motivo: ${RETRY_REASON}"
    exit "$EXIT_CODE"
  fi

  BACKOFF=$((ATTEMPT * 15))
  echo "Retry em ${BACKOFF}s..."
  sleep "$BACKOFF"
done
