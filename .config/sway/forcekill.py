#!/usr/bin/env python
import i3ipc
import os
import sys

conn=i3ipc.Connection()
pid=conn.get_tree().find_focused().pid
os.kill(pid, 15 if len(sys.argv) < 2 else int(sys.argv[1]))


