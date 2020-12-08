-- Lua code derived from,
--
-- http://web.archive.org/web/20090318054431/http://www.nofunc.com/Color_Blindness_Library
-- 
-- The Color Blind Simulation function is copyright (c) 2000-2001
-- by Matthew Wickline and the Human-Computer Interaction Resource Network
-- (http://hcirn.com/).
-- 
-- It is used with the permission of Matthew Wickline and HCIRN, and is freely
-- available for non-commercial use. For commercial use, please contact the
-- Human-Computer Interaction Resource Network ( http://hcirn.com/ ).

-- float_rgb => rgb over 0.0 -> 1.0 (vs 255 in the rest of hsl)
local float_rgb_to_xyz = function(rgb)
  local xyz = {}
  xyz.x = (0.430574 * rgb.r + 0.341550 * rgb.g + 0.178325 * rgb.b)
  xyz.y = (0.222015 * rgb.r + 0.706655 * rgb.g + 0.071330 * rgb.b)
  xyz.z = (0.020183 * rgb.r + 0.129553 * rgb.g + 0.939180 * rgb.b)
  return xyz
end

local xyz_to_float_rgb = function(xyz)
  local rgb = {}
  rgb.r =  (3.063218 * xyz.x - 1.393325 * xyz.y - 0.475802 * xyz.z)
  rgb.g = (-0.969243 * xyz.x + 1.875966 * xyz.y + 0.041555 * xyz.z)
  rgb.b =  (0.067871 * xyz.x - 0.228834 * xyz.y + 1.069251 * xyz.z)
  return rgb
end

local tans = {
  protan = {
      cpu = 0.735,
      cpv = 0.265,
      am = 1.273463,
      ayi = -0.073894
  },
  deutan = {
      cpu = 1.14,
      cpv = -0.14,
      am = 0.968437,
      ayi = 0.003331
  },
  tritan = {
      cpu = 0.171,
      cpv = -0.003,
      am = 0.062921,
      ayi = 0.292119
  }
}

local monochrome = function(rgb)
  local x = rgb.r * 0.299 + rgb.g * 0.587 + rgb.b * 0.114
  local z = math.floor(x + 0.5)
  return {
    r = z,
    b = z,
    g = z
  }
end

local anomylize = function(rgb_a, rgb_b)
  local v = 1.75
  local d = v * 1 + 1
  local rgb =  {
    r = (v * rgb_b.r + rgb_a.r * 1) / d,
    g = (v * rgb_b.g + rgb_a.g * 1) / d,
    b = (v * rgb_b.b + rgb_a.b * 1) / d,
  }
  rgb.r = math.floor(rgb.r + 0.5)
  rgb.g = math.floor(rgb.g + 0.5)
  rgb.b = math.floor(rgb.b + 0.5)

  return rgb
end

-- rgb -> hsl rgb over 255
-- some if this is ... very black box ...
local rgb_to_blind_rgb = function(rgb, type)
  local wx, wy, wz, gamma
  gamma = 2.2
  wx = 0.312713
  wy = 0.329016
  wz = 0.358271

  local float_rgb = {
    r = math.pow(rgb.r / 255, gamma),
    g = math.pow(rgb.g / 255, gamma),
    b = math.pow(rgb.b / 255, gamma)
  }
  local c = float_rgb_to_xyz(float_rgb)

  local sum_xyz = c.x + c.y + c.z
  c.u = 0
  c.v = 0

  if sum_xyz ~= 0 then
    c.u = c.x / sum_xyz
    c.v = c.y / sum_xyz
  end

  local nx, nz, clm, clyi
  nx = wx * c.y / wy
  nz = wz * c.y / wy
  d = {}
  s = {}
  d.y = 0

  if c.u < type.cpu then
    clm = (type.cpv - c.v) / (type.cpu - c.u)
  else
    clm = (c.v - type.cpv) / (c.u - type.cpu)
  end

  clyi = c.v - c.u * clm
  d.u = (type.ayi - clyi) / (clm - type.am)
  d.v = (clm * d.u) + clyi

  s.x = d.u * c.y / d.v
  s.y = c.y
  s.z = (1 - (d.u + d.v)) * c.y / d.v

  d.x = nx - s.x
  d.z = nz - s.z

  s = xyz_to_float_rgb(s)
  d = xyz_to_float_rgb(d)

  local adjr, adjg, adjb
  local adjf = function(key)
    if d[key] ~= 0 then
      if s[key] < 0 then
        return (0 - s[key]) / d[key]
      else
        return (1 - s[key]) / d[key]
      end
    else
      return 0
    end
  end
  adjr = adjf('r')
  adjg = adjf('g')
  adjb = adjf('b')

  local adjustf = function(val)
    return (val > 1 or val < 0) and 0 or val
  end
  local adjust = math.max(adjustf(adjr),
                          adjustf(adjg),
                          adjustf(adjb))

  s.r = s.r + (adjust * d.r)
  s.g = s.g + (adjust * d.g)
  s.b = s.b + (adjust * d.b)

  local z = function(v)
    if v <= 0 then
      v = 0
    else
      if v >= 1 then
        v = 1
      else
        v = math.pow(v, 1 / gamma)
      end
    end
    return math.floor((255 * v) + 0.5)
  end

  return {
    r = z(s.r),
    g = z(s.g),
    b = z(s.b)
  }
end

local blind = {
  protanopia = function(rgb)
    return rgb_to_blind_rgb(rgb, tans.protan)
  end,
  protanomaly = function(rgb)
    return anomylize(rgb, rgb_to_blind_rgb(rgb, tans.protan))
  end,
  deuteranopia = function(rgb)
    return rgb_to_blind_rgb(rgb, tans.deutan)
  end,
  deuteranomaly = function(rgb)
    return anomylize(rgb, rgb_to_blind_rgb(rgb, tans.deutan))
  end,
  tritanopia = function(rgb)
    return rgb_to_blind_rgb(rgb, tans.tritan)
  end,
  tritanomaly = function(rgb)
    return anomylize(rgb, rgb_to_blind_rgb(rgb, tans.tritan))
  end,
  achromatopsia = function(rgb)
    return monochrome(rgb)
  end,
  achromatomaly = function(rgb)
    return anomylize(rgb,monochrome(rgb))
  end
}

return blind

