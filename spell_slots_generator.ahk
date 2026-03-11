/*
BG3 Spell Slot Generator Macro
Author: Ismael Garcia Moreno

- UI scale must be 1.0
- Game should be in Borderless Window

HOTKEYS:

- F9: Starts the full macro
- F10: Manually starts the "Create Spell Slot/Sorcery Point" loop n times
- F12: Reloads the script
*/

#Requires AutoHotkey v2.0
TraySetIcon A_ScriptDir "./assets/bg3ssico.ico"
SendMode "Event"
CoordMode "Mouse", "Window"

baseW := 2560
baseH := 1440
scaleX := 0
scaleY := 0
sorcery_points := 0
spell_slots := 0
total_spell_slots := 0
break_loop := false
level := 0
potions := 0
amount_high := 0
levels := Map()
levels[3] := 60
levels[4] := 130
levels[5] := 190
levels[6] := 260

F9:: {
    global start_x, start_y
    MouseGetPos &start_x, &start_y
    GetScale()

    Inputs()
    Sleep 100

    start := A_TickCount
    ExecuteLoop()
    ElapsedTime(start)
}

F10:: {
    global start_x, start_y
    MouseGetPos &start_x, &start_y
    GetScale()

    n := InputBox("Introducir número de repeticiones:", "BG3 Macro")
    if (n.Result = "Cancel") {
        return
    }
    Sleep 100

    SpellLoop(n.Value)
}

GetScale() {
    global gameW, gameH, scaleX, scaleY, baseW, baseH
    WinGetClientPos(, , &gameW, &gameH, "A")
    scaleX := gameW / baseW
    scaleY := gameH / baseH
}

SX(x) {
    global scaleX
    return Round(x * scaleX)
}

SY(y) {
    global scaleY
    return Round(y * scaleY)
}

ElapsedTime(start) {
    elapsed := A_TickCount - start
    minutes := Round(elapsed / 60000, 2)
    MsgBox(total_spell_slots " level 2 spell slots created in " minutes " minutes")
}

Inputs() {
    global spell_slots, total_spell_slots, sorcery_points, level, potions, amount_high

    ss := InputBox("Enter the amount of initial Level 2 Spell Slots:", "Spell slots generator", , 3)
    if (ss.Result = "Cancel") {
        return
    }

    sp := InputBox("Enter the amount of initial Sorcery Points:", "Spell slots generator", , 4)
    if (sp.Result = "Cancel") {
        return
    }

    lvl := InputBox("Enter the objective spell slot level:", "Spell slots generator", , 4)
    if (lvl.Result = "Cancel") {
        return
    }

    pt := InputBox("Enter the amount of potions to use (3 of them will make 99 lvl 2 spell slots in 18 minutes):",
        "Spell slots generator", , 3)
    if (pt.Result = "Cancel") {
        return
    }

    high := InputBox("Enter the desired amount of high lvl slots:", "Spell slots generator", , 15)
    if (high.Result = "Cancel") {
        return
    }

    spell_slots := Integer(ss.Value)
    sorcery_points := Integer(sp.Value)
    total_spell_slots := spell_slots
    level := Integer(lvl.Value)
    potions := Integer(pt.Value)
    amount_high := Integer(high.Value)
}

ExecuteLoop() {
    global sorcery_points, break_loop

    break_loop := false
    loop {
        if break_loop {
            break
        }

        SlotsToSP()
        if sorcery_points >= 3 {
            SPToSlots()
        }
    }
}

SpellLoop(n, x := start_x, y := start_y) {
    MouseMove x, y, 0
    Sleep 180

    loop n {
        SendEvent "{Click}"
        Sleep 600

        SendEvent "{Click}"
        Sleep 180

        MouseMove 0, SY(-300), 0, "R"
        Sleep 300

        SendEvent "{Click}"
        Sleep 300

        MouseMove x, y, 0
        Sleep 2500
    }
}

SlotsToSP() {
    global sorcery_points, spell_slots, break_loop, potions
    if spell_slots == 0 {
        UsePotion()
        if potions == 0 {
            Transform()
            break_loop := true
            return
        }
    }
    SpellLoop(spell_slots)
    sorcery_points += spell_slots * 2
    spell_slots := 0
}

SPToSlots() {
    global sorcery_points, spell_slots, total_spell_slots
    SwitchButtons()
    SpellLoop(sorcery_points // 3)
    spell_slots := sorcery_points // 3
    total_spell_slots += spell_slots
    sorcery_points := Mod(sorcery_points, 3)
    SwitchButtons()
}

Transform() {
    global level, total_spell_slots, amount_high
    SpellLoop(total_spell_slots - 15)
    SwitchLevel()
    SpellLoop(amount_high, start_x + SX(levels[level]))
}

SwitchButtons(x := start_x, y := start_y) {
    MouseMove x - SX(50), y
    Sleep 80
    Click "Down"
    MouseMove x, y
    Sleep 80
    Click "Up"
    Sleep 300
}

SwitchLevel(x := start_x, y := start_y) {
    global level
    MouseMove x - SX(50), y
    Click "Down"
    MouseMove x + SX(levels[level]), y
    Sleep 50
    Click "Up"
    Sleep 300
}

UsePotion(x := start_x, y := start_y) {
    global spell_slots, total_spell_slots, potions
    MouseMove x + SX(60), y
    Sleep 100
    SendEvent "{Click}"
    Sleep 50
    MouseMove x, y
    potions -= 1
    spell_slots := total_spell_slots
    Sleep 15500
}

F12:: Reload