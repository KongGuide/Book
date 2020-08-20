local balancer = require "kong.runloop.balancer"
local phase_checker = require "kong.pdk.private.phases"
local check_phase = phase_checker.check
local PHASES = phase_checker.phases

local function new(self)
    local upstream = {}
    
    -- Get upstream balancer health获取负载平衡器中上游节点的整体健康状况
    --
    -- @function kong.upstream.get_balancer_health
    -- @phases access
    -- @tparam string upstream_name
    -- @treturn health_info|nil `health_info` on success, or `nil` if no health_info entities where found
    -- @treturn string|nil An error message describing the error if there was one.
    --
    -- @usage 用法
    -- local ok, err = kong.upstream.get_balancer_health("upstream_name")
    -- if not ok then
    --   kong.log.err(err)
    --   return
    -- end
    
    function upstream.get_balancer_health(upstream_name)
        check_phase(PHASES.access)
        --upstream_name必须为字符串
        if type(upstream_name) ~= "string" then
            error("upstream_name must be a string", 2)
        end
        --根据upstream_name从缓存中返回upstream对象信息
        local upstream = balancer.get_upstream_by_name(upstream_name)
        if not upstream then
            return nil, "could not find an Upstream named '" .. upstream_name .. "'"
        end
        --根据upstream.id取得负载平衡器中上游节点的整体健康状况
        local health_info, err = balancer.get_balancer_health(upstream.id)
        
        if err then
            return nil, "failed getting upstream health '" .. upstream_name .. "'"
        end
        
        return health_info
    end
    return upstream
end

return {
    new = new,
}
