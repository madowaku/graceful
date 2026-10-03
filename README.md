# GRACEFUL

A quiet logic puzzle about **graceful labeling**.

Place the labels `0..n-1` on a tree so that the absolute differences on its edges are exactly `1..n-1`, each used once.

## Target

- Engine: Godot 4.7
- Primary viewport: 720×1280 (tested also at 360×800)
- Content v0.1: 20 stages
  - 001–015: PLACE
  - 016–020: SWAP ONE
- UX pillars: place → see differences → diagnose collisions → complete the full difference set
- Visual direction: premium dark “luminous tree” interface, restrained gold/blue glow

## Planned v0.1

- Stage select and progress save
- Tap-to-place / tap-to-return labels
- Difference tracker
- TRACE inspection
- Undo / Reset
- Fixed vertex clues and fixed edge-difference clues
- SWAP ONE mode
- Clear animation
- Automated stage verification

The mathematical inspiration is the Graceful Tree Conjecture, but every shipped stage is a finite, pre-verified puzzle.
