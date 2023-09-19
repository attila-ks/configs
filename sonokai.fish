#!/bin/fish

# Sonokai Color Palette.
set -U foreground e2e2e3
set -U selection 3b3e48
set -U red fc5d7c
set -U orange ff9e64
set -U yellow e7c664
set -U green 9ed072
set -U purple b39df3
set -U gray 7f8490

# Syntax Highlighting Colors.
set -U fish_color_normal $foreground
set -U fish_color_command $green
set -U fish_color_keyword $red
set -U fish_color_quote $yellow
set -U fish_color_redirection $purple
set -U fish_color_end $red
set -U fish_color_error $red
set -U fish_color_param $foreground
set -U fish_color_comment $gray
set -U fish_color_selection --background=$selection
set -U fish_color_search_match --background=$selection
set -U fish_color_operator $red
set -U fish_color_escape $green
set -U fish_color_autosuggestion $gray

# Completion Pager Colors.
set -U fish_pager_color_progress $gray
set -U fish_pager_color_prefix $green
set -U fish_pager_color_completion $foreground
set -U fish_pager_color_description $gray
set -U fish_pager_color_selected_background --background=$selection
