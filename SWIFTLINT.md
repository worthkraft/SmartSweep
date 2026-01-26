# SwiftLint Configuration for SmartSweep

## Overview

This document explains the SwiftLint configuration used in the SmartSweep project. SwiftLint is a tool to enforce Swift style and conventions, helping maintain code quality and consistency across the codebase.

## Installation

If you haven't installed SwiftLint yet, you can do so using Homebrew:

```bash
brew install swiftlint
```

Or using CocoaPods by adding to your Podfile:

```ruby
pod 'SwiftLint'
```

## Configuration

The project uses a `.swiftlint.yml` file in the root directory to configure SwiftLint. This configuration has been tailored to match the coding style already present in the SmartSweep project.

## Key Rules

### Enabled Rules

- **Code Structure**: Rules like `array_init`, `collection_alignment`, and `multiline_parameters` ensure consistent code structure.
- **Performance**: Rules like `contains_over_filter_count` and `contains_over_first_not_nil` encourage more efficient code patterns.
- **Safety**: Rules like `force_unwrapping`, `implicitly_unwrapped_optional`, and `force_cast` (as warning) help prevent runtime crashes.
- **Readability**: Rules like `literal_expression_end_indentation`, `operator_usage_whitespace`, and `trailing_closure` improve code readability.

### Project-Specific Rules

Based on analysis of the SmartSweep codebase, we've configured these specific rules:

- **Disabled**: `vertical_whitespace` and `trailing_newline` are disabled to match existing code style
- **Warnings**: `redundant_type_annotation` and `pattern_matching_keywords` are set to warning level
- **Force Operations**: `force_cast`, `force_try`, and `force_unwrapping` are set to warning level

### Customized Limits

- **Line Length**: Warning at 120 characters, error at 150 characters
- **Function Body Length**: Warning at 60 lines, error at 100 lines
- **File Length**: Warning at 400 lines, error at 600 lines
- **Cyclomatic Complexity**: Warning at 12, error at 15
- **Nesting Levels**: Warning at 3 levels for types, 5 for functions

### Excluded Paths

The configuration excludes test directories, dependency management directories, and generated code.

## Integration with Xcode

To integrate SwiftLint with Xcode:

1. Add a new "Run Script Phase" in your target's "Build Phases"
2. Add the following script (or use the provided `swiftlint-run-script.sh`):

```bash
if which swiftlint > /dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

## Git Hooks Integration

A Git pre-commit hook is provided to run SwiftLint before each commit:

1. Copy the hook to your Git hooks directory:

```bash
cp git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

2. Now SwiftLint will run automatically before each commit, preventing commits with linting issues.

See `git-hooks/README.md` for more details on the available Git hooks.

## Automatic Corrections

Some SwiftLint violations can be automatically fixed using the provided script:

```bash
./swiftlint-autocorrect.sh
```

This script runs `swiftlint --fix` and then checks for any remaining violations. It will automatically correct issues like whitespace, trailing semicolons, and other formatting issues.

Alternatively, you can run the fix command directly:

```bash
swiftlint --fix
```

## Customizing Rules

If you need to disable a rule for a specific line or section of code, you can use:

```swift
// swiftlint:disable:next force_cast
let someValue = value as! SomeType
```

Or for a section of code:

```swift
// swiftlint:disable force_cast
// Code with force casts
// swiftlint:enable force_cast
```

## Updating the Configuration

As the project evolves, you may need to update the SwiftLint configuration. When doing so, consider:

1. The existing code style in the project
2. The team's preferences and coding standards
3. The balance between strictness and practicality

After updating the configuration, run SwiftLint to check for any new violations and address them as needed.