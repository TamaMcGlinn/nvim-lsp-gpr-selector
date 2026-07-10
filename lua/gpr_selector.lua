local function split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- return the .gpr files in the directory
-- if recursive is specified, search subdirectories as well
local function get_gpr_files_in_dir(dir, recursive)
    local gpr_match = recursive and "/**/*" or "/*"
    -- after implementing, I decided recursive is too dangerous to include
    -- if you open a random file and do :GPRSelect you potentially search
    -- all files on the whole system
    return split(vim.fn.glob(dir .. gpr_match .. ".gpr"))
end

local function parent_of(dir)
    if dir == "/" then return nil end
    local parent = dir:match("(.*)/")
    if parent == "" then
        return "/"
    else
        return parent
    end
end

-- search upwards to find .gpr files and return their paths
-- 1) if the file is a gpr file, return that
-- 2) otherwise, keep going upwards until at least one .gpr file was found,
-- and return all .gpr files in that directory
local function find_gprfiles()
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file:find("%.gpr$") ~= nil then return {[1] = current_file} end
    local dir = parent_of(current_file)
    local project_files = {}
    while #project_files == 0 do
        project_files = get_gpr_files_in_dir(dir, false)
        if #project_files == 0 then
            dir = parent_of(dir)
            if dir == nil then return {} end
        end
        project_files = get_gpr_files_in_dir(dir, false)
    end
    return project_files
end

local function get_choice_list(choices)
    local list = ""
    for number, item in ipairs(choices) do
        list = list .. "[" .. number .. "] " .. item .. "\n"
    end
    return list
end

local function gpr_select()
    local projectfiles = find_gprfiles()
    if #projectfiles == 0 then
        print("No gpr project found. Open one and run :GPRSelect.")
        return ''
    elseif #projectfiles == 1 then
        -- select automatically if 1 option,
        local project = projectfiles[1]
        print("Selected " .. project)
        return project
    else
        -- else ask which project file to use
        local prompt = "Choose a GPR project file:"
        local choice_list = get_choice_list(projectfiles)
        local choice = tonumber(vim.fn.input(prompt .. "\n" .. choice_list))
        if choice == nil then
            print("Cancelled due to invalid choice.")
            return ''
        else
            local project = projectfiles[choice]
            print("Chose " .. project)
            return project
        end
    end
end

local function restart_ada_lsp()
  if vim.fn.has("nvim-0.12") == 1 then
    vim.cmd("lsp restart ada_ls")
  else
    error("nvim-lsp-gpr-selector needs nvim 0.12")
  end
end

local function gpr_select_manual(filename)
    if filename == nil then filename = gpr_select() end
    vim.g["als_gpr_projectfile"] = filename
    restart_ada_lsp()
end

local function get_gpr_project()
    if vim.g.als_gpr_projectfile ~= nil then
        -- use previously saved project
        return vim.g.als_gpr_projectfile
    end
    local gpr_project = gpr_select()
    -- save project file for next time
    vim.g["als_gpr_projectfile"] = gpr_project
    return gpr_project
end

local last_project = nil

local function als_on_init(client)
    local gpr_project = get_gpr_project()
    if last_project == gpr_project then
      -- do nothing, user selected the same as already set
      return true
    end
    client.config = client.config or {}
    client.config.settings = client.config.settings or {}
    client.config.settings.ada = {projectFile = gpr_project}
    local new_config = { settings = { ada = client.config.settings.ada } }
    client.notify("workspace/didChangeConfiguration", new_config)
    -- we purposefully don't this, but in case we want to in future,
    -- we can change all currently running ALS clients as well:
    -- for _, existing_client in ipairs(vim.lsp.get_clients({ name = "als" })) do
    --   existing_client.notify("workspace/didChangeConfiguration", new_config)
    -- end
    last_project = gpr_project
    restart_ada_lsp()
    return true
end

return {gpr_select_manual = gpr_select_manual, als_on_init = als_on_init}
