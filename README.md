# RiddleCompass

**RiddleCompass** is a lightweight World of Warcraft addon that automatically detects **Decor Treasure Hunt** riddles and places the correct waypoint on your map.

It works instantly when the quest is opened and requires no user input or configuration.

---

## ✨ Features

- Automatically reads the riddle from the quest text  
- Instantly matches it to the correct riddle solution  
- Sets a waypoint using your installed `/way` handler (WQL, TomTom, etc.)  
- Works for Alliance and Horde  
- No background scanning, extremely efficient  
- Optional debug mode

---

## 🧭 How to Use

Just pick up the **Decor Treasure Hunt** quest.

RiddleCompass will:

1. Read the riddle  
2. Match it  
3. Automatically set a waypoint  

You're done!

---

## 🔧 Slash Commands

| Command | Description |
|---------|-------------|
| `/rc toggle` | Enable/Disable the addon |
| `/rc debug` | Toggle debug logging |

---

## 📁 Installation

Place the addon folder so the path looks like:

World of Warcraft/retail/Interface/AddOns/RiddleCompass/

Inside should be:

 - RiddleCompass.toc
 - core.lua
 - riddles_alliance.lua
 - riddles_horde.lua
 - Media

---

## 🛠 Contributing

If you discover an unknown riddle or want to improve the addon, feel free to:

- Submit an Issue
- Create a Pull Request
- Contact the author (Surance)

---

## 📌 License

MIT License  

---

## ❤️ Support

If you enjoy the addon, please consider giving it a star on GitHub or an upvote on CurseForge!
