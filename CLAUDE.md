# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A collection of T-SQL utility scripts for SQL Server database administration. No build system, test suite, or package manager — scripts are run directly against a SQL Server instance.

## Scripts Summary

| Script | Purpose |
|--------|---------|
| `DropAllDatabaseObjects` | Drops all non-system objects in order: SPs → Views → Functions → FK constraints → PK constraints → Tables. Contains hardcoded schema `[TicketDB0104829]` that must be updated per database. |
| `Change schema to all objects in database.sql` | Generates dynamic SQL to move tables, SPs, and views from `dbo` to a schema named after the database. Output is printed, not auto-executed. |
| `realign_identity_to_max_value.sql` | Reseeds identity columns where `last_value > seed_value` using `DBCC CHECKIDENT`. |
| `TurnOffNotForReplication` | Removes `NOT FOR REPLICATION` flag from identity columns. Has a `@debug BIT = 1` flag to print statements without executing. |
| `SQLVersions` | Parses a `SQLVersions` table, splitting version strings into Major/Minor/Build columns via `STRING_SPLIT`. |
| `STUFF and XML` | Demonstrates `STUFF` + `FOR XML PATH` to aggregate column names per table as comma-separated strings. |

## Conventions

- Scripts use T-SQL (SQL Server-specific features: cursors, `DBCC CHECKIDENT`, `STRING_SPLIT`, `FOR XML PATH`, dynamic SQL).
- Some scripts have a `.sql` extension; others do not — both are valid SQL files.
- Scripts that generate dynamic SQL typically `PRINT` the statements rather than auto-executing, allowing review before running.
- When adding scripts, follow the pattern of including a source reference (Stack Overflow, GitHub Gist) if the script is adapted from an external source.
