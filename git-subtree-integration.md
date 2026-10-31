# Git Technical Report: Integrating Microsoft Defender into a Cybersecurity Portfolio Using Git Subtree

**Project:** Cybersecurity Portfolio  
**Source Repository:** https://github.com/jambon3/Microsoft-Defender  
**Destination Repository:** https://github.com/jambon3/Cybersecurity  
**Platform:** Windows 11 / Git Bash (UCRT64)  
**Version Control:** Git / GitHub  
**Integration Method:** Git Subtree  
**Status:** Completed Successfully  
**Date:** October 31, 2026

---

# 1. Executive Summary

This project involved integrating an existing Microsoft Defender GitHub repository into a larger Cybersecurity portfolio repository.

The objective was to consolidate cybersecurity documentation, security investigations, technical notes, and practical exercises into a single portfolio while preserving the original Microsoft Defender commit history.

Git subtree was selected because it allows an existing Git repository to be integrated into a subdirectory of another repository without discarding its original commit history.

The integration was completed successfully.

The Microsoft Defender repository is now available as a subdirectory of the Cybersecurity repository, and the original Microsoft Defender repository remains separate and untouched.

---

# 2. Project Objectives

The main objectives were:

1. Consolidate cybersecurity projects into one GitHub repository.
2. Import Microsoft Defender documentation into the Cybersecurity portfolio.
3. Preserve the original Microsoft Defender Git commit history.
4. Maintain the original source repository.
5. Learn how to use Git subtree.
6. Understand Git branches, commits, remotes, merging, fetching, and pushing.
7. Establish a repeatable process for future repository integrations.

---

# 3. Repository Architecture

## Before Integration

Two independent GitHub repositories existed.

### Source Repository

```text
https://github.com/jambon3/Microsoft-Defender.git
```

### Destination Repository

```text
https://github.com/jambon3/Cybersecurity.git
```

## After Integration

The Microsoft Defender project was integrated into the Cybersecurity repository.

```text
Cybersecurity/
│
├── README.md
│
├── Microsoft-Defender/
│   │
│   ├── README.md
│   ├── MS-Defender.md
│   ├── MS365-secure-score.md
│   ├── User-training.md
│   ├── user-training-print-proofofcompletion.md
│   ├── LICENSE
│   │
│   ├── Advanced-hunting-template/
│   │
│   └── Pictures/
│
└── documentation/
    └── git/
        └── subtree-repository-integration.md
```

The original Microsoft Defender repository remains available independently on GitHub.

---

# 4. Environment and Preparation

The work was performed on Windows using Git Bash.

### Local Working Directory

```bash
/c/Users/david.krin/Documents/D
```

### Clone the Destination Repository

```bash
git clone https://github.com/jambon3/Cybersecurity.git
```

### Navigate Into the Repository

```bash
cd Cybersecurity
```

### Verify Current Directory

```bash
pwd
```

### List Repository Contents

```bash
ls -la
```

### Check Current Branch

```bash
git branch --show-current
```

Expected output:

```text
main
```

### Check Repository Status

```bash
git status
```

Initially, the repository was clean and synchronized with GitHub.

---

# 5. Understanding Git Subtree

Git subtree allows one Git repository to be incorporated into another repository under a specified directory.

For this project:

- **Parent repository:** Cybersecurity
- **Child repository:** Microsoft-Defender
- **Destination directory:** `Microsoft-Defender/`

Unlike simply copying files, Git subtree preserves the source repository's commit history.

The original repository is not deleted or modified by the import process.

## Important Distinction

| Method | Files Transferred | Original Commit History |
|----------|----------|----------|
| Manual File Copy | Yes | No |
| ZIP Download | Yes | No |
| Git Subtree | Yes | Yes |
| Git Submodule | Repository Reference | Separate |

Git subtree was selected because the goal was to have the actual Defender documentation inside the Cybersecurity repository.

---

# 6. Verify Git Subtree Availability

Check whether Git subtree is available:

```bash
git subtree
```

The command displays the available operations and usage information.

Attempted version check:

```bash
git subtree --version
```

Result:

