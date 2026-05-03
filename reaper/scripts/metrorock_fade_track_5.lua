-- Pair fade: track 5 swings between silence and 0 dB while track 6 ducks
-- in opposition (0 dB <-> -10 dB) over 2 seconds. Both tracks animate
-- together; direction is decided by track 5's current position.
-- Re-invoking mid-fade reverses both tracks immediately.

local LEAD_TRACK_IDX = 4    -- track 5
local DUCK_TRACK_IDX = 5    -- track 6
local FADE_TIME = 2.0
local LEAD_TOP_DB = 0.0
local LEAD_BOTTOM_DB = -150.0
local DUCK_TOP_DB = 0.0
local DUCK_BOTTOM_DB = -10.0
local STATE_NS = "Metrorock"
local STATE_KEY = "fade_gen_pair_" .. LEAD_TRACK_IDX .. "_" .. DUCK_TRACK_IDX

local function db_to_linear(db)
    if db <= -149 then return 0 end
    return 10 ^ (db / 20)
end

local function linear_to_db(lin)
    if lin <= 1e-8 then return -150 end
    return 20 * math.log(lin, 10)
end

local lead = reaper.GetTrack(0, LEAD_TRACK_IDX)
local duck = reaper.GetTrack(0, DUCK_TRACK_IDX)
if not lead or not duck then return end

reaper.SetMediaTrackInfo_Value(lead, "B_MUTE", 0)
reaper.SetMediaTrackInfo_Value(duck, "B_MUTE", 0)

local lead_cur_db = linear_to_db(reaper.GetMediaTrackInfo_Value(lead, "D_VOL"))
local duck_cur_db = linear_to_db(reaper.GetMediaTrackInfo_Value(duck, "D_VOL"))

local going_up = lead_cur_db <= (LEAD_TOP_DB + LEAD_BOTTOM_DB) / 2
local lead_target = going_up and LEAD_TOP_DB or LEAD_BOTTOM_DB
local duck_target = going_up and DUCK_BOTTOM_DB or DUCK_TOP_DB

local start_time = reaper.time_precise()

local my_gen = (tonumber(reaper.GetExtState(STATE_NS, STATE_KEY)) or 0) + 1
reaper.SetExtState(STATE_NS, STATE_KEY, tostring(my_gen), false)

local function tick()
    if (tonumber(reaper.GetExtState(STATE_NS, STATE_KEY)) or 0) ~= my_gen then return end
    local now = reaper.time_precise()
    local t = (now - start_time) / FADE_TIME
    if t >= 1 then
        reaper.SetMediaTrackInfo_Value(lead, "D_VOL", db_to_linear(lead_target))
        reaper.SetMediaTrackInfo_Value(duck, "D_VOL", db_to_linear(duck_target))
        return
    end
    local lead_db_now = lead_cur_db + (lead_target - lead_cur_db) * t
    local duck_db_now = duck_cur_db + (duck_target - duck_cur_db) * t
    reaper.SetMediaTrackInfo_Value(lead, "D_VOL", db_to_linear(lead_db_now))
    reaper.SetMediaTrackInfo_Value(duck, "D_VOL", db_to_linear(duck_db_now))
    reaper.defer(tick)
end

reaper.defer(tick)
