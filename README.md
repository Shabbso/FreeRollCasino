FreeRollCasino Addon - README
=============================

1. Introduction
---------------
FreeRollCasino is a World of Warcraft addon that brings a small in-game "casino"
experience to you and your friends. It currently offers **three mini-games**:

1) **Free Roll (1–100)**:
   - 1–66: Lose
   - 67–97: Double (2× payout)
   - 98–100: Triple (3× payout)

2) **Worn Troll Dice (2–6)**:
   - 2–5: Lose
   - 6: Return bet
   - 7–8: Double
   - 9–11: Triple
   - 12: Quadruple
   *(Or whatever custom rules you choose; the addon's code is flexible.)*

3) **WoW Blackjack**:
   - Players trade in a bet, then use a **custom UI** (Deal/Hit/Stand) to try
     to reach 21 without going bust.
   - The "dealer" is also automated. You can track final outcomes in-game.

The addon also includes:
- A **Config Panel** (in Escape → AddOns or new Settings) to set min/max bets.
- A **logging system** (`CasinoRecords`) for ephemeral session data.
- A **scrollable UI** (`/casinoui`) for viewing recent wins/losses.

2. Installation
---------------
1) **Download/Copy** all addon files into a folder named **FreeRollCasino**:
   - `FreeRollCasino.toc`
   - `FreeRollGame.lua`
   - `TrollDiceGame.lua`
   - `BlackjackGame.lua`
   - `BlackjackUI.lua`
   - `FreeRollCasino.lua`
   - `CasinoUI.lua`
   - `ConfigPanel.lua`

2) Move **FreeRollCasino** into: /Interface/AddOns/
3) **Enable** "FreeRollCasino" in your WoW AddOns list and/or type `/reload` if
you’re already logged in.

3. How It Works
---------------
### Game Modes
You can switch between any of the three games via `/casinomode`:

- **`/casinomode freeroll`**  
Uses the single 1–100 roll system.

- **`/casinomode troll`**  
Uses the "Worn Troll Dice" 2d6 system, detecting two 1–6 rolls.

- **`/casinomode blackjack`**  
Enables the **Blackjack** mini-game. (See below.)

### Accepting Bets
Players trade gold to the host (you) within the **min/max** bet range you’ve set
in the config panel. The addon tracks the bet for that specific player.

### Rolling / Game Flow
- **Free Roll**: The player types `/roll` (or `/roll 100`) in chat. The addon
checks the result and announces if they doubled, tripled, or lost.
- **Worn Troll Dice**: The player uses the "Worn Troll Dice" toy (in their Toy
Box), automatically sending two separate "rolls (1–6)" events that the addon
detects. The final sum is used to determine lose, double, triple, etc.
- **Blackjack**:
- Open the **Blackjack UI** by typing `/bjui` (or automatically if you do
 `/casinomode blackjack` and the code is set to auto-show).
- Click **Deal** to start a round (must have traded gold first).
- Click **Hit** to draw another “card” (number 1–11).
- Click **Stand** to finalize your hand. The dealer will then draw until
 reaching 17+ or busting, and the addon announces the outcome.

### Viewing History
You can open a scrollable log with `/casinoui` to see who bet, what they rolled,
and how much they won or lost. This data is **session-based** (not saved across
logouts).

4. FAQ
------
**Q1: "How do I install or update?"**  
A1: Copy the files to your `Interface/AddOns/FreeRollCasino` folder. Make sure
they’re all named correctly and listed in the `.toc` file. Then `/reload` or
restart the game.

**Q2: "Why can’t I automatically pay out winners?"**  
A2: WoW’s API disallows fully automated trading for gold to prevent exploitation.
The addon logs amounts owed, but you must manually open a trade window.

**Q3: "Can I run multiple games at once?"**  
A3: Only one game mode is active at a time (`/casinomode freeroll | troll | blackjack`).
If you switch mid-game, the current bets may be reset, so finish up ongoing bets
first.

**Q4: "What if someone rolls without trading gold?"**  
A4: The addon ignores that roll. A debug message prints locally (not publicly)
stating no bet was found.

**Q5: "Does the Blackjack UI handle multi-player scenarios?"**  
A5: The current version is simplified for single-player vs. the dealer. You can
expand it, but that’d require more concurrency logic.

**Q6: "Is there a chance to incorporate special card logic like Aces (1 or 11)?"**  
A6: By default, the code uses straight `1–11` values. You can modify the
`CalculateTotal` function in `BlackjackGame.lua` for more authentic Blackjack
handling.

5. Tips & Best Practices
------------------------
- **Test** on a second account or with a friend to verify trades and rolls.
- **Payout promptly** to build trust and avoid confusion.
- **Customize**: Feel free to alter dice rules or payout structures in the `.lua`
files. Just keep track of the logic so players aren’t surprised.
- **Use the Config Panel**: (Escape → AddOns → FreeRollCasino) to adjust min/max
bets without editing Lua files.

6. Disclaimer
-------------
- This addon is for **entertainment purposes** within WoW.
- **Gambling** (even with virtual currency) may be subject to Blizzard’s policies.
Use responsibly and respect server/community rules.

---

**Thank you for installing FreeRollCasino!**  
Have fun, and may the dice (or cards) roll in your favor.  
