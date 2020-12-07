describe "hsl adjust contrast", ->
  hsl = require('lush.hsl')

  it "doesnt alter hue or saturation", ->
    over = hsl(0, 50, 51)
    over_c = hsl.adjust.contrast(100)(over)
    assert.equal(over.h, over_c.h)
    assert.equal(over.s, over_c.s)
    assert.not.equal(over.l, over_c.l)

  -- these should all cap at 0 or 100 lightness
  it "adjusts over 50", ->
    over = hsl(0, 50, 51)

    -- max out
    over_c = hsl.adjust.contrast(100)(over)
    assert.equal(100, over_c.l)

    -- no change
    over_c = hsl.adjust.contrast(0)(over)
    assert.equal(over.l, over_c.l)

    -- 50% increase, should add 50% more lightness
    over = hsl(0, 50, 75)
    over_c = hsl.adjust.contrast(50)(over)
    -- 75, amount over 50 => 25
    -- 50% of 25 => 12.5
    -- 75 + 12.5 => 87.5
    -- rounded up => 88
    assert.equal(88, over_c.l)

  it "adjusts under 50", ->
    -- max out
    under = hsl(0, 50, 49)
    under_c = hsl.adjust.contrast(100)(under)
    assert.equal(0, under_c.l)

    -- no change
    under = hsl(0, 50, 49)
    under_c = hsl.adjust.contrast(0)(under)
    assert.equal(under.l, under_c.l)

    -- 50% increase, should subtract 50% lightness
    over = hsl(0, 50, 25)
    over_c = hsl.adjust.contrast(50)(over)
    -- see 50+ for maths, technically should probably
    -- round down to 12 but doesn't seem worth the complication
    assert.equal(13, over_c.l)

  it "does not adjust at even 50", ->
    even = hsl(0, 50, 50)
    even_c = hsl.adjust.contrast(100)(even)
    assert.equal(50, even_c.l)
    even_c = hsl.adjust.contrast(0)(even)
    assert.equal(even.l, even_c.l)
    even_c = hsl.adjust.contrast(50)(even)
    assert.equal(even.l, even_c.l)
