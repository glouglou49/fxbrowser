local r = reaper
local ctx = r.ImGui_CreateContext('FX Browser & Tagger')
local font = r.ImGui_CreateFont('Segoe UI', 14)
local font_large = r.ImGui_CreateFont('Segoe UI', 18)
r.ImGui_Attach(ctx, font)
r.ImGui_Attach(ctx, font_large)

-- --- THEME STYLE REAPER ---
local function apply_modern_theme()
    -- Couleurs style REAPER (gris foncé neutre)
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_WindowBg(), 0x2D2D2DFF)          -- Fond fenêtre
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ChildBg(), 0x252525FF)            -- Fond enfant
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_PopupBg(), 0x2D2D2DFF)            -- Fond popup
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Border(), 0x4A4A4AFF)             -- Bordures
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_FrameBg(), 0x3A3A3AFF)            -- Fond input
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_FrameBgHovered(), 0x4A4A4AFF)     -- Fond input hover
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_FrameBgActive(), 0x5A5A5AFF)      -- Fond input actif
    
    -- Boutons
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Button(), 0x4A4A4AFF)             -- Bouton normal
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonHovered(), 0x5A5A5AFF)      -- Bouton hover
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonActive(), 0x6A6A6AFF)       -- Bouton click
    
    -- Headers
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Header(), 0x4A4A4AFF)
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_HeaderHovered(), 0x5A5A5AFF)
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_HeaderActive(), 0x6A6A6AFF)
    
    -- Texte
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Text(), 0xDDDDDDFF)               -- Texte principal
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_TextDisabled(), 0x808080FF)       -- Texte désactivé
    
    -- Titlebars
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_TitleBg(), 0x1E1E1EFF)
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_TitleBgActive(), 0x3A3A3AFF)
    
    -- Menu
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_MenuBarBg(), 0x2D2D2DFF)
    
    -- Separateurs
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Separator(), 0x4A4A4AFF)
    
    -- Scrollbar
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ScrollbarBg(), 0x252525FF)
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ScrollbarGrab(), 0x4A4A4AFF)
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ScrollbarGrabHovered(), 0x5A5A5AFF)
    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ScrollbarGrabActive(), 0x6A6A6AFF)
    
    -- Styles (arrondis, espacement)
    r.ImGui_PushStyleVar(ctx, r.ImGui_StyleVar_FrameRounding(), 4)
    r.ImGui_PushStyleVar(ctx, r.ImGui_StyleVar_WindowRounding(), 4)
    r.ImGui_PushStyleVar(ctx, r.ImGui_StyleVar_ChildRounding(), 4)
    r.ImGui_PushStyleVar(ctx, r.ImGui_StyleVar_ScrollbarRounding(), 4)
    r.ImGui_PushStyleVar(ctx, r.ImGui_StyleVar_FramePadding(), 6, 4)
    r.ImGui_PushStyleVar(ctx, r.ImGui_StyleVar_ItemSpacing(), 6, 4)
    r.ImGui_PushStyleVar(ctx, r.ImGui_StyleVar_WindowPadding(), 10, 10)
end

local function pop_modern_theme()
    r.ImGui_PopStyleVar(ctx, 7)
    r.ImGui_PopStyleColor(ctx, 23)
end

-- Génération de couleurs pseudo-aléatoires pour les tags (basée sur le nom du tag)
local tag_colors = {}
local function get_tag_color(tag_name)
    if tag_colors[tag_name] then
        return tag_colors[tag_name]
    end
    
    -- Générer une couleur basée sur le hash du nom
    local hash = 0
    for i = 1, #tag_name do
        hash = (hash * 31 + string.byte(tag_name, i)) % 360
    end
    
    -- Convertir HSV en RGB (couleurs foncées pour lisibilité du texte blanc)
    local h = hash / 360
    local s = 0.7    -- Saturation élevée
    local v = 0.55   -- Luminosité réduite pour que le texte blanc soit lisible
    
    local r_val, g_val, b_val
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    if i == 0 then r_val, g_val, b_val = v, t, p
    elseif i == 1 then r_val, g_val, b_val = q, v, p
    elseif i == 2 then r_val, g_val, b_val = p, v, t
    elseif i == 3 then r_val, g_val, b_val = p, q, v
    elseif i == 4 then r_val, g_val, b_val = t, p, v
    else r_val, g_val, b_val = v, p, q
    end
    
    -- Convertir en couleur ImGui (RGBA)
    local color = (math.floor(r_val * 255) << 24) + 
                  (math.floor(g_val * 255) << 16) + 
                  (math.floor(b_val * 255) << 8) + 0xFF
    
    tag_colors[tag_name] = color
    return color
end

-- --- CONFIGURATION ---
local script_path = debug.getinfo(1, "S").source:match("^@?(.*[/\\])") or ""
local db_file = script_path .. "fxbrowser_database.json"

-- --- VARIABLES GLOBALES ---
local db = {}
local search_text = ""
local scan_in_progress = false
local scan_message = ""
local selected_plugin_index = nil
local selected_effect_types = {}  -- Tags de type d'effet (eq, comp, reverb, etc.)
local selected_manufacturers = {} -- Tags d'éditeurs (waves, fabfilter, uad, etc.)

-- OPTIMISATION: Cache pour les filtres et les listes
local filtered_db = {}
local cached_all_tags = {}
local cached_all_manufacturers = {}
local need_filter_update = true
local need_stats_update = true

-- Variables pour le popup de rapport de scan
local added_plugins_list = {}
-- Variables pour le popup de rapport de scan
local added_plugins_list = {}
local show_added_plugins_popup = false
local show_recycle_bin = false -- Flag pour la corbeille

-- Listes pour catégoriser les tags
local effect_type_tags = {
    "eq", "comp", "reverb", "delay", "saturation", "modulation", 
    "gate", "instrument", "filter", "pitch", "utility", "analyzer", "inconnu"
}

local manufacturer_tags = {
    "waves", "fabfilter", "uad", "izotope", "soundtoys", "plugin-alliance",
    "slate", "ni", "valhalla", "softube", "eventide", "sonnox", "ssl",
    "neve", "api", "lexicon", "arturia", "spectrasonics", "xln", "toontrack",
    "steinberg", "ik", "acustica", "mcdsp", "metric-halo", "kilohearts",
    "baby-audio", "goodhertz", "oeksound", "tdr", "airwindows", "reaper"
}

-- Fonction pour vérifier si un tag est un type d'effet
local function is_effect_type(tag)
    for _, t in ipairs(effect_type_tags) do
        if t == tag then return true end
    end
    return false
end

-- Fonction pour vérifier si un tag est un éditeur
-- Tout tag qui n'est pas un type d'effet est considéré comme un éditeur
local function is_manufacturer(tag)
    -- D'abord vérifier dans la liste connue
    for _, t in ipairs(manufacturer_tags) do
        if t == tag then return true end
    end
    -- Si ce n'est pas un type d'effet, c'est probablement un éditeur
    return not is_effect_type(tag)
end

