# Pocket Orchestra [ORCHESTRA-PLAN]

Phones as instruments around one desktop session host: LAN WebSockets, host-generated audio, three instruments and native and canvas presentations across macOS, Windows, iOS, Android and web; Linux is a follow-on target, and Linux hosting, trusted HTTPS/WSS, motion instruments, saved compositions, event recordings and replay, external lighting and Internet relay each need a follow-up scope decision [ORCHESTRA-PLAN-LATER]. `@osprey/synth` owns the DSP. Commands are in the [README](https://github.com/Nimblesite/osprey/blob/main/src/osprey/examples/pocket_orchestra/README.md): `make -C src/toolchain/targets/macos pocket-orchestra`, `make -C src/toolchain/targets/tests pocket-orchestra`, `make -C src/toolchain/targets/macos/tests pocket-orchestra-headless`.

## Feasibility [ORCHESTRA-PLAN-SPIKE]

- [ ] Native capabilities, host canvas support, multitouch, audio and transport adapters inventoried with implementation evidence per platform against [ORCHESTRA-PLATFORMS]; reference hardware, latency distributions, audio buffers and frame timings recorded; failed feasibility criteria resolved before instruments are built out [ORCHESTRA-PLAN-SPIKE].
- [ ] A physical phone sends start, update and end events to a desktop through a bidirectional WebSocket adapter, with host acknowledgements and voice release on disconnect [ORCHESTRA-PLAN-SPIKE].
- [ ] Continuous audio output and simultaneous voices on macOS and Windows, with physical input-to-speaker latency measured against [ORCHESTRA-ACCEPTANCE] [ORCHESTRA-PLAN-SPIKE].
- [ ] The controller served from the desktop: local-network permission and HTTP/WebSocket behaviour verified in mobile Safari, Chromium and Firefox, with the supported local deployment procedure recorded; native controls beside a canvas and a switch to canvas-rendered controls proven on each required host, with simultaneous touches and accessible actions [ORCHESTRA-PLAN-SPIKE].
- [ ] Canonical models declared in typeDiagram, generation verified for Osprey and the required host bindings, JSON and TDBIN compared for codec support, framing and payload size, and the protocol recorded [ORCHESTRA-PLAN-SPIKE].

## Shared session core [ORCHESTRA-PLAN-CORE]

- [ ] Typed session transitions, admission, roster, player ownership, sequence and epoch validation and state snapshots [ORCHESTRA-NETWORK-PROTOCOL]; bounded queues, update coalescing, heartbeat expiry, reconnect and explicit voice release [ORCHESTRA-NETWORK-TIMING].
- [ ] Production and deterministic test handlers for the effects in [ORCHESTRA-EFFECTS], reusing the native capability boundary and the standard diagnostics package [ORCHESTRA-PLAN-CORE].
- [ ] Complete ensemble scenarios on a virtual clock with in-memory peers, including malformed events, denied roles, congestion and suspension, each linked to its spec ID [ORCHESTRA-PLAN-CORE].

## Playable desktop host and first controller [ORCHESTRA-PLAN-ENSEMBLE]

- [ ] macOS and Windows host adapters for transport, continuous audio, output selection and lifecycle, with application decisions in Osprey [ORCHESTRA-PLAN-ENSEMBLE].
- [ ] Percussion end to end from phone touch through authenticated networking to host sound and the shared stage; bass ribbon and chord field with shared key and scale selection, instrument changes and per-player volume and mute [ORCHESTRA-PLAN-ENSEMBLE].
- [ ] Conductor admission, connection health, QR and manual joining, master volume and Silence; both timing modes, accepted-event timestamps and remote stage clock estimation [ORCHESTRA-PLAN-ENSEMBLE].
- [ ] Device loss, host sleep, stalled peers and shutdown while notes are active, and the eight-controller workload, tested; a real ensemble performance through one speaker output with bounded resources and no stuck voices [ORCHESTRA-PLAN-ENSEMBLE].

## Platform and widget coverage [ORCHESTRA-PLAN-HOSTS]

- [ ] Native iOS and Android controllers on the shared Osprey core with local-network permissions, cancellation and foreground recovery; browser controllers and stage viewers served by the desktop host; the additional desktop controller mode on macOS and Windows; `pocket-orchestra` launch targets in the windows, ios, android and web Makefiles [ORCHESTRA-PLAN-HOSTS].
- [ ] Both presentations on every platform in [ORCHESTRA-PLATFORMS], with switching tested while connected, while holding a note and after a reconnect; native control classes, semantic HTML, canvas interaction, accessible equivalents, reduced motion, large text, safe areas and resizing verified [ORCHESTRA-PLAN-HOSTS].
- [ ] Windows packaged with WinUI and MSIX AppContainer capabilities; LAN hosting and local client connections verified under the installed package's actual restrictions, any sandbox exception documented with evidence [ORCHESTRA-PLAN-HOSTS].

## Delivery evidence [ORCHESTRA-PLAN-DELIVERY]

- [ ] Host implementation in the existing `src/toolchain/hosts/` platforms with shared recipes in `scripts/make/`, and view and instrument logic shared across presentations [ORCHESTRA-PLAN-DELIVERY].
- [ ] `pocket-orchestra` and `pocket-orchestra-headless` test targets on every delivered platform (macOS and the host-free suite exist), with app-specific diagnostics under `target/` [ORCHESTRA-PLAN-DELIVERY].
- [ ] Reviewed platform screenshot goldens, accessibility journeys, audio assertions, transport integration tests and measured physical-device acceptance runs; physical iPhone and Android to speaker latency measured on Wi-Fi with device and browser versions recorded; physical output-route switching verified [ORCHESTRA-PLAN-DELIVERY] [ORCHESTRA-PLAN-PLAYABLE].
- [ ] Build and static analysis, cached parallel testing with coverage, then the coverage check, wired into the required CI phases with package coverage thresholds retained or raised [ORCHESTRA-PLAN-DELIVERY].
- [ ] Static duplication analysis on the implementation, host adapters reviewed for duplicated application logic, and model generation reproducible [ORCHESTRA-PLAN-DELIVERY].
- [ ] The [ORCHESTRA-ACCEPTANCE] evidence completed with actual browser versions, operating systems, device models and measured limits; installation, starting a session, joining, permission recovery and LAN troubleshooting documented with the actual app commands [ORCHESTRA-PLAN-DELIVERY].
- [ ] Host echo and reverb storage extracted into reusable synth graph processors, with alias rejection and physical-device latency measured [ORCHESTRA-PLAN-SOUND].