```text
error: unknown option `version'
```

This was not an installation failure.

The installed Git subtree implementation simply does not support a version switch.

The displayed usage confirmed that subtree operations were available.

---

# 7. Identify Repository Branches

The destination repository was using:

```text
main
```

The source repository's default branch was checked using:

```bash
git ls-remote --symref https://github.com/jambon3/Microsoft-Defender.git HEAD
```

Result:

```text
ref: refs/heads/main HEAD
36e5bea6fb1913ba0f979aea1b367776b216152c HEAD
```

This confirmed that the source repository also used the `main` branch.

---

# 8. Initial Repository Conflict

The destination repository initially contained a placeholder directory:

```text
microsoft-defender/
```

This directory had been created before the original Defender repository was imported.

Since the intention was to import the complete repository using Git subtree, the placeholder directory needed to be removed.

### Remove the Directory

```bash
git rm -r microsoft-defender
```

### Commit the Removal

```bash
git commit -m "Remove placeholder Microsoft Defender folder"
```

This removed the placeholder from the destination repository's working tree.

It did **not** delete the separate Microsoft Defender GitHub repository.

---

# 9. Git Push Rejection

Initial push attempt:

```bash
git push origin main
```

Git returned:

```text
! [rejected] main -> main (fetch first)

error: failed to push some refs
```

## Root Cause

The remote GitHub repository contained a commit that was not present in the local branch.

Git was protecting the remote history from being overwritten.

## Fetch Remote Changes

```bash
git fetch origin
```

Result:

```text
18564da..11bab23 main -> origin/main
```

This updated the local remote-tracking reference.

It did not automatically merge the remote changes into the current branch.

---

# 10. Diagnose Divergent Git Histories

```bash
git status
```

Result:

```text
On branch main

Your branch and 'origin/main' have diverged,
and have 14 and 1 different commits each, respectively.

nothing to commit, working tree clean
```

This indicated:

- 14 commits existed locally but not on GitHub.
- 1 commit existed on GitHub but not locally.
- The repository contained no uncommitted changes.

### Inspect Commit History

```bash
git log --oneline --graph --decorate --all -15
```

### Inspect Remote Commit

```bash
git show --stat origin/main
```

Remote commit:

```text
11bab236 Delete microsoft-defender/README.md
```

This established that the remote change was the deletion of the placeholder README file.

---

# 11. Import Microsoft Defender Using Git Subtree

```bash
git subtree add --prefix=Microsoft-Defender \
https://github.com/jambon3/Microsoft-Defender.git main
```

## Command Breakdown

| Parameter | Purpose |
|------------|------------|
| `git subtree add` | Imports another repository |
| `--prefix=Microsoft-Defender` | Destination directory |
| Repository URL | Source repository |
| `main` | Source branch |

The subtree operation imported the source repository into the destination repository.

### Verify Imported History

```bash
git log --oneline --graph --decorate --all -15
```

Important output:

```text
*   483c266 Add 'Microsoft-Defender/' from commit '36e5bea...'
|\
| * 36e5bea Update review frequency section formatting
| * 5a9e50a Clean up MS365-secure-score.md
| * 6ecc4c1 Document Microsoft Secure Score overview and guidelines
| * 02e1713 Delete Project-1 directory
| * 8b868b4 defender
| * 7074b89 defender
| * 1934df8 defender
| * 65ba3cd defender
| * 144b85e defender
| * 2c7dc91 defender
| * ef2b614 defender
| * 1eb92fb Initial commit
```

This confirmed that the original Microsoft Defender commit history was preserved.

---

# 12. Merge the Remote Change

Before merging, create a backup branch:

```bash
git branch backup-before-sync
```

Merge the remote changes:

```bash
git merge origin/main
```

Git opened the configured editor to request a merge commit message.

For Vim:

1. Press `Esc`
2. Type:

```text
:wq
```

3. Press `Enter`

### Verify the Merge

```bash
git log --oneline --graph --decorate -5
```

Important output:

```text
*   f44f602 (HEAD -> main) Merge remote-tracking branch 'origin/main'
|\
| * 11bab23 (origin/main, origin/HEAD) Delete microsoft-defender/README.md
* |   483c266 Add 'Microsoft-Defender/' from commit '36e5bea...'
```

The local subtree integration and the remote GitHub change were successfully connected through a merge commit.

---

# 13. Publish the Integrated Repository

Push the completed integration:

```bash
git push origin main
```

### Final Verification

```bash
git status
```

Expected output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

The integration was completed successfully.

---

# 14. Troubleshooting and Lessons Learned

## Problem 1: Markdown Entered Into Git Bash

### Error

```text
bash: Documentation,: command not found
```

### Cause

Markdown documentation was pasted directly into the terminal.

### Solution

Save Markdown in a `.md` file.

```bash
nano README.md
```

---

## Problem 2: Incorrect Directory Navigation

### Error

```text
bash: cd: too many arguments
```

### Cause

The `~` shortcut and another path were supplied together.

### Correct Command

```bash
cd "/c/Users/david.krin/Documents/D"
```

---

## Problem 3: Unsupported Git Subtree Version Command

### Error

```text
error: unknown option `version'
```