-- --- FONCTIONS JSON ---
local function table_to_json(tbl)
    local buffer = {"[\n"}
    local len = #tbl
    for i, plugin in ipairs(tbl) do
        table.insert(buffer, "  {\n")
        table.insert(buffer, '    "real_name": "' .. plugin.real_name:gsub('"', '\\"') .. '",\n')
        table.insert(buffer, '    "alias": "' .. (plugin.alias or ""):gsub('"', '\\"') .. '",\n')
        table.insert(buffer, '    "manufacturer": "' .. (plugin.manufacturer or ""):gsub('"', '\\"') .. '",\n')
        table.insert(buffer, '    "tags": "' .. (plugin.tags or ""):gsub('"', '\\"') .. '",\n')
        table.insert(buffer, '    "deleted": ' .. (plugin.deleted and "true" or "false") .. "\n")
        table.insert(buffer, "  }" .. (i < len and ",\n" or "\n"))
    end
    table.insert(buffer, "]")
    return table.concat(buffer)
end

local function json_to_table(json_str)
    local result = {}
    -- Regex améliorée pour capturer le champ optionnel 'deleted'
    -- Le pattern cherche les champs clés dans n'importe quel ordre n'est pas trivial en regex simple.
    -- On va assumer la structure générée mais aussi supporter l'absence de 'deleted' (anciens fichiers)
    
    -- On va plutôt utiliser un parser "bloc par bloc" pour être plus robuste
    for plugin_str in json_str:gmatch("{([^}]*)}") do
        local real_name = plugin_str:match('"real_name"%s*:%s*"([^"]*)"')
        local alias = plugin_str:match('"alias"%s*:%s*"([^"]*)"')
        local manufacturer = plugin_str:match('"manufacturer"%s*:%s*"([^"]*)"')
        local tags = plugin_str:match('"tags"%s*:%s*"([^"]*)"')
        local deleted_str = plugin_str:match('"deleted"%s*:%s*(%w+)')
        
        if real_name then
            table.insert(result, {
                real_name = real_name:gsub('\\"', '"'),
                alias = (alias or ""):gsub('\\"', '"'),
                manufacturer = (manufacturer or ""):gsub('\\"', '"'),
                tags = (tags or ""):gsub('\\"', '"'),
                deleted = (deleted_str == "true")
            })
        end
    end
    return result
end

-- --- SAUVEGARDE / CHARGEMENT ---
local function save_database()
    local file = io.open(db_file, "w")
    if file then
        file:write(table_to_json(db))
        file:close()
        scan_message = "✓ Base de données sauvegardée (" .. #db .. " plugins)"
        return true
    else
        scan_message = "✗ Erreur : impossible de sauvegarder le fichier"
        return false
    end
end

local function load_database()
    local file = io.open(db_file, "r")
    if file then
        local content = file:read("*all")
        file:close()
        db = json_to_table(content)
        scan_message = "✓ Base chargée : " .. #db .. " plugins"
        need_filter_update = true
        need_stats_update = true
        return true
    else
        scan_message = "⚠ Aucune base existante (créez-en une avec le scanner)"
        return false
    end
end

-- Fonction pour obtenir la priorité d'un type de plugin
local function get_plugin_priority(fx_name)
    -- Ordre de priorité :
    -- 1. VST3 64-bit (meilleur)
    -- 2. VST3 32-bit
    -- 3. VST 64-bit
    -- 4. VST 32-bit
    -- 5. Autres (JS, AU, CLAP, etc.)
    
    local is_64bit = fx_name:match("64") or fx_name:match("_x64") or fx_name:match("x64%.") or fx_name:match("_64bit")
    local is_32bit = fx_name:match("32") or fx_name:match("_x32") or fx_name:match("_32bit")
    
    if fx_name:match("^VST3:") or fx_name:match("^VST3i:") or fx_name:match("%.vst3$") then
        return is_64bit and 1 or (is_32bit and 3 or 2)
    elseif fx_name:match("^VST:") or fx_name:match("^VSTi:") or fx_name:match("%.dll$") then
        return is_64bit and 4 or (is_32bit and 6 or 5)
    else
        return 7  -- Priorité basse (JS, AU, CLAP, etc.)
    end
end

-- Fonction pour extraire le nom de base d'un plugin (sans préfixe ni suffixes)
local function get_plugin_base_name(fx_name)
    -- Retirer les préfixes communs
    local base_name = fx_name:gsub("^VST3i?:%s*", "")
    base_name = base_name:gsub("^VSTi?:%s*", "")
    base_name = base_name:gsub("^JS:%s*", "")
    base_name = base_name:gsub("^AU[i]?:%s*", "")
    base_name = base_name:gsub("^CLAP[i]?:%s*", "")
    base_name = base_name:gsub("^DX:%s*", "")
    
    -- Retirer les extensions
    base_name = base_name:gsub("%.vst3$", "")
    base_name = base_name:gsub("%.dll$", "")
    base_name = base_name:gsub("%.vst$", "")
    
    -- Retirer les suffixes de version 32/64 bits
    base_name = base_name:gsub("_x64$", "")
    base_name = base_name:gsub("_x32$", "")
    base_name = base_name:gsub("_64bit$", "")
    base_name = base_name:gsub("_32bit$", "")
    base_name = base_name:gsub("%s+x64$", "")
    base_name = base_name:gsub("%s+x32$", "")
    base_name = base_name:gsub("%s+64$", "")
    base_name = base_name:gsub("%s+32$", "")
    base_name = base_name:gsub("64$", "")  -- Pour les cas comme "helgobox_x64"
    
    -- Normaliser les espaces et underscores
    base_name = base_name:gsub("_", " "):gsub("%s+", " ")
    base_name = base_name:gsub("^%s+", ""):gsub("%s+$", "")
    
    return base_name:lower()  -- Retourner en minuscules pour comparaison
end

-- Fonction pour vérifier si un nom de plugin est valide
local function is_valid_plugin_name(fx_name)
    -- Filtrer les noms trop courts
    if #fx_name < 3 then
        return false
    end
    
    -- Filtrer les noms génériques
    local generic_names = {"^name$", "^plugin$", "^fx$", "^vst$", "^effect$"}
    for _, pattern in ipairs(generic_names) do
        if fx_name:lower():match(pattern) then
            return false
        end
    end
    
    -- Filtrer les chaînes hexadécimales (comme "565354455A6433657A6472756D6D6572")
    if fx_name:match("^[0-9A-Fa-f]+$") and #fx_name > 20 then
        return false
    end
    
    -- Filtrer les noms qui semblent être des identifiants systèmes
    if fx_name:match("^[A-Z0-9_]+$") and not fx_name:match("%.") then
        -- Exception pour les plugins en majuscules avec extensions
        return false
    end
    
    -- Filtrer les shells de plugins (WaveShell, etc.) - ce ne sont pas des plugins utilisables
    local shell_patterns = {
        "waveshell",
        "waves.*shell",
        "shell.*vst",
        "vst.*shell",
        "wrapper",
        "bridge",
        "jbridge",
        "32lives"
    }
    local name_lower = fx_name:lower()
    for _, pattern in ipairs(shell_patterns) do
        if name_lower:match(pattern) then
            return false
        end
    end
    
    -- Filtrer les entrées avec des caractères bizarres (comme "<1636169028")
    if fx_name:match("<[0-9]+$") then
        return false
    end
    
    return true
end

