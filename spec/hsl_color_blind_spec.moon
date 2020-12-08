describe "color blind", ->
  cb = require("lush.hsl.color_blind")

  it "protanopia", ->
    c = cb.protanopia({r: 125, g: 100, b: 80})
    assert.same({r: 112, g: 105, b: 82}, c)

  it "protanomaly", ->
    c = cb.protanomaly({r: 125, g: 100, b: 80})
    assert.same({r: 117, g: 103, b: 81}, c)

  it "deuteranopia", ->
    c = cb.deuteranopia({r: 125, g: 100, b: 80})
    assert.same({r: 123, g: 101, b: 80}, c)

  it "deuteranomaly", ->
    c = cb.deuteranomaly({r: 125, g: 100, b: 80})
    assert.same({r: 124, g: 101, b: 80}, c)

  it "tritanopia", ->
    c = cb.tritanopia({r: 125, g: 100, b: 80})
    assert.same({r: 127, g: 97, b: 104}, c)

  it "tritanomaly", ->
    c = cb.tritanomaly({r: 125, g: 100, b: 80})
    assert.same({r: 126, g: 98, b: 95}, c)

  it "achromatopsia", ->
    c = cb.achromatopsia({r: 125, g: 100, b: 80})
    assert.same({r: 105, g: 105, b: 105}, c)

  it "achromatomaly", ->
    c = cb.achromatomaly({r: 125, g: 100, b: 80})
    assert.same({r: 112, g: 103, b: 96}, c)
