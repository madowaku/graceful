# GRACEFUL Implementation Sprint v0.1

## Goal

Build the smallest complete version that proves the puzzle is fun, not merely mathematically interesting.

The core loop is:

1. Place or swap labels.
2. Watch edge differences update immediately.
3. Read the missing and duplicated difference values.
4. Repair the tree until every value from 1 through m appears exactly once.
5. Receive a short GRACEFUL clear beat and continue.

## Content

Twenty hand-authored and solver-verifiable stages are included.

- 001–005 DIFFERENCE: learn the maximum difference and difference chains.
- 006–010 BRANCH: learn hub pressure and branching constraints.
- 011–015 GAPS: fixed edge-difference clues reverse the reasoning direction.
- 016–020 BROKEN GRACE: diagnose a complete but damaged labeling and repair it with one swap.

## Interaction

PLACE mode:

- Tap a number in the tray, then tap a vertex to place it.
- Tap a non-fixed occupied vertex with no selected tray number to return that label to the tray.
- A placed number disappears from the tray.
- Fixed vertex clues cannot be removed.

SWAP mode:

- Tap one vertex, then another.
- Their values swap.
- Only one pair repairs each shipped stage.

TRACE:

- TRACE is an inspection mode, not a hint that reveals a move.
- While TRACE is on, tapping a vertex highlights that vertex and its incident edges.
- Leaving TRACE returns to normal editing.

## Difference feedback

- Unused difference: dim.
- Used exactly once: gold.
- Used more than once: red.
- Fixed edge clue: blue badge.
- TRACE selection: blue highlight.

Do not block invalid moves. A broken state is useful information.

## Visual target

Premium, quiet, dark puzzle UI.

- Midnight navy background.
- Warm gold for valid structure.
- Cool blue for inspection and fixed difference clues.
- Red only for duplicate-difference conflicts.
- Circular graph nodes with restrained glow.
- Difference strip always visible.
- Avoid fantasy ornament that competes with the graph. The tree itself is the hero.

The generated concept image from the design conversation is a mood target, not a pixel-perfect specification. Prioritize readability on 360×800 before adding atmosphere.

## Technical target

- Godot 4.7.
- Primary logical viewport 720×1280.
- Responsive down to 360×800.
- GL Compatibility renderer.
- No third-party addons required for v0.1.
- Stage data lives separately from presentation.
- All shipped stages must pass tools/verify_stages.gd.

Verification command:

godot --headless --path . --script res://tools/verify_stages.gd

## Acceptance gate

Before calling v0.1 complete:

- Godot opens the project with no parse errors.
- F5 launches Stage 001.
- All twenty stages are reachable through progression.
- Undo and Reset work in both modes.
- TRACE never changes puzzle state.
- Fixed vertex clues cannot be removed.
- Fixed edge clues are visually distinct.
- Duplicate differences are visible without modal warnings.
- Clear state is detected correctly.
- Progress survives restart.
- The headless verifier reports 20/20 PASS.
- 720×1280 and 360×800 remain playable without clipped controls.
- Human playtest confirms that Stage 002 teaches maximum difference without explanatory prose being necessary.
