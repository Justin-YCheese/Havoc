# Lua Coding Style Guide

Guide that describes code styling practices used in Havoc Tabletop Edition.

## General Recommendation

When in doubt, follow existing code base conventions.

## Files

- Names of files and directories: Pascal Case, but spaces are allowed

## Imports

- Keep `#include` statements at the top of the file and order them alphabetically

## Functions

- Name using camelCase
- Parameter names use camelCase

```lua
function addValues(x, y)
    -- Code here
end
```

## Constants

- Variables and fields that can be made constants should always be constants
- Use constants instead of magic numbers
- Name with UPPERCASE_SNAKECASE

```lua
CONSTANT = 50
```

## Commenting

- Place comments on a separate line, not at the end of a line of code
- Begin comment with an uppercase letter
- Do not end comments with a period
- Insert one space between comment delimiter (--) and the comment

```lua
 -- This is an example comment
```

- When commenting multiple lines use `CTRL + /`

```lua
 -- -- This was already a comment
 -- local sum = 0
 -- local cardTable = {}
```

## Whitespace & Indentation

- Maximum of one statement per line
- Column limit: 150
- Indent by four spaces
- No tabs
- No line break before `then` keyword
- Always have a line break after `then` and `else` keywords
- No consecutive whitespace
- No consecutive line breaks
- No line break between closing brace and else

```lua
if true then
    -- Do stuff here
else
    -- Do stuff here
end
```

## Variable Scope

- Use local rather than globals whenever possible
- Always have global variables at the top of the script