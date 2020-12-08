local blind = require('lush.hsl.color_blind')
local convert = require('lush.hsl.convert')

M = {}

M.contrast = function(amount)
  -- clamp to [0, 100] -> [0.0, 1.0]
  amount = math.max(0,math.min(amount, 100)) / 100

  return function(color)
    -- no adjustment
    if color.l == 50 then return color end

    -- find direction (up, over 50 or down, under 50)
    local adjusted_l
    if color.l > 50 then
      adjusted_l = color.l + ((100 - color.l) * amount)
    end

    if color.l < 50 then
      adjusted_l = color.l - (color.l * amount)
    end

    return color.lightness(adjusted_l)
  end
end

local make_blind_fn = function(type_name)
  return function(hsl_color)
    -- to avoid circular dependency, we use the given
    -- hsl_color object to generate the new objects of
    -- the right type.
    local rgb_color = convert.hsl_to_rgb(hsl_color)
    local blind_rgb = blind[type_name](rgb_color)
    local blind_hsl = convert.rgb_to_hsl(blind_rgb)
    return hsl_color.hue(blind_hsl.h)
                    .saturation(blind_hsl.s)
                    .lightness(blind_hsl.l)
  end
end

M.protanopia = function()
  return make_blind_fn('protanopia')
end

M.protanomaly = function()
  return make_blind_fn('protanomaly')
end

M.deuteranopia = function()
  return make_blind_fn('deuteranopia')
end

M.deuteranomaly = function()
  return make_blind_fn('deuteranomaly')
end

M.tritanopia = function()
  return make_blind_fn('tritanopia')
end

M.tritanomaly = function()
  return make_blind_fn('tritanomaly')
end

M.achromatopsia = function()
  return make_blind_fn('achromatopsia')
end

M.achromatomaly = function()
  return make_blind_fn('achromatomaly')
end

return M
