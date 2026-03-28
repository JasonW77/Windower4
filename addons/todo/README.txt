To-Do Addon for Windower 4
==========================

Author: Uncle Awesome
Version: 1.9

Description
-----------
`todo` is a Windower 4 addon that tracks:
- Personal tasks (per-character)
- Shared tasks (cross-character)
- Records of Eminence (RoE) objectives (active and completed)

It displays these in three draggable windows with persistent position and font settings.

Features
--------
- Personal tasks saved to: `data/<character>/tasks.txt`
- Shared tasks saved to: `data/shared_tasks.txt`
- RoE objective names/metadata loaded from: `data/RoE.csv`
- Three separate windows:
  - Personal Tasks
  - Shared Tasks
  - RoE Checklist
- Color-coded task states and RoE sections
- Add/remove/complete/uncomplete for personal and shared tasks
- Share a personal task into the shared list
- Font size control globally or by specific window
- Per-character persistent settings (position, visibility on login, titles, fonts)

Installation
------------
1. Put this addon in `addons/todo/`.
2. Ensure `addons/todo/data/RoE.csv` exists (required for RoE objective names/categories).
3. Load in game with:
   - `//lua load todo`

Usage
-----
Primary command alias from the addon is `//td`.

Examples below use `//td`:

- `//td start`
  - Shows Personal, Shared, and RoE windows.

- `//td stop`
  - Hides all three windows.

- `//td add|a <task>`
  - Add a personal task.

- `//td remove|r <index>`
  - Remove a personal task by index.

- `//td complete|c <index>`
  - Mark a personal task complete (`[X]`).

- `//td uncomplete|uc <index>`
  - Remove completion marker from a personal task.

- `//td addshared|as <task>`
  - Add a shared task.

- `//td removeshared|rs <index>`
  - Remove a shared task by index.

- `//td completeshared|cs <index>`
  - Mark a shared task complete (`[X]`).

- `//td uncompleteshared|ucs <index>`
  - Remove completion marker from a shared task.

- `//td share <index>`
  - Copy a personal task into shared tasks (without `[X]` prefix).

- `//td fontsize|fs`
  - Display current font sizes.

- `//td fontsize|fs <6-15>`
  - Set font size for all windows.

- `//td fontsize|fs <personal|shared|roe> <6-15>`
  - Set font size for one specific window.

- `//td setautostart|sas true|false`
  - Control whether windows appear on login.

- `//td title|t <personal|shared> "New Title"`
  - Rename personal/shared window titles.

RoE Display Behavior
--------------------
- Reads active RoE objectives from packet `0x111`
- Reads completed RoE objectives from packet `0x112`
- Uses `RoE.csv` flags to categorize objectives into sections:
  - Repeatable
  - Unity
  - Daily
  - Timed
  - Retroactive
  - Other
- Objectives are sorted alphabetically by name in each section.

Color Notes
-----------
- Personal normal tasks: Sky Blue
- Shared normal tasks: Green
- Completed tasks (`[X]`): Steel Blue
- RoE section headers: distinct colors per category

Behavior Notes
--------------
- Task files are saved immediately after changes.
- Character directory is auto-created when needed.
- Window positions are persisted while visible.
- RoE title defaults to `RoE Checklist` via settings.
- `title` command currently supports only personal/shared windows.

Requirements
------------
- Windower 4
- Lua 5.1 (bundled with Windower)

License
-------
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
