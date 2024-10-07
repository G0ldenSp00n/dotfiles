if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias vim="nvim"
alias cfg:m1l="cp ~/.config/alacritty/alacritty-m1-lap.toml ~/.config/alacritty/alacritty.toml"
alias cfg:m1d="cp ~/.config/alacritty/alacritty-m1-desktop.toml ~/.config/alacritty/alacritty.toml"
alias cfg:framel="cp ~/.config/alacritty/alacritty-frame-lap.toml ~/.config/alacritty/alacritty.toml"
alias cfg:framed="cp ~/.config/alacritty/alacritty-frame-desktop.toml ~/.config/alacritty/alacritty.toml"
alias cfg:spoonboxd="cp ~/.config/alacritty/alacritty-frame-desktop.toml ~/.config/alacritty/alacritty.toml"
alias cfg:workd="cp ~/.config/alacritty/alacritty-work-desktop.toml ~/.config/alacritty/alacritty.toml"
alias cfg:workdL="cp ~/.config/alacritty/alacritty-work-desktop-large-font.toml ~/.config/alacritty/alacritty.toml"
alias cfg:workl="cp ~/.config/alacritty/alacritty-work-laptop.toml ~/.config/alacritty/alacritty.toml"

set -l os (uname)
if test "$os" = "Darwin"
  set -gx EDITOR /opt/homebrew/bin/nvim
else if test "$os" = "Linux"
  set -gx EDITOR /usr/sbin/nvim
end
set fish_greeting
