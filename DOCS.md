# Neovim keymap guide

Every shortcut in this config, plus the built-in and plugin keys worth knowing.

> **Search all of this inside Neovim:** press `Space k` (or run `:Keys`) and describe what you want
> in your own words: *"rename variable"*, *"close file"*, *"who wrote this line"*, *"split screen"*.
> Typos are fine. Type a key like *"space f f"* or *"ctrl d"* to see what it does, and press
> `Enter` to run the selected shortcut.

This file is generated from `lua/keyguide/registry.lua` by `:KeysExport`. Edit the registry (not
this file) when you add or change a keymap, then run `:KeysExport` again.

## How to read the keys

| Written as | Means |
| --- | --- |
| `Space f f` | Press Space, then `f`, then `f`, one after another. Space is the *leader* key, written `<leader>` in the config files. |
| `Ctrl+d` | Hold Ctrl and press `d`. |
| `Alt+j` | Hold Alt (Option on a Mac) and press `j`. |
| `Shift+Tab` | Hold Shift and press Tab. |
| `gcc` | Press `g`, `c`, `c` one after another. |
| `:w` | A command: type it (starting with `:`) and press Enter. |
| `Ctrl+j / Ctrl+n` | Either key does the same thing. |

**Modes.** *Normal* mode is the default: keys are commands. *Insert* mode is for typing text (enter
with `i`, leave with `Esc`). *Visual* mode is for selecting (`v`, `V`, `Ctrl+v`). *Command* mode is
the `:` line. *Operator-pending* means right after `d`, `c` or `y` (that's where text objects go).

Tip: press `Space` and wait a moment. A popup (which-key) shows every key that can follow.

## Start here

The keys you'll use every day.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space k` | Normal | Open the keymap guide: search every shortcut in plain English | `config/keymaps.lua` |
| `Space f f` | Normal | Find a file by name (fff: very fast, ranks files you open often first) | `plugins/fff.lua` |
| `Space f g` | Normal | Search for text in every file of the project (fff live grep) | `plugins/fff.lua` |
| `Space e` | Normal | Open / close the file explorer sidebar | `config/keymaps.lua` |
| `Space w` | Normal | Save the file (also formats it and trims trailing spaces) | `config/keymaps.lua` |
| `Space q` | Normal | Quit: close the current window | `config/keymaps.lua` |
| `u` | Normal | Undo | built-in |
| `gcc` | Normal | Comment / uncomment the current line | mini.comment |
| `K` | Normal | Show documentation for the thing under the cursor (hover)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space g D` | Normal | Go to the definition<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space r n` | Normal | Rename the symbol under the cursor everywhere (variable, function ...)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space c a` | Normal | Show code actions (quick fixes, refactors, add missing import ...)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space x x` | Normal | Show / hide the list of all errors & warnings in the project (Trouble) | `plugins/trouble-nvim.lua` |
| `Space b n` | Normal | Go to the next buffer | `config/keymaps.lua` |
| `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` | Normal | Move to the window on the left / below / above / right (also tmux panes) | vim-tmux-navigator |
| `Space s v` | Normal | Split the window vertically (side by side) | `config/keymaps.lua` |
| `Alt+j` / `Alt+k` | Normal + Visual | Move the line (or selection) down / up | mini.move |

## Contents

- [Help & discovery](#help--discovery)
- [Basics: modes, saving, undo](#basics-modes-saving-undo)
- [Moving around](#moving-around)
- [Search & replace in this file](#search--replace-in-this-file)
- [Editing text](#editing-text)
- [Comments, brackets & quotes](#comments-brackets--quotes)
- [Text objects: act on 'inside' / 'around' things](#text-objects-act-on-inside--around-things)
- [Find files & text](#find-files--text)
- [Inside the fff finder](#inside-the-fff-finder)
- [Inside fzf-lua pickers](#inside-fzf-lua-pickers)
- [Buffers (open files)](#buffers-open-files)
- [Windows & splits](#windows--splits)
- [Tabs](#tabs)
- [File explorer](#file-explorer)
- [Inside the file explorer (nvim-tree)](#inside-the-file-explorer-nvim-tree)
- [Code intelligence (LSP)](#code-intelligence-lsp)
- [Errors & diagnostics](#errors--diagnostics)
- [Inside the Trouble list](#inside-the-trouble-list)
- [Git](#git)
- [Inside the Git status window (:Git)](#inside-the-git-status-window-git)
- [Autocomplete menu](#autocomplete-menu)
- [Typing helpers (Insert mode)](#typing-helpers-insert-mode)
- [Folding (collapse code)](#folding-collapse-code)
- [Debugging (Rust)](#debugging-rust)
- [Focus, colors & AI](#focus-colors--ai)
- [Config, plugins & tools](#config-plugins--tools)
- [Inside the keymap guide](#inside-the-keymap-guide)

## Help & discovery

Ways to find shortcuts and answers without leaving Neovim.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space k` | Normal | Open the keymap guide: search every shortcut in plain English | `config/keymaps.lua` |
| `:Keys` | Command | Open the keymap guide with a search already typed, e.g. :Keys split window | `keyguide/init.lua` |
| `:KeysSheet` | Command | Open the full cheat sheet (DOCS.md) in a new tab | `keyguide/init.lua` |
| `:KeysExport` | Command | Regenerate DOCS.md from the keymap guide's list | `keyguide/init.lua` |
| `Space` | Normal | Press Space and wait: a popup lists every shortcut that starts with Space | which-key.nvim |
| `Space ?` | Normal | Show the shortcuts that only exist in the current buffer (which-key) | `plugins/which-key.lua` |
| `Space f h` | Normal | Search Neovim's help pages (fzf-lua) | `plugins/fzf-lua.lua` |
| `:help` | Command | Open Neovim's built-in manual on a topic, e.g. :help motion | built-in |
| `:Tutor` | Command | Start the interactive Vim tutorial (about 30 minutes, practice by doing) | built-in |
| `:FzfLua keymaps` | Command | Fuzzy-search the raw list of every active keymap (fzf-lua) | fzf-lua |

## Basics: modes, saving, undo

Neovim starts in Normal mode, where keys are commands. Press i to type text and Esc to go back.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `i` | Normal | Start typing before the cursor (Insert mode) | built-in |
| `a` | Normal | Start typing after the cursor | built-in |
| `A` | Normal | Start typing at the end of the line | built-in |
| `I` | Normal | Start typing at the beginning of the line | built-in |
| `o` | Normal | Open a new line below and start typing | built-in |
| `O` | Normal | Open a new line above and start typing | built-in |
| `Esc` | Insert | Go back to Normal mode (leave Insert or Visual mode) | built-in |
| `v` | Normal | Select characters (Visual mode) | built-in |
| `V` | Normal | Select whole lines (Visual Line mode) | built-in |
| `ggVG` | Normal | Select the whole file | built-in |
| `Ctrl+v` | Normal | Select a rectangle / column (Visual Block mode) | built-in |
| `u` | Normal | Undo | built-in |
| `Ctrl+r` | Normal | Redo | built-in |
| `.` | Normal | Repeat the last change | built-in |
| `Space w` | Normal | Save the file (also formats it and trims trailing spaces)<br>*Formatting on save uses the tools set up in lua/servers/efm-langserver.lua.* | `config/keymaps.lua` |
| `:w` | Command | Save the file | built-in |
| `Space q` | Normal | Quit: close the current window | `config/keymaps.lua` |
| `:q` | Command | Quit: close the current window | built-in |
| `:wq` | Command | Save and quit | built-in |
| `:q!` | Command | Quit without saving (throw away changes) | built-in |
| `:qa` | Command | Quit Neovim completely (all windows) | built-in |
| `:e` | Command | Open a file by typing its path, e.g. :e src/main.go (a new name creates the file) | built-in |
| `:terminal` | Command | Open a terminal inside Neovim<br>*Type exit in the terminal to close it.* | built-in |
| `Ctrl+\ Ctrl+n` | Terminal | Leave the terminal's typing mode so you can scroll / copy (i to type again) | built-in |
| `Space p a` | Normal | Copy the full path of the current file to the clipboard | `config/keymaps.lua` |

## Moving around

Normal-mode motions. Most can take a count first, e.g. 5j moves 5 lines down.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `h` / `l` | Normal | Move left / right | built-in |
| `j` / `k` | Normal | Move down / up (follows wrapped lines) | `config/keymaps.lua` |
| `w` | Normal | Jump forward to the start of the next word | built-in |
| `b` | Normal | Jump back to the start of the previous word | built-in |
| `e` | Normal | Jump to the end of the word | built-in |
| `0` | Normal | Go to the start of the line | built-in |
| `^` | Normal | Go to the first non-blank character of the line | built-in |
| `$` | Normal | Go to the end of the line | built-in |
| `gg` | Normal | Go to the first line of the file | built-in |
| `G` | Normal | Go to the last line of the file | built-in |
| `:42` | Command | Jump / go to line N: type : and the number, e.g. :120 | built-in |
| `%` | Normal | Jump between matching brackets ( ) [ ] { } | built-in |
| `{` / `}` | Normal | Jump to the previous / next blank line (paragraph) | built-in |
| `Ctrl+d` | Normal | Scroll half a page down (keeps the cursor centered) | `config/keymaps.lua` |
| `Ctrl+u` | Normal | Scroll half a page up (keeps the cursor centered) | `config/keymaps.lua` |
| `zz` | Normal | Center the screen on the cursor line | built-in |
| `Ctrl+o` | Normal | Jump back to where you were before (jump list) | built-in |
| `Ctrl+i` | Normal | Jump forward again in the jump list | built-in |
| `f` | Normal | Jump to a character on the line: f then the character (; repeats, , goes back) | built-in |
| `gx` | Normal | Open the link or path under the cursor in the browser / system app | built-in |
| `gf` | Normal | Open the file whose path is under the cursor | built-in |
| `ma` | Normal | Set mark a at the cursor (any letter); jump back to it with 'a | built-in |

## Search & replace in this file

Searching inside the file you're looking at.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `/` | Normal | Search forward in this file: type the text, then Enter | built-in |
| `?` | Normal | Search backward in this file | built-in |
| `n` | Normal | Go to the next search match (centered) | `config/keymaps.lua` |
| `N` | Normal | Go to the previous search match (centered) | `config/keymaps.lua` |
| `*` | Normal | Search for the word under the cursor (forward) | built-in |
| `#` | Normal | Search for the word under the cursor (backward) | built-in |
| `Space h` | Normal | Clear search highlighting | `config/keymaps.lua` |
| `:%s/old/new/g` | Command | Find and replace in the whole file (add c at the end to confirm each one) | built-in |

## Editing text

Deleting, copying, pasting, indenting and moving lines (Normal / Visual mode).

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `x` | Normal | Delete the character under the cursor | built-in |
| `dd` | Normal | Delete (cut) the current line | built-in |
| `dw` | Normal | Delete a word (d works with any motion: d$, dj, dip ...) | built-in |
| `D` | Normal | Delete from the cursor to the end of the line | built-in |
| `yy` | Normal | Copy (yank) the current line | built-in |
| `p` | Normal | Paste after the cursor | built-in |
| `P` | Normal | Paste before the cursor | built-in |
| `ciw` | Normal | Change the word under the cursor (delete it and start typing) | built-in |
| `cc` | Normal | Change (rewrite) the whole line | built-in |
| `r` | Normal | Replace one character: r then the new character | built-in |
| `~` | Normal | Switch upper / lower case of the character | built-in |
| `Ctrl+a` / `Ctrl+x` | Normal | Increase / decrease the number under the cursor | built-in |
| `>>` / `<<` | Normal | Indent / unindent the current line | built-in |
| `>` / `<` | Visual | Indent / unindent the selection (stays selected) | `config/keymaps.lua` |
| `J` | Normal | Join the line below onto this one (cursor stays put) | `config/keymaps.lua` |
| `Alt+j` / `Alt+k` | Normal + Visual | Move the line (or selection) down / up<br>*keymaps.lua defines the same keys; mini.move's version is the one that runs.* | mini.move |
| `Alt+h` / `Alt+l` | Normal + Visual | Move the line (or selection) left / right (changes indent) | mini.move |
| `Space p` | Visual | Paste over the selection without losing what you copied | `config/keymaps.lua` |
| `Space x` | Normal + Visual | Delete without copying (your clipboard stays as it was)<br>*In Normal mode add a motion, e.g. Space x w. Space x x and Space x d are taken by diagnostics.* | `config/keymaps.lua` |
| `Space q q` | Normal | Insert a Go 'if err != nil' block | `config/keymaps.lua` |

## Comments, brackets & quotes

Commenting (mini.comment), wrapping text in brackets/quotes (mini.surround) and auto-closing pairs (mini.pairs).

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `gcc` | Normal | Comment / uncomment the current line | mini.comment |
| `gc` | Visual | Comment / uncomment the selected lines | mini.comment |
| `gc` | Normal | Comment with a motion, e.g. gcip = paragraph, gc3j = 4 lines | mini.comment |
| `gc` | Operator-pending | Comment block text object, e.g. dgc deletes the whole comment | mini.comment |
| `sa` | Normal + Visual | Add brackets/quotes around text: sa + motion + character, e.g. saiw) wraps a word in ( ) | mini.surround |
| `sd` / `sdn` / `sdl` | Normal | Delete the brackets/quotes around the cursor: sd + character, e.g. sd"<br>*Add n / l (sdn, sdl) to act on the next / previous pair. Same for sr, sf, sF and sh.* | mini.surround |
| `sr` / `srn` / `srl` | Normal | Replace surrounding brackets/quotes: sr + old + new, e.g. sr)] turns ( ) into [ ] | mini.surround |
| `sf` / `sF` / `sfn` / `sfl` / `sFn` / `sFl` | Normal | Jump to the next (sf) / previous (sF) surrounding character | mini.surround |
| `sh` / `shn` / `shl` | Normal | Briefly highlight the surrounding brackets/quotes | mini.surround |
| `(` / `[` / `{` / `"` / `'` / `` ` `` / `)` / `]` / `}` | Insert | Brackets and quotes close themselves automatically while typing | mini.pairs |
| `Backspace` | Insert | Backspace between an empty pair deletes both characters | mini.pairs |

## Text objects: act on 'inside' / 'around' things

Use after d (delete), c (change), y (copy) or v (select). Example: ci" = change inside quotes, dap = delete paragraph.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `iw` / `aw` | Operator-pending + Visual | Inside / around a word | built-in |
| `ip` / `ap` | Operator-pending + Visual | Inside / around a paragraph | built-in |
| `i(` / `a(` / `ib` / `ab` | Operator-pending + Visual | Inside / around parentheses (b = any bracket type) | mini.ai |
| `i"` / `a"` / `iq` / `aq` | Operator-pending + Visual | Inside / around quotes (q = any quote type) | mini.ai |
| `if` / `af` | Operator-pending + Visual | Inside / around a function call | mini.ai |
| `ia` / `aa` | Operator-pending + Visual | Inside / around a function argument | mini.ai |
| `it` / `at` | Operator-pending + Visual | Inside / around an HTML/XML tag | mini.ai |
| `ii` / `ai` | Operator-pending + Visual | Inside / around the current indentation block | mini.indentscope |
| `in` / `an` / `il` / `al` | Operator-pending + Visual | Next / last text object, e.g. cin) changes inside the next ( ) | mini.ai |
| `g[` / `g]` | Normal + Visual + Operator-pending | Jump to the left / right edge of a text object | mini.ai |
| `[i` / `]i` | Normal + Visual + Operator-pending | Jump to the top / bottom of the current indentation block | mini.indentscope |

## Find files & text

Project-wide search. fff is the fast default; fzf-lua covers buffers, symbols & more.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space f f` | Normal | Find a file by name (fff: very fast, ranks files you open often first) | `plugins/fff.lua` |
| `Space f g` | Normal | Search for text in every file of the project (fff live grep) | `plugins/fff.lua` |
| `Space f z` | Normal | Fuzzy text search across the project that tolerates typos (fff) | `plugins/fff.lua` |
| `Space f c` | Normal + Visual | Search the project for the word under the cursor or the selected text (fff) | `plugins/fff.lua` |
| `Space f l` | Normal | Reopen the last fff search, with the same query and results | `plugins/fff.lua` |
| `Space f F` | Normal | Find a file by name (fzf-lua version) | `plugins/fzf-lua.lua` |
| `Space f G` | Normal | Search text in the project (fzf-lua version) | `plugins/fzf-lua.lua` |
| `Space f b` | Normal | List open buffers and jump to one (fzf-lua) | `plugins/fzf-lua.lua` |
| `Space f s` | Normal | List symbols (functions, classes ...) in this file (fzf-lua) | `plugins/fzf-lua.lua` |
| `Space f S` | Normal | Search symbols across the whole project (fzf-lua) | `plugins/fzf-lua.lua` |
| `Space f x` | Normal | List errors & warnings in this file (fzf-lua) | `plugins/fzf-lua.lua` |
| `Space f X` | Normal | List errors & warnings in the whole project (fzf-lua) | `plugins/fzf-lua.lua` |

## Inside the fff finder

Keys that work while the fff window (Space f f, Space f g ...) is open. You type in Insert mode.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Enter` | Insert | Open the selected file | fff |
| `Ctrl+s` | Insert | Open in a horizontal split | fff |
| `Ctrl+v` | Insert | Open in a vertical split (side by side) | fff |
| `Ctrl+t` | Insert | Open in a new tab | fff |
| `Esc` | Insert | Close the finder | fff |
| `Down` / `Ctrl+n` | Insert | Move down the list | fff |
| `Up` / `Ctrl+p` | Insert | Move up the list | fff |
| `Ctrl+d` / `Ctrl+u` | Insert | Scroll the preview down / up | fff |
| `Tab` | Insert | Mark / unmark a file (pick several) | fff |
| `Ctrl+q` | Insert | Send the marked files to the quickfix list | fff |
| `Shift+Tab` | Insert | Live grep: switch between plain, regex and fuzzy matching | fff |
| `Alt+Down` / `Alt+Up` | Insert | Live grep: jump to the next / previous file's matches | fff |
| `Ctrl+Up` / `Ctrl+Down` | Insert | Bring back previous / next search queries (history) | fff |
| `git:modified` | Insert | Type git:modified (or staged, untracked ...) to only show those files | fff |
| `*.lua` | Insert | Type \*.lua or src/ to filter by extension or folder; !test/ excludes | fff |
| `F2` | Insert | Show / hide the scoring debug info | fff |

## Inside fzf-lua pickers

Keys for fzf-lua windows (Space f b, Space f s, Space f h ...).

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Enter` | Insert | Open / accept the selected item | fzf-lua |
| `Ctrl+s` / `Ctrl+v` / `Ctrl+t` | Insert | Open in a split / vertical split / new tab | fzf-lua |
| `Ctrl+j` / `Ctrl+n` | Insert | Move down the list | fzf-lua |
| `Ctrl+k` / `Ctrl+p` | Insert | Move up the list | fzf-lua |
| `Tab` | Insert | Select several items | fzf-lua |
| `Alt+q` | Insert | Send the selected items to the quickfix list | fzf-lua |
| `Shift+Down` / `Shift+Up` | Insert | Scroll the preview down / up | fzf-lua |
| `F4` | Insert | Show / hide the preview | fzf-lua |
| `Alt+h` / `Alt+i` | Insert | Files picker: include hidden / git-ignored files | fzf-lua |
| `F1` | Insert | Show every key available in the picker | fzf-lua |
| `Esc` | Insert | Close the picker | fzf-lua |

## Buffers (open files)

Every file you open stays loaded as a buffer, even when it's not on screen.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space b n` | Normal | Go to the next buffer | `config/keymaps.lua` |
| `Space b p` | Normal | Go to the previous buffer | `config/keymaps.lua` |
| `Space b q` | Normal | Close the current file (buffer) | `config/keymaps.lua` |
| `]b` / `[b` | Normal | Next / previous buffer (built in) | built-in |
| `Ctrl+^` | Normal | Switch back to the file you were in before (alternate file) | built-in |
| `:ls` | Command | List all open buffers | built-in |

## Windows & splits

A window is a view on a buffer. Split the screen to see several files at once.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` | Normal | Move to the window on the left / below / above / right (also tmux panes)<br>*keymaps.lua maps these too; vim-tmux-navigator's version runs and also crosses into tmux panes.* | vim-tmux-navigator |
| `Ctrl+\` | Normal | Go back to the previously used window / tmux pane | vim-tmux-navigator |
| `Space s v` | Normal | Split the window vertically (side by side) | `config/keymaps.lua` |
| `Space s h` | Normal | Split the window horizontally (top / bottom) | `config/keymaps.lua` |
| `Ctrl+Up` / `Ctrl+Down` | Normal | Make the window taller / shorter | `config/keymaps.lua` |
| `Ctrl+Left` / `Ctrl+Right` | Normal | Make the window narrower / wider | `config/keymaps.lua` |
| `Ctrl+w =` | Normal | Make all windows the same size | built-in |
| `Ctrl+w q` | Normal | Close the current window | built-in |
| `Ctrl+w o` | Normal | Close every other window (keep only this one) | built-in |
| `Ctrl+w w` | Normal | Cycle to the next window | built-in |

## Tabs

A tab holds a whole layout of windows.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `L` | Normal | Go to the next tab | `config/keymaps.lua` |
| `H` | Normal | Go to the previous tab<br>*Shift+h / Shift+l are the same keys as H / L, so the buffer mappings keymaps.lua gives them are replaced by these. Use Space b n / Space b p for buffers.* | `config/keymaps.lua` |
| `Space 1 … Space 9` | Normal | Go to tab number 1-9 | `config/keymaps.lua` |
| `gt` / `gT` | Normal | Next / previous tab (built in) | built-in |
| `:tabnew` | Command | Open a new tab | built-in |
| `:tabclose` | Command | Close the current tab | built-in |

## File explorer

The project tree on the side (nvim-tree).

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space e` | Normal | Open / close the file explorer sidebar | `config/keymaps.lua` |
| `Space H S` | Normal | Open netrw (the old built-in explorer) in a horizontal split<br>*netrw is disabled in lua/config/lazy.lua, so this does nothing unless you re-enable it.* | `config/keymaps.lua` |
| `Space V S` | Normal | Open netrw in a vertical split<br>*netrw is disabled in lua/config/lazy.lua, so this does nothing unless you re-enable it.* | `config/keymaps.lua` |
| `Space n t` | Normal | Open netrw in a new tab<br>*netrw is disabled in lua/config/lazy.lua, so this does nothing unless you re-enable it.* | `config/keymaps.lua` |
| `Space w l` | Normal | Toggle a netrw explorer on the left<br>*netrw is disabled, so this does nothing; in files with a language server it lists workspace folders instead.* | `config/keymaps.lua` |

## Inside the file explorer (nvim-tree)

Keys that work in the sidebar opened with Space e. Press g? there for the full list.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Enter` / `o` | Normal | Open the file / expand or collapse the folder | nvim-tree.lua |
| `a` | Normal | Create a new file (end the name with / to make a folder) | nvim-tree.lua |
| `r` | Normal | Rename the file or folder | nvim-tree.lua |
| `d` | Normal | Delete the file or folder | nvim-tree.lua |
| `D` | Normal | Move the file or folder to the trash | nvim-tree.lua |
| `x` | Normal | Cut the file (then p to move it) | nvim-tree.lua |
| `c` | Normal | Copy the file (then p to paste it) | nvim-tree.lua |
| `p` | Normal | Paste the cut / copied file here | nvim-tree.lua |
| `y` | Normal | Copy the file name | nvim-tree.lua |
| `Y` | Normal | Copy the relative path | nvim-tree.lua |
| `gy` | Normal | Copy the absolute path | nvim-tree.lua |
| `Ctrl+v` / `Ctrl+x` / `Ctrl+t` | Normal | Open in a vertical split / horizontal split / new tab | nvim-tree.lua |
| `Tab` | Normal | Preview the file (focus stays in the tree) | nvim-tree.lua |
| `H` | Normal | Show / hide dotfiles (hidden files) | nvim-tree.lua |
| `I` | Normal | Show / hide git-ignored files | nvim-tree.lua |
| `R` | Normal | Refresh the tree | nvim-tree.lua |
| `-` | Normal | Go up one directory (make the parent the root) | nvim-tree.lua |
| `Ctrl+]` | Normal | Make the folder under the cursor the root | nvim-tree.lua |
| `P` | Normal | Jump to the parent folder | nvim-tree.lua |
| `Backspace` | Normal | Close the parent folder | nvim-tree.lua |
| `E` / `W` | Normal | Expand all / collapse all folders | nvim-tree.lua |
| `f` / `F` | Normal | Filter files by name as you type / clear the filter | nvim-tree.lua |
| `S` | Normal | Search for a path and jump to it | nvim-tree.lua |
| `s` | Normal | Open the file with the system's default app | nvim-tree.lua |
| `m` | Normal | Mark the file (bd deletes marked, bmv moves marked) | nvim-tree.lua |
| `[c` / `]c` | Normal | Jump to the previous / next file with git changes | nvim-tree.lua |
| `[e` / `]e` | Normal | Jump to the previous / next file with errors | nvim-tree.lua |
| `Ctrl+k` | Normal | Show file info (size, dates) | nvim-tree.lua |
| `q` | Normal | Close the explorer | nvim-tree.lua |
| `g?` | Normal | Show every explorer key | nvim-tree.lua |

## Code intelligence (LSP)

Need a language server running for the file (Python, Go, TypeScript, Lua, C, Rust ...). Check with :LspInfo.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `K` | Normal | Show documentation for the thing under the cursor (hover)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space g d` | Normal | Peek at the definition in a popup (without leaving the file)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space g D` | Normal | Go to the definition<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space g S` | Normal | Open the definition in a vertical split<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space r n` | Normal | Rename the symbol under the cursor everywhere (variable, function ...)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space c a` | Normal | Show code actions (quick fixes, refactors, add missing import ...)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space f r` | Normal | List every place the symbol is used (references, fzf-lua)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space f d` | Normal | LSP finder: definition + references together (fzf-lua)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space f t` | Normal | Go to the type definition (fzf-lua)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space f i` | Normal | Go to the implementation (fzf-lua)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space f w` | Normal | Search symbols across the workspace (fzf-lua)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space o i` | Normal | Organize imports (and then format)<br>*Works in files with a language server attached. Only does something if the language server supports it (TypeScript, Go ...).* | `utils/lsp.lua` |
| `Space w a` / `Space w r` | Normal | Add / remove a workspace folder<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space c s` | Normal | Toggle the symbols outline panel (Trouble) | `plugins/trouble-nvim.lua` |
| `Space c l` | Normal | Toggle the LSP panel: definitions, references ... (Trouble) | `plugins/trouble-nvim.lua` |
| `grn` | Normal | Rename (Neovim built-in version)<br>*Works in files with a language server attached.* | built-in |
| `gra` | Normal + Visual | Code actions (Neovim built-in version)<br>*Works in files with a language server attached.* | built-in |
| `grr` | Normal | List references (Neovim built-in version)<br>*Works in files with a language server attached.* | built-in |
| `gri` | Normal | Go to implementation (Neovim built-in version)<br>*Works in files with a language server attached.* | built-in |
| `grt` | Normal | Go to type definition (Neovim built-in, 0.12+)<br>*Works in files with a language server attached.* | built-in |
| `gO` | Normal | List symbols in this file (Neovim built-in)<br>*Works in files with a language server attached.* | built-in |
| `Ctrl+s` | Insert | Show the function's parameters while typing<br>*Works in files with a language server attached.* | built-in |

## Errors & diagnostics

Errors, warnings and hints from language servers and linters.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space x x` | Normal | Show / hide the list of all errors & warnings in the project (Trouble)<br>*keymaps.lua also maps Space x x (a location-list toggle); Trouble's mapping is the one that runs.* | `plugins/trouble-nvim.lua` |
| `Space x X` | Normal | Problems in this file only (Trouble) | `plugins/trouble-nvim.lua` |
| `Space x L` | Normal | Show the location list (Trouble) | `plugins/trouble-nvim.lua` |
| `Space x Q` | Normal | Show the quickfix list (Trouble) | `plugins/trouble-nvim.lua` |
| `Space x d` | Normal | Show the full error message under the cursor in a popup | `config/keymaps.lua` |
| `]d` / `[d` | Normal | Jump to the next / previous error or warning | `config/keymaps.lua` |
| `]D` / `[D` | Normal | Jump to the last / first problem in the file | built-in |
| `Ctrl+w d` | Normal | Show the problems under the cursor (built in) | built-in |
| `Space d` | Normal | Show the problems at the cursor (Lspsaga popup)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space D` | Normal | Show the problems on the whole line (Lspsaga popup)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |
| `Space n d` / `Space p d` | Normal | Jump to the next / previous problem with a popup (Lspsaga)<br>*Works in files with a language server attached.* | `utils/lsp.lua` |

## Inside the Trouble list

Keys for the problems / symbols / references panel. Press ? there for help.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Enter` | Normal | Jump to the item | trouble.nvim |
| `o` | Normal | Jump to the item and close the panel | trouble.nvim |
| `p` | Normal | Preview the item | trouble.nvim |
| `P` | Normal | Turn automatic preview on / off | trouble.nvim |
| `}` / `]]` | Normal | Next item | trouble.nvim |
| `{` / `[[` | Normal | Previous item | trouble.nvim |
| `Ctrl+s` / `Ctrl+v` | Normal | Open the item in a split / vertical split | trouble.nvim |
| `dd` | Normal | Remove the item from the list | trouble.nvim |
| `za` | Normal | Fold / unfold a group | trouble.nvim |
| `zM` / `zR` | Normal | Fold / unfold all groups | trouble.nvim |
| `r` | Normal | Refresh | trouble.nvim |
| `q` | Normal | Close the panel | trouble.nvim |
| `?` | Normal | Show every Trouble key | trouble.nvim |

## Git

Blame from gitsigns, everything else through vim-fugitive's :Git command.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space g g` | Normal | Show who last changed this line, when, and the commit (git blame popup) | `config/keymaps.lua` |
| `Space g B` | Normal | Turn inline git blame for the current line on / off | `config/keymaps.lua` |
| `:Git` | Command | Open the Git status window (stage, commit, push ...); :G also works | vim-fugitive |
| `:Git diff` | Command | Show your unstaged changes | vim-fugitive |
| `:Gvdiffsplit` | Command | Compare this file with the last commit, side by side | vim-fugitive |
| `:Git blame` | Command | Blame the whole file in a side panel | vim-fugitive |
| `:Git commit` | Command | Commit the staged changes | vim-fugitive |
| `:Git push` | Command | Push your commits to the remote | vim-fugitive |
| `:Git pull` | Command | Pull changes from the remote | vim-fugitive |
| `:Git log` | Command | Show the commit history | vim-fugitive |
| `:Gwrite` | Command | Stage the current file (git add) | vim-fugitive |
| `:Gread` | Command | Throw away your changes to this file (back to the last commit) | vim-fugitive |
| `:Gitsigns preview_hunk` | Command | Preview the change (hunk) under the cursor | gitsigns.nvim |
| `:Gitsigns stage_hunk` | Command | Stage just the change under the cursor | gitsigns.nvim |
| `:Gitsigns reset_hunk` | Command | Undo just the change under the cursor | gitsigns.nvim |
| `:Gitsigns nav_hunk next` | Command | Jump to the next changed block (use prev for the previous one) | gitsigns.nvim |

## Inside the Git status window (:Git)

Keys for the window opened by :Git. Press g? there for the full list.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `s` | Normal | Stage the file / change under the cursor | vim-fugitive |
| `u` | Normal | Unstage the file / change under the cursor | vim-fugitive |
| `-` | Normal | Stage or unstage (toggle) | vim-fugitive |
| `=` | Normal | Show / hide the diff inline | vim-fugitive |
| `dv` | Normal | Open a side-by-side diff of the file | vim-fugitive |
| `X` | Normal | Discard the change under the cursor | vim-fugitive |
| `cc` | Normal | Commit the staged changes | vim-fugitive |
| `ca` | Normal | Amend the last commit | vim-fugitive |
| `)` / `(` | Normal | Jump to the next / previous file or change | vim-fugitive |
| `Enter` | Normal | Open the file | vim-fugitive |
| `gq` | Normal | Close the status window | vim-fugitive |
| `g?` | Normal | Show every key | vim-fugitive |

## Autocomplete menu

The popup while typing. Suggestions come from the language server, snippets, words in the file, paths and Codeium AI.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Ctrl+j` / `Ctrl+n` / `Down` | Insert | Next suggestion | `plugins/nvim-cmp.lua` |
| `Ctrl+k` / `Ctrl+p` / `Up` | Insert | Previous suggestion | `plugins/nvim-cmp.lua` |
| `Enter` / `Ctrl+y` | Insert | Accept the selected suggestion (Enter only accepts if you picked one) | `plugins/nvim-cmp.lua` |
| `Ctrl+Space` | Insert | Open the suggestion menu yourself | `plugins/nvim-cmp.lua` |
| `Ctrl+e` | Insert | Close the suggestion menu | `plugins/nvim-cmp.lua` |
| `Ctrl+f` / `Ctrl+b` | Insert | Scroll the documentation popup down / up | `plugins/nvim-cmp.lua` |

## Typing helpers (Insert mode)

Handy keys while you're typing text.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Ctrl+w` | Insert | Delete the word before the cursor | built-in |
| `Ctrl+u` | Insert | Delete everything before the cursor on this line | built-in |
| `Ctrl+o` | Insert | Run one Normal-mode command, then keep typing | built-in |
| `Ctrl+r` | Insert | Paste a register while typing: Ctrl+r then + pastes the clipboard | built-in |
| `Insert` | Insert | Move the cursor one character right | `config/keymaps.lua` |
| `Ctrl+Insert` | Insert | Move the cursor one line down | `config/keymaps.lua` |

## Folding (collapse code)

Folds come from treesitter and start fully open.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `za` | Normal | Fold / unfold the block under the cursor | built-in |
| `zc` / `zo` | Normal | Close / open the fold under the cursor | built-in |
| `zM` | Normal | Fold everything | built-in |
| `zR` | Normal | Unfold everything | built-in |

## Debugging (Rust)

nvim-dap + dap-ui. The debugger UI opens and closes by itself.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space d c` | Normal | Start / continue debugging<br>*Works in Rust files, once rust-analyzer is running.* | `utils/lsp.lua` |
| `Space d b` | Normal | Toggle a breakpoint on this line<br>*Works in Rust files, once rust-analyzer is running.* | `utils/lsp.lua` |
| `Space d o` | Normal | Step over (run this line)<br>*Works in Rust files, once rust-analyzer is running.* | `utils/lsp.lua` |
| `Space d i` | Normal | Step into the function call<br>*Works in Rust files, once rust-analyzer is running.* | `utils/lsp.lua` |
| `Space d u` | Normal | Step out of the current function<br>*Works in Rust files, once rust-analyzer is running.* | `utils/lsp.lua` |
| `Space d r` | Normal | Open the debug console (REPL)<br>*Works in Rust files, once rust-analyzer is running.* | `utils/lsp.lua` |
| `:RustLsp debuggables` | Command | Pick a Rust target to debug<br>*Works in Rust files, once rust-analyzer is running.* | rustaceanvim |
| `:RustLsp runnables` | Command | Pick something to run (binaries, tests ...)<br>*Works in Rust files, once rust-analyzer is running.* | rustaceanvim |
| `:RustLsp explainError` | Command | Explain the Rust error under the cursor<br>*Works in Rust files, once rust-analyzer is running.* | rustaceanvim |

## Focus, colors & AI

Zen mode, the color picker and Codeium.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space z` | Normal | Toggle Zen mode: centered, distraction free, dims other code | `plugins/zen-mode.lua` |
| `:Twilight` | Command | Dim everything except the code you're working on | twilight.nvim |
| `:CccPick` | Command | Open the color picker (edits the color under the cursor) | ccc.nvim |
| `:CccConvert` | Command | Convert the color under the cursor (hex / rgb / hsl) | ccc.nvim |
| `:CccHighlighterToggle` | Command | Show / hide color previews next to color codes | ccc.nvim |
| `:Codeium Auth` | Command | Log in to Codeium / Windsurf AI (needed once) | windsurf.nvim |
| `:Codeium Toggle` | Command | Turn Codeium AI suggestions on / off | windsurf.nvim |

## Config, plugins & tools

Reloading the config and managing plugins, language servers and the fff index.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `Space r k` | Normal | Reload keymaps.lua | `config/keymaps.lua` |
| `Space r c` | Normal | Reload init.lua (the whole config)<br>*Plugins don't fully reload this way; restart Neovim after big changes.* | `config/keymaps.lua` |
| `Space r l` | Normal | Reload plugins (Lazy reload)<br>*To reload one plugin, run :Lazy reload &lt;plugin-name>.* | `config/keymaps.lua` |
| `Space r s` | Normal | Install / update / clean plugins (Lazy sync) | `config/keymaps.lua` |
| `:Lazy` | Command | Open the plugin manager | lazy.nvim |
| `:Mason` | Command | Install language servers, formatters and linters | mason.nvim |
| `:LspInfo` | Command | Show which language servers are running | `plugins/mason-lsp.lua` |
| `:checkhealth` | Command | Check your setup for problems | built-in |
| `:FFFScan` | Command | Rescan files for the fff finder (when added files don't show up) | fff |
| `:FFFHealth` | Command | Check that the fff finder is installed correctly | fff |
| `:FFFClearCache` | Command | Clear fff caches (file ranking history and file index) | fff |
| `:TSUpdate` | Command | Update treesitter parsers (syntax highlighting) | nvim-treesitter |

## Inside the keymap guide

Keys for the window opened with Space k.

| Keys | Mode | What it does | From |
| --- | --- | --- | --- |
| `(just type)` | Insert | Type what you want to do in your own words, or a key like 'space f f' to see what it does | `keyguide/ui.lua` |
| `Enter` | Insert | Run the selected shortcut (commands are put on the : line for you to finish) | `keyguide/ui.lua` |
| `Down` / `Ctrl+n` / `Ctrl+j` / `Tab` | Insert | Next result | `keyguide/ui.lua` |
| `Up` / `Ctrl+p` / `Ctrl+k` / `Shift+Tab` | Insert | Previous result | `keyguide/ui.lua` |
| `Ctrl+u` | Insert | Clear what you typed | `keyguide/ui.lua` |
| `Esc` / `Ctrl+c` | Insert | Close the guide | `keyguide/ui.lua` |
