local M = {}

function M.shoot(api)
    api:shootOnce(api:isShootingNeedConsumeAmmo())
end

function M.start_reload(api)
    local cache = {
        ammo_needed = api:getNeededAmmoAmount(),
        is_empty = (api:getAmmoCount() <= 0 and not api:hasAmmoInBarrel()),
        reloaded = false
    }
    api:cacheScriptData(cache)
    return true
end

function M.tick_reload(api)
    local cache = api:getCachedScriptData()
    local param = api:getScriptParams()
    local reload_time = api:getReloadTime()

    -- Clamp ammo_needed to max 9 to match animations
    local ammo_needed = cache.ammo_needed
    if ammo_needed > 9 then
        ammo_needed = 9
    elseif ammo_needed < 0 then
        ammo_needed = 0
    end

    local anim_name = ""
    if cache.is_empty then
        anim_name = "reload_empty"
    elseif ammo_needed == 9 then
        anim_name = "reload_9"
    elseif ammo_needed == 8 then
        anim_name = "reload_8"
    elseif ammo_needed == 7 then
        anim_name = "reload_7"
    elseif ammo_needed == 6 then
        anim_name = "reload_6"
    elseif ammo_needed == 5 then
        anim_name = "reload_5"
    elseif ammo_needed == 4 then
        anim_name = "reload_4"
    elseif ammo_needed == 3 then
        anim_name = "reload_3"
    elseif ammo_needed == 2 then
        anim_name = "reload_2"
    elseif ammo_needed == 1 then
        anim_name = "reload_1"
    else
        anim_name = "gun_check"
    end

    -- Get timing from script params or fallback defaults
    local feed = (param[anim_name .. "_feed"] or 1.0) * 1000
    local cooldown = (param[anim_name .. "_cooldown"] or 2.0) * 1000

    if (reload_time < feed) then
        return EMPTY_RELOAD_FEEDING, feed - reload_time
    elseif (reload_time < cooldown) then
        if not cache.reloaded then
            local amount = api:getNeededAmmoAmount()
            if api:isReloadingNeedConsumeAmmo() then
                api:putAmmoInMagazine(api:consumeAmmoFromPlayer(amount))
            else
                api:putAmmoInMagazine(amount)
            end

            if cache.is_empty then
                api:setAmmoInBarrel(true)
            end

            cache.reloaded = true
            api:cacheScriptData(cache)
        end
        return EMPTY_RELOAD_FINISHING, cooldown - reload_time
    else
        return NOT_RELOADING, -1
    end
end

return M
