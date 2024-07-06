# if status --is-login
#     set -g theme_nerd_fonts yes
#     set PATH /usr/bin $PATH
#     alias ll='ls -al'
# end

if status is-interactive
    set PATH /usr/bin $PATH
    alias ll='ls -al'

    # Commands to run in interactive sessions can go here
    # set -g theme_powerline_fonts yes
    set -g theme_nerd_fonts yes
    # set -g fish_prompt_pwd_dir_length 0
end
