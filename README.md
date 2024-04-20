# AdvancedText

Extends RichTextLabel and adds support for Markdown and RenPy.
Our RenPy Markup and Markdown have some extra stuff so read docs to learn it.
This new version is designed in way so any one can crate its own TextParser to use with AdvancedText nodes.
[**Read Docs**](https://rakugoteam.github.io/advanced-text-docs/2.0/)

## Features

- Supports Markdown and RenPy
- Adds headers supports RenPy and BBCode
- Support for variables in [Rakugo Dialogue System](https://github.com/rakugoteam/Rakugo-Dialogue-System) use`<var_name>`
- Support [Emojis For Godot](https://github.com/rakugoteam/Emojis-For-Godot) use `:emoji:`
- Support [Godot Material Icons](https://github.com/rakugoteam/Godot-Material-Icons) use `[icon:icon_name]`

### Nodes

- **AdvancedTextLabel** - **RichTextLabel** that allow to use one of included TextParsers
- **AdvancedTextButton** - **AdvancedTextLabel** that behaves like a button

### Resources

- **TextParser** - base class for our TextParsers
- **ExtendedBBCodeParser**:
  - base of for our RenPy Markup and Markdown parsers
  - includes support for things mentioned in [Features](#features)
- **RenPyMarkup** - RenPy Markup Parser with extra tags so it is 100% replaceable with Godot's BBCode
- **MarkdownParser** - Markdown Parser with extra stuff so it is 100% replaceable with Godot's BBCode

## Download

`Engine.has/get_singleton()` functions don't work with external singletons,
so we must offer 2 versions of this addon one with and one without integrations (**clean** version) with: [Rakugo Dialogue System](https://github.com/rakugoteam/Rakugo-Dialogue-System), [Emojis For Godot](https://github.com/rakugoteam/Emojis-For-Godot), [Godot Material Icons](https://github.com/rakugoteam/Godot-Material-Icons).
