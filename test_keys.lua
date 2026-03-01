for _, map in ipairs(vim.api.nvim_get_keymap('n')) do
  if map.lhs == ' <Space>' or map.lhs == ' wv' or map.lhs == ' ws' or map.lhs == ' wq' then
    print(map.lhs .. ' -> ' .. (map.rhs or ''))
  end
end
