# gb-juicebar

**gb-juicebar** is a custom juice bar resource for QBCore-based FiveM servers. It adds an immersive juice-making experience using a custom NUI interface and a bespoke MLO environment. This script is functional but still in a work-in-progress state—it works, but needs further polishing, which I currently don't have time to finish.

---

## How It Works

Players can walk up to the juice bar location (configured in `config.lua`) and interact with the NUI interface to craft different types of juices (lemon, orange, pineapple, etc.). The frontend is drag-and-drop based, and upon successful crafting, items are rewarded via server events. The system includes:

* Interactable crafting zone
* NUI (HTML/JS/CSS) UI with icons and animations
* Client-server synced crafting logic
* MLO with custom props and textures for full immersion

---

## Features

* 🍹 Juice Crafting System (Lemon, Orange, Pineapple, etc.)
* 🧃 Custom NUI Interface with drag-and-drop mechanics
* 🏠 Integrated Custom MLO (interior and exterior)
* 🎨 Custom props and textures
* 📦 Optimized for performance (but may need fine-tuning)

***ALL LOCATIONS ARE DEFINED IN CONFIG.LUA*** in terms of FRUIT SHOP ETC.

---

## Installation ***IMPORTANT***

1. **Drag and drop** the `gb-juicebar` folder into your `resources` directory.

3. Make sure required items are configured in your QBCore shared items file.

4. Move all images from the `images/` folder in this script into `qb-inventory/html/images` to ensure proper item image display.

---

## Dependencies

* QBCore Framework (latest)

---

## Configuration

Modify `config.lua` to set the juice bar location, crafting recipes, and interaction settings:

```lua
Config.Locations = {
    vector3(-1195.9, -892.4, 13.99) -- Example coords
}
```

Customize crafting recipes, durations, and required items as needed.

---
## Drop this into your 'qb-core/shared/jobs.lua' :

    juicebar = {
        label = "Juice Bar",
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = { name = "Employee", payment = 50 },
            ['1'] = { name = "Manager", isboss = true, payment = 100 }
        }
    },


## Shared Items (to add in `qb-core/shared/items.lua`)

```lua
["lemon"] = { name = "lemon", label = "Lemon", weight = 100, type = "item", image = "lemon.png", unique = false, useable = false, shouldClose = true, combinable = nil, description = "A fresh lemon." },
["orange"] = { name = "orange", label = "Orange", weight = 100, type = "item", image = "orange.png", unique = false, useable = false, shouldClose = true, combinable = nil, description = "A juicy orange." },
["pineapple"] = { name = "pineapple", label = "Pineapple", weight = 100, type = "item", image = "pineapple.png", unique = false, useable = false, shouldClose = true, combinable = nil, description = "A sweet pineapple." },

["lemonade"] = { name = "lemonade", label = "Lemonade", weight = 250, type = "item", image = "lemonjuice.png", unique = false, useable = true, shouldClose = true, combinable = nil, description = "Fresh homemade lemonade!" },
["orangejuice"] = { name = "orangejuice", label = "Orange Juice", weight = 250, type = "item", image = "orangejuice.png", unique = false, useable = true, shouldClose = true, combinable = nil, description = "Freshly squeezed orange juice!" },
["pineapplejuice"] = { name = "pineapplejuice", label = "Pineapple Juice", weight = 250, type = "item", image = "pineapplejuice.png", unique = false, useable = true, shouldClose = true, combinable = nil, description = "Delicious pineapple juice!" },

["lemonslice"] = { name = "lemonslice", label = "Lemon Slice", weight = 50, type = "item", image = "lemonslice.png", unique = false, useable = false, shouldClose = true, combinable = nil, description = "A slice of lemon, ready for juice." },
["orangeslice"] = { name = "orangeslice", label = "Orange Slice", weight = 50, type = "item", image = "orangeslice.png", unique = false, useable = false, shouldClose = true, combinable = nil, description = "A slice of orange, ready for juice." },
["pineappleslice"] = { name = "pineappleslice", label = "Pineapple Slice", weight = 50, type = "item", image = "pineappleslice.png", unique = false, useable = false, shouldClose = true, combinable = nil, description = "A slice of pineapple, ready for juice." },
```

---

## Known Issues / To-Do

*  Needs polish on UI transitions and error handling
*  Lacks inventory integration by default
*  Some visual assets might need optimization or resizing
*  Lacks cash register

---

## Credits

* Developed by GrossBean
* Map & prop work by contributors listed in `stream/`
* Thanks to the QBCore community for support

---

## License

See `LICENSE.md` for licensing terms.

---

## Support

This is a personal project and not officially maintained. Feel free to fork, improve, or use as a learning resource. Bug reports or feature requests may not be addressed due to time constraints.
