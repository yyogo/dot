#!/usr/bin/python

# This script requires i3ipc-python package (install it from a system package manager
# or pip).
# It adds icons to the workspace name for each open window.
# Set your keybindings like this: set $workspace1 workspace number 1
# Add your icons to WINDOW_ICONS.
# Based on https://github.com/maximbaz/dotfiles/blob/master/bin/i3-autoname-workspaces

import argparse
import i3ipc
import logging
import re
import signal
import sys

logging.basicConfig(level='INFO')

WINDOW_NAMES = {
    "firefox": "ff",
    "alacritty": "term",
    "spotify": "music",
    "telegramdesktop": "chat"
}

#DEFAULT_ICON = "󰀏"


def name_for_window(window):
    app_id = window.app_id
    if app_id is not None and len(app_id) > 0:
        app_id = app_id.lower()
        if app_id in WINDOW_NAMES:
            return WINDOW_NAMES[app_id]
        logging.info(
            "No icon available for window with app_id: %s" % str(app_id)
        )
    else:
        # xwayland support
        class_name = window.window_class
        if len(class_name) > 0:
            class_name = class_name.lower()
            if class_name in WINDOW_NAMES:
                return WINDOW_NAMES[class_name]
            logging.info(
                "No icon available for window with class_name: %s" % str(class_name)
            )
    return None


def rename_workspace(ipc, workspace):
    name_parts = parse_workspace_name(workspace.name)
    name = None
    t = ipc.get_tree()
    for wid in workspace.focus:
        w = t.find_by_id(wid)
        if w.app_id is not None or w.window_class is not None:
            name = name_for_window(w)
            if name:
                break
            #if not ARGUMENTS.duplicates and icon in icon_tuple:
            #    continue
            #icon_tuple += (icon,)
    name_parts["shortname"] = name
    new_name = construct_workspace_name(name_parts)
    if new_name != workspace.name:
        ipc.command('rename workspace "%s" to "%s"' % (workspace.name, new_name))

def rename_workspaces(ipc):
    t = ipc.get_tree()
    for workspace in t.workspaces():
        rename_workspace(ipc, workspace)


def undo_window_renaming(ipc):
    for workspace in ipc.get_tree().workspaces():
        name_parts = parse_workspace_name(workspace.name)
        name_parts["icons"] = None
        name_parts["shortname"] = None
        new_name = construct_workspace_name(name_parts)
        ipc.command('rename workspace "%s" to "%s"' % (workspace.name, new_name))
    ipc.main_quit()
    sys.exit(0)


def parse_workspace_name(name):
    return re.match(
        "(?P<num>[0-9]+):?(?P<shortname>\w+)? ?(?P<icons>.+)?", name
    ).groupdict()


def construct_workspace_name(parts):
    new_name = str(parts["num"])
    if parts["shortname"] or parts["icons"]:
        new_name += ":"

        if parts["shortname"]:
            new_name += parts["shortname"]

        if parts["icons"]:
            new_name += " " + parts["icons"]

    return new_name


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="This script automatically changes the workspace name in sway depending on your open applications."
    )
    parser.add_argument(
        "--duplicates",
        "-d",
        action="store_true",
        help="Set it when you want an icon for each instance of the same application per workspace.",
    )
    parser.add_argument(
        "--logfile",
        "-l",
        type=str,
        default="/tmp/sway-autoname-workspaces.log",
        help="Path for the logfile.",
    )
    args = parser.parse_args()
    global ARGUMENTS
    ARGUMENTS = args

    logging.basicConfig(
        level=logging.INFO,
        filename=ARGUMENTS.logfile,
        filemode="w",
        format="%(message)s",
    )

    ipc = i3ipc.Connection()

    for sig in [signal.SIGINT, signal.SIGTERM]:
        signal.signal(sig, lambda signal, frame: undo_window_renaming(ipc))

    def window_event_handler(ipc, e):
        if e.change in ["new", "close", "move"]:
            rename_workspaces(ipc)
        if e.change in ["focus"]:
            rename_workspace(ipc, ipc.get_tree().find_focused().workspace())

    ipc.on("window", window_event_handler)

    rename_workspaces(ipc)

    ipc.main()
