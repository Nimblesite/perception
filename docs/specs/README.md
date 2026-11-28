# Perception specifications

What Perception is, who it is for and how it is described come from the [Perception messaging](../messaging/perception%20messaging.md); these specifications state the requirements behind it. [All Osprey specification subjects](https://github.com/Nimblesite/osprey/blob/main/docs/specs/README.md).

**Perception Studio** is a modular synth daw (Studio *is* the daw, one app), a VST3 plug-in and host, and a hardware synth factory: a patch is played in Studio, loaded inside another daw as the **Perception Modular** VST3 plug-in, or flashed to a device that runs it with no computer. All of it is built on the synth package `@osprey/synth`; the package never depends on Perception. The synthesis engine must get much faster, most of all on the device: see [DEVICE-PERF](device/device.md).

## Synth package `@osprey/synth`

- [Graph, signals and rendering](synth/graph.md) [SYNTH] [SYNTH-GRAPH] [SYNTH-SIGNALS] [SYNTH-RENDER]
- [DSP, spectral processing and formula melodies](synth/dsp.md) [SYNTH-DSP] [SYNTH-SPECTRAL] [SYNTH-FORMULA-NOTES]
- [VST3 hosting and hosted graphs](synth/vst-hosting.md) [SYNTH-HOST-VST] [SYNTH-HOST-STREAM]
- [Grains and advanced synthesis](synth/advanced.md) [SYNTH-ADVANCED]
- [Research sources](synth/research.md) [SYNTH-RESEARCH]

## Perception Studio

- [Perception Studio](studio/studio.md) [DAW]
- [Patch editor and instrument builder](studio/patch-editor.md) [STUDIO-ROUTING-EDITOR] [STUDIO-INSTRUMENT]
- [How Studio uses the synth package](studio/package.md) [PERCEPTION-SYNTH]

## Perception device

- [Device, firmware and engine](device/device.md) [DEVICE-PERF] [DEVICE]
- [Hardware](device/hardware.md) [DEVICE-HW]

The device is compiled with the [embedded targets](https://github.com/Nimblesite/osprey/blob/main/docs/specs/compiler/EmbeddedTargets.md).

## Pocket Orchestra

- [Pocket Orchestra](orchestra/pocket-orchestra.md) [ORCHESTRA]

## Delivery plans

- [Perception Studio](../plans/studio/studio.md) · [advanced synthesis](../plans/synth/advanced.md) · [device](../plans/device/device.md) · [Pocket Orchestra](../plans/orchestra/pocket-orchestra.md)
