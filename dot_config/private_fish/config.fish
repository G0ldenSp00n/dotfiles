if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias vim="nvim"
alias cfg:m1l="cp ~/.config/alacritty/alacritty-m1-lap.toml ~/.config/alacritty/alacritty.toml"
alias cfg:m1d="cp ~/.config/alacritty/alacritty-m1-desktop.toml ~/.config/alacritty/alacritty.toml"
alias cfg:framel="cp ~/.config/alacritty/alacritty-frame-lap.toml ~/.config/alacritty/alacritty.toml"
alias cfg:framed="cp ~/.config/alacritty/alacritty-frame-desktop.toml ~/.config/alacritty/alacritty.toml"
alias cfg:spoonboxd="cp ~/.config/alacritty/alacritty-frame-desktop.toml ~/.config/alacritty/alacritty.toml"
set -gx EDITOR /usr/sbin/nvim
set fish_greeting
