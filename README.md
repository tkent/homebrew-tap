# tkent/tap

Homebrew tap for tools by Terence Kent.

```sh
brew install tkent/tap/cairn
```

| Formula | Description |
|---|---|
| `cairn` | Knowledge in Open Knowledge Format (OKF) as a CLI and MCP server |

Binaries are downloaded from [tkent/cairn-releases](https://github.com/tkent/cairn-releases/releases).
macOS and Linux, on arm64 and x86_64.

## Maintenance

`Formula/cairn.rb` is generated: don't edit it by hand. cairn's release workflow runs
`tools/bump-formula.sh <version> <checksums.txt>`, which renders `tools/cairn.rb.tmpl`,
then commits the result. Stable versions only; pre-releases (`-devN`) never land here.
To change the formula, edit the template.
