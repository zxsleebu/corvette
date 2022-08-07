require("corvette_lib/ui")
require("corvette_lib/bit")
ffi.cdef([[
    typedef struct{ float x; float y; float z; } Vector_t;
    typedef struct{ float x; float y; } Vector2_t;
    typedef struct {
    	Vector_t vecPosAnim;
    	Vector_t vecPosAnimLast;
    	Vector_t vecPosPlant;
    	Vector_t vecPlantVel;
    	float flLockAmount;
    	float flLastPlantTime;
    } procedural_foot_t;
    typedef struct{
    	bool		bInitialized;
    	int			nIndex;
    	const char* szName;
    } AnimstatePose_t;
    typedef struct{
        char pad0[0x78];
        float flEyeYaw;
        float flPitch;
        float flGoalFeetYaw;
        float flCurrentFeetYaw;
        float flCurrentTorsoYaw;
        float flUnknownVelocityLean;
        float flLeanAmount;
        char pad2[4];
        float flFeetCycle;
        float flFeetYawRate;
        char pad3[4];
        float fDuckAmount;
        float fLandingDuckAdditive;
        char pad4[4];
        Vector_t vOrigin;
        Vector_t vLastOrigin;
        Vector2_t vVelocity;
        char pad5[4];
        float flUnknownFloat1;
        char pad6[8];
        float flUnknownFloat2;
        float flUnknownFloat3;
        float flUnknown;
        float flSpeed2D;
        float flUpVelocity;
        float flSpeedNormalized;
        float flFeetSpeedForwardsOrSideWays;
        float flFeetSpeedUnknownForwardOrSideways;
        float flTimeSinceStartedMoving;
        float flTimeSinceStoppedMoving;
        bool bOnGround;
        bool bInHitGroundAnimation;
        float flJumpToFall;
        float flDurationInAir;
        float flLeftGroundHeight;
        float flLandAnimMultiplier;
        float flWalkToRunTransition;
        bool bLandedOnGroundThisFrame;
        bool bLeftTheGroundThisFrame;
        float flInAirSmoothValue;
        bool bOnLadder;
        float flLadderWeight;
        float flLadderSpeed;
        bool bWalkToRunTransitionState;
        bool bDefuseStarted;
        bool bPlantAnimStarted;
        bool bTwitchAnimStarted;
        bool bAdjustStarted;
        char ActivityModifiers[20];
        float flNextTwitchTime;
        float flTimeOfLastKnownInjury;
        float flLastVelocityTestTime;
        Vector_t vecVelocityLast;
        Vector_t vecTargetAcceleration;
        Vector_t vecAcceleration;
        float flAccelerationWeight;
        float flAimMatrixTransition;
        float flAimMatrixTransitionDelay;
        bool bFlashed;
        float flStrafeChangeWeight;
        float flStrafeChangeTargetWeight;
        float flStrafeChangeCycle;
        int	nStrafeSequence;
        bool bStrafeChanging;
        float flDurationStrafing;
        float flFootLerp;
        bool bFeetCrossed;
        bool bPlayerIsAccelerating;
        AnimstatePose_t	tPoseParamMappings[20];
        float flDurationMoveWeightIsTooHigh;
        float flStaticApproachSpeed;
        int nPreviousMoveState;
        float flStutterStep;
        float flActionWeightBiasRemainder;
        procedural_foot_t footLeft;
        procedural_foot_t footRight;
        float flCameraSmoothHeight;
        bool bSmoothHeightValid;
        float flLastTimeVelocityOverTen;
        float flAimYawMin;
        float flAimYawMax;
        float flAimPitchMin;
        float flAimPitchMax;
        int	 nAnimstateModelVersion;
    } c_animstate_t;
]])

---@param s entity_t
---@param vector boolean|nil
---@return vec3_t|number
lua_entity_t.get_velocity = function(s, vector)
    local velocity = s:get_prop("m_vecVelocity") ---@type vec3_t
    if vector then
        return velocity end
    return velocity:length()
end
---@param s entity_t
---@return boolean
lua_entity_t.is_crouching = function(s)
    return s:get_prop("m_flDuckAmount") > 0.33
end
---@param s entity_t
---@return boolean
lua_entity_t.is_in_air = function(s)
    return bit.band(s:get_prop("m_fFlags"), 1) ~= 1
end
do
local player = ffi.cast("int*", memory.find_pattern("client.dll", "55 8B EC 83 E4 F8 83 EC 18 56 57 8B F9 89 7C 24 0C") + 0x47)[0]
local get_abs_origin = ffi.cast("float*(__thiscall*)(int)", ffi.cast("int*", player + 0x28)[0])
---@param s entity_t
---@return vec3_t
lua_entity_t.get_abs_origin = function(s)
    local address = s:get_address()
    local origin = get_abs_origin(address)
    origin = vec3_t(origin[0], origin[1], origin[2])
    return origin and origin or s:get_render_origin()
