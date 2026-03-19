# MakeRW

A tool to make read-only paths writable without modifying the rootfs. Supports persisting changes across reboots.

## Usage

```bash
# Create writable overlay (make a RO directory RW)
makerw create /usr/local/lib/

# Modify files in the directory
echo "foo" > /usr/local/lib/new_file

# Save changes to persist after reboot
makerw commit /usr/local/lib/

# After reboot, restore overlays to the saved state:
makerw reapply

# And the test file should still be there
cat /usr/local/lib/new_file
> foo
```
