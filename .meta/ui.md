# `<UIMarkup>` and you.
###### Discuss the prototype in [this relevant issue](https://github.com/misleadingname/luastation13/issues/3).

A `<UIMarkup>` defines user interface elements using an XML-based, component-driven system.
UI elements are built on an Entity-Component-System (ECS) architecture, allowing flexible composition of visual and interactive behaviors.

There are two main types of UI markup:
- **Scene** – A complete UI screen or overlay (e.g., menus, HUDs, dialogs).
- **Template** – A reusable UI component with parameters (e.g., buttons, text fields).

---

## Scenes

A **Scene** represents a complete UI layout that can be loaded and displayed.
Scenes are composed of nested `<UIElement>` nodes, each with components that define appearance, layout, and interaction.

```xml
<!-- Defines a simple menu scene -->
<UIMarkup Id="UI.Markup.MainMenu" Type="Scene">
	<UIElement>
		<UiTransform Position="0.5,0.5" Size="400,300" PosX="ratio" PosY="ratio" Anchor="0.5,0.5" />
		<UiLayout Type="Vertical" Spacing="8" Padding="16,16" />
		<UiPanel Graphic="Graphic.UiPanel" />

		<UIButton Text="New Game" />
		<UIButton Text="Load Game" />
		<UIButton Text="Quit" />
	</UIElement>
</UIMarkup>
```

---

## Templates

A **Template** is a reusable UI component that accepts parameters.
Templates allow you to define a component once and instantiate it many times with different values.

Parameters are defined with `<Params>` and referenced using `{ParamName}` syntax.

```xml
<!-- Defines a custom button template -->
<UIMarkup Id="MyButton" Type="Template">
	<Params>
		<Param Name="Id" Default="UnnamedButton" />
		<Param Name="Text" Default="Button" />
		<Param Name="Color" Default="1,1,1,1" />
	</Params>

	<UIEntity Id="{Id}">
		<UiTransform Size="128,32" SizeX="pixel" SizeY="pixel" />
		<UiLabel Text="{Text}" Color="{Color}" HAlign="center" VAlign="center" />
		<UiPanel Graphic="Graphic.UiButton" />
		<UiTarget />
	</UIEntity>
</UIMarkup>
```

Using the template:

```xml
<MyButton Text="Save" Color="0,1,0,1" />
<MyButton Text="Cancel" Color="1,0,0,1" />
```

---

## Components

UI elements are composed of **components** that define specific behaviors.
Each component is added as an XML tag within a `<UIElement>` or `<UIEntity>`.

### UiElement

The core component for hierarchy and visibility.
Every UI entity automatically receives this component.

- `parent` – Parent entity reference (set automatically).
- `children` – Array of child entities (populated automatically).
- `visible` – Whether the element is visible (default: `true`).
- `enabled` – Whether the element is interactive (default: `true`).
- `z` – Z-order for rendering (default: `0`).

```xml
<!-- UiElement is implicit, no XML tag needed -->
```

---

### UiTransform

Defines position, size, rotation, and anchoring.

**Attributes:**
- `Position` – Position as `"x,y"` (default: `"0,0"`).
- `Size` – Size as `"width,height"` (default: `"64,128"`).
- `Rotation` – Rotation in degrees (default: `0`).
- `Anchor` – Anchor point as `"x,y"` in 0-1 range (default: `"0,0"`).
- `PosX` / `PosY` – Position mode: `"pixel"`, `"ratio"`, or `"content"` (default: `"pixel"`).
- `SizeX` / `SizeY` – Size mode: `"pixel"`, `"ratio"`, or `"content"` (default: `"pixel"`).

**Size Modes:**
- `pixel` – Absolute pixel value.
- `ratio` – Ratio of parent size (0.0 to 1.0).
- `content` – Auto-size to fit content (children or label text).

**Anchor Points:**
- `0,0` – Top-left corner.
- `0.5,0.5` – Center.
- `1,1` – Bottom-right corner.

```xml
<!-- Centered dialog, 400x300 pixels -->
<UiTransform Position="0.5,0.5" Size="400,300" PosX="ratio" PosY="ratio" Anchor="0.5,0.5" />

<!-- Full-width, fixed height -->
<UiTransform Position="0,0" Size="1,50" SizeX="ratio" SizeY="pixel" />

<!-- Auto-size to fit children -->
<UiTransform Size="0,0" SizeX="content" SizeY="content" />
```

---

### UiLayout

Defines layout container behavior for positioning children.

**Attributes:**
- `Type` – Layout type: `"vertical"` or `"horizontal"` (default: `"vertical"`).
- `Padding` – Padding around children as `"x,y"` (default: `"0,0"`).
- `Spacing` – Pixels between children (default: `0`).
- `Align` – Cross-axis alignment: `"begin"`, `"center"`, `"end"` (default: `"begin"`).
- `Justify` – Main-axis alignment: `"begin"`, `"center"`, `"end"`, `"stretch"` (default: `"begin"`).
- `Wrap` – Whether to wrap children (default: `false`, not yet implemented).

