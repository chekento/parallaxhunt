# Parallax Hunt

Native Android/Game-Engine edition of **Parallax Hunt**, rebuilt in **Godot 4.7.2**.

## Current native alpha

This repository is the engine migration from the HTML prototype into a real mobile game project. The first APK focuses on the native foundation:

- procedural large top-down city with visually distinct districts
- PMDD-style height/parallax projection for roofs, trees, vehicles and secrets
- true simultaneous multi-touch: left movement + right perspective peek
- Android sensor parallax (gravity/gyro) with touch fallback
- large readable mobile HUD, district banners and quest tracker
- collectible echo fragments, perspective secrets and scan pulse
- traffic and usable parked vehicle classes
- native synthesized SFX including a custom treasure/reveal chime
- debug Android APK CI build

The front-camera **face/head tracking** adapter is architected as the next native module. The alpha already uses Android motion sensors as a reliable native parallax source rather than pretending camera face tracking is complete.

## Engine

Godot **4.7.2 stable**, Compatibility renderer for broad Android support.

## Android build

Pushes to `main` run `.github/workflows/android-debug.yml` and upload `ParallaxHunt-debug.apk` as a workflow artifact.

## Controls

- Left thumb: move / steer
- Right thumb: perspective peek (works simultaneously with left thumb)
- `SCAN`: highlights perspective objects
- `INTERACT`: collect/use nearby objects and vehicles
- Sensor mode: Android gravity/gyro subtly drives PMDD parallax; touch remains additive

## Status

This is the first native APK foundation. The existing web prototype remains the gameplay/design reference while systems are migrated incrementally into engine-native scenes and scripts.


## Native build

The repository now includes a reproducible Android debug APK workflow for Godot 4.7.2.
