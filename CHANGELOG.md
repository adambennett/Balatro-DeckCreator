### v1.2.0
- Implemented 'Banned Items' menu
- Fixed a crash that occurred sometimes when using the Deck Creator without first unlocking all items in the game
- Fixed some modifiers triggering twice when both Balamod and Steamodded are loaded simultaneously
- Fixed various crashes that occurred when reloading a saved run
- Fixed an issue where consumables were being re-added multiple times when loading your run
- Fixed placeholder custom icons not loading properly on 'Starting Items' page
- Increased max selection for "Winning Ante" option from 50 -> 9999
- Increased max selection for "Hand Size" option from 25 -> 9999
- Improved layout of left panel icons on 'Starting Items' page
- Reorganized layout of Jokers displayed in add/ban Jokers menus to show wide rather than tall
- Added support for Perishable and Rental jokers
- Added 'Blind Score Multiplier' to 'General' page for more control of blind score requirements
- Added 'Tags' sub-menu to 'Starting Items' page
- Adjusted several existing Static Mods options to be more interesting
- Added many new Static Mods options
- Static Mods page reorganized into sections
- Improved cross-mod compat
    - Base deck is generated the same way as the normal game, i.e. mods that change your starting deck will also change the default Base Deck cards for Deck Creator
    - Adding cards to Base Deck with modded suits is now supported
    - Adding custom Joker, Tarot, Planet, Voucher, and Spectral cards to Starting Items is now supported
- Removed logic to add import description to decks loaded from other files ("custom deck imported via..." message)
- Improved deck description logic
  - Max length accepted by UI increased from 70 -> 90
  - Lines are no longer split automatically based on length
  - Spaces should no longer be inserted by mistake
  - Now supports new line delimiter - enter "<n" without the quotes anywhere to create a new line
  - Now supports all base-game text modifiers, i.e. "attention" to create yellow text
    - Syntax for adding these is "<:[key]<[text]<" where the brackets represent the info you want to pass
    - For example, to write "TEST" in yellow letters, you could do: "My <:attention<TEST<" and only "TEST" would be colored
    - Also supports linking item keys which then appear on hover-over
      - For example, to create the Magic Deck description, you could start with: "Start run with the<n<:tarot,T:v_crystal_ball<Crystal Ball< voucher"
  - Added property 'rawDescription' to custom deck objects, which can be modified directly inside the CustomDecks.txt file
    - Modifications to this property will supercede all other description settings, so you can use this to create a longer-than-90-characters description
    - Follow the same syntax as the UI, i.e. "<n" for new lines

### v1.1.0
- Better support for loading Steamodded and Balamod simultaneously
- Fixed card backs not applying during run
- Added 'Random' as card back option
- Fixed crash that occurred when starting a run with either Paintbrush or Palette vouchers
- Fixed issue where switching profiles in game would reset the custom deck list and not load it again until the game was reloaded
- Fixed broken Static Mod - "Chance to Increase Rank of Drawn Cards by 1"
- Improved 'Add Card' sub-menu to only reset selections when current editing deck is closed

### v1.0.0
- Added extra line of tabs to 'Create Deck' menu
- Added three new tabs - Base Deck, Starting Items, and Banned Items. Banned Items is not yet implemented.
- Base Deck tab allows players to add and remove cards from the starting deck. Click on any individual card to remove it!
- Starting Items works similarly to the base deck menu, but allows players to add Jokers, Consumables, and Vouchers to their run.
- Renamed old tab "Gameplay" as "Static Mods"
- Renamed old tab "Deck Mods" as "Dynamic Mods"
- Added 'Manage Decks' menu to allow users to edit, copy, and delete their custom decks
- Added many new gameplay modifiers under the two 'Mods' menus
- Updated several of the existing modifiers to be more interesting
- Improvements to menu navigation
- Better deck import logic to allow for multiple decks of the same name and now preventing possible duplicated imports
- Various bug fixes

### v0.0.1
- Initial release
