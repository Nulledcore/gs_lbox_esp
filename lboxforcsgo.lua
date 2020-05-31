local surface = require('gamesense/surface')
local tf2font = surface.create_font("TF2 Build", 12, 400, 0x200)


ui.new_label("lua", "b", "----------------LMAOBOX.ESP----------------")
local boxtypes = {"Off","Solid", "Outlined"}
local positions = {"Right", "Bottom"}
local enable_lbox_esp = ui.new_checkbox("lua", "b", "Enable")
local lbox_esp_type = ui.new_combobox("lua", "b", "Box type", boxtypes)
local lbox_position = ui.new_combobox("lua", "b", "Position", positions)
local lbox_chams = ui.new_checkbox("lua", "b", "Team chams")
local lbox_glow = ui.new_checkbox("lua", "b", "Team glow")

ui.new_label("lua", "b", "-------------------COLORS-------------------")
ui.new_label("lua", "b", "T Color")
local tclr = ui.new_color_picker("lua", "b", "tclrs", 255,104,104, 255)
ui.new_label("lua", "b", "T XQZ Color")
local tclr_xqz = ui.new_color_picker("lua", "b", "tclr_xqz", 255,104,104, 255)
ui.new_label("lua", "b", "CT Color")
local ctclr = ui.new_color_picker("lua", "b", "ctclrs", 113,175,255, 255, 255)
ui.new_label("lua", "b", "CT XQZ Color")
local ctclr_xqz = ui.new_color_picker("lua", "b", "ctclr_xqz", 113,175,255, 255, 255)
ui.new_label("lua", "b", "------------------------------------------------")

local function get_distance_in_feet(a_x, a_y, a_z, b_x, b_y, b_z)
    return math.ceil(math.sqrt(math.pow(a_x - b_x, 2) + math.pow(a_y - b_y, 2) + math.pow(a_z - b_z, 2)) * 0.0254 / 0.3048)
end

local pos = {}
local teams = {
	[0] = "None",
	[1] = "Spec",
	[2] = "T",
	[3] = "CT",
}

local function HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        elseif i == 5 then r, g, b = v, p, q
    end
  
    return r * 255, g * 255, b * 255
end

local function lerp(h1, s1, v1, h2, s2, v2, t)
    local h = (h2 - h1) * t + h1
    local s = (s2 - s1) * t + s1
    local v = (v2 - v1) * t + v1
    return h, s, v
end

local _, chams_color = ui.reference("Visuals", "Colored models", "Player")
local _, chams_xqz_color = ui.reference("Visuals", "Colored models", "Player behind wall")
local _, shadow_color = ui.reference("Visuals", "Colored models", "Shadow")
local _, glow_color = ui.reference("Visuals", "Player esp", "Glow")

