--[[
Constants.lua START

This file contains global constants.
]]

BUTTON_GUID = '9fdc25'
FIELD_ZONE_GUID = '7a6e1a'
DECK_ZONE_GUID = '7f0e92'
WIN_PILE_GUID = {}
WIN_PILE_GUID['Blue'] = '4ca699'
WIN_PILE_GUID['Orange'] = 'c641a0'
HAND_GUID = {}
HAND_GUID['Blue'] = 'fd5538'
HAND_GUID['Orange'] = '48113c'
DISCARD_GUID = '7f3593'
DECK_BUILDER_GUID = 'b8db70'

SCORE_GUID = {}
SCORE_GUID['Blue'] = 'f1b2b4'
SCORE_GUID['Orange'] = '119183'
SCORE_GUID['Discard'] = '5cf4ba'

-- Value of face cards
FACE_CARD_VALUE = 10

-- Global table of card stats
stats = {}
stats['Ace'] = {1,1}
stats['2'] = {2,2}
stats['3'] = {20,3}
stats['4'] = {4,4}
stats['5'] = {5,5}
stats['6'] = {6,6}
stats['7'] = {7,7}
stats['8'] = {8,8}
stats['9'] = {9,9}
stats['10'] = {10,10}
stats['Jack'] = {FACE_CARD_VALUE,11}
stats['Queen'] = {FACE_CARD_VALUE,12}
stats['King'] = {FACE_CARD_VALUE,13}
stats['Joker'] = {0,0}

-- Player variables
PLAYER_COLOR_STRINGS = {'Orange', 'Blue'}

-- Game constants
STARTING_HAND_SIZE = 4

-- Notebook constants
ROUNDS_TAB_INDEX = 3 -- Index of Rounds Tab in Notebook
SUMMARY_TAB_INDEX = 4 -- Index of Summary Tab in Notebook
STARTING_ROUNDS_NOTEBOOK_LINE = 'Recording Round Data Here'

-- Colors
WHITE = {1, 1, 1}
BLACK = {0, 0, 0}
RED = {1, 0, 0}
BRIGHT_PURPLE = {212, 0, 255}

-- Button colors
BUTTON_BACKGROUND_COLOR = WHITE
BUTTON_TEXT_COLOR = BLACK
BUTTON_WARNING_BACKGROUND_COLOR = RED
BUTTON_WARNING_TEXT_COLOR = WHITE

-- Card color contants
FOUR_OF_A_KIND_HIGHLIGHT_COLOR = BRIGHT_PURPLE

-- Button attributes
SMALL_BUTTON_WIDTH = 900
STANDARD_BUTTON_WIDTH = 1200
BIG_BUTTON_WIDTH = 1500
SMALL_BUTTON_HEIGHT = 650
STANDARD_BUTTON_HEIGHT = 800
BUTTON_FONT_SIZE = 300

-- Button labels
DEFAULT_RESET_BUTTON_LABEL = 'Reset'

-- Reset button Constants
NUM_CLICKS_TO_RESET = 3
SECONDS_UNTIL_COUNTER_RESET = 2
SECONDS_UNTIL_RESET_DECK_SHUFFLE = 0.25

-- Discard constants
DISCARD_X_OFFSET = 6
DISCARD_Y_OFFSET = 5

-- Messages
PLAYER_HAS_NO_COLOR_BROADCAST_MESSAGE = 'The player does not have a color'
PLAYER_HAS_NO_COLOR_LOG_MESSAGE = 'A player with no color tried to press results button'
BET_BUTTON_TOOLTIP_MESSAGE = 'Bet to risk extra cards'

-- Shortcut constants
PLAY_CARD_X_OFFSET = 2
PLAY_CARD_Y_OFFSET = 3
PLAY_CARD_Z_OFFSET = 3

-- Misc
NUM_OF_ZONES_FOR_FIELD_CARDS = 1 -- The number of zones which a card on the field should be in
NUM_OF_ZONES_FOR_SPOILS_CARD = 1

--[[
Constants.lua END
]]
