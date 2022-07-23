require("corvette_lib/ui")
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
do local jump_key = input.find_key_bound_to_binding("jump")
---@param s entity_t
---@return "stand"|"walk"|"move"|"air"|"c-air"|"crouch"|"fakeduck"|nil
lua_entity_t.get_movement_type = function(s)
    local velocity = s:get_velocity()
    local crouching = s:is_crouching()
    if s:is_in_air() and crouching then
        return "c-air" end
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