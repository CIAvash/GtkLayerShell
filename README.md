NAME
====

GtkLayerShell - A [Raku](https://www.raku-lang.ir/en) module for interfacing with `Gtk Layer Shell`

DESCRIPTION
===========

Provides a Raku interface for [Gtk Layer Shell](https://github.com/wmww/gtk-layer-shell), a library for creating panels and other desktop components for Wayland, using the Layer Shell protocol.

SYNOPSIS
========

```raku
use GtkLayerShell:auth<zef:CIAvash>:api<0.7>;

# With Gnome::Gtk3 module
use Gnome::Gtk3::Main;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::Box;
use Gnome::Gtk3::Label;

my Gnome::Gtk3::Main   $m          .= new;
my Gnome::Gtk3::Window $gtk_window .= new;

my $window = $gtk_window.get-native-object;

my GtkLayerShell $layer_surface .= new: :$window, :init,
                                        :layer(LAYER_OVERLAY)
                                        :anchors(:EDGE_LEFT, :EDGE_TOP),
                                        :margins(:EDGE_TOP(5), :EDGE_LEFT(10)),
                                        :exclusive_zone(50);

# Or
my $layer_surface = GtkLayerShell.new: :$window;
$layer_surface.init;
$layer_surface.set: :layer(LAYER_OVERLAY),
                    :anchors(:EDGE_LEFT, :EDGE_TOP),
                    :margins(:EDGE_TOP(5), :EDGE_LEFT(10)),
                    :name_space<panel>,
                    :auto_exclusive_zone

# Or
my $layer_surface = GtkLayerShell.new: :$window, :init;
$layer_surface.set_layer:  LAYER_OVERLAY;
$layer_surface.set_anchor: EDGE_TOP,  True;
$layer_surface.set_anchor: EDGE_LEFT, True;
$layer_surface.set_margin: EDGE_TOP,  10;
$layer_surface.set_margin: EDGE_LEFT, 10;

my $box = Gnome::Gtk3::Box.new;
$box.add: Gnome::Gtk3::Label.new: :text('Gtk Layer Shell!');

$gtk_window.add: $box;

$gtk_window.show-all;

$m.gtk-main;

# With GTK::Simple
use GTK::Simple;
use GTK::Simple::App;

my GTK::Simple::App $app .= new;

my GtkLayerShell $layer_surface .= new: :window($app.WIDGET), :init, :anchors(:EDGE_RIGHT, :EDGE_BOTTOM);

$app.set-content: GTK::Simple::HBox.new: GTK::Simple::Label.new: text => 'Gtk Layer Shell!';

$app.run;
```

INSTALLATION
============

You need to have [Gtk Layer Shell](https://github.com/wmww/gtk-layer-shell) and a Wayland compositor that works with it, [Raku](https://www.raku-lang.ir/en) and [zef](https://github.com/ugexe/zef), then run:

```console
zef install "GtkLayerShell:auth<zef:CIAvash>:api<0.7>"
```

or if you have've cloned the repo:

```console
zef install .
```

TESTING
=======

```console
prove -ve 'raku -I.' --ext rakutest
```

ATTRIBUTES
==========

## has GtkLayerShell::DefinedWindow $.window

A layer surface. `Pointer` to `Gtk.Window`.

## has Bool:D $.init

Whether to initialize layer for `window` on instantiation

METHODS
=======

## method major_version

```raku
method major_version() returns Int:D
```

Returns the major version number of the GTK Layer Shell library

## method minor_version

```raku
method minor_version() returns Int:D
```

Returns the minor version number of the GTK Layer Shell library

## method micro_version

```raku
method micro_version() returns Int:D
```

Returns the micro/patch version number of the GTK Layer Shell library

## method is_supported

```raku
method is_supported() returns Bool
```

Returns `True` if the platform is Wayland and Wayland compositor supports the zwlr_layer_shell_v1 protocol. May block for a Wayland roundtrip the first time it's called.

## method protocol_version

```raku
method protocol_version() returns Int:D
```

Returns version of the zwlr_layer_shell_v1 protocol supported by the compositor or 0 if the protocol is not supported. May block for a Wayland roundtrip the first time it's called.

## method init

```raku
method init() returns Mu
```

Sets the `window` up to be a layer surface once it is mapped. This must be called before the `window` is realized.

## method set

```raku
method set(
    LayerShellLayer :$layer,
    Str :$name_space,
    GtkLayerShell::Native::Monitor :$monitor,
    :@anchors where .all ~~ Anchor,
    :@margins where .all ~~ Margin,
    Int :$exclusive_zone,
    Bool :$auto_exclusive_zone,
    LayerShellKeyboardMode :$keyboard_mode
) returns Mu
```

Sets multiple properties of the layer surface at once

### PARAMETERS

#### Enum LayerShellLayer :$layer

The `LayerShellLayer` on which this surface appears

#### Str :$name_space

The namespace of this layer surface

#### GtkLayerShell::Native::Monitor :$monitor

The output(`Pointer` to `Gdk.Monitor`) this layer surface will be placed on (`Any` to let the compositor decide)

#### :@anchors where .all ~~ Anchor

Pairs of `LayerShellEdge`, `Int` to set margins of this layer suface's edges

#### :@margins where .all ~~ Anchor

Pairs of `LayerShellEdge`, `Bool` this layer suface may be anchored to

#### Int :$exclusive_zone

The size of the exclusive zone for this layer surface

#### Bool :$auto_exclusive_zone

Automatically set the size of exclusive zone for this layer surface

#### Enum LayerShellKeyboardMode :$keyboard_mode

The type of keyboard interactivity requested

## method is_layer_window

```raku
method is_layer_window() returns Bool
```

Returns if `window` has been initialized as a layer surface.

## method zwlr_layer_surface_v1

```raku
method zwlr_layer_surface_v1() returns GtkLayerShell::Native::ZwlrLayerSurfaceV1
```

Returns The underlying layer surface Wayland object

## method set_namespace

```raku
method set_namespace(
    Str:D $name_space
) returns Mu
```

Sets the `namespace` of the surface. No one is quite sure what this is for, but it probably should be something generic ("panel", "osk", etc). If the window is currently mapped, it will get remapped so the change can take effect.

### PARAMETERS

#### Str:D $name_space

The namespace of this layer surface

## method get_namespace

```raku
method get_namespace() returns Str:D
```

Returns the namespace property. If namespace is unset, returns the default namespace ("gtk-layer-shell")

## method set_layer

```raku
method set_layer(
    LayerShellLayer:D $layer
) returns Mu
```

Sets the "layer" on which the surface appears (controls if it is over top of or below other surfaces). The layer may be changed on-the-fly in the current version of the layer shell protocol, but on compositors that only support an older version, the `window` is remapped so the change can take effect.

Default is `LAYER_TOP`

### PARAMETERS

#### LayerShellLayer:D $layer

The layer on which this surface appears

## method get_layer

```raku
method get_layer() returns LayerShellLayer:D
```

Returns the current layer

## method set_monitor

```raku
method set_monitor(
    GtkLayerShell::Native::Monitor $monitor
) returns Mu
```

Sets the output for the window to be placed on, or `Pointer` type object to let the compositor choose. If the window is currently mapped, it will get remapped so the change can take effect.

Default behavior is to let the compositor choose

### PARAMETERS

#### GtkLayerShell::Native::Monitor:D $monitor

The output(`Pointer` to `Gdk.Monitor`) this layer surface will be placed on

## method get_monitor

```raku
method get_monitor() returns GtkLayerShell::Native::Monitor
```

Returns the monitor(`Pointer` to `Gdk.Monitor`) this surface will/has requested to be on, can be `Pointer` type object.

NOTE: To get which monitor the surface is actually on, use `gdk_get_monitor_at_window` from a Gdk module.

## method set_anchor

```raku
method set_anchor(
    LayerShellEdge:D $edge,
    Bool:D $anchor_to_edge
) returns Mu
```

Sets whether `window` should be anchored to `edge`.

- If two perpendicular edges are anchored, the surface with be anchored to that corner
- If two opposite edges are anchored, the window will be stretched across the screen in that direction Default is `False` for each `LayerShellEdge`

### PARAMETERS

#### Enum LayerShellEdge:D $edge

A `LayerShellEdge` this layer suface may be anchored to

#### Bool:D $anchor_to_edge

Whether or not to anchor this layer surface to `edge`

## method get_anchor

```raku
method get_anchor(
    LayerShellEdge:D $edge
) returns Bool
```

Returns if this surface is anchored to the given edge
`LayerShellEdge`

## method set_margin

```raku
method set_margin(
    LayerShellEdge:D $edge,
    Int:D $margin_size
) returns Mu
```

Sets the margin for a specific `edge` of a `window`. Effects both surface's distance from the edge and its exclusive zone size (if auto exclusive zone enabled). Default is 0 for each `LayerShellEdge`

### PARAMETERS

#### Enum LayerShellEdge:D $edge

The `LayerShellEdge` for which to set the margin

#### Int:D $margin_size

The margin for `edge` to be set

## method get_margin

```raku
method get_margin(
    LayerShellEdge:D $edge
) returns Int:D
```

Returns the size of the margin for the given edge
`LayerShellEdge`

## method set_exclusive_zone

```raku
method set_exclusive_zone(
    Int $exclusive_zone
) returns Mu
```

Has no effect unless the surface is anchored to an edge. Requests that the compositor does not place other surfaces within the given exclusive zone of the anchored edge.

For example, a panel can request to not be covered by maximized windows. See wlr-layer-shell-unstable-v1.xml for details. Default is 0

### PARAMETERS

#### Int $exclusive_zone

The size of the exclusive zone

## method get_exclusive_zone

```raku
method get_exclusive_zone() returns Int:D
```

Returns the window's exclusive zone (which may have been set manually or automatically)

## method enable_auto_exclusive_zone

```raku
method enable_auto_exclusive_zone() returns Mu
```

When auto exclusive zone is enabled, exclusive zone is automatically set to the size of the `window` + relevant margin. To disable auto exclusive zone, just set the exclusive zone to 0 or any other fixed value.

NOTE: you can control the auto exclusive zone by changing the margin on the non-anchored edge. This behavior is specific to gtk-layer-shell and not part of the underlying protocol

## method is_auto_exclusive_zone_enabled

```raku
method is_auto_exclusive_zone_enabled() returns Bool
```

Returns if the surface's exclusive zone is set to change based on the window's size

## method set_keyboard_mode

```raku
method set_keyboard_mode(
    LayerShellKeyboardMode:D $mode
) returns Mu
```

Sets if/when `window` should receive keyboard events from the compositor, see `LayerShellKeyboardMode` for details. Default is `KEYBOARD_MODE_NONE`

### PARAMETERS

#### Enum LayerShellKeyboardMode:D $mode

The type of keyboard interactivity requested

## method get_keyboard_mode

```raku
method get_keyboard_mode() returns LayerShellKeyboardMode:D
```

Returns current keyboard interactivity mode for `window`

REPOSITORY
==========

[https://github.com/CIAvash/GtkLayerShell/](https://github.com/CIAvash/GtkLayerShell/)

BUG
===

[https://github.com/CIAvash/GtkLayerShell/issues](https://github.com/CIAvash/GtkLayerShell/issues)

AUTHOR
======

Siavash Askari Nasr - [https://www.ciavash.name](https://www.ciavash.name)

COPYRIGHT
=========

Copyright © 2021 Siavash Askari Nasr

LICENSE
=======

This file is part of GtkLayerShell.

GtkLayerShell is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

GtkLayerShell is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with GtkLayerShell. If not, see <http://www.gnu.org/licenses/>.