-- Fonction pour auto-détecter le type de plugin et générer des tags
local function auto_detect_tags(fx_name)
    local tags = {}
    local name_lower = fx_name:lower()
    local detected_manufacturer = ""
    
    -- ==========================================
    -- EXTRACTION AUTOMATIQUE DE L'ÉDITEUR DEPUIS LE NOM
    -- ==========================================
    -- Extraire le nom entre parenthèses à la fin (ex: "Bass Rider (Waves)" -> "Waves")
    local manufacturer = fx_name:match("%s*%(([^%)]+)%)%s*$")
    if manufacturer then
        -- Ignorer les configurations de canaux et autres patterns techniques
        local ignore_patterns = {
            "^%d+ch$",           -- (64ch), (2ch)
            "^%d+%->%d+ch$",     -- (2->4ch), (1->4ch)
            "^mono$",
            "^stereo$",
            "^multi$",
            "^%d+$",             -- Juste des chiffres
            "^m/s$",             -- Mid/Side
            "^lr$",              -- Left/Right
            "^surround$",
        }
        
        local mfr_lower = manufacturer:lower()
        local is_channel_config = false
        
        for _, pattern in ipairs(ignore_patterns) do
            if mfr_lower:match(pattern) then
                is_channel_config = true
                break
            end
        end
        
        if not is_channel_config then
            -- Garder le manufacturer original (non modifié)
            detected_manufacturer = manufacturer
        end
    end
    
    -- Détection EQ
    local eq_keywords = {
        "eq", "equalizer", "equali", "pro%-q", "fabfilter q",
        "channel strip", "strip", "pultec", "neve", "ssl.*channel",
        "api.*eq", "parametric", "graphic eq", "linear eq",
        "vintage eq", "console", "preamp"
    }
    for _, keyword in ipairs(eq_keywords) do
        if name_lower:match(keyword) then
            table.insert(tags, "eq")
            break
        end
    end
    
    -- Détection Compresseur
    local comp_keywords = {
        "comp", "compressor", "limiter", "1176", "la%-2a", "la2a",
        "ssl.*comp", "dbx", "distressor", "fairchild", "vari%-mu",
        "opto", "fet", "vca", "dynamics", "punch", "glue",
        "bus comp", "master comp", "vintage comp", "api.*comp"
    }
    for _, keyword in ipairs(comp_keywords) do
        if name_lower:match(keyword) then
            table.insert(tags, "comp")
            break
        end
    end
    
    -- Détection Reverb
    local reverb_keywords = {
        "reverb", "verb", "hall", "room", "plate", "spring",
        "chamber", "ambience", "space", "lexicon", "bricasti",
        "emt", "valhalla.*verb", "convolution"
    }
    for _, keyword in ipairs(reverb_keywords) do
        if name_lower:match(keyword) then
            table.insert(tags, "reverb")
            break
        end
    end
    
    -- Détection Delay
    local delay_keywords = {
        "delay", "echo", "tape echo", "analog delay", "digital delay",
        "ping.*pong", "slapback", "echoboy", "echoplex", "memory man",
        "space echo", "re%-201"
    }
    for _, keyword in ipairs(delay_keywords) do
        if name_lower:match(keyword) then
            table.insert(tags, "delay")
            break
        end
    end
    
    -- Autres catégories optionnelles
    -- Saturation/Distortion
    if name_lower:match("satur") or name_lower:match("distort") or 
       name_lower:match("overdrive") or name_lower:match("dirt") then
        table.insert(tags, "saturation")
    end
    
    -- Modulation (Chorus, Flanger, Phaser)
    if name_lower:match("chorus") or name_lower:match("flanger") or 
       name_lower:match("phaser") or name_lower:match("vibrato") then
        table.insert(tags, "modulation")
    end
    
    -- Gate/Expander
    if name_lower:match("gate") or name_lower:match("expander") then
        table.insert(tags, "gate")
    end
    
    -- Synth/Instrument
    if name_lower:match("synth") or name_lower:match("vsti") or 
       name_lower:match("instrument") or name_lower:match("piano") or
       name_lower:match("drum") then
        table.insert(tags, "instrument")
    end
    
    -- Si aucun tag détecté, ajouter "inconnu"
    if #tags == 0 then
        table.insert(tags, "inconnu")
    end
    
    -- Retourner les tags ET le manufacturer séparément
    return table.concat(tags, " "), detected_manufacturer
end

-- --- SCANNER DE FX ---
-- Fonction utilitaire pour scanner Reaper sans modifier la DB
local function collect_reaper_fx()
    local fx_names = {}
    
    -- Méthode 1: Lire les fichiers INI de Reaper
    local resource_path = r.GetResourcePath()
    local ini_files = {
        resource_path .. "\\reaper-vstplugins64.ini",
        resource_path .. "\\reaper-vstplugins.ini",
        resource_path .. "\\reaper-jsfx.ini",
        resource_path .. "\\reaper-dxplugins.ini"
    }
    
    for _, ini_file in ipairs(ini_files) do
        local file = io.open(ini_file, "r")
        if file then
            for line in file:lines() do
                local shell_name = line:match(",([^,{]+%(.-%))[%s]*$")
                if shell_name and shell_name ~= "" then
                    shell_name = shell_name:gsub("^%s+", ""):gsub("%s+$", "")
                    if shell_name ~= "" and not fx_names[shell_name] and is_valid_plugin_name(shell_name) then
                        if ini_file:match("vst") then
                            fx_names["VST3: " .. shell_name] = true
                        else
                            fx_names[shell_name] = true
                        end
                    end
                else
                    local plugin_name = line:match("^([^=]+)=")
                    if plugin_name and plugin_name ~= "" and not plugin_name:match("^%[") then
                        plugin_name = plugin_name:gsub("^%s+", ""):gsub("%s+$", "")
                        if plugin_name ~= "" and not fx_names[plugin_name] and is_valid_plugin_name(plugin_name) then
                            fx_names[plugin_name] = true
                        end
                    end
                end
            end
            file:close()
        end
    end
    
    -- Méthode 2: Scanner via l'API Reaper
    r.InsertTrackAtIndex(r.CountTracks(0), false)
    local temp_track = r.GetTrack(0, r.CountTracks(0) - 1)
    
    if temp_track then
        local browser_index = 0
        while browser_index < 100000 do
            local fx_added = r.TrackFX_AddByName(temp_track, "FX:" .. browser_index, false, -1)
            
            if fx_added >= 0 then
                local _, fx_name = r.TrackFX_GetFXName(temp_track, fx_added, "")
                if fx_name and fx_name ~= "" and is_valid_plugin_name(fx_name) then
                    fx_names[fx_name] = true
                end
                r.TrackFX_Delete(temp_track, fx_added)
                browser_index = browser_index + 1
            else
                local test_ahead = true
                for i = 1, 100 do
                    local test_fx = r.TrackFX_AddByName(temp_track, "FX:" .. (browser_index + i), false, -1)
                    if test_fx >= 0 then
                        r.TrackFX_Delete(temp_track, test_fx)
                        test_ahead = false
                        break
                    end
                end
                
                if test_ahead then break else browser_index = browser_index + 1 end
            end
        end
        
        local js_index = 0
        while js_index < 10000 do
            local fx_added = r.TrackFX_AddByName(temp_track, "JS:" .. js_index, false, -1)
            if fx_added >= 0 then
                local _, fx_name = r.TrackFX_GetFXName(temp_track, fx_added, "")
                if fx_name and fx_name ~= "" and is_valid_plugin_name(fx_name) then
                    fx_names[fx_name] = true
                end
                r.TrackFX_Delete(temp_track, fx_added)
                js_index = js_index + 1
            else
                if js_index > 100 then break end
                js_index = js_index + 1
            end
        end
        r.DeleteTrack(temp_track)
    end
    
    -- Déduplication
    local deduplicated = {}
    for fx_name, _ in pairs(fx_names) do
        local base_name = get_plugin_base_name(fx_name)
        local priority = get_plugin_priority(fx_name)
        
        if not deduplicated[base_name] then
            deduplicated[base_name] = {name = fx_name, priority = priority}
        else
            if priority < deduplicated[base_name].priority then
                deduplicated[base_name] = {name = fx_name, priority = priority}
            end
        end
    end
    return deduplicated
