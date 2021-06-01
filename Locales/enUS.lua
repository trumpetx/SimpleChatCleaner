local L =  LibStub("AceLocale-3.0"):NewLocale("SimpleChatCleaner", "enUS", true)
if not L then return end

L["Simple Chat Cleaner"] = true
L["Debug"] = true
L["enabled"] = true
L["Enabled"] = true
L["disabled"] = true
L["Enables the Chat Cleaner"] = true
L["Toggles debug mode"] = true
L["Match Whole Words"] = true
L["Filter by the full word only instead of partial matches"] = true
L["Filter Friendly"] = true
L["Filter friends and guild members"] = true
L["AddonEnabled"] = function(X,Y, cmd)
	return 'version ' .. X .. ' by |cFF00FF00' .. Y .. '|r loaded. |cFF00FF00 /' .. cmd .. '|r to configure.'
end
L["SessionCount"] = function(ct)
	return ct .. " messages blocked this session"
end
L["Add Word to Filter One"] = true
L["Adds a word to the first Filter Group"] = true
L["Add Word to Filter Two"] = true
L["Adds a word to the second Filter Group"] = true
L["List Filters"] = true
L["List all word filters to the chat console"] = true
L["Clear All Filters"] = true
L["Removes all words from all filters"] = true
L["Config Options"] = true
L["Filters"] = true
L["Filter Yell"] = true
L["Filter /yell"] = true
L["Filter Say"] = true
L["Filter /say"] = true
L["All Channels"] = true
L["Empty Filter"] = true
L["Channels"] = true
L["All Channels"] = true
L["Add Channel"] = true
L["Adds a channel to filter on, an empty list means ALL channels"] = true
L["Stats"] = true
L["Show basic filtering stats"] = true
-- addon command triggers
L["scc"] = true
L["simplechatcleaner"] = true
L["simplechat"] = true
