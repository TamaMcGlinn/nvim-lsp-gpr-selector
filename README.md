Neovim ALS GPR project selector
===============================

This is a Neovim plugin for configuring ALS via LSP, allowing you to select the GPR project to use.

> [!IMPORTANT]
>
> Requires at least Neovim 0.12

The problem
===========

When working with Ada projects that use .gpr project files (such as [Alire](https://alire.ada.dev/) projects), the [ada_language_server](https://github.com/AdaCore/ada_language_server) instance used for smart language based features (autocompletion, goto-definition, find-references, symbol-rename), which Neovim communicates with using the Microsoft [Language Server Protocol](https://microsoft.github.io/language-server-protocol/), needs to be told which project file to use. Otherwise, you get this error:

```
LSP[als] More than one .gpr found.
Note: you can configure a project  through the ada.projectFile setting.
```

This error also props up whenever you open an Ada source file outside the directory passed as the root directory to als. This means that you get hit with this error when `goto-definition` takes you into system-installed program text (such as the GNAT runtime).

The .gpr project file determines which source files to include, and how to configure the preprocessor (if any), so there is no way to correctly implement smart language based features without the right project. See [this demonstrator project with multiple .gpr files](https://github.com/TamaMcGlinn/test_multigpr) as an example, which you can use to test this plugin.

Solutions
=========

The best solution, in my opinion, is to install this plugin. However, for completeness in understanding, I list solutions from simplest to best.

Hardcoded projectfile
---------------------

The note in the error message comes from ALS, and asks you to set `ada.projectFile`. The minimal way using [lspconfig](https://github.com/neovim/nvim-lspconfig) would be:

```
vim.lsp.enable('ada_ls')
vim.lsp.config('ada_ls', {
  settings = {
    ada = {
      projectFile = "two.gpr";
      -- scenarioVariables = { ... };
    }
  }
})
```

Per-project settings file
-------------------------

If you add a `.als.json` file in the root of your project with local settings:

```
{
   "projectFile": "two.gpr",
}
```

It works. Also, if you have this plugin installed it will not get in your way until you
want to switch project. TODO: A nice feature in future would be to check if the `.als.json` is
gitignored, and if so, update it whenever you switch project using this plugin.

See [the ada_language_server documentation](https://github.com/AdaCore/ada_language_server/blob/master/doc/settings.md) for more fields you can add to .als.json.

Installing gpr_selector
-----------------------

Install the plugin in the usual way, e.g.

```
Plug 'TamaMcGlinn/nvim-lspconfig'
```

Then add this to your language server setup section:

```
require("lspconfig").als.setup{
  on_init = require("gpr_selector").als_on_init
}
```

Optionally map the GPRSelect command:

```
nnoremap <leader>rs :GPRSelect<CR>
```

### Usage:

Instead of the error 'more than one .gpr found', you will be faced with a menu:

```
Choose a GPR project file:
[1] /home/tama/code/ada/test_multigpr/one.gpr
[2] /home/tama/code/ada/test_multigpr/test_multigpr.gpr
[3] /home/tama/code/ada/test_multigpr/two.gpr
```

This .gpr file will be remembered throughout the vim session, so you only need to do this once and don't need to bother about it when looking at system-installed program text. However, if you decide to switch, you can issue the command: `:GPRSelect` to show the menu again. If you issue it while a .gpr file is open, that file is selected without needing the menu.
