# Security review, OpenSuperWhisper

**Submitter:** Rohan Isawe
**App:** OpenSuperWhisper by Starmel
**Version reviewed:** 0.1.0 (latest as of 2026-07-04)
**Purpose of request:** Local, offline voice-to-text dictation on my work Mac to replace typing for prompts, meeting notes, and technical writing.

---

## Summary

OpenSuperWhisper is a fully **local, on-device** speech-to-text app for macOS. It uses open-source ASR (Automatic Speech Recognition) engines (Whisper.cpp or NVIDIA Parakeet) running entirely in-process on the Mac. **No audio or transcription data is sent to any external server.**

The only network activity is a one-time download of the model file (~1.6 GB) from HuggingFace or the FluidAudio release page. After that, the app functions fully offline.

---

## Data handling

| Data | Where it goes |
|---|---|
| Microphone audio | Never leaves the machine. Consumed in-process by the local ASR engine. |
| Transcribed text | Written directly into the currently-focused text field on the local Mac. |
| Model weights | Downloaded once from HuggingFace / FluidAudio; static file on disk thereafter. |
| Telemetry / analytics | None declared. No login, no account, no API key. |

The transcription pipeline is: **Microphone → local ASR engine (whisper.cpp or Parakeet, in-process) → active text field.** No cloud round-trip.

---

## Why this is different from cloud dictation

Confidential Smartsheet content (architecture, tickets, threat models, code review notes, internal discussions) can be transcribed without any of it reaching:
- OpenAI (creator of Whisper: provides only the static model weights, does not receive user audio)
- NVIDIA (creator of Parakeet: same, released the weights)
- Any SaaS provider

This is why local Whisper is preferred over Whisper API, macOS "Enhanced Dictation" (Apple-server-side), or Otter.ai for enterprise use.

---

## Ways to verify the local-only claim

Any of the below can be run by IT to confirm:

1. **Airplane-mode test.** Disable Wi-Fi after model download. App continues to transcribe.
2. **Firewall block.** Add a Little Snitch / macOS firewall rule denying network access to `OpenSuperWhisper.app`. Transcription still works.
3. **Live network inspection:** `sudo lsof -i -P -n | grep -i "OpenSuperWhisper\|whisper"` during transcription. Zero outbound connections.

---

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Unsigned third-party binary | App is MIT-licensed with public source. Can build locally (`./run.sh build`) if signed-binary policy requires it. Source repo: [Starmel/OpenSuperWhisper](https://github.com/Starmel/OpenSuperWhisper). |
| Sparkle-based auto-update may phone home | Update-check pings HuggingFace-hosted release manifests, not a proprietary telemetry endpoint. Can be disabled in-app if required. |
| Microphone access on corp Mac | Requires an explicit macOS mic-permission grant on first launch. Same permission model as Slack, Zoom, Teams. |
| Location of the model file | Stored under app-managed directory in `~/Library/`. Not sensitive; can be deleted anytime. |
| App not on Workbrew allowlist | This request seeks approval to sideload to `~/Applications/`. Direct download from official GitHub release: [OpenSuperWhisper.dmg](https://github.com/Starmel/OpenSuperWhisper/releases/latest/download/OpenSuperWhisper.dmg). |

---

## Alternatives considered

| Alternative | Reason not chosen |
|---|---|
| macOS built-in dictation | "Enhanced Dictation" is server-side (Apple): confidential content leaves the device. |
| Whisper API (OpenAI cloud) | Cloud round-trip; audio content sent to OpenAI. Not enterprise-safe. |
| Otter.ai / Rev / SpeakEasy | SaaS; all audio uploaded. Not enterprise-safe. |
| Do without voice input | Loses productivity gain (Kun Chen's video shows ~5x prompt throughput). |

Only OpenSuperWhisper delivers **local execution + open source + no data egress**.

---

## References

**Product**
- Official repository: <https://github.com/Starmel/OpenSuperWhisper>
- License: MIT: <https://github.com/Starmel/OpenSuperWhisper/blob/main/LICENSE>
- Latest release: <https://github.com/Starmel/OpenSuperWhisper/releases/latest>
- Build/CI workflow (proves reproducible build): <https://github.com/Starmel/OpenSuperWhisper/blob/main/.github/workflows/build.yml>

**Underlying engines (both open source, both run locally)**
- Whisper.cpp: <https://github.com/ggerganov/whisper.cpp>
- Parakeet via FluidAudio: <https://github.com/AntinomyCollective/FluidAudio>

**Model weights (one-time download, then offline)**
- Whisper models on HuggingFace: <https://huggingface.co/ggerganov/whisper.cpp/tree/main>
- Parakeet by NVIDIA: <https://github.com/NVIDIA/parakeet>

**Original model releases (context)**
- Whisper by OpenAI (open-source release, September 2022): <https://openai.com/research/whisper>
- Whisper GitHub: <https://github.com/openai/whisper>
- NVIDIA Parakeet paper / release: <https://huggingface.co/nvidia/parakeet-tdt-1.1b>

**Business context**
- Setup this fits into: <https://github.com/rcha0s/agentic-mac-setup>
- Kun Chen's L8 agentic engineering workflow video (context for why local voice matters in this workflow): <https://youtu.be/iQyg-KypKAA> (Chapters 10–14, 20 cover Input & Memory)

---

## Request

Approval to install OpenSuperWhisper to `~/Applications/` on my work Mac (`risawe`), grant microphone permission, and use it for local voice dictation. No system-wide changes required.

If preferred, I am willing to:
- Build the app from source under IT supervision
- Provide `lsof` output during a test session
- Run it in a policy-mode with auto-update disabled and mic-access reviewed
