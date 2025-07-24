# shamey-core

This is a library that many other scripts in the `shamey-` family depend on.

The purpose of this script is twofold:
1. Keep the codebase as D.R.Y. as (reasonably) possible by providing a library of common utility functions in a centralized API, to be used by other scripts.
2. Housing some smaller "misfit" features that are too small to be in their own script, but need to run regardless (e.g. telegram notification icon).

The first purpose is intended to be supplemental to well-made third-party libraries like [jo_libs](https://github.com/Jump-On-Studios/RedM-jo_libs).

## Features
- **API** - Provides clean, optimized functions for common tasks that other scripts can use.
- **Degradation** - Handles all degradation for *NON-GUN* weapons, items, & hold-ables.
- **Imaps** - VORP already handles a lot of the basic imaps, but these are special ones enabled/disabled for our server.
- **Multiple Jobs** - I designed a system that allows characters to have multiple jobs and switch between them (`/multijob` command). This involved custom database changes, which I cannot document at this time.
- **PVP** - This handles the `/pvp` command, plus our chosen PVP arrangement (friendly-fire and ped relationships).
- **Telegram Notify** - Extremely simple bit of code that runs the telegram icon in our HUD.
- **Zone Finder** - This runs a "Freight Finder" on Discord. Every interval, every client is polled for the character's zone info, which is shipped back to the server-side code, which counts and organizes the info and then ships it to Discord.
- **Accessibility** - A unique, custom, item-based accessibility system, which this script handles. It checks their pockets for the special item(s) and then, if present, makes a tweak to a setting to accomodate a need.
- **Misc** - Stuff like the `/c` command.

## Requirements
- jo_libs
- VORP Framework
- (This also uses `30log` for OOP, but a standalone copy is included.)

## License & Support
This software was formerly proprietary to Rainbow Railroad Roleplay, but I am now releasing it free and open-source under GNU GPLv3. I cannot provide any support.