end
end
do local jump_key = input.find_key_bound_to_binding("jump") ---@type e_keys
---@param s entity_t
---@return "stand"|"walk"|"move"|"air"|"crouch"|"fakeduck"|nil
lua_entity_t.get_movement_type = function(s)
    local velocity = s:get_velocity()
    local crouching = s:is_crouching()
    if s:is_in_air() then
        return "air" end
    if s == entity_list.get_local_player() then
        if input.is_key_held(jump_key) then
            return "air" end
        if ui.antiaim.main.general.fake_duck:get() then
            return "fakeduck" end
        if ui.misc.main.movement.slow_walk:get()
            and velocity > 3
            and not crouching then
            return "walk" end
    end
    if crouching then
        return "crouch" end
    if velocity < 3 then
        return "stand" end
    if velocity > 3 then
        return "move" end
end end
---@param s entity_t
---@return ffi.ctype*|nil
lua_entity_t.get_animstate = function(s)
    local ptr = s:get_address()
    if not ptr then return end
    return ffi.cast("c_animstate_t**", ptr + 0x9960)[0]
end
---@param s entity_t
---@return vec3_t[]
lua_entity_t.get_skeleton = function(s)
    local skel = {}
    for i = 0, 18 do
        skel[#skel+1] = s:get_hitbox_pos(i) end
    return skel
end
do
local lag_records = {}
local get_lerp_time = function()
    local upd_rate = cvars.cl_updaterate:get_int()
    local min_upd_rate = cvars.sv_minupdaterate
    local max_upd_rate = cvars.sv_maxupdaterate
    if min_upd_rate and max_upd_rate then
        upd_rate = max_upd_rate:get_int() end
    local ratio = cvars.cl_interp_ratio:get_float()
    if ratio == 0 then
        ratio = 1 end
    local lerp = cvars.cl_interp:get_float()
    local c_min_ratio = cvars.sv_client_min_interp_ratio
    local c_max_ratio = cvars.sv_client_max_interp_ratio
    if c_min_ratio and c_max_ratio and c_min_ratio:get_float() ~= 1 then
        ratio = clamp(ratio, c_min_ratio:get_float(), c_max_ratio:get_float()) end
    return math.max(lerp, (ratio / upd_rate))
end
local is_tick_valid = function(tick)
    local sv_maxunlag = cvars.sv_maxunlag:get_float()
    local outgoing_latency = engine.get_latency(e_latency_flows.OUTGOING)
    local correct = clamp(outgoing_latency + get_lerp_time(), 0, sv_maxunlag)
    local delta = correct - (global_vars.cur_time() - engine.tick_to_time(tick))
    return math.abs(delta) < 0.2
end
---@param s entity_t
---@return nil
lua_entity_t.save_lagrecord = function(s)
    local uid = s:get_steamids()
    if not uid then return end
    if not lag_records[uid] then
        lag_records[uid] = {} end
    local records = lag_records[uid]
    lag_records[uid][#records+1] = {
        skeleton = s:get_skeleton(),
        velocity = s:get_velocity(true),
        origin = s:get_abs_origin(),
        tick = engine.time_to_ticks(s:get_prop("m_flSimulationTime")),
    }
    records = lag_records[uid]
    for i = 1, #records do
        if records[i] then
            if not is_tick_valid(records[i].tick) then
                table.remove(lag_records[uid], i) end
        end
    end
end
---@param s entity_t
---@return table|nil
lua_entity_t.get_lagrecords = function(s)
    local uid = s:get_steamids()
    if not uid then return end
    return lag_records[uid]
end
end
callbacks.add(e_callbacks.NET_UPDATE, function()
    local lp = entity_list.get_local_player()
    if not lp or not lp:is_alive() then return end
    lp:save_lagrecord()
end)

do
    ffi.cdef[[
        typedef struct {
            uint64_t unknown;
            union {
                uint64_t steamID64;
                struct{
                    uint32_t xuid_low;
                    uint32_t xuid_high;
                };
            };
            char            szName[128];      
            int             userId;          
            char            szSteamID[20];    
            char            pad_0x00A8[0x10];  
            unsigned long   iSteamID;           
            char            szFriendsName[128];
            bool            fakeplayer;
            bool            ishltv;
            unsigned int    customfiles[4];
            unsigned char   filesdownloaded;
        } player_info_t;
    ]]
    local get_player_info = IEngine:get_vfunc("bool(__thiscall*)(void*, int, player_info_t*)", 8)
    ---@param s entity_t
    ---@return {userid: number}|nil
    lua_entity_t.get_info = function(s)
        local info = ffi.new("player_info_t")
        if get_player_info(s:get_index(), info) then
            ---@diagnostic disable-next-line: undefined-field
            return {userid = info.userId}
        end
    end
end
-- entity_list.get_player_from_userid = function(user_id)
--     local players = entity_list.get_players()
--     for i = 1, #players do
--         local info = players[i]:get_info()
--         if info and info.userid == user_id then
--             return players[i] end
--     end
-- end