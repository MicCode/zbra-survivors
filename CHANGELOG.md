
- - -
## 0.13.0 - 2025-07-28

#### ➕ New features
- **(controls)** added gamepad vibrations
- **(sound)** added a smooth transition between musics
#### 🪲 Bug fixes
- **(controls)** remapped gamepad controls to be more ergonomic
- **(controls)** allow UI navigation with controller
- **(gameplay)** made boss bigger and ennemy hit sounds less buggy
- **(sound)** made announcements independent from SFX + added a dedicated volume setting
- **(ui)** added missing xbox controls sprites

- - -

## 0.12.0 - 2025-07-27

#### ➕ New features
- **(gameplay)** some ennemies are randomly spawned as elites with better stats
- **(ui)** added a settings menu
- **(visual)** display ghost when timewarping
- **(visual)** highlight ennemies on hit

- - -

## 0.11.0 - 2025-07-27

#### ➕ New features
- **(visual)** added gun recoil
- **(visual)** added camera shake effects on explosions and damage taken
#### 🪲 Bug fixes
- **(gameplay)** reset equipment on new game
- **(ui)** fixed bad consumable item number in UI when picking up a new one

- - -


## 0.10.0 - 2025-07-27

#### ➕ New features
- added land mines
- added a xp collector item
- animate main UI
#### 🪲 Bug fixes
- slightly increased ennemy spawn frequency
- increased trees density in map
- player can change equipped consumable item even if not used

- - -

## 0.9.0 - 2025-07-27

#### ➕ New features
- display current equipped gun in game UI
- consumable items can now be used when player stroke the use button
- added aim guides to show gun dispersion angle

- - -

## 0.8.0 - 2025-07-27

#### ➕ New features
- added a red dot sight line for some guns
- collectible items vanish after a certain amount of time
- display real guns and collectibles sprites in minimap
#### 🪲 Bug fixes
- fixed time scale issues when restarting or leaving a game while timewarping
- fixed restart button not working in game over menu
- clear minimap on game reset + refresh minimap display at a given rate
- fixed sound issues

- - -

## 0.7.0 - 2025-07-27

#### ➕ New features
- save settings in json file and load it at startup
#### 🪲 Bug fixes
- better gun sounds

- - -

## 0.6.0 - 2025-07-27

#### ➕ New features
- added strings localization
#### 🪲 Bug fixes
- zoomed in camera

- - -

## 0.5.0 - 2025-07-27

#### ➕ New features
- added splashscreen + created game theme

- - -

## 0.4.0 - 2025-07-27

#### Documentation
- created TODO file
#### ➕ New features
- added a minimap
- improved fire effect

- - -

## 0.3.0 - 2025-07-27

#### ➕ New features
- added announcement on multiple kill in one shot
- infinite world generation
#### 🪲 Bug fixes
- better lvl up effect
- fixed ennemies not dropping xp on death

- - -

## 0.2.0 - 2025-07-27

#### ➕ New features
- visual and sound effects when timewarping
#### 🪲 Bug fixes
- fixed ennemy movements that were stuck between objects
- reworked UI to be more flexible

- - -

## 0.1.0 - 2025-07-27

#### Documentation
- updated readme
- updated readme
- added readme
#### Style
- use spaces indent
- harmonized file names
#### ➕ New features
- improved flamethrower
- better ennemy death visual effect
- added a timewrapping item - matrix style !
- added first version of an endgame boss
- added a radiance flask which triggers a burning area effect around player
- ennemies eventually drop a life flask to heal player
- reduced elements size + added invisible walls to restrict game area
- display controller button when dash is ready or player can equip a gun
- added control sprites
- fire deals damage over time
- display gun name in its info panel
- added a dash visual effect
- added main menu + restart button when game over
- added particle and light effects
- display gun stats when player is near their collectible
- animate ui on xp and level gain
- play sound and animation on level up
- ennemies bleed on hit
- added sniper rifle + bullet pierce count
- added damage amount indicators + improved environment
- trees can burn
- added flamethrower
- added game settings
- added sounds and music
- added base xp system
- added a crosshair when gun is equipped
- adde location markers on screen edges to indicate entities directions
- added twinstick controller control
- added player dead sprite + improved physics render frequency
- added ammo shell ejection animation
- made bullets configurable for all guns
- added shotgun new gun
- game UI + game state
- added a dash to player movements
- put statistics stuff in global services
- added new ennemy + ennemy spawn service
- added new weapon
- fire at mouse position + trigger fire or grab item with user action
- loot system
- added sounds + ui
- base gameplay
#### 🪲 Bug fixes
- Reworked sounds & music handling
- make boss disapear after death
- fixed ennemies sticking to player on contact
- reduced main map size
- fixed player instance reference from ennemy
- removed particle effects (laggy)
- fixed runtime issues


