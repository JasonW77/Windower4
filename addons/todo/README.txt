To-Do Addon for Windower 4
==========================

Author: Uncle Awesome
Version: 1.9

Description:
------------
A simple, user-friendly to-do list addon for Final Fantasy XI (via Windower 4).
Now supports **personal and shared task lists in separate windows**, each with independent settings and titles.
Manage tasks with customizable commands and a sleek, color-coded UI.

Features:
---------
- Personal tasks saved to: `data/<character>/tasks.txt`
- Shared tasks saved to: `data/shared_tasks.txt`
- Personal and shared tasks are shown in separate draggable windows
- Add, remove, complete, uncomplete, and share tasks using chat commands
- Set custom titles for each window
- Customize font size and save window position per character
- Tasks are color-coded by type:
  - Normal tasks: Sky Blue (135, 206, 235)
  - Completed tasks: Steel Blue (70, 130, 180)
  - Shared tasks: Lime Green (50, 205, 50)
- Shared tasks are always displayed in their own window
- Automatically creates folders and saves per-character settings
- Optional auto-display of the list when logging in

Installation:
-------------
1. Place `todo.lua` in your Windower `addons/todo/` folder.
2. Create a `data` folder inside the addon folder if it doesn't exist.
3. Windower will automatically create per-character directories and files on use.

Usage:
------
Commands are entered in the game chat:

  //todo start
    - Show both personal and shared to-do list windows.

  //todo stop
    - Hide both windows.

  //todo add|a <task description>
    - Add a task to your personal list.
    Example:
      `//todo add Farm Beastcoins in Dynamis`

  //todo remove|r <index>
    - Remove the task at the given index number.
    Example:
      `//todo r 2`

  //todo complete|c <index>
    - Mark a task as completed. Adds `[X]` and colors it blue.
    Example:
      `//todo c 4`

  //todo uncomplete|uc <index>
    - Remove the `[X]` from a task and revert its status.
    Example:
      `//todo uc 4`

  //todo share <index>
    - Share a task to the shared list. It will appear as a green `[shared]` entry.
    Example:
      `//todo share 3`

  //todo fontsize|fs <6-48>
    - Set the font size for both windows.
    Example:
      `//todo fs 16`

  //todo setautostart|as true|false
    - Automatically show the lists on character login.
    Example:
      `//todo as true`

  //todo title|t <personal|shared> "New Title"
    - Set a custom title for the personal or shared list window.
    Example:
      `//todo t personal "Hero's Journal"`
      `//todo t shared "Guild Missions"`

Color Key:
----------
- [shared] Task = Lime Green (50, 205, 50)
- [X] Completed Task = Steel Blue (70, 130, 180)
- Normal Task = Sky Blue (135, 206, 235)

Behavior Notes:
---------------
- Shared and personal tasks are displayed in separate windows for clarity.
- Shared tasks are not duplicated if already present.
- Tasks are saved immediately after modification.
- Window positions, titles, and font size are saved per character.
- The `//todo loadshared` command has been deprecated.

Requirements:
-------------
- Windower 4
- Lua 5.1 (included with Windower)
- Default system font: Arial

Support:
--------
Report issues, request features, or send suggestions to Uncle Awesome.
(Optional: link to GitHub repo or Discord)

License:
--------
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

Enjoy efficient task tracking with the To-Do Addon for Windower!
