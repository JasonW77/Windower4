To-Do Addon for Windower 4
==========================

Author: Uncle Awesome
Version: 1.7

Description:
------------
A simple to-do list addon for Final Fantasy XI using Windower 4.
Allows players to manage personal and shared task lists with an on-screen display.
Supports saving window position, color-coded shared tasks, and automatic display toggling per character.

Features:
---------
- Personal tasks saved to: data/<character>/tasks.txt
- Shared tasks saved to: data/shared_tasks.txt
- Add, remove, complete tasks with simple chat commands
- Shared tasks are displayed in green text
- Window position saved and restored per character
- Optional automatic display on login, configurable per character
- Drag the window to reposition it; position is saved automatically

Installation:
-------------
1. Place the `todo.lua` addon file in your Windower addons folder.
2. Create the `data` folder inside the addon folder if it doesn't exist.
3. The addon will automatically create per-character directories and task files as needed.

Usage:
------
Commands are entered via chat as follows:

//todo start
  - Show the to-do list window.

//todo stop
  - Hide the to-do list window.

//todo add <task description>
  - Add a new task to your personal list.

//todo remove <index>
  - Remove the task at the given list index.

//todo complete <index>
  - Mark the task at the given index as completed (adds a checkmark).

//todo share
  - Save your current task list to the global shared_tasks.txt file.

//todo loadshared
  - Load shared tasks from shared_tasks.txt into your current list (prefixed as shared).

//todo setautostart true|false
  - Toggle automatic showing of the to-do list window when you log in.
    - Default is false (hidden).
    - Setting is saved per character in settings.xml.

Features Notes:
---------------
- Shared tasks are visually distinguished in green.
- Window position is saved on drag and restored on login.
- The addon automatically creates necessary folders and files if missing.
- Personal and shared task lists are kept separate.

Requirements:
-------------
- Windower 4
- Lua 5.1 compatible environment (comes with Windower)
- Default font Arial for display (can be changed in the code)

Support:
--------
Report bugs or request features on the addon repository or contact Uncle Awesome.

License:
--------
[Insert your license here, e.g. MIT License]

---

Enjoy keeping track of your quests and to-do lists efficiently!
