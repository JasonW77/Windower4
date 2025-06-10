To-Do Addon for Windower 4
==========================

Author: Uncle Awesome
Version: 1.8

Description:
------------
A simple, user-friendly to-do list addon for Final Fantasy XI (via Windower 4).
Supports personal and shared task lists with a customizable, on-screen UI.
Offers drag-and-drop window positioning, colored task types, and persistent saved states.

Features:
---------
- Personal tasks saved to: data/<character>/tasks.txt
- Shared tasks saved to: data/shared_tasks.txt
- Add, remove, complete, uncomplete, and share tasks using chat commands
- Tasks are color-coded by type:
  - Normal tasks: Sky Blue (135, 206, 235)
  - Completed tasks: Steel Blue (70, 130, 180)
  - Shared tasks: Lime Green (50, 205, 50)
- Shared tasks are always displayed at the top of the list
- Automatically creates folders and saves per-character settings
- Optional auto-display of the list when logging in
- Font size can be changed manually

Installation:
-------------
1. Place `todo.lua` in your Windower `addons/todo/` folder.
2. Create a `data` folder inside the addon folder if it doesn't exist.
3. Windower will automatically create per-character directories and files on use.

Usage:
------
Commands are entered in the game chat:

  //todo start
    - Show the to-do list window and load personal tasks.

  //todo stop
    - Hide the to-do list window.

  //todo add <task description>
    - Add a task to your personal list.
    Example:
      `//todo add Farm Beastcoins in Dynamis`

  //todo remove <index>
    - Remove the task at the given index number.
    Example:
      `//todo remove 2`

  //todo complete <index>
    - Mark a task as completed. Adds `[X]` and colors it blue.
    Example:
      `//todo complete 4`

  //todo uncomplete <index>
    - Remove the `[X]` from a task and revert its status.
    Example:
      `//todo uncomplete 4`

  //todo share <index>
    - Share a task to the shared list. It will appear as a green `[shared]` entry.
    Example:
      `//todo share 3`

  //todo fontsize <6-48>
    - Set the font size of the to-do list text.
    Example:
      `//todo fontsize 16`

  //todo setautostart true|false
    - Automatically show the list on character login.
    Example:
      `//todo setautostart true`

Color Key:
----------
- [shared] Task = Lime Green (50, 205, 50)
- [X] Completed Task = Steel Blue (70, 130, 180)
- Normal Task = Sky Blue (135, 206, 235)

Behavior Notes:
---------------
- Shared tasks are automatically loaded at the top of the list when the addon is loaded.
- Shared tasks are not duplicated if already present.
- Tasks are saved immediately after modifications.
- Window position is saved when moved and restored automatically.
- The //todo loadshared command has been deprecated as shared tasks load automatically.

Requirements:
-------------
- Windower 4
- Lua 5.1 (included with Windower)
- Default system font: Arial

Support:
--------
Report issues, request features, or send suggestions to Uncle Awesome.
(Optional: link to repository or contact info)

License:
--------
[Insert license name here, e.g., MIT License]

---

Enjoy efficient task tracking with the To-Do Addon for Windower!
