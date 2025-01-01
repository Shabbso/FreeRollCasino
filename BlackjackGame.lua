-- BlackjackGame.lua
-------------------------------------------------------------------------------
local BlackjackGame = {}
BlackjackGame.playerBets = {}
BlackjackGame.playerHands = {}
BlackjackGame.dealerState = {}

function BlackjackGame:OnTrade(player, amount)
    local minB = FreeRollCasinoDB.minBet or 5
    local maxB = FreeRollCasinoDB.maxBet or 5000

    if amount < minB or amount > maxB then
        print("|cffff0000[Blackjack] Bet must be between " .. minB .. "g and " .. maxB .. "g.|r")
        return
    end
    self.playerBets[player] = amount
    print("|cff00ff00[Blackjack] " .. player .. " placed a bet of " .. amount 
          .. "g! Use the Blackjack UI to deal!|r")
end

function BlackjackGame:StartGame(player)
    -- Mark round active at the start of dealing
    SetRoundActive(true)

    if not self.playerBets[player] then
        print("|cffff0000[Blackjack] " .. player .. " has no active bet. Trade gold first!|r")
        return
    end

    self.playerHands[player] = { hand = {}, total = 0, state = "active" }
    self.playerHands[player].hand[1] = self:GetRandomCard()
    self.playerHands[player].hand[2] = self:GetRandomCard()
    self.playerHands[player].total = self:CalculateTotal(self.playerHands[player].hand)

    self.dealerState[player] = { hand = {}, total = 0, state = "active" }
    self.dealerState[player].hand[1] = self:GetRandomCard()
    self.dealerState[player].hand[2] = self:GetRandomCard()
    self.dealerState[player].total = self:CalculateTotal(self.dealerState[player].hand)

    if self.playerHands[player].total == 21 then
        print("|cffffff00[Blackjack] " .. player .. " hits 21 immediately!|r")
        self:DealerFinish(player)
    end
end

function BlackjackGame:PlayerHit(player)
    local pState = self.playerHands[player]
    if not pState or pState.state ~= "active" then
        print("|cffff0000[Blackjack] " .. player .. " is not in an active game.|r")
        return
    end

    local newCard = self:GetRandomCard()
    table.insert(pState.hand, newCard)
    pState.total = self:CalculateTotal(pState.hand)

    if pState.total > 21 then
        pState.state = "bust"
        print("|cffff0000[Blackjack] " .. player .. " busts with " .. pState.total .. "!|r")
        self:FinishGame(player, "bust")
    elseif pState.total == 21 then
        print("|cffffff00[Blackjack] " .. player .. " has 21! Now standing...|r")
        self:PlayerStand(player)
    end
end

function BlackjackGame:PlayerStand(player)
    local pState = self.playerHands[player]
    if not pState or pState.state ~= "active" then
        print("|cffff0000[Blackjack] " .. player .. " is not in an active game.|r")
        return
    end

    pState.state = "stand"
    self:DealerFinish(player)
end

function BlackjackGame:DealerFinish(player)
    local dState = self.dealerState[player]
    local pState = self.playerHands[player]
    if not dState or not pState then return end

    if pState.state == "bust" then
        self:FinishGame(player, "dealerauto")
        return
    end

    while dState.total < 17 do
        local newCard = self:GetRandomCard()
        table.insert(dState.hand, newCard)
        dState.total = self:CalculateTotal(dState.hand)
    end

    if dState.total > 21 then
        dState.state = "bust"
    else
        dState.state = "stand"
    end

    self:FinishGame(player, "dealerdone")
end

function BlackjackGame:FinishGame(player, reason)
    local bet = self.playerBets[player]
    local pState = self.playerHands[player]
    local dState = self.dealerState[player]
    if not bet or not pState or not dState then return end

    local playerTotal = pState.total
    local dealerTotal = dState.total

    local outcome = "Lose"
    local netGain = -bet

    if pState.state == "bust" then
        outcome = "Lose"
    else
        if dState.state == "bust" then
            outcome = "Win"
            netGain = bet
        else
            if playerTotal > dealerTotal then
                outcome = "Win"
                netGain = bet
            elseif playerTotal < dealerTotal then
                outcome = "Lose"
            else
                outcome = "Push"
                netGain = 0
            end
        end
    end

    if outcome == "Win" then
        print("|cff00ff00[Blackjack] " .. player .. " wins! "
            .. playerTotal .. " vs Dealer's " .. dealerTotal
            .. ". Gains " .. bet .. "g net.|r")
        SendChatMessage(player .. " wins at Blackjack! ("
            .. playerTotal .. " vs " .. dealerTotal .. ")", "SAY")
    elseif outcome == "Push" then
        print("|cffffff00[Blackjack] " .. player .. " pushes with Dealer. Bet returned.|r")
        SendChatMessage(player .. " pushes at Blackjack! ("
            .. playerTotal .. " vs " .. dealerTotal .. ") - Bet returned.", "SAY")
    else
        print("|cffff0000[Blackjack] " .. player .. " loses! "
            .. playerTotal .. " vs " .. dealerTotal .. ".|r")
        SendChatMessage(player .. " loses at Blackjack! ("
            .. playerTotal .. " vs " .. dealerTotal .. ")", "SAY")
    end

    table.insert(CasinoRecords, {
        time = date("%H:%M:%S"),
        player = player,
        bet = bet,
        outcome = "Blackjack_"..outcome,
        netGain = netGain,
        detail = "P="..playerTotal..", D="..dealerTotal
    })

    self.playerBets[player] = nil
    self.playerHands[player] = nil
    self.dealerState[player] = nil

    if BlackjackUI and BlackjackUI:IsShown() and BlackjackUI.RefreshUI then
        BlackjackUI:RefreshUI()
    end

    -- Mark round inactive now that the game is finished
    SetRoundActive(false)
end

function BlackjackGame:GetRandomCard()
    return math.random(1, 11)
end

function BlackjackGame:CalculateTotal(hand)
    local sum = 0
    for _, v in ipairs(hand) do
        sum = sum + v
    end
    return sum
end

function BlackjackGame:FormatHand(hand)
    local t = {}
    for _, card in ipairs(hand) do
        table.insert(t, tostring(card))
    end
    return table.concat(t, ", ")
end

_G["BlackjackGame"] = BlackjackGame