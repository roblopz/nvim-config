## Plugin Configuration Structure

Your lua/_lazy/test/init.lua (or _lazy/test.lua) defines two local development plugins:

return {
  {
    name = 'test_a',
    dir = vim.fn.stdpath 'config' .. '/lua/test_a',
    main = 'test_a',
    dev = true,
    config = function()
      _G.test_a = true
    end,
  },
  {
    name = 'test_b',
    dir = vim.fn.stdpath 'config' .. '/lua/test_b',
    main = 'test_b',
    dev = true,
    config = function()
      _G.test_b = true
    end,
  },
}

## Key Fields Explained

• name: Plugin identifier for lazy.nvim
• dir: Points to the plugin's root directory
• main: Module name that lazy.nvim will require() when loading
• dev: Marks this as a development plugin (prevents updates)
• config: Function that runs after the plugin loads

## Required File Structure

For this setup to work, you need:

~/.config/nvim/
├── lua/
│   ├── test_a/
│   │   └── init.lua          # Main module file
│   └── test_b/
│       └── init.lua          # Main module file
└── lua/_lazy/ae/init.lua     # Plugin specs

## How It Works

1. Lazy.nvim reads the plugin spec from _lazy/ae/init.lua
2. When loading test_a, it looks in lua/test_a/ directory
3. The main = 'test_a' tells it to require('test_a')
4. Since test_a is a directory with init.lua, it loads lua/test_a/init.lua
5. After loading, the config function runs, setting _G.test_a = true
