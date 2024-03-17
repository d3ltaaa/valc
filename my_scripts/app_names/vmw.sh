LOCATION="/home/falk/Qemu/Win10.img"

  qemu-system-x86_64 \
  -enable-kvm \
  -boot menu=on \
  -drive file="$LOCATION" \
  -m 6G \
  -cpu host \
  -smp 4 \
  -vga virtio \
  -display sdl,gl=on \
  -nic user,hostfwd=tcp::6022-:22,hostfwd=tcp::5900-:5900 
  # -cdrom ~/Downloads/Win_C_10.iso \
