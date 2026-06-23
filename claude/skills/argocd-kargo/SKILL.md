---
name: argocd-kargo
description: Use this skill when the user asks about ArgoCD or Kargo operations, application syncs, rollbacks, freight promotion, stage management, or pipeline promotion workflows. Keywords: argocd, kargo, promote, freight, stage, sync, rollback, pipeline promotion, app sync, warehouse.
---

# ArgoCD / Kargo

Use `argocd` CLI for ArgoCD operations and `kargo` CLI for Kargo operations.

## Rules

- For destructive or mutating operations (`kargo promote`, `kargo approve`, `kargo delete`, `kargo apply`, `argocd app sync`, `argocd app rollback`), print the command and ask for confirmation before running.

## ArgoCD CLI Reference

| Command | Purpose |
|---|---|
| `argocd login` | Authenticate to Argo CD server |
| `argocd app list` | List applications |
| `argocd app get <app>` | Get app details |
| `argocd app sync <app>` | Sync/deploy application |
| `argocd app diff <app>` | Show diff before sync |
| `argocd app history <app>` | View deployment history |
| `argocd app rollback <app>` | Rollback to previous version |

## Kargo CLI Reference

| Command | Purpose |
|---|---|
| `kargo login` | Authenticate to Kargo API |
| `kargo logout` | End session |
| `kargo create` | Create resources |
| `kargo apply` | Apply configuration |
| `kargo get` | List resources |
| `kargo delete` | Remove resources |
| `kargo promote` | Promote freight to a stage |
| `kargo approve` | Approve a promotion |
| `kargo refresh` | Refresh a resource |
| `kargo verify` | Verify a stage |
| `kargo dashboard` | Open web UI |

## Kargo Stage Conventions

| Stage | autoPromotionEnabled | mrGated |
|---|---|---|
| dev | `true` | `false` |
| qa | `false` | `true` |
| prod | `false` | `true` |

When adding a new service to Kargo, follow this pattern in `kargo/values.yaml`.
