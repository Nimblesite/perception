# Patch editor and instrument builder

## Patch editor [STUDIO-ROUTING-EDITOR]

The Track patch page is Perception Studio's modular instrument editor for `@osprey/synth`: node cards, cables, an inspector and meters on one canvas. Its native component picker, port controls and parameter fields share one typed graph with the canvas. A new patch starts with an oscillator, filter, gain and output.

- **Modules.** **Patch Controls → Add component** inserts a built-in module or a discovered VST3 instance: grain clouds, sine oscillators, low-pass filters, gains, mixers, delays, MIDI note generators, formula melodies ([SYNTH-FORMULA-NOTES]), normalised LFOs, stereo conversion, modulated stereo gain and mono or stereo outputs. Selecting a module edits its parameters, checked against its descriptor. Right-click a module and choose **Delete node** to remove it and its cables.
- **Validation.** The graph library checks port rates, units, channel counts and feedback cycles. A rejected edit leaves the previous graph unchanged.
- **Undo.** Undo and Redo restore every edit, including a deleted node with its cables ([DAW-HUMAN]).
- **Heard only through Master ([DAW-GRAPH-OUTPUT]).** A patch is heard only as part of the project graph, through Master, when the song plays. There is no Play patch, no Audition and no on-screen keyboard that sounds a patch by itself.

### Cables [STUDIO-ROUTING-CABLES]

Drag from an output socket to a compatible input socket to draw a cable, or click the output and then the input. LFOs route to compatible effect parameters. Click an exposed cable to highlight it, then click **Delete cable ×** or press **Backspace** or **Delete**. **Escape** cancels a pending connection. A rejected connection keeps the existing cables. The Filter's purple **CUTOFF** input takes normalised modulation; unplugged, the Cutoff value applies. Its cyan monitor socket routes the same audio output to the Scope.

### VST3 plug-ins [STUDIO-ROUTING-VST]

**File → Settings…** sets the VST3 folder. Perception Studio discovers plug-ins in the background at startup and whenever a new folder is saved. For now, each bundle runs in its own Perception Modular worker process. This is a **temporary workaround** until Studio hosts VST3 directly ([SYNTH-HOST-VST-TEMPORARY], [SYNTH-HOST-VST-INPROCESS]). Its instruments and effects appear in **Add component** as independent instances. A failed scan or descriptor is reported, never replaced with a fake success.

### Grain cloud [SYNTH-ADVANCED-GRAINS-INTEGRATION]

**Add component → Grain cloud** adds an independent granular instrument whose card shows its real source waveform. It starts with a built-in 1,024-frame harmonic sample. With playback stopped, select the cloud, open **Patch controls** and choose **Load WAV sample**; **Use built-in harmonic sample** restores the original. The import accepts what `WaveImport.decode` accepts ([SYNTH-ADVANCED-GRAINS-PLAYBACK]), takes middle C (MIDI 60) as the root, and averages stereo to mono. A cancelled choice or failed import keeps the current source. Undo and Redo keep samples in patch history.

Connect its stereo output to **Stereo output**, or through **Modulated stereo gain** and compatible stereo effects. A patch plays through exactly one output, so the old mono output is removed when replacing the initial patch. **Patch controls** edits source position, playback rate, grain duration, per-grain gain, pan, onset interval and timing jitter. Timing fields are whole 48 kHz frame counts, and jitter must be less than the onset interval. Zero rate holds a position and a negative rate reverses. The default pool allows 16 overlapping grains and reports exhaustion explicitly.

## Instrument builder [STUDIO-INSTRUMENT]

Status: specified, not built. The synth package's `Macros` module validates and applies macros today ([SYNTH-ADVANCED-STUDIO]); Perception has no instrument face yet. The [instrument builder plan](../../plans/studio/studio.md#instrument-face-studio-instrument-face) tracks delivery. The [design screenshots](../../designs/studio-timeline/README.md#instrument-builder-studio-instrument) show Play, Edit and MIDI learn.

This contract belongs to [Perception Studio](studio.md): an instrument is stored in the project file and played through the project graph ([DAW-GRAPH-OUTPUT]).

An instrument is a patch with a performer's face on it. The patch keeps its modules and cables; the instrument hides them and shows only the controls the user chose. Each control is a **macro**: one knob, slider, toggle or pad that moves one or more module parameters at once (Brightness turning a filter's cutoff up and its resonance down, for example). The instrument is stored with its patch in the project file ([DAW-PROJECT-PATCH]), so reopening the project restores the same face.

