# Havoc Tabletop Simulator Edition Changelog

This document tracks all notables changes of Havoc Tabletop Simulator Edition.

---

## v0.7.1 VSCode Migration

- Migrates the codebase to VSCode since Atom was sunsetted
- All functionality remains the same

---

## v0.7.0 Organize & Score Counters

### Added

- Live Score Counters
- Anti Stacking in Spoils and Graveyard

### Changed

- Shrunk Deck Builder Zone
- Renamed Tabletop Object scripts
- Made Spoils, Graveyard, and Field zones taller

### Fixed

- Tablet now displays rules again
- Fix bug where Results, Clear and Reset buttons stop working after manually modifying the Rounds notebook
  - Specifically by entering a newline at the end of the notebook
- Fix bug where a nil operation error appears whenever a player attempts to bet when the deck is empty
- Fix bug where summing shortcuts trigger a function-not-found error

### Removed

- Sum buttons

---

## v0.6.3 Display More Data & Bet Shortcut

### Added

- Add bet shortcut which triggers the bet button based on player color

### Changed

- Update Sum buttons to display the number of cards in their respective zones
- Update Reset button to show game data before resetting
  - Shows the number of rounds played, plus the points and number of cards that are in the win piles and discard
- Betting statuses are now tracked so that players can only bet once per round
  - Pressing the Results, Clear or Reset buttons clears bet statuses for all players, allowing them to bet for the next round/game

### Fixed

- Randomize cleared card positions a bit more to prevent cards from overlapping exactly and forming a deck
- Fix Reset button not regenerating bet buttons

---

## v0.6.2 Shorten Rounds Notebook Message

### Changed

- Rounds notebook only records the number of four-of-a-kinds earned if a player gets one or more of them in the current round
  - Won't see "with 0 FoK" anymore

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
