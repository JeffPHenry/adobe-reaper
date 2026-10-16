# adobe-reaper

**Your Mac is not Adobe's server farm.**

Close Photoshop and Adobe leaves a dozen processes running anyway: Creative Cloud, Adobe Desktop Service, Core Sync, CCXProcess, AdobeIPCBroker, the crash processor, a stack of "UI Helper" renderers, and more. They use RAM and CPU and phone home all day, for an app you aren't using.

`adobe-reaper` is a tiny shell script plus a launchd agent. Every 60 seconds it checks whether any Adobe app is open. If one is, it does nothing. If none are, it shuts down the background processes Adobe left behind.

No dependencies and no daemon of its own. About 40 lines of bash.

## What it does

1. **An Adobe app is open?** (Photoshop, Illustrator, Premiere, Lightroom, etc.) → it does nothing. Creative Cloud works normally while you work.
2. **No Adobe app is open?** → it finds your user's processes running from:
   - `/Library/Application Support/Adobe/`
   - `/Applications/Utilities/Adobe *`
   - `/Applications/Adobe Creative Cloud/`
3. It sends them a polite `SIGTERM`, waits 5 seconds, then sends `SIGKILL` to anything still hanging around.
4. It logs what it closed to `~/Library/Logs/adobe-reaper.log`.

It only touches processes owned by **your user**. Nothing runs as root and nothing system-wide is touched.

## Install

```bash
git clone https://github.com/JeffPHenry/adobe-reaper.git
cd adobe-reaper
./install.sh
```

This copies the script to `~/.local/bin/adobe-reaper.sh` and loads a launch agent at `~/Library/LaunchAgents/com.user.adobe-reaper.plist`, which runs at login and every 60 seconds after that.

Want a different interval?

```bash
INTERVAL=300 ./install.sh   # every 5 minutes
```

## Try it first

See what it *would* kill without killing anything:

```bash
./adobe-reaper.sh --dry-run
```

## Watch it work

```bash
tail -f ~/Library/Logs/adobe-reaper.log
```

```
2026-10-16 01:36:45 closing: ACCFinderSync,Adobe Crash Processor,Adobe Desktop Service,AdobeIPCBroker,Core Sync,Creative Cloud,Creative Cloud Content Manager.node,Creative Cloud Helper,Creative Cloud UI Helper,...
```

## Pause / resume

```bash
launchctl unload ~/Library/LaunchAgents/com.user.adobe-reaper.plist   # pause
launchctl load   ~/Library/LaunchAgents/com.user.adobe-reaper.plist   # resume
```

## Uninstall

```bash
./uninstall.sh
```

## Things to know

- **Creative Cloud sync and updates won't run while no Adobe app is open.** That's the point. If you need to install or update something, open the Creative Cloud app while an Adobe app is running, or pause the reaper first.
- **Cloud document sync (Core Sync) stops too** whenever no Adobe app is open. If you rely on files syncing in the background, keep that in mind.
- Adobe may respawn some helpers at login. The reaper will close them again within a minute.
- Tested on macOS Sequoia. It should work on any recent macOS with Adobe apps installed in the default `/Applications` location.

## License

MIT © [Jeff Henry](https://jefferyhenry.com)
