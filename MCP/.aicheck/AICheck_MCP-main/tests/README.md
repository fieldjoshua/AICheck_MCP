# Project Test Suite

This directory contains the permanent test suite for the project. Tests are organized into the following categories:

## Test Categories

- **unit/**: Unit tests for individual components
- **integration/**: Tests for component interactions
- **e2e/**: End-to-end tests for complete workflows
- **fixtures/**: Test data and fixtures

## Test Naming Conventions

- Test files use the pattern `[feature-name].test.[ext]` where `[ext]` is the appropriate extension for the language
- Integration test files use the pattern `[feature-name].integration.test.[ext]`
- E2E test files use the pattern `[workflow-name].e2e.test.[ext]`

## Test Organization

- Test directory structure mirrors the code structure being tested
- Shared test utilities go in `tests/utils/` (to be created when needed)
- Test data goes in `tests/fixtures/`