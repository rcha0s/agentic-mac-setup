# Install OpenSuperWhisper (voice dictation)

Kun's voice-input layer. Local Whisper (turbo-v3-large), hotkey-triggered, free.
Third-party app; not distributed via Homebrew's default channels, so we
install manually. On a personal Mac this lands in `/Applications`; on an
enterprise Mac where `/Applications` is locked, use `~/Applications/`
(same pattern as WezTerm).

## Prerequisites

- **Microphone.** Built-in on MacBooks; USB mic works fine.
- **Free disk space.** The model is ~1.5GB; the app itself is small.

## Steps

1. **Download the latest release DMG:**

 ```
 curl -L -o ~/Downloads/OpenSuperWhisper.dmg \
 "https://github.com/Starmel/OpenSuperWhisper/releases/latest/download/OpenSuperWhisper.dmg"
 ```

2. **Mount the DMG:**

 ```
 open ~/Downloads/OpenSuperWhisper.dmg
 ```

 A Finder window opens showing the app.

3. **Drag `OpenSuperWhisper.app` to `/Applications/`** on a personal Mac.
   On an enterprise-managed Mac where `/Applications` is locked, drop it in
   `~/Applications/` instead (both are valid; Spotlight finds either).

4. **Eject the DMG** and delete the download:

 ```
 diskutil eject "/Volumes/OpenSuperWhisper"
 rm ~/Downloads/OpenSuperWhisper.dmg
 ```

5. **First launch:**

 ```
 open -a OpenSuperWhisper
 ```

 macOS will show "Downloaded from Internet, are you sure?" Click **Open**.
 Grant mic permission when prompted.

6. **Configure hotkey and model:**

 - Open the app's preferences (menu bar icon)
 - Choose the model: start with **turbo-v3-large** if you have the disk
 space, else **turbo** or **base** for a smaller footprint
 - Bind a hotkey: Kun uses **Fn** or **⌥Space**; pick something that
 doesn't collide with existing shortcuts

## Using it

- Focus any text field
- Press the hotkey → speak → release the hotkey
- Transcription appears at the cursor

Works everywhere: Claude Code prompts, WezTerm, Neovim insert-mode buffers,
Slack, browser text fields. Kun uses it for prompts and prose.

## If you'd rather not install it

Voice input is optional. Kun considers it a productivity multiplier but not
required. Type your prompts if you prefer.

## References

- Repo: <https://github.com/Starmel/OpenSuperWhisper>
- Latest releases: <https://github.com/Starmel/OpenSuperWhisper/releases>
- Kun mentions it in the "Input & memory" section of his workflow video
 ([iQyg-KypKAA](https://youtu.be/iQyg-KypKAA), chapters 10–14, 20).
