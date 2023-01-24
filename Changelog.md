# Havoc Tabletop Simulator Edition Changelog

This document tracks all notables changes of Havoc Tabletop Simulator Edition.

---

## v0.6.1 Fix Reset Backup Flag

### Fixed

- Fix the reset button not resetting player backup flags

---

## v0.6.0 Reset Button

### Added

- Add checks so that only a player of the correct color can trigger their corresponding bet button
  - A warning message appears if a player tries to bet with the wrong button
- Add reset button
  - Reset everything to quickly start another game
  - Triggered by clicking the button three times in a row
    - To prevent resetting by accident
    - If not clicked fast enough (within 2 seconds between button presses), then the counter resets
    - The button displays how many times the player has clicked it so far
  - On reset:
    - The deck is rebuilt, placed back in the correct spot face-down and shuffled, then 4 cards are dealt to each player
    - The Rounds notebook is cleared

### Fixed

- Fix the bet button causing a nil error when the player has no valid color
- Fix moving the deck when drawing cards, usually when Orange draws cards quickly
- Fix clicking an opponent's bet button causing the betted card to go to the wrong side

---

## v0.5.3 Removed Bonus Points

### Added

- Backup Messages
  - For first time getting a Four of a Kind

### Fixed

- Calculating bonus points still calculating even through they are no longer in the game
- Messages pertaining to bonuses

---

## v0.5.2 Clear Button

### Added

- Add clear button which moves cards on the field to discard
  - Also updates the Rounds notebook with how many cards were discarded
  - Slightly randomizes card positions so it is easier to see what cards are in discard

### Fixed

- Fix floating discard sum button

---

## v0.5.1 Notebook

### Fixed

- Rounds message now uses the win pile points of who presses the button and not just the Blue player
- The Rounds Notebook now only counts 4-of-kinds gained instead of counting the bonuses that are already there

### Deprecated

- Removed 'Player wins' message when results button is pressed
- The Rounds Notebook no longer needs the 0th index

---

## v0.5.0 Notebook

### Added

- Add tablet that displays Havoc rule book
- Add notes to in-game notebook that keeps a record of each round
  - Who won
  - Round number
  - Points earned
  - Bonuses earned
  - Number of cards won
- Added `calculatePointsPrint` function to replace the temporary calculate points functions in layout zones

### Changed

- Results button now states points earned and any 4 of a kinds gained
- Added a `calculatePoints` function that is now used for the results button and sum button

---

## v0.4.0 Shortcuts

### Added

- Add Draw Card, Get Discard Sum, Get My Sum and Get Opponent's Sum shortcuts

### Changed

- Change sum buttons to broadcast a message to everyone in the game

---

## v0.3.0 Bet

### Fixed

- Bet buttons regenerate after pressing Results button

---

## v0.2.0 Recording

### Added

- Add Bet buttons to easily bet a card
- Add Sum buttons that count the number of points in win piles and discard

### Fixed

- Make the result button account for the zone around the whole game

---

## v0.1.0 Sum

### Added

- Create basic layout
- Create Steam Workshop page for Havoc
- Add Deal button to deal cards and start the game
- Add Results button that stores cards in the win pile of whichever player pressed the button

---