**Alignment Guide:**
- **Vertical Layout**: `Align` = horizontal, `Justify` = vertical.
- **Horizontal Layout**: `Align` = vertical, `Justify` = horizontal.

```xml
<!-- Vertical layout with centered items -->
<UiLayout Type="Vertical" Align="center" Justify="begin" Spacing="8" Padding="16,16" />

<!-- Horizontal layout with stretched items -->
<UiLayout Type="Horizontal" Align="center" Justify="stretch" Spacing="4" />
```

---

### UiFlexItem

Enables flexbox-style sizing for items in horizontal layouts.

**Attributes:**
- `Grow` – How much to grow relative to siblings (default: `0`).
- `Shrink` – How much to shrink when space is limited (default: `1`).
- `Basis` – Initial size before growing/shrinking (default: `"auto"`).

**Notes:**
- Only works in horizontal layouts.
- Items with `Grow > 0` expand to fill available space.
- Proportional: `Grow="2"` takes twice as much space as `Grow="1"`.

```xml
<!-- Item that grows to fill space -->
<UIEntity>
	<UiTransform Size="100,32" />
	<UiFlexItem Grow="1" />
	<UiLabel Text="Flexible" />
</UIEntity>
```

### UiLabel

Renders text.

**Attributes:**
- `Text` – Text to display (default: `""`).
- `Color` – Text color as `"r,g,b,a"` (default: `"1,1,1,1"`).
- `Font` – Font asset ID (default: `"Font.Default"`).
- `HAlign` – Horizontal alignment: `"left"`, `"center"`, `"right"`, `"justify"` (default: `"left"`).
- `VAlign` – Vertical alignment: `"top"`, `"center"`, `"bottom"` (default: `"top"`).

```xml
<UiLabel Text="Hello World" Color="1,1,1,1" Font="Font.Default" HAlign="center" VAlign="center" />
```

---

### UiPanel

Renders background graphics.

**Attributes:**
- `Graphic` – Graphic asset ID (default: `"Graphic.UiPanel"`).
- `Color` – Tint color as `"r,g,b,a"` (default: `"1,1,1,1"`).

```xml
<UiPanel Graphic="Graphic.UiPanel" Color="1,1,1,1" />
```

---

### UiTarget

Enables interaction (hover, click, focus).

**Attributes:**
- `Toggle` – Whether element is a toggle button (default: `false`).

**Runtime Properties:**
- `hovered` – Whether mouse is over element.
- `focused` – Whether element has keyboard focus.
- `selected` – Whether element is selected.
- `onHover` / `onFocus` / `onClick` – Callback functions (set in code).

```xml
<UiTarget Toggle="false" />
```

---

### UiTextField

Text input field.

**Attributes:**
- `Value` – Current text value (default: `""`).
- `Placeholder` – Placeholder text when empty (default: `""`).
- `Disabled` – Whether input is disabled (default: `false`).

**Runtime Properties:**
- `cursorPosition` – Cursor position in characters.
- `selectionStart` / `selectionEnd` – Text selection range.

```xml
<UiTextField Value="" Placeholder="Enter text..." Disabled="false" />
```

---

## Layout System

The layout system automatically positions child elements based on layout rules.

### Vertical Layout

Stacks children top-to-bottom.

```xml
<UIElement>
	<UiTransform Size="400,600" />
	<UiLayout Type="Vertical" Align="center" Justify="begin" Spacing="8" Padding="16,16" />

	<UIButton Text="Button 1" />
	<UIButton Text="Button 2" />
	<UIButton Text="Button 3" />
</UIElement>
```

**Behavior:**
- Children positioned from top to bottom.
- `Align` controls horizontal positioning.
- `Justify` controls vertical distribution.
- `Spacing` adds pixels between children.
- `Padding` adds space around all children.

---

### Horizontal Layout

Arranges children left-to-right.

```xml
<UIElement>
	<UiTransform Size="600,50" />
	<UiLayout Type="Horizontal" Align="center" Justify="begin" Spacing="8" Padding="8,8" />

	<UIButton Text="Button 1" />
	<UIButton Text="Button 2" />
	<UIButton Text="Button 3" />
</UIElement>
```

**Behavior:**
- Children positioned from left to right.
- `Align` controls vertical positioning.
- `Justify` controls horizontal distribution.
- Supports flexbox with `UiFlexItem`.

---

### Nested Layouts

Layouts only affect their direct children.
Nest layouts freely for complex UIs.

