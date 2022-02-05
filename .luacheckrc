-- vim: ft=lua syntax=lua softtabstop=3 tabstop=3 shiftwidth=3 fenc=utf-8 expandtab
-- code: language=lua insertSpaces=true tabSize=3

-- codes = true
-- globals = {"_","vim"}
stds.nvim = {
  globals = {
    "rvim",
    "packer_plugins",
    vim = { fields = { "g" } },
    "TERMINAL",
    "USER",
    "C",
    "Config",
    "Api",
    "Cmd",
    "Fn",
    "Keymap",
    "Execute",
    "G",
    "_GlobalCallbacks",
    "WhichKey",
    "MUtils",
    "fterm_cmd",
    os = { fields = { "capture" } },
  },
  read_globals = {
    "bit",
    "jit",
    "os",
    "vim",
    "packer_plugins",
    "join_paths",
    "get_runtime_dir",
    "get_config_dir",
    "get_cache_dir",
    "get_user_dir",
    "use",
    "unpack",
    vim = { fields = { "cmd", "api", "fn", "o", "wo", "bo" } },
  },
}
std = "lua52+nvim"

-- Don't report unused self arguments of methods.
self = false

-- Rerun tests only if their modification time changed.
cache = true

-- https://luacheck.readthedocs.io/en/stable/warnings.html
-- "631", -- max_line_length
ignore = {
  "212/_.*", -- unused argument, for vars with "_" prefix
  "111/_.*", -- unused argument, for functions with "_" prefix
  "631/.*vim.*",
}
exclude_files = {
   "plugin/packer_compiled.lua",
   "tmp/*",
}

