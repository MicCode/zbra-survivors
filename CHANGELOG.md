---

## 1.5.0 - 2025-07-14

#### Build system

-   update export config - (5e84273) - Mic
-   configured export for linux - (29e344c) - Mic

#### Features

-   added splashscreen + created game theme - (190ba7c) - Mic

#### Refactoring

-   reworked the way music is handled + added fade transition between scenes - (349eead) - Mic
-   added groups in resources properties - (9665dc4) - Mic

---

## 1.4.0 - 2025-07-13

#### Documentation

-   created TODO file - (27fe86d) - Mic

#### Features

-   added a minimap - (51f0020) - Mic
-   improved fire effect - (51cbacf) - Mic

---

## 1.3.0 - 2025-07-12

#### Bug Fixes

-   better lvl up effect - (6628b0f) - Mic
-   fixed ennemies not dropping xp on death - (528c6e2) - Mic

#### Features

-   added announcement on multiple kill in one shot - (7ec9166) - Mic
-   infinite world generation - (ae1617b) - Mic

---

## 1.2.0 - 2025-07-12

#### Bug Fixes

-   fixed ennemy movements that were stuck between objects - (1f9506e) - Mic
-   reworked UI to be more flexible - (3027787) - Mic

#### Features

-   visual and sound effects when timewarping - (c7ce92d) - Mic

#### Refactoring

-   simplified the way ennemies info are stored using resources - (4e45df0) - Mic
-   simplified the way guns info are stored using resources - (deca9d0) - Mic

---

## 1.1.0 - 2025-07-11

#### Features

-   improved flamethrower - (3f21d06) - Mic
-   better ennemy death visual effect - (369d086) - Mic

---

## 1.0.1 - 2025-07-11

#### Bug Fixes

-   Reworked sounds & music handling - (1b7a9bb) - Mic

#### Refactoring

-   reorganized assets in a dedicated folder - (f32f373) - Mic

#### Style

-   use spaces indent - (f22ea37) - Mic

---

## 1.0.0 - 2025-07-11

#### Bug Fixes

-   make boss disapear after death - (66fb35c) - Mic
-   fixed ennemies sticking to player on contact - (04ea857) - Mic
-   reduced main map size - (a53efa8) - Mic
-   fixed player instance reference from ennemy - (206f022) - Mic
-   removed particle effects (laggy) - (a798907) - Mic
-   fixed runtime issues - (c43a036) - Mic

#### Build system

-   added automatic version bump - (6ffcd53) - Mic

#### Documentation

-   updated readme - (0c342a4) - Mic
-   updated readme - (ebcd343) - Mic
-   added readme - (aff082c) - Mic

#### Features

-   added a timewrapping item - matrix style ! - (9720d75) - Mic
-   added first version of an endgame boss - (266f035) - Mic
-   added a radiance flask which triggers a burning area effect around player - (f2df6b9) - Mic
-   ennemies eventually drop a life flask to heal player - (66a564f) - Mic
-   reduced elements size + added invisible walls to restrict game area - (bcc2978) - Mic
-   display controller button when dash is ready or player can equip a gun - (fe9fb66) - Mic
-   added control sprites - (d8a367d) - Mic
-   fire deals damage over time - (7c0673c) - Mic
-   display gun name in its info panel - (10c224c) - Mic
-   added a dash visual effect - (858e280) - Mic
-   added main menu + restart button when game over - (0ff8376) - Mic
-   added particle and light effects - (c2831f8) - Mic
-   display gun stats when player is near their collectible - (8f87085) - Mic
-   animate ui on xp and level gain - (298748c) - Mic
-   play sound and animation on level up - (87ad1e2) - Mic
-   ennemies bleed on hit - (3a5b14b) - Mic
-   added sniper rifle + bullet pierce count - (52c0c9b) - Mic
-   added damage amount indicators + improved environment - (5a45e68) - Mic
-   trees can burn - (42a49ae) - Mic
-   added flamethrower - (d85a67e) - Mic
-   added game settings - (4e3e25a) - Mic
-   added sounds and music - (f8c8797) - Mic
-   added base xp system - (fc825da) - Mic
-   added a crosshair when gun is equipped - (44cda34) - Mic
-   adde location markers on screen edges to indicate entities directions - (6c9d2e5) - Mic
-   added twinstick controller control - (01b7f4a) - Mic
-   added player dead sprite + improved physics render frequency - (cdf96da) - Mic
-   added ammo shell ejection animation - (50eb85c) - Mic
-   made bullets configurable for all guns - (e560a22) - Mic
-   added shotgun new gun - (f5695b1) - Mic
-   game UI + game state - (ae41c53) - Mic
-   added a dash to player movements - (82aec1d) - Mic
-   put statistics stuff in global services - (3082522) - Mic
-   added new ennemy + ennemy spawn service - (81cfc61) - Mic
-   added new weapon - (0a61645) - Mic
-   fire at mouse position + trigger fire or grab item with user action - (f02eef1) - Mic
-   loot system - (90880a4) - Mic
-   added sounds + ui - (1572271) - Mic

#### Refactoring

-   moved game management code into service instead of level scene + prepared a game timer to display game time remaining - (41400f1) - Mic
-   simplified the way guns and ennemies are handled - (24aff40) - Mic
-   simplified guns folder hierarchy - (1ace3ef) - Mic
-   cleaned project file and scenes hierarchy - (3743dc3) - Mic
-   cleaned code - (eb1c2c4) - Mic
-   use shot per seconds in guns stats - (a4e8e2c) - Mic
-   reorganized code to have a more simple file structure + updated equipment service to be more generic - (979c1a3) - Mic

#### Style

-   harmonized file names - (c44e5db) - Mic

---
