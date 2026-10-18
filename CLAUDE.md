# Instructions for Antsy

Antsy emits ANSI escape sequences as plain strings you can print in a
stream, without knowing what comes next. This file is for Claude and is
excluded from the distribution (see MANIFEST.SKIP).

## Working here

* Work on the `master` branch. Check the current branch before
  committing.
* Don't commit on your own. Leave changes uncommitted for brian to
  review, and commit only when he says to. When you do commit, make
  small commits with one logical change each, and end the message with
  a co-author trailer that names the model used, for example:

      Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>

* Never push.
* Before editing, explain the change and show a diff (brian's global
  rules).
* The minimum Perl is v5.26. The module uses `use v5.26;` and
  `use experimental qw(signatures);`. Tests don't use signatures.
* Leave README.pod and Makefile.PL alone unless asked. README.pod likely
  comes from a template, and Makefile.PL is a modulino.
* `cpan_tester_reports/` is brian's working directory for downloaded
  CPAN Testers reports. It's in MANIFEST.SKIP. Don't touch it.

## How the module is organized

* Most functions are generated in BEGIN blocks from tables, then added
  to `@EXPORT_OK`, `:all`, and a tag with `_export( NAME, TAG )`. A few
  are ordinary subs listed in the `@subs` export block.
* `_seq( COMMAND, ARGS )` builds a CSI sequence (`ESC [ args command`).
  DEC save and restore (`ESC 7`, `ESC 8`) aren't CSI, so they're written
  out directly.
* Constant sequences are subs with an empty prototype, `sub () { $value }`.
  When a loop makes several closures, give each its own variable; a
  shared variable that gets reassigned changes what every closure
  returns (this was the bg_orange bug).

## Naming conventions

* Colors have a `text_` or `bg_` prefix: `text_red`, `bg_bright_blue`,
  `text_256`, `text_rgb`, `text_default`. `text_gray`/`text_grey` and
  `bg_gray`/`bg_grey` are aliases for the bright_black colors.
* Attributes have bare names: `bold`, `faint`, `italic`, `underline`,
  `blink`, `inverse`, `conceal`. Turning one off is `no_NAME`, plus
  `normal_intensity` (SGR 22) and `reveal` (SGR 28).
* Cursor functions start with `cursor_`. The older `hide_cursor`,
  `show_cursor`, `save_cursor`, and `restore_cursor` are deprecated in
  the docs only; they still work.
* Erasing has `erase_in_display(N)`, `erase_in_line(N)`, and named
  shortcuts such as `erase_to_end_of_screen`. The older `clear_*`
  constants emit the same sequences.
* Never export a sub whose name is a Perl builtin. Importing it replaces
  the builtin in the caller (`reverse @list` would call Antsy::reverse).
  `reset` and `reverse` are defined but not exported; `reset_all`,
  `normal`, `inverse`, and `reverse_video` are the exportable names.
  The `%shadows_builtin` hash in the attributes block enforces this.
* Aliases are welcome so people find a function under the name they
  know (for example `dark`, `dim`, and `faint`). Keep them consistent
  with the conventions above.

## Behavior to preserve

* Counted moves (`cursor_up` and friends, `scroll_up`, `scroll_down`)
  default to 1 and never emit a count of 0, because terminals treat 0
  as 1. A 0 returns the empty string, except `cursor_next_line(0)` and
  `cursor_previous_line(0)` go to the start of the current line,
  `cursor_column(0)` goes to column 1, and `cursor_row(0)` goes to row 1.
* `erase_in_display` and `erase_in_line` carp and return the empty
  string for a bad argument; erasing nothing is safer than erasing the
  wrong part.
* `cursor_save` and `cursor_restore` are the SCO sequences (same as the
  deprecated names). The DEC ones are `cursor_save_state` and its
  aliases. The docs section "Saving and restoring the cursor" explains
  why.

## Docs

* Every public sub needs a POD entry; t/pod_coverage.t enforces it.
  Pair aliases as consecutive `=item` lines over one description.
* Start POD with `=encoding utf8`.
* Show commands with a `$ ` prompt, for example `$ prove -l t/colors.t`
  (README.pod and Makefile.PL keep their own `%` prompts).
* Files Claude writes get NAME, SYNOPSIS, DESCRIPTION, SOURCE
  AVAILABILITY (https://github.com/briandfoy/antsy), AUTHOR (Claude,
  with the model, as author; brian d foy <briandfoy@pobox.com> as
  supervisor), and COPYRIGHT AND LICENSE (Copyright © YEAR, brian d foy,
  Artistic License 2.0).
* Don't link to private repositories (terminal-test is private).
* Check links before adding them.

## Tests

* Run them with `prove -l t`. Check POD with `podchecker`.
* Test::Manifest runs only the files listed in t/test_manifest, so a new
  test file goes there and in MANIFEST.
* t/attributes.t, t/colors.t, t/cursor.t, and t/erase.t check each
  function's sequence and export; t/aliases.t checks that every name in
  an alias group returns the same thing. When you add an alias, add it
  to its group in t/aliases.t.
* To show a test catches a bug, run it against the previous version:
  `git show HEAD:lib/Antsy.pm` into a scratch lib directory and
  `prove -I` that.

## Before the next release (0.908)

Nothing in this list is done yet.

* Changes needs an entry. These are breaking:
  * `reset` and `reverse` are no longer exported (`:all`, `:text`, and
    `:control` no longer provide them). A program that imports `:all`
    and still calls `reset` silently gets Perl's builtin.
  * The `%s` export tag and the stray `_black` through `_white`
    functions (which emitted SGR 0-7) are gone.
* `examples/back_up_three_lines.pl` isn't in MANIFEST.

## Ideas not done yet

* Scroll regions: `scroll_region( TOP, BOTTOM )` (DECSTBM) and
  `scroll_region_reset`, maybe origin mode on and off.
* The iTerm2 cursor shape functions don't check that they're running in
  iTerm2, unlike the other iTerm2 functions.
* Runtime deprecation warnings for the old cursor names.
* Strikethrough (SGR 9/29), rapid blink (SGR 6), tab movement (CHT,
  CBT), and a cursor position query (CSI 6n).
