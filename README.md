# Havoc Tabletop Simulator Edition

A card game by Justin and Brandon.

## Introduction

  Havoc is a quick competitive card game in which the player with the most points wins. Each game is played with several rounds that have multiple phases. Cards have different point values, power values, and abilities. The players play cards from their hands and draw cards from the deck. Generally, the player who plays cards with higher power wins.

  I'm making a version of this card game in tabletop simulator in the Steam Workshop, but it is not currently public. I'm using this GitHub repository to easily transfer code changes between contributors.

## Rule Book

If you want to learn how to play the game, here is the [rule book](https://docs.google.com/document/d/1foQJ5_BKYie_It4hxwMqEcR7xeiID4BLHJoUC3gFIMc/edit?usp=sharing)! It is updated when any new changes are made.

## Installation Steps

### Requirements

- You must own Tabletop Simulator to play Havoc Tabletop Simulator Edition

### Steps

1. Get added as a contributor to the Havoc Steam Workshop page
1. Install Tabletop Simulator
1. Go to Create > Multiplayer > create a server
1. Click on Workshop > browse for the [Havoc Steam Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=2723093390&searchtext=Havoc) > Subscribe
1. Click on Havoc and load it
1. Invite another player to start playing

## Development Environment Setup

1. Clone the Havoc Tabletop Simulator Edition [git repository](https://github.com/Justin-YCheese/Havoc)
1. Download [VS Code](https://code.visualstudio.com/download)
1. Install [Tabletop Simulator extension for VS Code](https://marketplace.visualstudio.com/items?itemName=rolandostar.tabletopsimulator-lua)
1. In VS Code, go to Extensions list (four squares icon) > right-click "Tabletop Simulator Lua" extension > Settings.
1. Under `TTS Lua: Include Other File Paths`, click `Add Item` button. Enter a file path that leads to your project root folder.
    - The `~` is the same as `C:/Users/YOUR_USERNAME`
    - Example path: `~/Documents/Game Dev/repo/Havoc`
1. Get added as a Havoc Steam Workshop collaborator
1. Subscribe to the [Havoc mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2723093390&searchtext=Havoc)
1. Follow the installation steps above to get the mod
1. In VS Code, press `CTRL + ALT + L` to load game script files. A `Tabletop Simulator Lua` folder should appear in your VS Code workspace.
1. Open `Tabletop Simulator Lua\Global.-1.lua`. Replace everything in there with `require("src/Havoc")` so that your local code gets used.
1. Edit script files and use `CTRL+ ALT + S` to test in Tabletop Simulator

### With Github

1. In Atom > go to Packages > GitHub > Toggle GitHub Tab
1. Sign into GitHub in Atom and allow Atom access to your GitHub
1. Open a new project and clone the Havoc repository with the HTML link
1. Go to Files > Settings > Packages > tabletopsimulator-lua > Settings
1. Where it says "Base path for files you wish to bundle or #include" put
in the full path to your cloned repository (it should end with '\Havoc')
1. Now open both the Tabletop Simulator Lua and Havoc repository for quick work
1. To make a new branch, use the branch options of the bottom right tabs

## Update Steam Workshop Mod

### Requirements

- Your development environment must be setup
- Havoc Tabletop Simulator Edition must be installed

### Steps

1. Create a singleplayer or multiplayer session in Tabletop Simulator
1. Load Havoc from the Workshop category
1. Open your Havoc project in VS Code
1. Get latest code from the repo
1. Load game script files with `CTRL + ALT + L`, then send local code to TTS using `CTRL + ALT + S`
1. Make any UI changes if needed
1. In TTS, go to Modding > Scripting. Replace the code in both Lua/UI sections with corresponding files in `src/TTS Object Scripts`.
1. Update the Havoc Steam Workshop mod through Tabletop Simulator

### Visual Studio Code Migration

- Tabletop Simulator no longer supports Atom so developers need to switch to Visual Studio Code (VS Code) instead
- [Tabletop Simulator extension documentation](https://tts-vscode.rolandostar.com/extension/setup)
- Note that `require` checks `~/Documents/Tabletop Simulator` first and any included paths afterwards
  - If files have duplicate names, then subsequent files are ignored

1. Install [Visual Studio Code](https://code.visualstudio.com/download)
1. Install [Tabletop Simulator extension for VS Code](https://marketplace.visualstudio.com/items?itemName=rolandostar.tabletopsimulator-lua)
1. Open Tabletop Simulator, open a game of Havoc
1. Open VS Code and press `CTRL + ALT + L` to load game script files
1. Make a small change to the Global file and use `CTRL + ALT + S` to send script changes to Tabletop Simulator. Check to make sure the change is uploaded. Revert the change when done testing.
1. Open ATOM, go to File > Settings > Packages > tabletopsimulator-lua Settings and copy the value for 'Base path for files you wish to bundle or #include'. The path should lead to the repo folder.
1. In VS Code, go to Extensions list (four squares icon) > right-click "Tabletop Simulator Lua" extension > Extension Settings. Under "Include Other File Paths", paste the copied file path from Atom.

### VS Code Extension Controls

- Commands have to be done while VS Code and Havoc TTS are open and running
- Load game script files = `CTRL + ALT + L`
- Send local script files to Tabletop Simulator = `CTRL+ ALT + S`

### Fixing TTS Save/Get Scripts Not Found

- Loading and saving files to/from Tabletop Simulator stopped working due to one of the VSCode updates (~Aug 2025)
- To fix this, follow the steps below

1. Go to `C:\Users\YOUR_USERNAME\.vscode\extensions\rolandostar.tabletopsimulator-lua-1.1.3\dist`
1. Open `extension.js` and scroll to line 9406 which should start with: `const wasmBin = fs.readFileSync(path.join(vscode.env.appRoot, 'node_modules.asar', ...`
1. Replace `node_modules.asar` with `node_modules` and save the file
1. Try to load/save scripts from TTS
