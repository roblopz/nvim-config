local gen_tsx_prompt = [[
Generate a tsx component at @buffer, follow the below example (replace "Component" with the component name inferred from file name):
```
import Box from "@mui/material/Box";

export interface IComponentProps {}

export const Component: React.FC<IComponentProps> = () => {
  return (
    <Box>
      <h1>Component</h1>
      <span>Content</span>
    </Box>
  );
};
```
]]

return {
  'NickvanDyke/opencode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  config = function()
    vim.opt.autoread = true

    vim.g.opencode_opts = {
      on_send = function()
        -- pcall(require('opencode.terminal').show_if_exists)
      end,
      on_opencode_not_found = function()
        if require('opencode-sync.api').locating_opencode then
          return false
        end

        local ok, opened = pcall(require('opencode.terminal').open)
        if not ok then
          -- Discard error so users can safely exclude `snacks.nvim` dependency without overriding this function.
          -- Could incidentally hide an unexpected error in `snacks.terminal`, but seems unlikely.
          return false
        elseif not opened then
          -- `snacks.terminal` is available but failed to open, which we do want to know about.
          error('Failed to auto-open embedded opencode terminal', 0)
        end

        return true
      end,
      prompts = {
        explain = {
          description = 'Explain code near cursor',
          prompt = 'Explain @cursor and its context',
        },
        fix = {
          description = 'Fix diagnostics',
          prompt = 'Fix these @diagnostics',
        },
        optimize = {
          description = 'Optimize selection',
          prompt = 'Optimize @selection for performance and readability',
        },
        document = {
          description = 'Document selection',
          prompt = 'Add documentation comments for @selection',
        },
        test = {
          description = 'Add tests for selection',
          prompt = 'Add tests for @selection',
        },
        review_buffer = {
          description = 'Review buffer',
          prompt = 'Review @buffer for correctness and readability',
        },
        review_diff = {
          description = 'Review git diff',
          prompt = 'Review the following git diff for correctness and readability:\n@diff',
        },
        new_react_component = {
          description = 'Generate React component',
          prompt = gen_tsx_prompt,
        },
        remove_file_unused_imports = {
          description = 'Remove unused imports',
          prompt = '@buffer: remove unused imports, ignore side-effect imports if any',
        },
      },
    }

    vim.keymap.set('n', '<leader>ait', function()
      require('opencode').toggle()
    end, { desc = 'Toggle opencode' })

    vim.keymap.set('n', '<leader>aia', function()
      require('opencode').ask()
    end, { desc = 'Ask opencode' })

    vim.keymap.set('n', '<leader>aic', function()
      require('opencode').ask '@cursor: '
    end, { desc = 'Ask opencode @cursor' })

    vim.keymap.set('v', '<leader>aii', function()
      require('opencode').ask '@selection: '
    end, { desc = 'Ask opencode about selection' })

    vim.keymap.set({ 'n', 'v' }, '<leader>ais', function()
      require('opencode').select()
    end, { desc = 'Select opencode prompt' })

    vim.keymap.set('n', '<leader>oe', function()
      require('opencode').prompt 'Explain @cursor and its context'
    end, { desc = 'Explain this code' })

    vim.keymap.set('n', '<leader>aiy', function()
      require('opencode').command 'messages_copy'
    end, { desc = 'Copy last opencode response' })

    -- vim.keymap.set('n', '<leader>ain', function()
    --   require('opencode').command 'session_new'
    -- end, { desc = 'New opencode session' })

    -- vim.keymap.set('n', '<S-C-f>', function()
    --   require('opencode').command 'messages_half_page_up'
    -- end, { desc = 'Messages half page up' })
    --
    -- vim.keymap.set('n', '<S-C-b>', function()
    --   require('opencode').command 'messages_half_page_down'
    -- end, { desc = 'Messages half page down' })
  end,
}
