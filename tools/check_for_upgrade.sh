#!/usr/bin/env zsh

zmodload zsh/datetime

function _current_epoch() {
  echo $(( $EPOCHSECONDS / 60 / 60 / 24 ))
}

function _update_zsh_update() {
  echo "LAST_EPOCH=$(_current_epoch)" >! ~/.zsh-update
}

function _upgrade_zsh() {
  /bin/bash $HOME/.dotfiles/script/upgrade
  # update the zsh file
  _update_zsh_update
}

epoch_target=$UPDATE_ZSH_DAYS
if [[ -z "$epoch_target" ]]; then
  # Default to old behavior
  epoch_target=13
fi

# Cancel upgrade if the current user doesn't have write permissions for the
# oh-my-zsh directory.
[[ -w "$ZSH" ]] || return 0

if [ -f ~/.zsh-update ]
then
  . ~/.zsh-update

  if [[ -z "$LAST_EPOCH" ]]; then
    _update_zsh_update && return 0;
  fi

  epoch_diff=$(($(_current_epoch) - $LAST_EPOCH))
  if [ $epoch_diff -gt $epoch_target ]
  then
    if [ "$DISABLE_UPDATE_PROMPT" = "true" ]
    then
      _upgrade_zsh
    else
      echo "Would you like to check for updates (my update script)?"
      echo "Type Y to update sytem, prelude, oh-my-zsh and dotfiles: \c"
      read line
      if [ "$line" = Y ] || [ "$line" = y ] || [ -z "$line" ]; then
        _upgrade_zsh
      else
        _update_zsh_update
      fi
    fi
  fi
else
  # create the zsh file
  _update_zsh_update
fi
