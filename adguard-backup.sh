#!/bin/sh
export BORG_REPO=/mnt/Sicherungen/Backup
# Euer Passwort muss hier hinterlegt werden.
export BORG_PASSPHRASE='Fabio2006!'
 
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup unterbrochen >&2; exit 2' INT TERM
 
info "Start backup"
 
# Hier wird das Backup erstellt, passt das so an wie Ihr das gerne haben möchtet
borg create                         \
    --stats                         \
    --compression lz4               \
    ::'AdGuardHome-{now}'            \
    /var/log/                        \
    /opt/AdGuardHome/    
 
backup_exit=$?
 
info "Loeschen von alten Backups"
# Automatisches löschen von alten Backups
borg prune                          \
    --prefix '{hostname}-'          \
    --keep-daily    1               \
    --keep-weekly   7               \
    --keep-monthly  6
 
prune_exit=$?
 

# Informationen ob das Backup geklappt hat.
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
 
if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi
 
exit ${global_exit}
