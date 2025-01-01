-------------------------------------------------------------------------------
-- TrollDiceGame.lua
-- 2d6 logic for Worn Troll Dice with updated rules:
--   2-6 = lose
--   7   = break-even
--   8-9 = double
--   10-11 = triple
--   12  = 4x
-------------------------------------------------------------------------------

local TrollDiceGame = {}
TrollDiceGame.playerBets = {}
TrollDiceGame.toyRolls   = {}

--------------------------------------------------------------------------------
-- Called when someone trades you gold for this Troll Dice game
--------------------------------------------------------------------------------
function TrollDiceGame:OnTrade(player, amount)
    local minB = FreeRollCasinoDB.minBet or 5
    local maxB = FreeRollCasinoDB.maxBet or 5000

    if amount < minB or amount > maxB then
        print("|cffff0000[TrollDice] Bet must be between " .. minB .. "g and " .. maxB .. "g.|r")
        return
    end
    self.playerBets[player] = amount
    print("|cff00ff00[TrollDice] " .. player .. " placed a bet of " .. amount .. "g!|r")
end

--------------------------------------------------------------------------------
-- Called when the system sees "<player> rolls X (1-6)"
-- The toy does this twice (die1, die2).
--------------------------------------------------------------------------------
function TrollDiceGame:OnSystemRoll(player, rollValue)
    if not self.playerBets[player] then
        print("|cffcccccc[TrollDice] Ignoring roll from " .. player .. " - no bet on record.|r")
        return
    end

    if not self.toyRolls[player] then
        self.toyRolls[player] = { die1 = nil, die2 = nil }
    end

    local rolls = self.toyRolls[player]
    if not rolls.die1 then
        rolls.die1 = rollValue
        print("|cff00ff00[TrollDice] " .. player .. " first die: " .. rollValue .. "|r")
    else
        rolls.die2 = rollValue
        print("|cff00ff00[TrollDice] " .. player .. " second die: " .. rollValue .. "|r")

        local sum = rolls.die1 + rolls.die2
        print("|cff00ff00[TrollDice] " .. player .. " final roll: " 
              .. rolls.die1 .. " + " .. rolls.die2 .. " = " .. sum .. "|r")

        self:ResolveBet(player, sum)

        -- Clear bet/roll storage
        self.playerBets[player] = nil
        self.toyRolls[player] = nil
    end
end

--------------------------------------------------------------------------------
-- Resolve Bet with the updated rules:
--   2–6 = lose,
--   7   = break-even,
--   8–9 = 2×,
--   10–11 = 3×,
--   12 = 4×
--------------------------------------------------------------------------------
function TrollDiceGame:ResolveBet(player, sum)
    local bet = self.playerBets[player]
    if not bet then return end

    local outcome = "Lose"
    local netGain = -bet

    if sum >= 2 and sum <= 6 then
        -- Lose
        print("|cffff0000[TrollDice] " .. player .. " rolled " .. sum .. ". Loses " .. bet .. "g.|r")
        SendChatMessage(player .. " rolled " .. sum .. " and lost " .. bet .. "g!", "SAY")

    elseif sum == 7 then
        -- Break-even
        outcome = "BreakEven"
        netGain = 0
        print("|cffffff00[TrollDice] " .. player .. " rolled 7. Bet returned: " .. bet .. "g.|r")
        SendChatMessage(player .. " rolled a 7 and broke even! Their " .. bet .. "g is returned.", "SAY")

    elseif sum >= 8 and sum <= 9 then
        -- 2×
        outcome = "2x"
        netGain = bet
        local winnings = bet * 2
        print("|cff00ff00[TrollDice] " .. player .. " rolled " .. sum .. ". Wins " .. winnings .. "g!|r")
        SendChatMessage(player .. " rolled " .. sum .. " and won " .. winnings .. "g!", "SAY")

    elseif sum >= 10 and sum <= 11 then
        -- 3×
        outcome = "3x"
        netGain = 2 * bet
        local winnings = bet * 3
        print("|cff00ff00[TrollDice] " .. player .. " rolled " .. sum .. ". Wins " .. winnings .. "g!|r")
        SendChatMessage(player .. " rolled " .. sum .. " and won " .. winnings .. "g!", "SAY")

    elseif sum == 12 then
        -- 4×
        outcome = "4x"
        netGain = 3 * bet
        local winnings = bet * 4
        print("|cff00ff00[TrollDice] " .. player .. " rolled 12. Wins " .. winnings .. "g!|r")
        SendChatMessage(player .. " rolled 12 (Boxcars!) and won " .. winnings .. "g!", "SAY")
    end

    -- Record result if you have a logging system (e.g. CasinoRecords)
    table.insert(CasinoRecords, {
        time = date("%H:%M:%S"),
        player = player,
        bet = bet,
        roll = sum,
        outcome = outcome,
        netGain = netGain,
    })

    -- If a UI is open, refresh it
    if FreeRollCasinoUIFrame and FreeRollCasinoUIFrame:IsShown() then
        FreeRollCasinoUIFrame.Refresh()
    end
end

-------------------------------------------------------------------------------
-- Make sure the global name is set so the main addon can see it
-------------------------------------------------------------------------------
_G["TrollDiceGame"] = TrollDiceGame