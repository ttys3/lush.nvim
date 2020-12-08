describe "adjust colors post parse", ->
  parser = require('lush.parser')
  hsl = require('lush.hsl')

  it "works", ->
    spec = -> {
      Normal { bg: hsl(0,50, 10), fg: hsl(0, 50, 55)}
    }
    opts = {
      after: {
        adjust_colors: {
          hsl.adjust.contrast(100)
        }
      }
    }
    parsed = parser(spec, opts)
    assert.not.nil(parsed)
    assert.equal(0, parsed.Normal.bg.l)
    assert.equal(100, parsed.Normal.fg.l)

  it "can chain", ->
    spec = -> {
      Normal { bg: hsl(0,50, 10), fg: hsl(0, 50, 55)}
    }
    opts = {
      after: {
        adjust_colors: {
          hsl.adjust.contrast(10),
          hsl.adjust.contrast(100)
        }
      }
    }
    parsed = parser(spec, opts)
    assert.not.nil(parsed)
    assert.equal(0, parsed.Normal.bg.l)
    assert.equal(100, parsed.Normal.fg.l)

  it "can colorblind", ->
    spec = -> {
      Normal { bg: hsl(0,50, 10), fg: hsl(0, 50, 55)}
    }
    opts = {
      after: {
        adjust_colors: {
          hsl.adjust.protanopia(),
        }
      }
    }
    parsed = parser(spec, opts)
    assert.not.nil(parsed)
    assert.equal(51, parsed.Normal.bg.h)
    assert.equal(18, parsed.Normal.bg.s)
    assert.equal(8, parsed.Normal.bg.l)

  it "can blind twice", ->
    spec = -> {
      Normal { bg: hsl(0,50, 10), fg: hsl(0, 50, 55)}
    }
    opts = {
      after: {
        adjust_colors: {
          hsl.adjust.achromatomaly(),
          hsl.adjust.tritanomaly(),
        }
      }
    }
    parsed = parser(spec, opts)
    assert.equal(354, parsed.Normal.bg.h)
    assert.equal(22, parsed.Normal.bg.s)
    assert.equal(9, parsed.Normal.bg.l)

  it "errors on non-functions", ->
    spec = -> {
      Normal { bg: hsl(0,50, 10), fg: hsl(0, 50, 55)}
    }
    opts = {
      after: {
        adjust_colors: {
          'haha',
          hsl.adjust.contrast(100)
        }
      }
    }
    e = assert.error(-> parser(spec, opts))
    assert.matches("adjust_colors_non_function", e.code)
    assert.not.matches("No message avaliable", e.msg)