```xml
<UIElement>
	<UiLayout Type="Vertical" Spacing="16" />

	<!-- Nested horizontal layout -->
	<UIElement>
		<UiTransform Size="1,48" SizeX="ratio" SizeY="pixel" />
		<UiLayout Type="Horizontal" Spacing="8" />

		<UIButton Text="Button 1" />
		<UIButton Text="Button 2" />
	</UIElement>
</UIElement>
```

---

## Content Sizing

The `"content"` size mode automatically sizes elements to fit their content.

### For Labels

When an element has a `UiLabel`, `SizeX="content"` or `SizeY="content"` will size to fit the text.

```xml
<!-- Auto-size to fit text -->
<UIElement>
	<UiTransform Size="0,0" SizeX="content" SizeY="content" />
	<UiLabel Text="Auto-sized!" Font="Font.Default" />
	<UiPanel Graphic="Graphic.UiPanel" />
</UIElement>
```

### For Layouts

When an element has a `UiLayout`, `SizeX="content"` or `SizeY="content"` will size to fit all children.

**Vertical Layouts:**
- `SizeX="content"` – Fits the widest child.
- `SizeY="content"` – Fits total height of all children + spacing + padding.

**Horizontal Layouts:**
- `SizeX="content"` – Fits total width of all children + spacing + padding.
- `SizeY="content"` – Fits the tallest child.

```xml
<!-- Container auto-sizes to fit children -->
<UIElement>
	<UiTransform Size="0,0" SizeX="content" SizeY="content" />
	<UiLayout Type="Vertical" Spacing="8" Padding="8,8" />
	<UiPanel Graphic="Graphic.UiPanel" />

	<UIButton Text="Button 1" />
	<UIButton Text="Button 2" />
</UIElement>
```

---

## Flexbox Features

Horizontal layouts support CSS Flexbox-inspired sizing with `UiFlexItem`.

### Basic Flex-Grow

Items grow to fill available space equally.

```xml
<UIElement>
	<UiTransform Size="600,50" />
	<UiLayout Type="Horizontal" Spacing="8" Padding="8,8" />

	<UIEntity>
		<UiTransform Size="100,32" />
		<UiFlexItem Grow="1" />
		<UiLabel Text="Flex 1" HAlign="center" VAlign="center" />
		<UiPanel Graphic="Graphic.UiPanel" />
	</UIEntity>

	<UIEntity>
		<UiTransform Size="100,32" />
		<UiFlexItem Grow="1" />
		<UiLabel Text="Flex 2" HAlign="center" VAlign="center" />
		<UiPanel Graphic="Graphic.UiPanel" />
	</UIEntity>
</UIElement>
```

Both items will grow equally to fill the container.

---

### Proportional Flex-Grow

Items grow proportionally based on their `Grow` value.

```xml
<UIElement>
	<UiTransform Size="600,50" />
	<UiLayout Type="Horizontal" Spacing="8" Padding="8,8" />

	<UIEntity>
		<UiTransform Size="100,32" />
		<UiFlexItem Grow="1" />
		<UiLabel Text="1x" HAlign="center" VAlign="center" />
		<UiPanel Graphic="Graphic.UiPanel" />
	</UIEntity>

	<UIEntity>
		<UiTransform Size="100,32" />
		<UiFlexItem Grow="3" />
		<UiLabel Text="3x" HAlign="center" VAlign="center" />
		<UiPanel Graphic="Graphic.UiPanel" />
	</UIEntity>
</UIElement>
```

The second item will be 3 times wider than the first.

---

### Mixed Fixed and Flexible

Combine fixed-size items with flexible ones.

```xml
<UIElement>
	<UiTransform Size="600,50" />
	<UiLayout Type="Horizontal" Spacing="8" Padding="8,8" />

	<UIButton Text="Fixed" />

	<UIEntity>
		<UiTransform Size="100,32" />
		<UiFlexItem Grow="1" />
		<UiLabel Text="Flexible" HAlign="center" VAlign="center" />
		<UiPanel Graphic="Graphic.UiPanel" />
	</UIEntity>

	<UIButton Text="Fixed" />
</UIElement>
```

The middle item grows to fill remaining space.

## Built-in Templates

The UI system provides several built-in templates for common UI elements.

### UIButton

A clickable button with text and background.

**Parameters:**
- `Id` – Entity ID (default: `"UnnamedButton"`).
- `Text` – Button text (default: `"Button"`).
- `Graphic` – Background graphic (default: `"Graphic.UiButton"`).
- `Font` – Text font (default: `"Font.Default"`).
- `Color` – Tint color (default: `"1,1,1,1"`).
- `Toggle` – Toggle button mode (default: `"false"`).

```xml
<UIButton Text="Click Me" />
<UIButton Id="SaveButton" Text="Save" Color="0,1,0,1" />
<UIButton Text="Toggle" Toggle="true" />
```

---

