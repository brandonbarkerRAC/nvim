local status, lualine = pcall(require, "lualine")
if (not status) then return end

lualine.setup {
  options = {
    icons_enabled = true,
    -- theme = 'tokyonight',
    -- section_separators = { left = '', right = '' },
    -- component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    component_separators = '|',
    disabled_filetypes = { 'packer', 'NvimTree', 'alpha' }
  },
  sections = {
    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
    lualine_b = { 'branch' },
    lualine_c = { {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 1            -- 0 = just filename, 1 = relative path, 2 = absolute path
    } },
    lualine_x = {
      {
        'diagnostics',
        sources = { "nvim_diagnostic" },
        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' }
      },
      'filetype'
    },
    lualine_y = { 'progress' },
    lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 }, }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 1,
    } },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = { 'fugitive' }
}