### Solution

Use:

```bash
git subtree
```

to verify functionality.

---

## Problem 4: Push Rejected

### Error

```text
[rejected] main -> main (fetch first)
```

### Solution

```bash
git fetch origin
git log --oneline --graph --decorate --all
git merge origin/main
```

---

## Problem 5: Unfamiliar Git Editor

Git was waiting for a merge commit message.

### Vim Exit Procedure

```text
Esc
:wq
Enter
```

---

## Problem 6: Understanding Nested Git Repositories

### Command

```bash
git -C microsoft-defender remote -v
```

Output:

```text
origin https://github.com/jambon3/Cybersecurity.git
```

The subtree directory did not contain its own `.git` repository.

Git searched upward and located the parent repository.

Determine repository ownership:

```bash
git -C microsoft-defender rev-parse --show-toplevel
```

---

# 15. Future Git Commands and Maintenance

### Check Repository Status

```bash
git status
```

### Check Current Branch

```bash
git branch --show-current
```

### View Commit History

```bash
git log --oneline --graph --decorate -20
```

### Fetch Remote Changes

```bash
git fetch origin
```

### Stage Changes

```bash
git add .
```

### Commit Changes

```bash
git commit -m "Describe the changes"
```

### Push Changes

```bash
git push origin main
```

### Pull Changes

```bash
git pull origin main
```

### Update the Microsoft Defender Subtree

```bash
git subtree pull --prefix=Microsoft-Defender \
https://github.com/jambon3/Microsoft-Defender.git main
```

### Push Subtree Changes Back to Source Repository

```bash
git subtree push --prefix=Microsoft-Defender \
https://github.com/jambon3/Microsoft-Defender.git main
```

---

# 16. Important Git Concepts Learned

| Concept | Meaning |
|----------|----------|
| Repository | A project tracked by Git |
| Clone | Downloading a repository and its history |
| Remote | Reference to another Git repository |
| Origin | Conventional name for the primary remote |
| Branch | Independent line of development |
| Commit | Recorded change in Git history |
| Fetch | Retrieves remote changes without merging |
| Merge | Combines changes and histories |
| Push | Uploads local commits to a remote |
| Pull | Fetches and integrates remote changes |
| Subtree | Integrates another repository into a directory |
| Working Tree | Files currently checked out locally |
| HEAD | Current commit or branch position |
| Remote-Tracking Branch | Local reference to a remote branch |

---

# 17. Recommended Best Practices

1. Always check `git status` before making changes.
2. Fetch remote changes before integrating work from another branch.
3. Review commit history when Git reports divergent branches.
4. Create a backup branch before complex merges.
5. Avoid `git push --force` unless fully understood.
6. Avoid `git reset --hard` when work must be preserved.
7. Use meaningful commit messages.
8. Keep README files updated.
9. Document technical projects as they are completed.
10. Never publish credentials, confidential logs, customer information, or proprietary configurations.

---

# 18. Final Outcome

## Status: Successfully Completed ✅

The Microsoft Defender repository was integrated into the Cybersecurity portfolio using Git subtree.

### Achievements

- Microsoft Defender files were imported into the Cybersecurity repository.
- Original Defender commit history was preserved.
- Remote and local Git histories were reconciled.
- The integration was published to GitHub.
- The original Microsoft Defender repository remained separate.
- A backup branch was created before final synchronization.

## Final Repositories

### Cybersecurity Portfolio

https://github.com/jambon3/Cybersecurity

### Original Microsoft Defender Repository

https://github.com/jambon3/Microsoft-Defender

## Technical Takeaway

Git subtree is a powerful approach for consolidating related projects into a larger repository while preserving the original source project's commit history. Understanding fetch, merge, branch history, and remote synchronization is essential for performing this operation safely and effectively.