client.set_event_callback("paint", function()
    if not ui.get(enable_lbox_esp) then return end
    local enemy_players = entity.get_players(not enemies_only)
    for i=1,#enemy_players do
        local enemy = enemy_players[i]
        local health = entity.get_prop(enemy, "m_iHealth")
        local h, s, v = lerp(0, 1, 1, 120, 1, 1, health*0.01)
        local hr, hg, hb = HSVToRGB(h/360, s, v)
        if entity.get_prop(enemy, "m_iTeamNum") == 2 then
            r,g,b,a = ui.get(tclr)
            if ui.get(lbox_chams) then
                ui.set(chams_color, r,g,b,a)
                ui.set(chams_xqz_color, ui.get(tclr_xqz))
                ui.set(shadow_color, r,g,b,a)
            end
            if ui.get(lbox_glow) then
                ui.set(glow_color, r,g,b,185)
            end
        elseif entity.get_prop(enemy, "m_iTeamNum") == 3 then
            r,g,b,a = ui.get(ctclr)
            if ui.get(lbox_chams) then
                ui.set(chams_color, r,g,b,a)
                ui.set(chams_xqz_color, ui.get(ctclr_xqz))
                ui.set(shadow_color, r,g,b,a)
            end
            if ui.get(lbox_glow) then
                ui.set(glow_color, r,g,b,185)
            end
        else
            r,g,b,a = 241, 196, 15
            if ui.get(lbox_chams) then
                ui.set(chams_color, r,g,b,a)
                ui.set(chams_xqz_color, r,g,b,a)
                ui.set(shadow_color, r,g,b,a)
            end
            if ui.get(lbox_glow) then
                ui.set(glow_color, r,g,b,185)
            end
        end

        local x1, y1, x2, y2, mult = entity.get_bounding_box(enemy)
        if x1 == nil and y1 == nil then
            return
        end
        local bb_height = y2 - y1
        local bb_width = x2 - x1
        if ui.get(lbox_esp_type) == boxtypes[1] then
        elseif ui.get(lbox_esp_type) == boxtypes[2] then
            renderer.rectangle(x1, y1, 3, bb_height, r, g, b, a)
            renderer.rectangle(x2, y1, 3, bb_height, r, g, b, a)
            renderer.rectangle(x1, y1, bb_width, 3, r, g, b, a)
            renderer.rectangle(x1, y2, bb_width+3, 3, r, g, b, a)
        elseif ui.get(lbox_esp_type) == boxtypes[3] then
            --box
            renderer.rectangle(x1, y1, bb_width, 3, r, g, b, a)
            renderer.rectangle(x1, y2, bb_width+3, 3, r, g, b, a)
            renderer.rectangle(x1, y1, 3, bb_height, r, g, b, a)
            renderer.rectangle(x2, y1, 3, bb_height, r, g, b, a)

            --outer
            renderer.rectangle(x1, y2+3, bb_width+3, 1, 17, 17, 17, 255)
            renderer.rectangle(x1, y1, 1, bb_height+3, 17, 17, 17, 255)
            renderer.rectangle(x2+3, y1, 1, bb_height+3, 17, 17, 17, 255)
            renderer.rectangle(x1, y1, bb_width+3, 1, 17, 17, 17, 255)

            --inner
            renderer.rectangle(x1+3, y2, bb_width-2, 1, 17, 17, 17, 255)
            renderer.rectangle(x2, y1+3, 1, bb_height-2, 17, 17, 17, 255)
            renderer.rectangle(x1+3, y1+3, bb_width-2, 1, 17, 17, 17, 255)
            renderer.rectangle(x1+3, y1+3, 1, bb_height-2, 17, 17, 17, 255)
        end

        
        local ui_positions = ui.get(lbox_position)
        if ui_positions == positions[1] then
            pos = {x2+6,y1}
        elseif ui_positions == positions[2] then
            pos = {x1,y2+5}
        end


        surface.draw_text(pos[1], pos[2], r, g, b, a, tf2font, entity.get_player_name(enemy))

        local epx, epy, epz = entity.get_prop(enemy, "m_vecOrigin")
        local lpx, lpy, lpz = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
        local distance = get_distance_in_feet(lpx, lpy, lpz, epx, epy, epz)
        surface.draw_text(pos[1], pos[2]+12, r, g, b, a, tf2font, string.format("[%sf]", math.floor(distance)))

        local team = teams[entity.get_prop(enemy, "m_iTeamNum")]
        surface.draw_text(pos[1], pos[2]+24, r, g, b, a, tf2font, team)

        surface.draw_text(pos[1], pos[2]+36, hr, hg, hb, a, tf2font, string.format("%s/100 HP", health))
        renderer.rectangle(x1-6, y1, 4, bb_height+4.5, 17, 17, 17, a)
        renderer.rectangle(x1-5, y2+2, 2, (-bb_height*health/100), hr, hg, hb, a)

        local weapon = entity.get_player_weapon(enemy)
        local cname = entity.get_classname(weapon)
        surface.draw_text(pos[1], pos[2]+48, r, g, b, a, tf2font, cname)
    end
end)