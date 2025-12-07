# Branch Protection Setup

This document describes the recommended GitHub branch protection rules for this repository.

## Recommended Rules for Main/Master Branch

### 1. Navigate to Branch Protection Settings

1. Go to repository **Settings**
2. Click **Branches** in the left sidebar
3. Under "Branch protection rules", click **Add rule**
4. Enter `main` (or `master`) as the branch name pattern

### 2. Configure Protection Rules

#### Required Status Checks
✅ **Require status checks to pass before merging**
- Check: "Require branches to be up to date before merging"
- Select the following required checks:
  - `test-cpu` (from CI Tests workflow)
  - `test-gpu` (from CI Tests workflow)
  - `lint-and-validate` (from CI Tests workflow)
  - `validate-pr` (from PR Validation workflow)
  - `size-report` (from PR Validation workflow)

#### Pull Request Requirements
✅ **Require a pull request before merging**
- Require approvals: **1** (recommended minimum)
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners (if using CODEOWNERS file)

#### Additional Settings
✅ **Require conversation resolution before merging**
- Ensures all PR comments are addressed

✅ **Do not allow bypassing the above settings**
- Applies rules to administrators too (recommended)

❌ **Allow force pushes** (disabled)
- Protects against history rewrites

❌ **Allow deletions** (disabled)
- Prevents accidental branch deletion

### 3. Optional Advanced Rules

#### Require Signed Commits
✅ **Require signed commits** (optional but recommended)
- Ensures commits are verified

#### Restrict Push Access
✅ **Restrict who can push to matching branches**
- Limit to specific teams or users

#### Require Deployments to Succeed
- If using deployment workflows, require them to succeed

## Quick Setup via GitHub CLI

```bash
# Install GitHub CLI if not already installed
# brew install gh  # macOS
# See: https://cli.github.com/

# Login to GitHub
gh auth login

# Create branch protection rule for main branch
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field required_status_checks[contexts][]=test-cpu \
  --field required_status_checks[contexts][]=test-gpu \
  --field required_status_checks[contexts][]=lint-and-validate \
  --field required_status_checks[contexts][]=validate-pr \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field required_pull_request_reviews[dismiss_stale_reviews]=true \
  --field required_conversation_resolution=true \
  --field enforce_admins=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

## Workflow Overview

This repository has three main workflows:

### 1. CI Tests (`ci.yml`)
- **Trigger:** Push to main/master/develop, PRs to main/master/develop
- **Jobs:**
  - `test-cpu`: Sets up CPU conda environment, installs dependencies, runs smoke tests
  - `test-gpu`: Sets up GPU conda environment with CUDA toolkit, verifies GPU packages
  - `lint-and-validate`: Validates configuration files and checks for issues
  - `security-scan`: Scans for secrets and vulnerabilities

### 2. PR Validation (`pr-validation.yml`)
- **Trigger:** PR opened/synchronized/reopened
- **Jobs:**
  - `validate-pr`: Checks PR title, merge conflicts, file sizes, TODOs
  - `size-report`: Generates PR statistics and size classification

### 3. Dependency Security Scan (`dependency-scan.yml`)
- **Trigger:** Weekly schedule (Mondays 9 AM UTC), manual, or on dependency changes
- **Jobs:**
  - `security-audit`: Runs pip-audit, safety, and bandit
  - `check-outdated`: Reports outdated packages

## Testing Workflows Locally

### Using act (GitHub Actions locally)

```bash
# Install act
brew install act  # macOS
# or see: https://github.com/nektos/act

# Run the CI workflow
act pull_request -W .github/workflows/ci.yml

# Run a specific job
act pull_request -W .github/workflows/ci.yml -j test-cpu
```

### Manual Testing

Before pushing, test locally:

```bash
# Run the same checks as CI
make doctor          # Check system prerequisites
make setup-cpu       # Create environment
make test ENV=agents_unplugged-cpu  # Run smoke tests

# Validate files
python -c "import yaml; yaml.safe_load(open('environment-minimal-cpu.yml'))"
python -m py_compile code/smoke_test.py
```

## Workflow Badges

Add these badges to your README.md:

```markdown
[![CI Tests](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
[![PR Validation](https://github.com/OWNER/REPO/actions/workflows/pr-validation.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/pr-validation.yml)
[![Dependency Scan](https://github.com/OWNER/REPO/actions/workflows/dependency-scan.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/dependency-scan.yml)
```

Replace `OWNER/REPO` with your GitHub username and repository name.

## Troubleshooting Workflows

### Workflow Fails with "Environment not found"

- Ensure the conda environment is created successfully
- Check the cache key matches your dependency files

### "No space left on device"

- GitHub Actions runners have limited disk space (~14GB available)
- The workflow cleans up unnecessary files before installation
- If still failing, consider reducing the test matrix

### Cache Not Working

- Verify the cache key includes all dependency files
- Cache is scoped to branch, so new branches won't have cache initially
- Maximum cache size is 10GB per repository

### Dependency Installation Timeout

- GitHub Actions has a 6-hour timeout per job
- The workflow uses `--no-cache-dir` to avoid filling disk
- If still timing out, consider splitting into multiple jobs

## Resources

- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [conda-incubator/setup-miniconda](https://github.com/conda-incubator/setup-miniconda)