end

-- Fonction pour mettre à jour la base (AJOUTER seulement les nouveaux)
local function scan_fx_update()
    scan_in_progress = true
    scan_message = "Mise à jour (recherche de nouveaux plugins)..."
    r.defer(function()
        local collected = collect_reaper_fx()
        local added_count = 0
        added_plugins_list = {} -- Réinitialiser la liste
        
        -- Indexer la DB actuelle pour recherche rapide
        local existing_map = {}
        for _, plugin in ipairs(db) do
            local base = get_plugin_base_name(plugin.real_name)
            existing_map[base] = true
        end
        
        -- Ajouter seulement ce qui manque
        for _, info in pairs(collected) do
            local base = get_plugin_base_name(info.name)
            if not existing_map[base] then
                local auto_tags, auto_manufacturer = auto_detect_tags(info.name)
                local new_plugin = {
                    real_name = info.name,
                    alias = "",
                    manufacturer = auto_manufacturer or "",
                    tags = auto_tags
                }
                table.insert(db, new_plugin)
                table.insert(added_plugins_list, new_plugin.real_name) -- Ajouter à la liste du rapport
                added_count = added_count + 1
            end
        end
        
        if added_count > 0 then
            table.sort(db, function(a, b) return a.real_name < b.real_name end)
            save_database()
            scan_message = "✓ Mise à jour terminée : " .. added_count .. " nouveaux plugins ajoutés."
            show_added_plugins_popup = true -- Déclencher le popup
        else
            scan_message = "✓ Aucun nouveau plugin trouvé."
        end
        
        scan_in_progress = false
        need_filter_update = true
        need_stats_update = true
    end)
end

-- Fonction pour réinitialiser complètement la base (RESET)
local function scan_fx_reset()
    scan_in_progress = true
    scan_message = "Scan complet (Reset) en cours..."
    r.defer(function()
        local collected = collect_reaper_fx()
        db = {} -- On efface tout
        
        for _, info in pairs(collected) do
            local auto_tags, auto_manufacturer = auto_detect_tags(info.name)
            table.insert(db, {
                real_name = info.name,
                alias = "",
                manufacturer = auto_manufacturer or "",
                tags = auto_tags
            })
        end
        
        table.sort(db, function(a, b) return a.real_name < b.real_name end)
        save_database()
        
        scan_message = "✓ Base réinitialisée : " .. #db .. " plugins trouvés."
        scan_in_progress = false
        need_filter_update = true
        need_stats_update = true
    end)
end

-- --- FONCTIONS INTERFACE ---
local function add_fx(name, alias)
    local track = r.GetSelectedTrack(0, 0)
    if not track then
        scan_message = "✗ Erreur : aucune piste sélectionnée"
        return
    end
    
    -- Liste des variantes à essayer
    local attempts = {}
    
    -- 1. Nom tel quel
    table.insert(attempts, name)
    
    -- 2. Si c'est juste un nom de fichier (ex: "plugin.vst3"), essayer avec préfixes
    if not name:match("^VST[3]?[i]?:") and not name:match("^JS:") and not name:match("^AU[i]?:") then
        -- Déterminer le type de plugin d'après l'extension
        if name:match("%.vst3$") then
            -- Essayer VST3: avec le nom sans extension
            local base = name:gsub("%.vst3$", "")
            -- Essayer avec des espaces au lieu des underscores
            local spaced = base:gsub("_", " ")
            table.insert(attempts, "VST3: " .. spaced)
            table.insert(attempts, "VST3: " .. base)
            table.insert(attempts, "VST3i: " .. spaced)
            table.insert(attempts, "VST3i: " .. base)
        elseif name:match("%.dll$") then
            local base = name:gsub("%.dll$", "")
            local spaced = base:gsub("_", " ")
            table.insert(attempts, "VST: " .. spaced)
            table.insert(attempts, "VST: " .. base)
            table.insert(attempts, "VSTi: " .. spaced)
            table.insert(attempts, "VSTi: " .. base)
        end
        
        -- Essayer aussi le nom complet avec le fichier
        table.insert(attempts, "VST3: " .. name)
        table.insert(attempts, "VST: " .. name)
    end
    
    -- 3. Si le nom contient déjà un préfixe, essayer aussi sans
    if name:match("^VST[3]?[i]?:%s*") then
        local without_prefix = name:gsub("^VST[3]?[i]?:%s*", "")
        table.insert(attempts, without_prefix)
    end
    
    -- Essayer chaque variante
    local index = -1
    local successful_name = nil
    
    for _, attempt_name in ipairs(attempts) do
        index = r.TrackFX_AddByName(track, attempt_name, false, -1)
        if index >= 0 then
            successful_name = attempt_name
            break
        end
    end
    
    if index >= 0 then
        -- Succès !
        if alias ~= "" then
            r.TrackFX_SetNamedConfigParm(track, index, "renamed_name", alias)
        end
        r.TrackFX_Show(track, index, 3) -- Ouvrir la fenêtre flottante
        scan_message = "✓ FX ajouté : " .. (alias ~= "" and alias or successful_name)
    else
        -- Échec après toutes les tentatives
        scan_message = "✗ Erreur : impossible d'ajouter '" .. name .. "'"
        
        -- AUTO-DELETE : Si le plugin ne charge pas, on le supprime de la liste (Soft Delete)
        local deleted_count = 0
        for i, plugin in ipairs(db) do
            -- On cherche par le nom réel ou l'alias affiché
            if plugin.real_name == name or (plugin.alias ~= "" and plugin.alias == name) then
                plugin.deleted = true
                deleted_count = deleted_count + 1
            end
        end
        
        if deleted_count > 0 then
            save_database()
            need_filter_update = true
            need_stats_update = true
            scan_message = scan_message .. " -> Plugin supprimé de la liste (envoyé à la corbeille)"
        end
    end
end

local function match_search(plugin, text)
    if text == "" then return true end
    text = text:lower()
    
    -- Rechercher dans le nom réel, l'alias et les tags
    local searchable = (plugin.real_name .. " " .. plugin.alias .. " " .. plugin.tags):lower()
    
    -- Support de recherche multi-mots (tous les mots doivent matcher)
    for word in text:gmatch("%S+") do
        if not searchable:find(word, 1, true) then
            return false
        end
    end
    
    return true
end

