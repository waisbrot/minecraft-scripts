local function init_config()
    settings.set("startup_libraries", {})
    settings.set("startup_libdir", "/lib")
    settings.set("startup_jobs", {})
    settings.set("startup_is_configured", true)

    settings.save("/.settings")
    print("Initialized settings")
end

local function maybe_init_config()
    if not fs.exists("/.settings") then
        init_config()
    end
    if not settings.get("startup_is_configured", false) then
        init_config()
    end
end

local function ensure_lib_dir()
    local libdir = settings.get("startup_libdir")
    if not fs.isDir(libdir) then
        fs.makeDir(libdir)
    end
end

local function load_libraries()
    local libdir = settings.get("startup_libdir")
    local libs = settings.get("startup_libraries")
    for _, lib in ipairs(libs) do
        assert(os.loadAPI(fs.combine(libdir, lib)), "Failed to load "..lib)
        print("Loaded "..lib)
    end
end

local function start_job(job_name, job)
    print("Starting "..job)
    local job_id = multishell.launch({}, job, "--boot")
    multishell.setTitle(job_id, job_name)
end

local function start_jobs()
    local jobs = settings.get("startup_jobs")
    for job_name, job in ipairs(jobs) do
        start_job(job_name, job)
    end
end

local function boot()
    maybe_init_config()
    ensure_lib_dir()
    load_libraries()
    start_jobs()
    print("Ready")
end

local function add_item(item, list)
    for _, eitem in ipairs(list) do
        if eitem == item then
            print("Already present: " .. item)
            return false
        end
    end
    table.insert(list, item)
    return true
end

local function add_lib(lib)
    local libdir = settings.get("startup_libdir")
    local full_path = fs.combine(libdir, lib)
    assert(fs.exists(full_path), "Unable to find library "..lib.." at "..full_path)
    assert(os.loadAPI(full_path), "Failed to load "..lib)
    local libs = settings.get("startup_libraries")
    add_item(lib, libs)
    settings.set("startup_libraries", libs)
    settings.save("/.settings")
end

local function add_job(job_name, job)
    local jobs = settings.get("startup_jobs")
    if jobs[job_name] ~= nil then
        print("Already present: " .. job_name)
        return
    end
    start_job(job_name, job)
    jobs[job_name] = job
    settings.set("startup_jobs")
    settings.save("/.settings")
end

function main()
    if #arg == 0 then boot()
    elseif arg[1] == '+lib' then add_lib(arg[2])
    elseif arg[1] == '+job' then add_job(arg[2], arg[3])
    else print("Usage: startup [+lib <lib> | +job <name> <job>]")
    end
end

main()