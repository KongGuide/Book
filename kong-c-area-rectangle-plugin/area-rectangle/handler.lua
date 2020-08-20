local BasePlugin = require "kong.plugins.base_plugin"
local ffi = require 'ffi'
local C = ffi.load('area_rectangle_func')
ffi.cdef[[
float area_rectangle(float x,float y);
]]

local plugin = BasePlugin:extend()
plugin.PRIORITY = 1000

function plugin:new()
  plugin.super.new(self, "kong.plugins.area_rectangle")
end

function plugin:access()
  plugin.super.access(self)
  local x = tonumber(kong.request.get_query_arg("x"))
  local y = tonumber(kong.request.get_query_arg("y"))
  return kong.response.exit(200, "Area of a rectangle Calculator:" .. C.area_rectangle(x,y))
end

return plugin
