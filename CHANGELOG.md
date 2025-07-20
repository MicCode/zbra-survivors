## 0.8.0 - 2025-07-20
#### Bug Fixes
- fixed time scale issues when restarting or leaving a game while timewarping - (7e2c3f4) - Mic
- fixed restart button not working in game over menu - (8978ee4) - Mic
- clear minimap on game reset + refresh minimap display at a given rate - (04e33aa) - Mic
- fixed sound issues - (3b039ef) - Mic
#### Features
- added a red dot sight line for some guns - (6405b98) - Mic
- collectible items vanish after a certain amount of time - (569328a) - Mic
- display real guns and collectibles sprites in minimap - (754f300) - Mic
#### Miscellaneous Chores
- **(version)** 0.8.0 - (0d1da76) - Mic

- - -

## 0.7.0 - 2025-07-20
#### Bug Fixes
- better gun sounds - (3c9ff1c) - Mic
#### Features
- save settings in json file and load it at startup - (242650d) - Mic
#### Miscellaneous Chores
- **(version)** 0.7.0 - (77025c9) - Mic

- - -

## 0.6.0 - 2025-07-20
#### Bug Fixes
- zoomed in camera - (855e744) - Mic
#### Features
- added strings localization - (ca15420) - Mic
#### Miscellaneous Chores
- **(version)** 0.6.0 - (7778030) - Mic

- - -

## 0.5.0 - 2025-07-20
#### Build system
- update export config - (286360f) - Mic
- configured export for linux - (be0c6d5) - Mic
#### Features
- added splashscreen + created game theme - (23171b8) - Mic
#### Miscellaneous Chores
- **(version)** 0.5.0 - (f6a57cc) - Mic
#### Refactoring
- reworked the way music is handled + added fade transition between scenes - (4aff910) - Mic
- added groups in resources properties - (7067a0e) - Mic

- - -

## 0.4.0 - 2025-07-20
#### Documentation
- created TODO file - (389b5bc) - Mic
#### Features
- added a minimap - (50955d7) - Mic
- improved fire effect - (e53ae38) - Mic
#### Miscellaneous Chores
- **(version)** 0.4.0 - (6f1b4d7) - Mic

- - -

## 0.3.0 - 2025-07-20
#### Bug Fixes
- better lvl up effect - (a03746a) - Mic
- fixed ennemies not dropping xp on death - (25ebbfe) - Mic
#### Features
- added announcement on multiple kill in one shot - (75a6eee) - Mic
- infinite world generation - (0009d58) - Mic
#### Miscellaneous Chores
- **(version)** 0.3.0 - (4143ecc) - Mic

- - -

## 0.2.0 - 2025-07-20
#### Bug Fixes
- fixed ennemy movements that were stuck between objects - (be8efe2) - Mic
- reworked UI to be more flexible - (acaca6d) - Mic
#### Features
- visual and sound effects when timewarping - (2a14b6e) - Mic
#### Miscellaneous Chores
- **(version)** 0.2.0 - (b08dd8a) - Mic
#### Refactoring
- simplified the way ennemies info are stored using resources - (d6d0978) - Mic
- simplified the way guns info are stored using resources - (cf17b1f) - Mic

- - -

## 0.1.0 - 2025-07-20
#### Bug Fixes
- Reworked sounds & music handling - (fbb12f7) - Mic
- make boss disapear after death - (66fb35c) - Mic
- fixed ennemies sticking to player on contact - (04ea857) - Mic
- reduced main map size - (a53efa8) - Mic
- fixed player instance reference from ennemy - (206f022) - Mic
- removed particle effects (laggy) - (a798907) - Mic
- fixed runtime issues - (c43a036) - Mic
#### Build system
- added automatic version bump - (6ffcd53) - Mic
#### Documentation
- updated readme - (0c342a4) - Mic
- updated readme - (ebcd343) - Mic
- added readme - (aff082c) - Mic
#### Features
- improved flamethrower - (8f75a46) - Mic
- better ennemy death visual effect - (9fbdb00) - Mic
- added a timewrapping item - matrix style ! - (9720d75) - Mic
- added first version of an endgame boss - (266f035) - Mic
- added a radiance flask which triggers a burning area effect around player - (f2df6b9) - Mic
- ennemies eventually drop a life flask to heal player - (66a564f) - Mic
- reduced elements size + added invisible walls to restrict game area - (bcc2978) - Mic
- display controller button when dash is ready or player can equip a gun - (fe9fb66) - Mic
- added control sprites - (d8a367d) - Mic
- fire deals damage over time - (7c0673c) - Mic
- display gun name in its info panel - (10c224c) - Mic
- added a dash visual effect - (858e280) - Mic
- added main menu + restart button when game over - (0ff8376) - Mic
- added particle and light effects - (c2831f8) - Mic
- display gun stats when player is near their collectible - (8f87085) - Mic
- animate ui on xp and level gain - (298748c) - Mic
- play sound and animation on level up - (87ad1e2) - Mic
- ennemies bleed on hit - (3a5b14b) - Mic
- added sniper rifle + bullet pierce count - (52c0c9b) - Mic
- added damage amount indicators + improved environment - (5a45e68) - Mic
- trees can burn - (42a49ae) - Mic
- added flamethrower - (d85a67e) - Mic
- added game settings - (4e3e25a) - Mic
- added sounds and music - (f8c8797) - Mic
- added base xp system - (fc825da) - Mic
- added a crosshair when gun is equipped - (44cda34) - Mic
- adde location markers on screen edges to indicate entities directions - (6c9d2e5) - Mic
- added twinstick controller control - (01b7f4a) - Mic
- added player dead sprite + improved physics render frequency - (cdf96da) - Mic
- added ammo shell ejection animation - (50eb85c) - Mic
- made bullets configurable for all guns - (e560a22) - Mic
- added shotgun new gun - (f5695b1) - Mic
- game UI + game state - (ae41c53) - Mic
- added a dash to player movements - (82aec1d) - Mic
- put statistics stuff in global services - (3082522) - Mic
- added new ennemy + ennemy spawn service - (81cfc61) - Mic
- added new weapon - (0a61645) - Mic
- fire at mouse position + trigger fire or grab item with user action - (f02eef1) - Mic
- loot system - (90880a4) - Mic
- added sounds + ui - (1572271) - Mic
- base gameplay - (4b90a00) - Mic
#### Miscellaneous Chores
- **(version)** 0.1.0 - (a26bab0) - Mic
#### Refactoring
- reorganized assets in a dedicated folder - (6ee1313) - Mic
- moved game management code into service instead of level scene + prepared a game timer to display game time remaining - (41400f1) - Mic
- simplified the way guns and ennemies are handled - (24aff40) - Mic
- simplified guns folder hierarchy - (1ace3ef) - Mic
- cleaned project file and scenes hierarchy - (3743dc3) - Mic
- cleaned code - (eb1c2c4) - Mic
- use shot per seconds in guns stats - (a4e8e2c) - Mic
- reorganized code to have a more simple file structure + updated equipment service to be more generic - (979c1a3) - Mic
#### Style
- use spaces indent - (7e29f74) - Mic
- harmonized file names - (c44e5db) - Mic