-- Fonction de tri personnalisée (Sélectionnés en premier, puis alphabétique)
local function sort_lists()
    local function sort_func(a, b, selection_table)
        -- Normaliser les noms pour le tri (insensible à la casse)
        local name_a = a.name:lower()
        local name_b = b.name:lower()
        
        local a_sel = selection_table[a.name] or false
        local b_sel = selection_table[b.name] or false
        
        -- Règle 1: Sélectionnés en premier
        if a_sel and not b_sel then return true end
        if b_sel and not a_sel then return false end
        
        -- Règle 2: Alphabétique
        return name_a < name_b
    end

    table.sort(cached_all_tags, function(a, b) return sort_func(a, b, selected_effect_types) end)
    table.sort(cached_all_manufacturers, function(a, b) return sort_func(a, b, selected_manufacturers) end)
end

-- Fonction pour mettre à jour les statistiques globales (tags et manufacturers)
-- N'est appelé que lors du chargement ou du scan
local function update_global_stats()
    -- 1. Tags
    local tags_set = {}
    for _, plugin in ipairs(db) do
        if plugin.tags and plugin.tags ~= "" then
            for tag in plugin.tags:gmatch("%S+") do
                tags_set[tag] = (tags_set[tag] or 0) + 1
            end
        end
    end
    
    cached_all_tags = {}
    for tag, count in pairs(tags_set) do
        table.insert(cached_all_tags, {name = tag, count = count})
    end
    
    -- 2. Manufacturers
    local mfr_set = {}
    for _, plugin in ipairs(db) do
        if plugin.manufacturer and plugin.manufacturer ~= "" then
            local mfr_key = plugin.manufacturer:lower():gsub("%s+", "-")
            if not mfr_set[mfr_key] then
                mfr_set[mfr_key] = {count = 0, display_name = plugin.manufacturer}
            end
            mfr_set[mfr_key].count = mfr_set[mfr_key].count + 1
        end
    end
    
    cached_all_manufacturers = {}
    for key, data in pairs(mfr_set) do
        table.insert(cached_all_manufacturers, {name = key, display_name = data.display_name, count = data.count})
    end
    
    -- Appliquer le tri initial
    sort_lists()
    
    need_stats_update = false
end

-- Fonction pour vérifier si un plugin correspond aux tags sélectionnés
local function match_selected_tags(plugin)
    -- Vérifier s'il y a des sélections dans chaque catégorie
    local has_effect_selection = false
    local has_manufacturer_selection = false
    
    for _, _ in pairs(selected_effect_types) do
        has_effect_selection = true
        break
    end
    
    for _, _ in pairs(selected_manufacturers) do
        has_manufacturer_selection = true
        break
    end
    
    -- Si aucune sélection, afficher tous les plugins
    if not has_effect_selection and not has_manufacturer_selection then
        return true
    end
    
    if not plugin.tags or plugin.tags == "" then
        return false
    end
    
    -- Vérifier les types d'effets (au moins un doit matcher si sélectionné)
    local matches_effect = not has_effect_selection
    if has_effect_selection then
        for tag, _ in pairs(selected_effect_types) do
            for plugin_tag in plugin.tags:gmatch("%S+") do
                if plugin_tag == tag then
                    matches_effect = true
                    break
                end
            end
            if matches_effect then break end
        end
    end
    
    -- Vérifier les éditeurs (utiliser le champ manufacturer)
    local matches_manufacturer = not has_manufacturer_selection
    if has_manufacturer_selection then
        local plugin_mfr = (plugin.manufacturer or ""):lower():gsub("%s+", "-")
        for selected_mfr, _ in pairs(selected_manufacturers) do
            if plugin_mfr == selected_mfr then
                matches_manufacturer = true
                break
            end
        end
    end
    
    -- Les deux conditions doivent être vraies (ET logique)
    return matches_effect and matches_manufacturer
end

-- Fonction pour mettre à jour la liste filtrée
-- N'est appelé que si la recherche ou les filtres changent
local function update_filtered_list()
    filtered_db = {}
    for _, plugin in ipairs(db) do
        if match_search(plugin, search_text) and match_selected_tags(plugin) then
            table.insert(filtered_db, plugin)
        end
    end
    need_filter_update = false
end

