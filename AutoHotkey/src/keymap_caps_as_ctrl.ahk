#Requires AutoHotkey v2.0

; CapsLock を完全に Ctrl として扱う
SetCapsLockState "AlwaysOff"

; 将来 Hyper キー化する場合はここで条件分岐する
; CapsLock: Ctrl として入力する
CapsLock::Ctrl
