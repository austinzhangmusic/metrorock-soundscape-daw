-- Toggle hard-mute on tracks 1-5.
-- If any of them is currently unmuted, mute all; otherwise unmute all.
-- Acts as a panic kill regardless of fader position.
--
-- Also force-disables ReaEQ on the master bus and Spoton on tracks 7 and 8
-- if they're currently enabled. Disable is one-way here (re-enable lives on
-- sensors 6 and 7), so an "un-panic" tap restores the mutes but not the FX.

local TRACK_INDICES = {0, 1, 2, 3, 4}
local AUTOTUNE_TRACK_INDICES = {6, 7}  -- tracks 7 and 8

local any_unmuted = false
for _, idx in ipairs(TRACK_INDICES) do
    local t = reaper.GetTrack(0, idx)
    if t and reaper.GetMediaTrackInfo_Value(t, "B_MUTE") == 0 then
        any_unmuted = true
        break
    end
end

local target = any_unmuted and 1 or 0
for _, idx in ipairs(TRACK_INDICES) do
    local t = reaper.GetTrack(0, idx)
    if t then
        reaper.SetMediaTrackInfo_Value(t, "B_MUTE", target)
    end
end

local function disable_fx_by_name(track, match)
    if not track then return end
    local fx_count = reaper.TrackFX_GetCount(track)
    for i = 0, fx_count - 1 do
        local _, name = reaper.TrackFX_GetFXName(track, i, "")
        if name:find(match, 1, true) and reaper.TrackFX_GetEnabled(track, i) then
            reaper.TrackFX_SetEnabled(track, i, false)
            return
        end
    end
end

disable_fx_by_name(reaper.GetMasterTrack(0), "ReaEQ")
for _, idx in ipairs(AUTOTUNE_TRACK_INDICES) do
    disable_fx_by_name(reaper.GetTrack(0, idx), "Spoton")
end
