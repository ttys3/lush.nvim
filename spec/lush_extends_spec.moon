describe "lush", ->
  lush = require('lush')

  it "should pass to parse(spec, {extends: ...})", ->
    parent = lush(-> {
      A { fg: "a_fg" }
    })

    child = lush((-> {
      B { A }
    }), {extends: {parent}})

    assert.is_equal(child.B.fg, parent.A.fg)

  it "extends(parent).with(spec)", ->
    parent = lush(-> {
      A { fg: "a_fg" }
    })

    child = lush.extend(parent).with(-> { B { A } })
    assert.is_equal(child.B.fg, parent.A.fg)

  it "can chain extends", ->
    parent = lush(-> {
      A { fg: "a_fg" }
    })
    other = lush(-> {
      C { fg: "c_fg" }
    })

    child = lush.extend(parent).extend(other).with(-> { B { A } })
    assert.is_equal(child.B.fg, parent.A.fg)
    assert.is_equal(child.C.fg, other.C.fg)

  it "accepts any number of parents", ->
    parent = lush(-> {
      A { fg: "a_fg" }
    })
    other = lush(-> {
      C { fg: "c_fg" }
    })

    child = lush.extend(parent, other).with(-> { B { A } })
    assert.is_equal(child.B.fg, parent.A.fg)
    assert.is_equal(child.C.fg, other.C.fg)

    child = lush.extend(unpack({parent, other})).with(-> { B { A } })
    assert.is_equal(child.B.fg, parent.A.fg)
    assert.is_equal(child.C.fg, other.C.fg)