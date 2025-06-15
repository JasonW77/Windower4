EXPtips Addon for Windower 4
==========================

Author: Uncle Awesome
Version: 1.0

Description:
------------
EXPtips is a Windower 4 addon for Final Fantasy XI that recommends leveling camps based on the player's current level or a manually provided level. Data is based on BG Wiki's Fantastic EXPs and Where to Find Them.

Features
- Quickly view ideal EXP camps based on level
- Automatically detects your current level
- Displays zone, level range, camp notes, and monster types

Installation
1. Place the 'exptips' folder in your Windower4/addons directory.
2. Make sure the addon includes the following files:
   - exptips.lua (main addon logic)
   - exp_data.lua (structured EXP data)
3. Load the addon in-game with:

 //lua load exptips

Usage
 //exptips           -- Uses your current job level to display EXP camps
 //exptips <level>   -- Displays camps for the specified level

Example
 //exptips 56

Will output:

 EXP Camps for level 56:
 [Escha - Zi'Tah] (50-68): Around (E-7/8) | Monsters: Eschan Dhalmel, Eschan Coeurl, Eschan Weapon
 [Kuftal Tunnel] (55-60): I-8 | At entrance from Western Altepa Desert. | Monsters: Robber Crab, Sand Lizard
 ...

Contributing
If you'd like to improve the data or code:
- Submit pull requests
- Report bugs
- Help update data as new zones/monsters become relevant

License
This project is licensed under the MIT License.

MIT License

Copyright (c) 2025 Uncle Awesome

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

---

BG Wiki is © 2024 by contributors. EXPtips is an unofficial addon and is not affiliated with Square Enix or BG Wiki.
