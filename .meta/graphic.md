# `<Graphic>`s and you.

A `<Graphic>` defines how an image or sprite sheet is represented in the engine.
Graphics are not gameplay objects; they are abstract references used by renderers and components.

There are currently two main types of graphics:
- **Static** – A single frame or a fixed slice of a sprite sheet.
- **Animated** – A sequence of frames rendered over time.

---

## Static Graphics

A **Static Graphic** represents an image that does not change over time.
These are used for tiles, entities, UI elements, or anything where the visual remains fixed.

```xml
<!-- Defines a graphic with the ID `Graphic.Fallback`, pointing at a single PNG file. -->
<Graphic Id="Graphic.Fallback" Type="Static">
	<FileName>resources/textures/core/default.png</FileName>
</Graphic>
```

---

### Frame Splitting (Indexed Graphics)

A static graphic can be *split* when the source file is a sprite sheet.
This allows reusing one large texture instead of loading many small ones.

Splitting requires `FrameWidth` and `FrameHeight` to define the size of each frame.
The `<Index>` tag selects a specific frame by its grid position (X = column, Y = row).
Indices are frame-based, not pixel-based.

Example:

```xml
<!-- Uses the first frame (0,0) from a 32x32 sprite sheet -->
<Graphic Id="Graphic.MyTile" Type="Static">
	<FileName>resources/textures/core/tiles.png</FileName>
	<FrameWidth>32</FrameWidth>
	<FrameHeight>32</FrameHeight>

	<Index X="0" Y="0" />
</Graphic>
```

---

### State Matching

Static graphics also support *matching*, which changes the selected frame depending on an entity’s component state.
This is useful for direction-based sprites, or other variations.

`<State>` binds the graphic to a component property.
Each `<StateValue>` then defines which frame(s) to use when that property has a specific value.

Think of it as a `switch` statement:
- The `Component` + `Key` is the variable being checked.
- Each `<StateValue>` is one case.

Example:

```xml
<!-- Graphic that changes depending on the Transform.Direction component -->
<Graphic Id="Graphic.MyMatch" Type="Static">
	<FileName>resources/textures/core/tiles.png</FileName>
	<FrameWidth>32</FrameWidth>
	<FrameHeight>32</FrameHeight>

	<State Component="Transform" Key="Direction">
		<StateValue Value="up">
			<Index X="0" Y="0" />
		</StateValue>
		<StateValue Value="down">
			<Index X="1" Y="0" />
		</StateValue>
		<StateValue Value="left">
			<Index X="2" Y="0" />
		</StateValue>
		<StateValue Value="right">
			<Index X="3" Y="0" />
		</StateValue>
	</State>
</Graphic>
```

---

## Animated Graphics

An **Animated Graphic** renders a looping sequence of frames.
These do not support *splitting* or *state matching*. Their purpose is simple, time-based animation.

An animated graphic requires:
- `FrameWidth` / `FrameHeight` – size of each frame.
- `FrameCount` – total number of frames in the animation.
- `FrameRate` – playback speed in frames per second.
- `LoopDelay` – optional pause (in seconds) before the loop restarts.

Example:

```xml
<!-- Animated graphic with 8 frames, 10 FPS, and a 3s loop delay -->
<Graphic Id="Graphic.MyAnim" Type="Animated">
	<FileName>resources/textures/core/animated.png</FileName>
	<FrameWidth>32</FrameWidth>
	<FrameHeight>32</FrameHeight>
	<FrameCount>8</FrameCount>
	<FrameRate>10</FrameRate>
	<LoopDelay>3</LoopDelay>
</Graphic>
```
