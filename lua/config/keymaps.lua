local map = vim.keymap.set

-- files / search
map("n", "<leader>e",  "<cmd>NvimTreeToggle<cr>",        { desc = "Toggle file tree" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",  { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",   { desc = "Grep in project" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",     { desc = "Buffers" })

-- basics
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Django helpers (run from the project root, inside `pipenv shell`)
map("n", "<leader>rs", "<cmd>belowright split | terminal python manage.py runserver<cr>",
  { desc = "Django runserver" })
map("n", "<leader>rm", "<cmd>belowright split | terminal python manage.py makemigrations && python manage.py migrate<cr>",
  { desc = "Django makemigrations + migrate" })
map("n", "<leader>rt", "<cmd>belowright split | terminal python manage.py test<cr>",
  { desc = "Django tests" })
