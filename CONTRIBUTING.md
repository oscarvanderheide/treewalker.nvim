# Contributing

Thank you for contributing to Treewalker!

## Getting started

* The way this project is set up for development assumes you are using lazy and have that installed. (see minimal_init.lua)
* It also assumes you have plenary and nvim-treesitter installed via lazy

## Things to know

* See the Makefile for tasks
* `make check` will run everything you need to be sure things are healthy
* in your lazy config, set dir = "<the plugin's dir>"
* use util.R in init.lua for the plugin to hot reload in your current dev environment
* use `util.log` to print to the fs, and `tail -f ~/.local/share/nvim/treewalker/debug.log` to read from it
* I often dev with a `make-test` in one small terminal pane, and `tail -f ...` in another
* require("treewalker.nodes") has some logging utilities
  - nodes.log(node) will print some info on the node
  - nodes.log_parents(node) will print the parent hierarchy up a handful of parents
