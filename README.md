FreeRollCasino Addon - README
=============================

1. Introduction
---------------
FreeRollCasino is a World of Warcraft addon that provides two casino-style
mini-games, a configurable panel for min/max bets, and a live UI window 
to track recent bet outcomes:

1) **Free Roll (1–100)**:
   - 1–66: Lose
   - 67–97: Double (2× payout)
   - 98–100: Triple (3× payout)

2) **Worn Troll Dice (2–12)**:
   - 2–6: Lose
   - 7: Bet returned (break-even)
   - 8–9: 2× payout
   - 10–11: 3× payout
   - 12: 4× payout

It allows you to accept gold bets from other players, detects their rolls,
announces the result in chat, and maintains a scrollable UI log of all bets.

2. Features
-----------
- **Two distinct game modes** (select with `/casinomode freeroll` or `/casinomode troll`).
- **Configurable Min/Max Bets** via a new interface panel (Escape → Options → AddOns).
- **Scrollable UI** (`/casinoui`) to view all bets, winners, and net gains/losses:
  - Stores session-based history in `CasinoRecords`.
  - Logs time, player name, bet amount, final roll, outcome, and net gain.
- **Hybrid Support** for older expansions (Cataclysm Classic, Wrath, etc.) and modern Retail:
  - Uses `InterfaceOptions_AddCategory` if available.
  - Falls back to the new Settings API (`Settings.RegisterAddOnCategory`) in Retail 10.0+.

3. Installation
---------------
1) Download or copy the following files into a folder named **FreeRollCasino**:
   - **FreeRollCasino.toc**
   - **FreeRollCasino.lua**
   - **FreeRollGame.lua**
   - **TrollDiceGame.lua**
   - **CasinoUI.lua**
   - **ConfigPanel.lua**

2) Move that **FreeRollCasino** folder into: /Interface/AddOns/
3) Restart or Reload WoW:
- At the character selection screen, **enable** "FreeRollCasino".
- In-game, type `/reload` to finalize loading if needed.

4. How to Use
-------------
1) **Select a Game Mode**  
- By default, the addon starts in "Free Roll" (1–100).
- Type `/casinomode troll` to switch to "Worn Troll Dice".
- Type `/casinomode freeroll` to switch back.

2) **Accepting Bets**  
- Another player trades you gold within the configured min/max limits 
  (default 5–5000 gold, adjustable via the Config panel).
- The addon automatically tracks the bet.

3) **Rolling**  
- **Free Roll**: The betting player types `/roll` (or `/roll 100`) in chat.
- **Worn Troll Dice**: The player uses the toy from their Toy Box, generating two
  1–6 rolls in the system chat.

4) **Outcome Announcements**  
- The addon listens for system roll messages and determines the result.
- Winners/losers are announced in `/say` and (for certain wins) whispered to claim payouts.
- The host can then open a trade window to pay out the winnings.

5) **Viewing the History (UI Window)**  
- Type `/casinoui` in chat to open/close a scrollable window listing recent bets.
- Displays time, player, bet amount, rolled value(s), outcome, and net gain/loss.
- Automatically refreshes if it’s open when new bets are resolved.

5. Configuring Bet Limits
-------------------------
- From the main game, press **Escape** → **Options** → **AddOns** (or **Settings** → 
**AddOns** in newer clients) and select **Free Roll Casino**.
- Adjust the **Min Bet** and **Max Bet** sliders in real time.
- The new values are saved in `FreeRollCasinoDB` and persist across sessions.

6. Slash Commands
-----------------
- **`/casinomode freeroll`**: Switch to the Free Roll (1–100) game.
- **`/casinomode troll`**: Switch to the Worn Troll Dice (2×1–6) game.
- **`/casinoui`**: Opens or closes the live history UI window.
- **`/reload`**: Common WoW command to reload the interface (useful after editing files).

7. Frequently Asked Questions
-----------------------------
**Q1**: "How do I change min/max bets without editing Lua files?"
- **A1**: Use the in-game config panel under **AddOns** → **Free Roll Casino**. The slider changes take effect immediately.

**Q2**: "Does the addon automatically pay the winner?"
- **A2**: No. WoW’s API prevents automatic trading. The addon announces how much
the player wins, but you must open a trade window manually to pay out.

**Q3**: "What if a random person rolls without trading gold first?"
- **A3**: The roll is ignored. The addon only processes rolls from players with an
active bet recorded.

**Q4**: "Will the UI log remain after I log out?"
- **A4**: Currently, no. The session-based history in `CasinoRecords` is not saved 
across logins. You can add SavedVariables for `CasinoRecords` if you wish to
store a permanent history.

**Q5**: "I'm on an older expansion (like Cataclysm Classic). Will it still work?"
- **A5**: Yes. The hybrid approach tries `InterfaceOptions_AddCategory` first, 
which works on Cataclysm Classic. If you eventually play Retail 10.0+, it uses
the new `Settings` API automatically.

8. Tips & Best Practices
------------------------
- **Trust but verify**: Double-check each trade for the correct gold amount.
- **Prompt payouts** help maintain trust with your bettors.
- **Extend/Customize**: Feel free to modify payouts, add special rules, or 
implement a system to track session-based profit/loss for each user.
- If you want a permanent record of all bets, consider adding 
`SavedVariables: CasinoRecordsDB` and storing them similarly to min/max bets.

9. Disclaimer
-------------
- This addon is for **entertainment purposes** within WoW.
- **Gambling** (even with virtual currency) can be subject to Blizzard’s policies.
Use responsibly and respect your server/community rules.

Thank you for choosing **FreeRollCasino**—have fun rolling, and may the odds be
ever in your favor! - Your favorite gambler, Shabbso
