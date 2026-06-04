-- Test ITG modstring parser
-- Syntax: parseITGModstring(modStr, startStep?, player?, field?)

function onCreatePost()
    addModifier("transform")
    addModifier("rotate")
    addModifier("scale")
    addModifier("drunk")
    addModifier("tipsy")
    addModifier("confusion")
    addModifier("bumpy")
    addModifier("invert")

    -- 100% drunk over 2 seconds (level=1, speed=0.5 → 1/0.5*1000=2000ms)
    parseITGModstring("*0.5 1 drunk", 0, -1)

    -- 50% tipsy over 4 seconds
    parseITGModstring("*0.25 50% tipsy", 32, -1)

    -- Invert over 8 seconds
    parseITGModstring("*0.125 1 invert", 64, -1)

    -- Disable drunk over 2 seconds
    parseITGModstring("*0.5 no drunk", 96, -1)

    -- Confusion 360 over 16 seconds
    parseITGModstring("*0.0625 360 confusion", 128, -1)

    -- Multi-mod at once
    parseITGModstring("*0.25 1 invert, *0.25 50% tipsy", 256, -1)

    -- xmod / cmod shortcuts (x1 = xmod 1, c3.2 = cmod 3.2)
    parseITGModstring("*-1 x2", 320, -1)
    parseITGModstring("*0.5 x1", 384, -1)

    -- Reset all
    parseITGModstring("*0.25 no drunk, *0.25 no tipsy, *0.25 0 confusion", 496, -1)
end