- **Two modes ([STUDIO-INSTRUMENT-MODES]).** A patch has a Patch view (the canvas) and an Instrument view. The Instrument view is in Play mode or Edit mode, switched by a command with a shortcut in every keymap ([DAW-KEYS]). Switching views or modes never changes a value or the sound.
- **Play mode ([STUDIO-INSTRUMENT-PLAY]).** Only the instrument's controls are shown; no module, cable or socket is visible. Turning a control moves its macro as one undoable edit ([DAW-CONTROLS], [DAW-HUMAN]), and the patch is heard through Master as always ([DAW-GRAPH-OUTPUT]). Notes from the MIDI keyboard play the instrument as they play the track ([DAW-MIDI-PLAY]).
- **Edit mode ([STUDIO-INSTRUMENT-EDIT]).** The user adds a control from the list of control kinds, then moves it by dragging, resizes it by its handles and places it anywhere on the instrument's face, snapping to the Perception spacing grid. They rename its label, choose its kind and delete it. Controls keep their size when the window resizes ([DAW-LAYOUT-FIXED-SCALE]). Each change is one undo step.
- **Macro mappings ([STUDIO-INSTRUMENT-MACRO]).** In Edit mode a control lists its targets: a module parameter each, with a range (from and to, which may be reversed) and a curve. One control can drive many parameters, and one parameter can be driven by at most one macro, so no two controls fight over a value. A target whose module is deleted from the patch is removed from the macro with a notice naming it; a macro left without targets is shown as unmapped, never silently dropped. Mappings use the synth package's `Macros` (declared ranges, curves, smoothing), so a macro moves exactly the values a dial on the module would.
- **MIDI and OSC control ([STUDIO-INSTRUMENT-REMOTE]).** Each control can be bound to a MIDI controller by moving it while the control is in learn ([DAW-MIDI-LEARN]), and has an OSC address `/track/<n>/instrument/<control>` ([DAW-OSC-ADDRESS]) so a phone surface such as TouchOSC drives it. Bindings are stored with the instrument. A remote change goes through the same checked edit as a turn on screen ([DAW-OSC-CHECK]), and the control on screen follows it; changed values are sent back to subscribed OSC peers ([DAW-OSC-FEEDBACK]).
- **Accessible ([DAW-ACCESS]).** Every instrument control reports its user-given name, value, range and kind, takes keyboard focus in its layout order and steps by arrow keys.

### Macros in the patch [STUDIO-INSTRUMENT-PATCH]

A macro belongs to the patch, not to the screen. The synth package's `PatchDocument` already holds `macros` beside its nodes and cables ([SYNTH-GRAPH]), so a patch saved, copied to another track or deployed to a device carries its macros with it. The face (control kinds, positions, sizes and labels) is stored beside the patch in the project file, because it is presentation. A macro's current amount, from 0 to 1, is saved with the patch, so reopening the project or loading the patch on a device starts from the same sound.

- **Amount is the only state ([STUDIO-INSTRUMENT-AMOUNT]).** A macro stores its amount; each target value is computed from it by `Macros.apply` and never stored twice. Turning a module dial that a macro drives detaches that target from the macro with a notice naming both, so the two never disagree.
- **Smoothing ([STUDIO-INSTRUMENT-SMOOTH]).** Amount changes reach the audio as ramps through the synth package's `Smoothers` with a declared time (default 20 ms), never as steps, in Perception and on a device alike ([SYNTH-RENDER]).
- **Curves ([STUDIO-INSTRUMENT-CURVE]).** A target's curve is its `exponent`, from 0.25 to 4, as `Macros` checks today. Reversed ranges are allowed. The mapping from amount to value is monotone and stays inside the target's range; that is a proof obligation ([STUDIO-INSTRUMENT-PROOF]).

### Device faces [STUDIO-INSTRUMENT-DEVICE]

A screen face can be any shape; a hardware face cannot. A **device profile** ([DEVICE-PROFILE]) lists a device's physical controls: their kinds, positions and labels. Choosing a profile for a patch's instrument switches Edit mode to a **device face**: the controls are the device's own, drawn where they sit on the box, and cannot be added, moved, resized or deleted. The user assigns a macro to each physical control instead.

- **Assigning ([STUDIO-INSTRUMENT-DEVICE-ASSIGN]).** Each physical control takes at most one macro; each macro sits on at most one physical control. A macro with no physical control can still be set from Perception and by MIDI. A physical control with no macro is shown as unassigned on screen and does nothing on the device.
- **Kinds must fit ([STUDIO-INSTRUMENT-DEVICE-KIND]).** A knob takes a continuous macro. A two-way switch takes a macro played at 0 or 1, and a three-way switch at 0, 0.5 or 1. A footswitch takes a macro it toggles or holds, chosen per assignment. A macro whose control kind does not match is refused with the reason, never converted silently.
- **One patch, many faces ([STUDIO-INSTRUMENT-DEVICE-FACES]).** A patch keeps its screen face and one device face per profile it has been assigned to. Switching between them never changes a value or the sound ([STUDIO-INSTRUMENT-MODES]).
- **Panel labels ([STUDIO-INSTRUMENT-DEVICE-LABELS]).** From a device face, Perception exports a printable panel overlay: an SVG at the profile's panel size with each control's macro name under it. The overlay is generated when asked and never committed ([REPO-NO-ARTIFACTS]).

### Proof obligations [STUDIO-INSTRUMENT-PROOF]

Per [MATH-CODE], the mapping formulas are written in Osprey and proved in Lean against the shipped source:

- `FitMath.macroValue` is monotone in the amount for every curve from 0.25 to 4, stays within the target's range for every amount from 0 to 1, and returns the range's ends at 0 and 1.
- A switch position maps to exactly one of its declared amounts.
- Each proof fails on a relevant mutation of the source, and runs in CI with the other synth proofs ([SYNTH-DSP-PROOFS-PRODUCTION]).
