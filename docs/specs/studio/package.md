# How Perception uses the synth package [PERCEPTION-SYNTH]

These rules are about the application, so they are stated here and not in the package specification.

## Showcase songs [SYNTH-SHOWCASE]

The shipped daw songs together play every synthesis family the toolkit has, each on its own audible track: subtractive, FM/phase modulation, phase distortion, wavetable, additive, granular, spectral (morph, freeze and formant pitch), and physical (waveguide string, bowed string, modal bar and bell, mesh membrane, resonator), plus the sampled intro. A test opens each song and checks that every family is present, so a family cannot quietly drop out.

## Reference continuous device execution [SYNTH-DEVICE-QUEUE]

Perception owns one bounded audio-device session. Completed graph blocks are encoded outside the callback and transferred as canonical 48 kHz mono/stereo float32 WAV. macOS queues them through AudioQueue and hosts VST sessions alongside the device. Windows converts the float samples to 16-bit PCM for WinMM and reclaims buffers as the device returns them. Both adapters bound the queue and accept 1–8192 frames with finite samples within -1..1. Invalid layouts, lengths, amplitudes, queue timeouts and mismatched acknowledgments are explicit failures.

Perception transfers 2048 graph frames at a time, while VST processing packets remain at most 256 frames. A typed pending device record retains the exact graph, sample clock and component states until the device acknowledges the transfer. Audio slices are reused across blocks. Audition drains every accepted frame; continuous Play schedules further blocks until Stop. Stop during opening first adopts the returned handle and then releases it, preventing a late-open resource leak. Host shutdown also releases owned sessions.

The reference producer allocates and runs outside the device callback. A native loaded-binary journey streamed 985088 frames through JX10, two ADelay instances, LFO modulation and the real device with zero queue-empty observations, then verified worker disposal. Queue-empty counters record the device's observations. Perception applies graph edits at restart. Transactional live replacement and host latency compensation remain outstanding.

Queue-empty observations must be monotonic within a device session. The controller rejects decreasing counters and retains a visible warning for a nonzero count through the audition completion. The backend emits a structured `audio.queue_empty` diagnostic when that count increases, outside the audio callback. A deliberate producer pause exercises this path on the real device.

Latest verification (2026-11-16): the final sustained native reruns failed the unchanged zero-empty-queue assertion, including a rerun without concurrent test compilation. Earlier successful 985088-frame evidence is not reproducible reliability. Exact finite VST-chain PCM still passes. Continuous playback is experimental pending producer-throughput work; do not treat this branch as release-ready.

## Auditioning a hosted graph

Perception snapshots the graph and plug-in bindings when an audition begins. Editing or deleting a live node cannot change the running snapshot; stale/duplicate process completions cannot advance it. The native journey drives a real mda JX10 through two real ADelay instances and stereo playback, independently checking every effect's PCM against the preceding output. This proves hosted graph playback, not continuous device callbacks or persistence across auditions.

## Formula melodies in the editor

In Perception, choose **Add component → Formula melody**. The inspector's **Formula over step t** field applies a formula when you press Return. A formula that does not parse leaves the patch unchanged, and the editor message names the column. Under the field, the inspector lists the first 16 notes the formula plays, by name, for example `Plays C4 G4 D4 A4 …`. A saved project stores the formula in the patch node's `asset` with the component `formulaNotes`. A stored formula that no longer parses refuses the track with the same fault.

## Perception module interfaces [STUDIO-ADVANCED-UI]

Use the single graph studio, palette, selected inspector, keyboard and transport. Package descriptors give units, limits and availability. Perception's `editor.td` owns selection, job identity and view state. Typed Signals supply applied observations. Stable IDs distinguish duplicate nodes. Provide accessible native controls and keyboard routing. Read bounded snapshots at most 30 Hz. Animation frames never schedule synthesis.

| Module | Node card | Inspector and interaction |
| --- | --- | --- |
| Granular | Source, active/capacity, Size, Density, Freeze, typed ports | Waveform, numeric region endpoints and handles, scan cursor, bounded grain markers, pitch, scan, direction, spread, seed and boundary mode. Distinguish Load sample, Capture, Freeze and Clear capture. |
| Physical | Model, pitch, decay, excitation and energy | Exciter and Body sections, contact/pickup positions and mode spectrum. Strike and keyboard send timestamped gestures. Show applied constrained morph values and selected coupling topology. |
| Neural transfer/DDSP | Model, status, input mode, wet mix and measured latency | Show channels, rate, license, provenance, availability, latent or harmonic/noise controls, confidence, meters and deadline errors. Support load cancellation. |
| Neural codec | Codec, bandwidth and asset status | Encode, Decode, metadata, progress, Cancel and Preview. Bound typed token edits by codec. |
| Text-to-sound | Job status and asset name | Prompt, duration, seed, model, Generate, Cancel, Preview and Insert sample. Retain the previous result during regeneration. Prevent late insertion. |
| Combined method | Texture, Material, Interaction and energy | Shared-body contact map, grain timeline and mode-energy view. Show allowance, constrained updates, seed and controller mode. Offer analytic and learned modes by capability. |

Show Empty, Preparing, Ready, Running and Failed where applicable. Show model/sample errors with retry or replacement. An unavailable processor cannot start playback. Persist versioned parameters, asset/model hashes, seed and intended controller mode. Load missing resources as relinkable unresolved nodes. Undo/redo affects accepted edits and bindings and invalidates pending replies by revision.

Show configured and applied values when they differ. Give every graphic an accessible label and numeric/text alternative, including contact location and modal energy. Order focus from source/model through parameters, routing and actions. Preserve usable ports and unclipped controls during drag, resize, zoom and keyboard navigation. Windows uses WinUI and the per-app sandbox contract. Document file/model capabilities per host.

Drive insertion, two same-kind instances, input selection, editing, modulation, keyboard playing, pointer/keyboard routing, freeze, model switch, cancellation, undo/redo, save/reload and missing-resource recovery through Perception. Headless and windowed journeys compare committed goldens, assert accessible names/focus order and verify actual audio or asset changes. Require a 10-minute maximum-workload device run with zero starvation, measured latency and callback allocation/lock instrumentation on Windows and every other advertised host. Retain existing queue-starvation failures as a delivery dependency.
