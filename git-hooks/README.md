# Git Hooks for SmartSweep

## Pre-commit Hook

The pre-commit hook runs SwiftLint before each commit to ensure code quality standards are maintained.

### Installation

To install the pre-commit hook, run the following command from the project root:

```bash
cp git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### How It Works

The pre-commit hook:

1. Identifies all Swift files staged for commit
2. Runs SwiftLint on these files
3. Blocks the commit if SwiftLint finds issues
4. Suggests running the auto-correction script to fix issues

### Bypassing the Hook

In rare cases where you need to bypass the hook (not recommended), you can use:

```bash
git commit --no-verify
```

## Adding More Hooks

You can add more Git hooks to this directory as needed. Common hooks include:

- `pre-push`: Run tests before pushing to remote
- `post-merge`: Update dependencies after pulling changes
- `post-checkout`: Clean build artifacts after switching branches

For more information on Git hooks, see the [Git documentation](https://git-scm.com/docs/githooks).