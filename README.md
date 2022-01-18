# Neovim ALS GPR project selector

This is a Neovim plugin for configuring ALS via LSP, allowing you to select the GPR project to use.

# The problem

When working with Ada projects that use .gpr project files (such as [Alire](https://alire.ada.dev/) projects),
the [ada_language_server](https://github.com/AdaCore/ada_language_server) instance used for smart language
based features (autocompletion, goto-definition, find-references, symbol-rename), which Neovim communicates
with using the Microsoft [Language Server Protocol](https://microsoft.github.io/language-server-protocol/),
needs to be told which project file to use. Otherwise, you get this error:

```
LSP[als] More than one .gpr found.
Note: you can configure a project  through the ada.projectFile setting.
```

This error also props up whenever you open an Ada source file outside the directory passed as the root directory
to als. This means that you get hit with this error when `goto-definition` takes you into system-installed
program text (such as the GNAT runtime).

The .gpr project file determines which source files to include, and how to configure the preprocessor (if any),
so there is no way to correctly implement smart language based features without the right project. See [this
demonstrator project with multiple .gpr files]() as an example, which you can use to test this plugin.

# Solutions

The best solution, in my opinion, is to install this plugin.
However, for completeness in understanding, I list solutions from simplest
to best.

## Hardcoded projectfile

The note in the error message comes from ALS, and asks you to set `ada.projectFile`. The minimal way using
[lspconfig](https://github.com/neovim/nvim-lspconfig) would be:

```
require("lspconfig").als.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ada = {
      projectFile = "/home/tama/code/ada/test_multigpr/one.gpr"
    }
  }
}
```

## Per-project configuration file

There is a solution [discussed here](https://neovim.discourse.group/t/lsp-project-specific-settings/541/2)
involving reading json files left in the project directory and using that to set the projectFile. As of
writing, there is no finished code ready to use for als. Although it is clear that this approach would
work, it would require a separate json file for each directory, to be modified by hand whenever needing
to switch projects.

## Installing gpr_selector

Install the plugin in the usual way, and also [lspconfig](https://github.com/neovim/nvim-lspconfig):

```
Plug 'TamaMcGlinn/vimlsp_gpr_selector'
Plug 'neovim/nvim-lspconfig'
```

Then add this to your language server setup section:

```
require("lspconfig").als.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  on_init = require("gpr_selector").als_on_init
}
```

Optionally map the GPRSelect command:

```
nnoremap <leader>rs :GPRSelect<CR>
```

### Usage:

Instead of the error 'more than one .gpr found',
you will be faced with a menu:

```
Choose a GPR project file:
[1] /home/tama/code/ada/test_multigpr/one.gpr
[2] /home/tama/code/ada/test_multigpr/test_multigpr.gpr
[3] /home/tama/code/ada/test_multigpr/two.gpr
```

This .gpr file will be remembered throughout the vim session, so you only need to do this once and don't
need to bother about it when looking at system-installed program text. However, if you decide to switch,
you can issue the command: `:GPRSelect` to show the menu again. If you issue it while a .gpr file is open,
that file is selected without needing the menu.
