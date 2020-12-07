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

return M