-- --- BOUCLE PRINCIPALE GUI ---
local function loop()
    -- Appliquer le thème moderne
    apply_modern_theme()
    
    -- Définir une taille par défaut uniquement lors de la première ouverture
    r.ImGui_SetNextWindowSize(ctx, 800, 600, r.ImGui_Cond_FirstUseEver())
    
    local visible, open = r.ImGui_Begin(ctx, '🎛️ FX Browser & Tagger', true)
    
    if visible then
        

        
        -- Message de statut
        if scan_message ~= "" then
            r.ImGui_TextColored(ctx, 0x00FF00FF, scan_message)
        end
        
        r.ImGui_Separator(ctx)
        
        r.ImGui_Separator(ctx)
        
        -- Mise à jour des caches si nécessaire (lazy update)
        -- Placé ici pour être actif quel que soit l'onglet
        if need_stats_update then update_global_stats() end
        if need_filter_update then update_filtered_list() end
        
        -- Onglets
        if r.ImGui_BeginTabBar(ctx, 'TabBar') then
            
            -- ONGLET RECHERCHE
            if r.ImGui_BeginTabItem(ctx, 'Rechercher (' .. #db .. ' FX)') then
                
                -- Barre de recherche
                -- Barre de recherche et Tags sélectionnés (Chips)
                
                -- 1. Afficher les tags sélectionnés sous forme de Chips au-dessus
                local has_chips = false
                for tag_name, _ in pairs(selected_effect_types) do
                    has_chips = true
                    local tag_color = get_tag_color(tag_name)
                    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Button(), tag_color)
                    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonHovered(), tag_color - 0x202020)
                    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonActive(), tag_color + 0x101010)
                    
                    if r.ImGui_Button(ctx, tag_name .. " x##chip") then
                        selected_effect_types[tag_name] = nil
                        need_filter_update = true
                        sort_lists()
                    end
                    
                    r.ImGui_PopStyleColor(ctx, 3)
                    r.ImGui_SameLine(ctx)
                end
                
                if has_chips then r.ImGui_NewLine(ctx) end

                -- 2. Afficher les éditeurs sélectionnés sous forme de Chips
                local has_mfr_chips = false
                for mfr_name, _ in pairs(selected_manufacturers) do
                    has_mfr_chips = true
                    local tag_color = get_tag_color(mfr_name)
                    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Button(), tag_color)
                    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonHovered(), tag_color - 0x202020)
                    r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonActive(), tag_color + 0x101010)
                    
                    if r.ImGui_Button(ctx, mfr_name .. " x##mfr_chip") then
                        selected_manufacturers[mfr_name] = nil
                        need_filter_update = true
                        sort_lists()
                    end
                    
                    r.ImGui_PopStyleColor(ctx, 3)
                    r.ImGui_SameLine(ctx)
                end
                
                if has_mfr_chips then r.ImGui_NewLine(ctx) end
                
                r.ImGui_SetNextItemWidth(ctx, -1)
                local changed, txt = r.ImGui_InputTextWithHint(ctx, '##Search', 
                    'Recherche (nom, alias, tags)...', search_text)
                if changed then 
                    search_text = txt 
                    need_filter_update = true
                end
                

                
                r.ImGui_Separator(ctx)
                
                -- Layout avec Table (3 colonnes)
                r.ImGui_Separator(ctx)
                
                -- Layout avec Table (3 colonnes) - SCROLLABLE AREA
                if r.ImGui_BeginChild(ctx, "SearchScrollArea") then
                    if r.ImGui_BeginTable(ctx, 'SearchLayout', 3) then
                    r.ImGui_TableSetupColumn(ctx, 'TypeEffet', r.ImGui_TableColumnFlags_WidthFixed(), 140)
                    r.ImGui_TableSetupColumn(ctx, 'Editeur', r.ImGui_TableColumnFlags_WidthFixed(), 140)
                    r.ImGui_TableSetupColumn(ctx, 'Results', r.ImGui_TableColumnFlags_WidthStretch())
                    
                    r.ImGui_TableNextRow(ctx)
                    
                    -- COLONNE 1 : Types d'effets
                    r.ImGui_TableSetColumnIndex(ctx, 0)
                    r.ImGui_Text(ctx, "�️ Type d'effet")
                    r.ImGui_Separator(ctx)
                    
                    -- Bouton "Tous" pour types
                    if r.ImGui_Button(ctx, "Tous##types", -1) then
                        selected_effect_types = {}
                        need_filter_update = true
                        sort_lists() -- Re-trier pour remettre l'ordre par défaut
                    end
                    r.ImGui_Separator(ctx)
                    
                    -- Afficher les tags de type d'effet
                    for _, tag_info in ipairs(cached_all_tags) do
                        -- Afficher tous les tags présents dans la base (plus de filtre strict)
                        local is_selected = selected_effect_types[tag_info.name] or false
                        
                        -- Si sélectionné, on ne l'affiche plus dans la liste (il est en haut en chip)
                        if not is_selected then
                            local tag_color = get_tag_color(tag_info.name)
                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Button(), tag_color)
                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonHovered(), tag_color - 0x202020)
                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonActive(), tag_color + 0x101010)
                            
                            local label = tag_info.name .. " (" .. tag_info.count .. ")"
                            
                            if r.ImGui_Button(ctx, label .. "##type", -1) then
                                selected_effect_types[tag_info.name] = true
                                need_filter_update = true
                                sort_lists()
                            end
                            
                            r.ImGui_PopStyleColor(ctx, 3)
                        end
                    end
                    
                    -- COLONNE 2 : Éditeurs
                    r.ImGui_TableSetColumnIndex(ctx, 1)
                    r.ImGui_Text(ctx, "🏭 Éditeur")
                    r.ImGui_Separator(ctx)
                    
                    -- Bouton "Tous" pour éditeurs
                    if r.ImGui_Button(ctx, "Tous##mfr", -1) then
                        selected_manufacturers = {}
                        need_filter_update = true
                        sort_lists() -- Re-trier pour remettre l'ordre par défaut
                    end
                    r.ImGui_Separator(ctx)
                    
                    -- Afficher les éditeurs depuis le champ manufacturer
                    for _, mfr_info in ipairs(cached_all_manufacturers) do
                        local is_selected = selected_manufacturers[mfr_info.name] or false
                        
                        -- Si sélectionné, on ne l'affiche plus (en chip en haut)
                        if not is_selected then
                            local tag_color = get_tag_color(mfr_info.name)
                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Button(), tag_color)
                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonHovered(), tag_color - 0x202020)
                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonActive(), tag_color + 0x101010)
                            
                            local label = mfr_info.display_name .. " (" .. mfr_info.count .. ")"
                            
                            if r.ImGui_Button(ctx, label .. "##mfr", -1) then
                                selected_manufacturers[mfr_info.name] = true
                                need_filter_update = true
                                sort_lists()
                            end
                            
                            r.ImGui_PopStyleColor(ctx, 3)
                        end
                    end
                    
                    -- COLONNE 3 : Liste des FX
                    r.ImGui_TableSetColumnIndex(ctx, 2)
                    r.ImGui_Text(ctx, "📋 Cliquez sur un FX pour l'ajouter")
                    r.ImGui_Separator(ctx)
                    
                    -- Liste des résultats
                    local match_count = #filtered_db
                    
                    -- Affichage de la grille de boutons
                    r.ImGui_PushStyleVar(ctx, r.ImGui_StyleVar_ItemSpacing(), 12, 12)
                    
                    local window_width = r.ImGui_GetContentRegionAvail(ctx)
                    local columns = math.floor(window_width / 200)
                    if columns < 1 then columns = 1 end
                    
                    if #filtered_db == 0 then
                        r.ImGui_TextColored(ctx, 0xFF0000FF, "Aucun plugin trouvé")
                    else
                        local displayed_count = 0
                        for i, plugin in ipairs(filtered_db) do
                            if not plugin.deleted then
                                if displayed_count < 100 then
                                    if displayed_count % columns ~= 0 then r.ImGui_SameLine(ctx) end
                                    
                                    local button_label = plugin.real_name
                                    if plugin.alias ~= "" then button_label = plugin.alias end
                                    
                                    if r.ImGui_Button(ctx, button_label .. "##" .. i, 190, 40) then
                                        add_fx(plugin.real_name, plugin.alias)
                                        if r.ImGui_IsKeyDown(ctx, r.ImGui_Mod_Ctrl()) then open = false end
                                    end
                                    
                                    if r.ImGui_IsItemHovered(ctx) then
                                        r.ImGui_BeginTooltip(ctx)
                                        r.ImGui_Text(ctx, "Nom réel: " .. plugin.real_name)
                                        if plugin.alias ~= "" then
                                            r.ImGui_Text(ctx, "Alias: " .. plugin.alias)
                                        end
                                        if plugin.tags ~= "" then
                                            r.ImGui_Text(ctx, "Tags: " .. plugin.tags)
                                        end
                                        r.ImGui_EndTooltip(ctx)
                                    end
                                    displayed_count = displayed_count + 1
                                end
                            end
                        end
                    end
                    r.ImGui_PopStyleVar(ctx)
                    
                    if match_count == 0 and (search_text ~= "" or next(selected_effect_types) or next(selected_manufacturers)) then
                        r.ImGui_TextColored(ctx, 0xFF0000FF, "Aucun résultat")
                    elseif match_count > 100 then
                        r.ImGui_TextColored(ctx, 0xFFFF00FF, "... et " .. (match_count - 100) .. " autres résultats")
                    end
                    
                    r.ImGui_EndTable(ctx)
                    end
                    r.ImGui_EndChild(ctx)
                end
                
                r.ImGui_EndTabItem(ctx)
            end
            
            -- ONGLET EDITEUR
            if r.ImGui_BeginTabItem(ctx, 'Éditeur') then
                
                -- --- BARRE D'OUTILS ---
                -- Layout horizontal : [Import] [Update] [Reset] [Trash]
                
                -- 1. Bouton Import
                if r.ImGui_Button(ctx, "➕ Importer FX piste") then
                    local track = r.GetSelectedTrack(0, 0)
                    if track then
                        local fx_count = r.TrackFX_GetCount(track)
                        local imported = 0
                        for fx_idx = 0, fx_count - 1 do
                            local _, fx_name = r.TrackFX_GetFXName(track, fx_idx, "")
                            if fx_name and fx_name ~= "" then
                                -- Vérifier si déjà dans la base
                                local exists = false
                                for _, plugin in ipairs(db) do
                                    if plugin.real_name == fx_name then
                                        exists = true
                                        break
                                    end
                                end
                                
                                if not exists then
                                    local auto_tags, auto_manufacturer = auto_detect_tags(fx_name)
                                    table.insert(db, {
                                        real_name = fx_name,
                                        alias = "",
                                        manufacturer = auto_manufacturer or "",
                                        tags = auto_tags
                                    })
                                    imported = imported + 1
                                end
                            end
                        end
                        save_database()
                        scan_message = "✓ " .. imported .. " FX importés depuis la piste"
                        need_filter_update = true
                        need_stats_update = true
                    else
                        scan_message = "✗ Aucune piste sélectionnée"
                    end
                end
                if r.ImGui_IsItemHovered(ctx) then
                    r.ImGui_BeginTooltip(ctx)
                    r.ImGui_Text(ctx, "Ajoute tous les FX de la piste sélectionnée à la base de données.")
                    r.ImGui_Text(ctx, "Utile pour les plugins Waves et autres non détectés par le scan.")
                    r.ImGui_EndTooltip(ctx)
                end
                
                r.ImGui_SameLine(ctx)
                
                -- 2. Bouton Update
                if r.ImGui_Button(ctx, "↻ Mettre à jour") then
                     if not scan_in_progress then
                        scan_fx_update()
                    end
                end
                if r.ImGui_IsItemHovered(ctx) then
                    r.ImGui_BeginTooltip(ctx)
                    r.ImGui_Text(ctx, "Scan rapide : Ajoute les nouveaux plugins sans toucher à vos tags existants.")
                    r.ImGui_EndTooltip(ctx)
                end
                
                r.ImGui_SameLine(ctx)
                
                -- 3. Bouton Reset
                if r.ImGui_Button(ctx, "⚠️ Reset") then
                    r.ImGui_OpenPopup(ctx, "ResetCallback")
                end
                if r.ImGui_IsItemHovered(ctx) then
                    r.ImGui_BeginTooltip(ctx)
                    r.ImGui_Text(ctx, "Scan complet : EFFACE TOUT (tags, alias) et reconstruit la base à zéro.")
                    r.ImGui_EndTooltip(ctx)
                end
                
                r.ImGui_SameLine(ctx)
                
                -- 4. Bouton Corbeille
                if r.ImGui_Button(ctx, "♻️ Corbeille") then
                   show_recycle_bin = true
                end
                if r.ImGui_IsItemHovered(ctx) then
                    r.ImGui_BeginTooltip(ctx)
                    r.ImGui_Text(ctx, "Voir et restaurer les plugins supprimés.")
                    r.ImGui_EndTooltip(ctx)
                end
                
                -- Popup de confirmation pour le Reset
                if r.ImGui_BeginPopupModal(ctx, "ResetCallback", true, r.ImGui_WindowFlags_AlwaysAutoResize()) then
                    r.ImGui_Text(ctx, "ATTENTION : Cette opération va effacer TOUS vos tags et alias personnalisés.\nLa base de données sera entièrement reconstruite.\n\nVoulez-vous vraiment continuer ?")
                    r.ImGui_Separator(ctx)
                    
                    if r.ImGui_Button(ctx, "OUI, tout effacer", 120) then
                        scan_fx_reset()
                        r.ImGui_CloseCurrentPopup(ctx)
                    end
                    
                    r.ImGui_SameLine(ctx)
                    
                    if r.ImGui_Button(ctx, "Annuler", 120) then
                        r.ImGui_CloseCurrentPopup(ctx)
                    end
                    
                    r.ImGui_EndPopup(ctx)
                end
                
                if scan_in_progress then
                    r.ImGui_TextColored(ctx, 0xFFFF00FF, "⏳ Scan en cours, veuillez patienter...")
                end
                
                r.ImGui_Separator(ctx)
                
                -- Filtre
                r.ImGui_Text(ctx, "Filtrer :")
                r.ImGui_SameLine(ctx)
                r.ImGui_SetNextItemWidth(ctx, 200)
                local filter_changed, filter_text = r.ImGui_InputTextWithHint(ctx, '##Filter', 'Filtrer...', search_text)
                if filter_changed then search_text = filter_text end
                
                r.ImGui_Separator(ctx)
                
                -- Table éditable
                if r.ImGui_BeginChild(ctx, 'EditRegion') then
                    if r.ImGui_BeginTable(ctx, 'EditTable', 5, 
                        r.ImGui_TableFlags_Borders() + 
                        r.ImGui_TableFlags_RowBg() + 
                        r.ImGui_TableFlags_ScrollY()) then
                        
                        r.ImGui_TableSetupColumn(ctx, 'Nom Réel', r.ImGui_TableColumnFlags_WidthStretch())
                        r.ImGui_TableSetupColumn(ctx, 'Alias', r.ImGui_TableColumnFlags_WidthFixed(), 120)
                        r.ImGui_TableSetupColumn(ctx, 'Éditeur', r.ImGui_TableColumnFlags_WidthFixed(), 150)
                        r.ImGui_TableSetupColumn(ctx, 'Tags', r.ImGui_TableColumnFlags_WidthFixed(), 150)
                        r.ImGui_TableSetupColumn(ctx, 'X', r.ImGui_TableColumnFlags_WidthFixed(), 30)
                        r.ImGui_TableHeadersRow(ctx)
                        
                        for i, plugin in ipairs(db) do
                            if not plugin.deleted and (filter_text == "" or match_search(plugin, filter_text)) then
                                r.ImGui_TableNextRow(ctx)
                                
                                -- Nom réel
                                r.ImGui_TableSetColumnIndex(ctx, 0)
                                r.ImGui_Text(ctx, plugin.real_name)
                                
                                -- Alias
                                r.ImGui_TableSetColumnIndex(ctx, 1)
                                r.ImGui_SetNextItemWidth(ctx, -1)
                                local chg_alias, new_alias = r.ImGui_InputText(ctx, '##alias'..i, plugin.alias)
                                if chg_alias then 
                                    plugin.alias = new_alias 
                                    need_filter_update = true
                                end
                                
                                -- Éditeur/Manufacturer (Editable Combo)
                                r.ImGui_TableSetColumnIndex(ctx, 2)
                                
                                -- 1. Input Text (permet de créer un nouveau)
                                r.ImGui_SetNextItemWidth(ctx, -25) -- Laisser place au bouton
                                local chg_mfr, new_mfr = r.ImGui_InputText(ctx, '##mfr'..i, plugin.manufacturer or "")
                                if chg_mfr then 
                                    plugin.manufacturer = new_mfr 
                                    need_filter_update = true
                                    need_stats_update = true
                                end
                                
                                -- 2. Bouton Popup (liste existants)
                                r.ImGui_SameLine(ctx)
                                if r.ImGui_ArrowButton(ctx, '##open_mfr_'..i, r.ImGui_Dir_Down()) then
                                    r.ImGui_OpenPopup(ctx, 'mfr_popup_'..i)
                                end
                                
                                -- 3. Popup Liste
                                if r.ImGui_BeginPopup(ctx, 'mfr_popup_'..i) then
                                    for _, mfr in ipairs(cached_all_manufacturers) do
                                        if r.ImGui_Selectable(ctx, mfr.display_name, false) then
                                            plugin.manufacturer = mfr.display_name
                                            need_filter_update = true
                                            need_stats_update = true
                                        end
                                    end
                                    r.ImGui_EndPopup(ctx)
                                end
                                
                                -- Tags (Chips + Add Button)
                                r.ImGui_TableSetColumnIndex(ctx, 3)
                                
                                -- 1. Afficher les tags existants sous forme de "chips"
                                local tags_to_keep = {}
                                local tag_removed = false
                                
                                if plugin.tags and plugin.tags ~= "" then
                                    for tag in plugin.tags:gmatch("%S+") do
                                        local tag_color = get_tag_color(tag)
                                        r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Button(), tag_color)
                                        r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonHovered(), tag_color - 0x202020)
                                        r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonActive(), tag_color + 0x101010)
                                        
                                        if r.ImGui_Button(ctx, tag .. " x##" .. i .. tag) then
                                            tag_removed = true
                                        else
                                            table.insert(tags_to_keep, tag)
                                        end
                                        
                                        r.ImGui_PopStyleColor(ctx, 3)
                                        r.ImGui_SameLine(ctx)
                                    end
                                end
                                
                                if tag_removed then
                                    plugin.tags = table.concat(tags_to_keep, " ")
                                    need_filter_update = true
                                    need_stats_update = true
                                end
                                
                                -- 2. Bouton Ajouter (+)
                                if r.ImGui_Button(ctx, "+##add_tag_"..i) then
                                    r.ImGui_OpenPopup(ctx, 'add_tag_popup_'..i)
                                end
                                
                                -- 3. Popup Ajout
                                if r.ImGui_BeginPopup(ctx, 'add_tag_popup_'..i) then
                                    r.ImGui_Text(ctx, "Ajouter un tag :")
                                    
                                    -- Input pour nouveau tag personnalisé
                                    local changed, new_custom_tag = r.ImGui_InputText(ctx, '##new_tag_input_'..i, '', r.ImGui_InputTextFlags_EnterReturnsTrue())
                                    if changed and new_custom_tag ~= "" then
                                        -- Nettoyer et ajouter
                                        new_custom_tag = new_custom_tag:gsub("%s+", "") -- Pas d'espaces dans les tags
                                        if new_custom_tag ~= "" then
                                            plugin.tags = plugin.tags .. " " .. new_custom_tag
                                            plugin.tags = plugin.tags:gsub("^%s+", ""):gsub("%s+$", "")
                                            need_filter_update = true
                                            need_stats_update = true
                                            r.ImGui_CloseCurrentPopup(ctx)
                                        end
                                    end
                                    
                                    r.ImGui_Separator(ctx)
                                    r.ImGui_Text(ctx, "Existant :")
                                    
                                    -- Liste des tags existants
                                    for _, tag_info in ipairs(cached_all_tags) do
                                        -- Vérifier si le tag est déjà sur le plugin
                                        local already_has = false
                                        for t in plugin.tags:gmatch("%S+") do
                                            if t == tag_info.name then already_has = true break end
                                        end
                                        
                                        if not already_has then
                                            local tag_color = get_tag_color(tag_info.name)
                                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Button(), tag_color)
                                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonHovered(), tag_color - 0x202020)
                                            r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonActive(), tag_color + 0x101010)
                                            
                                            if r.ImGui_Button(ctx, tag_info.name .. "##popup_" .. i) then
                                                plugin.tags = plugin.tags .. " " .. tag_info.name
                                                plugin.tags = plugin.tags:gsub("^%s+", ""):gsub("%s+$", "")
                                                need_filter_update = true
                                                need_stats_update = true
                                                r.ImGui_CloseCurrentPopup(ctx)
                                            end
                                            r.ImGui_PopStyleColor(ctx, 3)
                                        end
                                    end
                                    
                                    r.ImGui_EndPopup(ctx)
                                end
                                
                                -- Actions
                                r.ImGui_TableSetColumnIndex(ctx, 4)
                                if r.ImGui_Button(ctx, "X##" .. i, -1) then
                                    plugin.deleted = true -- Soft delete
                                    save_database()
                                    need_filter_update = true
                                    need_stats_update = true
                                end
                            end
                        end
                        
                        r.ImGui_EndTable(ctx)
                    end
                    r.ImGui_EndChild(ctx)
                end
                
                r.ImGui_Separator(ctx)
                
                if r.ImGui_Button(ctx, "💾 Sauvegarder les modifications", -1) then
                    save_database()
                end
                
                r.ImGui_Separator(ctx)
                
                r.ImGui_EndTabItem(ctx)
            end
            
            r.ImGui_EndTabBar(ctx)
        end
        
        if show_added_plugins_popup then
            r.ImGui_OpenPopup(ctx, " Rapport de Mise à Jour")
            show_added_plugins_popup = false -- Reset flag, OpenPopup handles subsequent frames
        end
        
        if r.ImGui_BeginPopupModal(ctx, " Rapport de Mise à Jour", true, r.ImGui_WindowFlags_AlwaysAutoResize()) then
            r.ImGui_Text(ctx, "Plugins ajoutés (" .. #added_plugins_list .. ") :")
            r.ImGui_Separator(ctx)
            
            if r.ImGui_BeginChild(ctx, "ReportList", 400, 300, 1) then
                for _, name in ipairs(added_plugins_list) do
                    r.ImGui_Text(ctx, "• " .. name)
                end
                r.ImGui_EndChild(ctx)
            end
            
            r.ImGui_Separator(ctx)
            if r.ImGui_Button(ctx, "OK, Fermer", 120) then
                r.ImGui_CloseCurrentPopup(ctx)
            end
            r.ImGui_EndPopup(ctx)
        end
        
        -- POPUP CORBEILLE (Recycle Bin)
        if show_recycle_bin then
            r.ImGui_OpenPopup(ctx, "♻️ Corbeille")
            show_recycle_bin = false
        end
        
        if r.ImGui_BeginPopupModal(ctx, "♻️ Corbeille", true, r.ImGui_WindowFlags_AlwaysAutoResize()) then
            r.ImGui_Text(ctx, "Plugins supprimés (masqués) :")
            r.ImGui_Separator(ctx)
            
            -- Compter les supprimés
            local deleted_count = 0
            for _, p in ipairs(db) do if p.deleted then deleted_count = deleted_count + 1 end end
            
            if deleted_count == 0 then
                r.ImGui_TextColored(ctx, 0x00FF00FF, "La corbeille est vide !")
            else
                if r.ImGui_BeginChild(ctx, "TrashList", 500, 300, 1) then
                    for i, plugin in ipairs(db) do
                        if plugin.deleted then
                             r.ImGui_PushID(ctx, i)
                             if r.ImGui_Button(ctx, "Restaurer") then
                                 plugin.deleted = nil -- Annuler la suppression
                                 save_database()
                                 need_filter_update = true
                                 need_stats_update = true
                             end
                             r.ImGui_SameLine(ctx)
                             r.ImGui_Text(ctx, plugin.real_name)
                             r.ImGui_PopID(ctx)
                        end
                    end
                    r.ImGui_EndChild(ctx)
                end
            end

            r.ImGui_Separator(ctx)
            if r.ImGui_Button(ctx, "Fermer", 120) then
                r.ImGui_CloseCurrentPopup(ctx)
            end
            r.ImGui_EndPopup(ctx)
        end
        
        r.ImGui_End(ctx)
    end
    
    -- Nettoyer le thème
    pop_modern_theme()
    
    if open then
        r.defer(loop)
    else
        -- Sauvegarde automatique à la fermeture
        save_database()
    end
end

-- --- INITIALISATION ---
load_database()
r.defer(loop)