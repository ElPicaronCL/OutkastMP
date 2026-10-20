---
title: Economy System (Design Spec)
tags: [#economy, #money, #banking, #businesses, #ov-economy, #gamemode, #design]
type: note
related: [../revamp-plan, ../overview, ../../architecture]
---
# Economy System

**Target OV module:** `ov-economy` (depends on `ov-core`, `ov-persistence`, `ov-characters`)

## Purpose

Money, banking, transactions, and businesses. Revamped from districtMTA economic features with strict server authority and auditability.

## Principles

- Server-authoritative transactions (no client-side money).
- Stable IDs for accounts/characters/businesses.
- Idempotent transaction handling; audit logs (server-side).
- Validate all transfers (sufficient funds, ownership, rate limits).

## Data model (proposed)

- `accounts_balances` (stable IDs) - canonical balances
- `transactions` - immutable-ish audit trail (timestamp, from/to IDs, amount, reason/type, metadata)
- `businesses` - business entities, ownership, employees, permissions
- `business_accounts` - business balances

## Events

Validated transfer intents (give/pay/deposit/withdraw), business actions. All client events rejected unless fully validated.

## Dependencies

- `ov-core`, `ov-persistence`, `ov-characters`

## Validation & security

- Never trust client amounts; recompute/validate server-side.
- Prevent negative balances, self-transfers abuse, replay where applicable.
- Review exports (keep minimal).

## Testing

Isolated start, transaction integrity tests, validation via Neon CLI. 

## Notes

Rewrite from districtMTA concepts; don’t inherit original event names without security review.