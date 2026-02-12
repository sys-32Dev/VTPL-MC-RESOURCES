local default = require("tacz_manual_action_state_machine")
local STATIC_TRACK_LINE = default.STATIC_TRACK_LINE
local MAIN_TRACK = default.MAIN_TRACK
local main_track_states = default.main_track_states

-- Override idle state to hook into reload and inspect
local idle_state = setmetatable({}, {__index = main_track_states.idle})

function idle_state.transition(this, context, input)
    if (input == INPUT_RELOAD) then
        return this.main_track_states.reload
    elseif (input == INPUT_INSPECT) then
        context:runAnimation("inspect", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
        return this.main_track_states.inspect
    end
    return main_track_states.idle.transition(this, context, input)
end

-- Custom reload state
local reload_state = {}

function reload_state.entry(this, context)
    local has_chambered = context:hasBulletInBarrel()
    local mag_ammo = context:getAmmoCount()
    local max_ammo = context:getMaxAmmoCount()
    local missing = max_ammo - mag_ammo

    -- Clamp missing ammo so no invalid animation call
    if missing > 9 then
        missing = 9
    elseif missing < 0 then
        missing = 0
    end

    local anim = ""

    if missing == 0 and has_chambered then
        -- Fully loaded: play a visual fake reload animation
        anim = "gun_check"
    elseif mag_ammo == 0 and not has_chambered then
        anim = "reload_empty"
    elseif missing == 9 then
        anim = "reload_9"
    elseif missing == 8 then
        anim = "reload_8"
    elseif missing == 7 then
        anim = "reload_7"
    elseif missing == 6 then
        anim = "reload_6"
    elseif missing == 5 then
        anim = "reload_5"
    elseif missing == 4 then
        anim = "reload_4"
    elseif missing == 3 then
        anim = "reload_3"
    elseif missing == 2 then
        anim = "reload_2"
    elseif missing == 1 then
        anim = "reload_1"
    else
        anim = "gun_check" -- fallback
    end

    context:runAnimation(anim, context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
end

function reload_state.transition(this, context, input)
    if (input == this.INPUT_RELOAD_RETREAT or input == INPUT_CANCEL_RELOAD) then
        return this.main_track_states.idle
    end
    return this.main_track_states.idle.transition(this, context, input)
end

-- Final state machine export
local M = setmetatable({
    main_track_states = setmetatable({
        idle = idle_state,
        reload = reload_state
    }, {__index = main_track_states}),
    INPUT_RELOAD_RETREAT = "reload_retreat"
}, {__index = default})

function M:initialize(context)
    default.initialize(self, context)
end

return M
