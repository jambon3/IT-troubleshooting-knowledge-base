Recommended cleanup method

### GitHub: Removing sensitive data from a repository
The process is:
1. Make a backup of your local repository.
2. Install git-filter-repo.
3. Create a replacement list that maps each exposed identifier to a fictional value, for example PRODUCTION-SERVER → APP-SERVER-01.
4. Rewrite all affected commit history using git-filter-repo --replace-text.
5. Review the rewritten history carefully, then force-push the cleaned branches and tags to GitHub.
6. Check for remaining references and contact GitHub Support if sensitive cached views need removal.
Be careful: history rewriting changes commit IDs and can affect branches, pull requests, and collaborators. Do not blindly copy commands from a guide without adapting them to your repository.

Once you have a sanitized repository, verify that:
- The latest files contain no company-specific identifiers.
- Old commits no longer contain the exposed information in the rewritten history.
- No other branches or tags retain the old history.
- Screenshots, diagrams, README files, and commit messages are also sanitized.
You can then decide whether to make the repository public again. Remember that making it private or rewriting history cannot guarantee that previously copied information disappears from every location.

