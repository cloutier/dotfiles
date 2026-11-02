# Repository instructions

Before every Git commit, perform a quick audit of the staged changes for secrets,
including passwords, API tokens, private keys, and other credentials. If a potential
secret is found, stop and notify the user; do not commit it.

When replacing or migrating files, do not retain obsolete originals or create
redundant backup copies if their contents are already preserved in Git history.
Protect uncommitted or untracked contents that are not recoverable from Git.
