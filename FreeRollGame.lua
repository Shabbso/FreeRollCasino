-- FreeRollGame.lua
-------------------------------------------------------------------------------
-- Single-roll (1–100) logic, now with roundActive toggles.
-------------------------------------------------------------------------------

local FreeRollGame = {}
FreeRollGame.playerBets = {}

function FreeRollGame:OnTrade(player, amount)
    local minB = FreeRollCasinoDB.minBet or 5
    local maxB = FreeRollCasinoDB.maxBet or 5000

    if amount < minB or amount > maxB then
        print("|cffff0000[FreeRoll] Bet must be between " .. minB .. "g and " .. maxB .. "g.|r")
        return
    end
    self.playerBets[player] = amount
    print("|cff00ff00[FreeRoll] " .. player .. " placed a bet of " .. amount .. "g!|r")
end

function FreeRollGame:OnSystemRoll(player, roll)
    if not self.playerBets[player] then
        print("|cffffd100[FreeRoll] Ignoring roll from " .. player .. ". No active bet found.|r")
        return
    end

    ----------------------------------------------------------------
    -- Mark the round as active once we confirm a valid roll & bet
    ----------------------------------------------------------------
    SetRoundActive(true)

    local bet = self.playerBets[player]
    local outcome = "Lose"
    local netGain = -bet

    if roll >= 1 and roll <= 66 then
        print("|cffff0000[FreeRoll] " .. player .. " rolled " .. roll .. ". They lose!|r")
        SendChatMessage(player .. " rolled " .. roll .. " and lost their bet of " .. bet .. "g!", "SAY")

    elseif roll >= 67 and roll <= 97 then
        outcome = "Double"
        netGain = bet
        local winnings = bet * 2
        print("|cff00ff00[FreeRoll] " .. player .. " rolled " .. roll .. ". Wins " .. winnings .. "g!|r")
        SendChatMessage("Congratulations, " .. player .. "! You win " .. winnings .. "g! Please open trade with me for your payout.", "WHISPER", nil, player)
        SendChatMessage(player .. " rolled " .. roll .. " and won " .. winnings .. "g!", "SAY")

    elseif roll >= 98 and roll <= 100 then
        outcome = "Triple"
        netGain = bet * 2
        local winnings = bet * 3
        print("|cff00ff00[FreeRoll] " .. player .. " rolled " .. roll .. ". Wins " .. winnings .. "g!|r")
        SendChatMessage("Congratulations, " .. player .. "! You win " .. winnings .. "g! Please open trade with me for your payout.", "WHISPER", nil, player)
        SendChatMessage(player .. " rolled " .. roll .. " and won a jackpot of " .. winnings .. "g!", "SAY")
    end

    -- Record result
    table.insert(CasinoRecords, {
        time = date("%H:%M:%S"),
        player = player,
        bet = bet,
        roll = roll,
        outcome = outcome,
        netGain = netGain,
    })

    -- If UI is open, refresh it
    if FreeRollCasinoUIFrame and FreeRollCasinoUIFrame:IsShown() then
        FreeRollCasinoUIFrame.Refresh()
    end

    -- Clear bet
    self.playerBets[player] = nil

    ----------------------------------------------------------------
    -- Now that outcome is decided, mark round inactive again.
    ----------------------------------------------------------------
    SetRoundActive(false)
end

_G["FreeRollGame"] = FreeRollGame