### UITextField

A text input field with placeholder support.

**Parameters:**
- `Id` – Entity ID (default: `"UnnamedTextField"`).
- `Text` – Initial text (default: `"TextField"`).
- `Placeholder` – Placeholder text (default: `""`).
- `Disabled` – Whether disabled (default: `"false"`).
- `Graphic` – Background graphic (default: `"Graphic.UiField"`).
- `Color` – Tint color (default: `"1,1,1,1"`).
- `Font` – Text font (default: `"Font.Default"`).
- `Position` / `Size` / `PosX` / `PosY` / `SizeX` / `SizeY` – Transform properties.

```xml
<UITextField Placeholder="Enter your name..." />
<UITextField Id="PasswordField" Placeholder="Password" />
```

---

### UILabel

A simple text label.

**Parameters:**
- `Id` – Entity ID (default: `"UnnamedLabel"`).
- `Text` – Label text (default: `"Label"`).
- `Font` – Text font (default: `"Font.Default"`).
- `Color` – Text color (default: `"1,1,1,1"`).
- `HAlign` – Horizontal alignment (default: `"center"`).
- `VAlign` – Vertical alignment (default: `"center"`).
- `Size` – Size (default: `"1,32"`).
- `PosX` / `PosY` / `SizeX` / `SizeY` – Transform modes.

```xml
<UILabel Text="Hello World" />
<UILabel Text="Title" Font="Font.DefaultLarge" HAlign="left" />
```

---

## Examples

### Centered Dialog

A dialog box centered on screen.

```xml
<UIElement>
	<UiTransform Position="0.5,0.5" Size="400,300" PosX="ratio" PosY="ratio" Anchor="0.5,0.5" />
	<UiLayout Type="Vertical" Spacing="12" Justify="stretch" Padding="16,16" />
	<UiPanel Graphic="Graphic.UiPanel" />

	<UIElement Id="HeaderContainer">
		<UiTransform Position="0,0" Size="1,0" PosX="ratio" PosY="ratio" SizeX="ratio" SizeY="content" />
		<UiLayout Type="Vertical" Align="left" Justify="begin" Spacing="2" Padding="0,0" />

		<UILabel Text="Dialog Title" Font="Font.DefaultLarge" />
		<UILabel Text="This is a message." />
	</UIElement>

	<UIElement>
		<UiTransform Size="1,0" SizeX="ratio" SizeY="content" />
		<UiLayout Type="Horizontal" Spacing="8" />

		<UIButton Text="OK" />
		<UIButton Text="Cancel" />
	</UIElement>
</UIElement>
```
---

### Form with Labels and Fields

A form layout with aligned labels and input fields.

```xml
<UIElement>
	<UiTransform Position="0.5,0.5" Size="400,300" PosX="ratio" PosY="ratio" Anchor="0.5,0.5" />
	<UiLayout Type="Vertical" Spacing="12" Padding="16,16" />
	<UiPanel Graphic="Graphic.UiPanel" />

	<UIElement>
		<UiTransform Size="1,0" SizeX="ratio" SizeY="content" />
		<UILabel Text="Login Form" Font="Font.DefaultLarge" HAlign="left" />
	</UIElement>
	<!-- Username row -->
	<UIElement>
		<UiTransform Size="1,32" SizeX="ratio" SizeY="pixel" />
		<UiLayout Type="Horizontal" Spacing="8" Align="center" />

		<UIElement>
			<UiTransform Size="100,32" SizeX="pixel" SizeY="pixel" />
			<UiLabel Text="Username:" HAlign="right" VAlign="center" />
		</UIElement>

		<UIElement>
			<UiTransform Size="1,32" SizeX="ratio" SizeY="pixel" />
			<UiFlexItem Grow="1" />
			<UITextField Placeholder="Enter username..." />
		</UIElement>
	</UIElement>

	<!-- Password row -->
	<UIElement>
		<UiTransform Size="1,32" SizeX="ratio" SizeY="pixel" />
		<UiLayout Type="Horizontal" Spacing="8" Align="center" />

		<UIElement>
			<UiTransform Size="100,32" SizeX="pixel" SizeY="pixel" />
			<UiLabel Text="Password:" HAlign="right" VAlign="center" />
		</UIElement>

		<UIElement>
			<UiTransform Size="1,32" SizeX="ratio" SizeY="pixel" />
			<UiFlexItem Grow="1" />
			<UITextField Placeholder="Enter password..." />
		</UIElement>
	</UIElement>

	<!-- Buttons -->
	<UIElement>
		<UiTransform Size="1,32" SizeX="ratio" SizeY="pixel" />
		<UiLayout Type="Horizontal" Spacing="8" Justify="end" />

		<UIButton Text="Login" />
		<UIButton Text="Cancel" />
	</UIElement>
</UIElement>
```