# Havoc Tabletop Simulator Edition

A card game by Justin and Brandon.

## Introduction

  Havoc is a quick competitive card game in which the player with the most points wins. Each game is played with several rounds that have multiple phases. Cards have different point values, power values, and abilities. The players play cards from their hands and draw cards from the deck. Generally, the player who plays cards with higher power wins.

  I'm making a version of this card game in tabletop simulator in the Steam Workshop, but it is not currently public. I'm using this GitHub repository to easily transfer code changes between contributors.

## Rule Book

If you want to learn how to play the game, here is the [rule book](https://docs.google.com/document/d/1ESWBAIITw3sij_6mAaZukogW9wVgF9ka4w8vCTnF8v0/edit?usp=sharing)! It is updated when any new changes are made.

## Installation Steps

### Requirements

- You must own Tabletop Simulator to play Havoc Tabletop Simulator Edition

### Steps

1. Get added as a contributor to the Havoc Steam Worksho page
1. Install Tabletop Simulator
1. Go to Create > Multiplayer > create a server
1. Click on Workshop > browse for the [Havoc Steam Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=2723093390&searchtext=Havoc) > Subscribe
1. Click on Havoc and load it
1. Invite another player to start playing

## Development Environment Setup

1. Clone the Havoc Tabletop Simulator Edition [git repository](https://github.com/Justin-YCheese/Havoc)
1. Download [Atom](https://atom.io/)
1. Open Atom > go to Settings > Install > search for 'tabletop' > install tabletopsimulator-lua
1. In Atom, go to File > Settings > Packages > tabletopsimulator-lua Settings and set 'Base path for files you wish to bundle or #include' to the full path to the repository directory.
1. Get added as a Havoc Steam Workshop collaborator
1. Subscribe to the [Havoc mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2723093390&searchtext=Havoc)
1. Follow the installation steps to get the mod, but start a single player session instead
1. In Atom, press `CTRL + SHIFT + L` to load game script files
1. Edit script files and use `CTRL+ SHIFT + S` to test in Tabletop Simulator

### With Github

1. In Atom > go to Packages > GitHub > Toggle GitHub Tab
1. Sign into GitHub in Atom and allow Atom access to your GitHub
1. Open a new project and clone the Havoc repository with the HTML link
1. Go to Files > Settings > Packages > tabletopsimulator-lua > Settings
1. Where it says "Base path for files you wish to bundle or #include" put
in the full path to your cloned repository (it should end with '\Havoc')
1. Now open both the Tabletop Simulator Lua and Havoc repository for quick work
1. To make a new branch, use the branch options of the bottom right tabs

## Project Building Steps

### Requirements

- Your development environment must be setup
- Havoc Tabletop Simulator Edition must be installed

### Steps

1. Create a single player session in Tabletop Simulator
1. Load Havoc from the Workshop category
1. Open Atom and load game script files with `CTRL + SHIFT + L`
1. Copy over latest changes from 'main' branch in the Havoc Tabletop Simulator Edition [git repository](https://github.com/Justin-YCheese/Havoc) to the Atom scripts
1. Update the Havoc Steam Workshop mod through Tabletop Simulator
