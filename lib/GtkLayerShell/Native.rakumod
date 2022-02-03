use NativeLibs:auth<github:salortiz>:ver<0.0.9>;

=NAME GtkLayerShell::Native - Native bindings for L<Gtk Layer Shell|https://github.com/wmww/gtk-layer-shell>

=DESCRIPTION
Provides Native bindings for L<Gtk Layer Shell|https://github.com/wmww/gtk-layer-shell>,
a library for creating panels and other desktop components for Wayland, using the Layer Shell protocol.

=begin SYNOPSIS

=begin code :lang<raku>

use GtkLayerShell::Native:auth<zef:CIAvash>:api<0.7>;

# $window must be a native object
gtk_layer_init_for_window $window;

gtk_layer_set_layer $window, GTK_LAYER_SHELL_LAYER_OVERLAY;

gtk_layer_set_anchor $window, GTK_LAYER_SHELL_EDGE_TOP,  True;
gtk_layer_set_anchor $window, GTK_LAYER_SHELL_EDGE_LEFT, True;

gtk_layer_set_margin $window, GTK_LAYER_SHELL_EDGE_TOP,  10;
gtk_layer_set_margin $window, GTK_LAYER_SHELL_EDGE_LEFT, 10;

=end code

=end SYNOPSIS

=head1 SUBS

unit module GtkLayerShell::Native:auth($?DISTRIBUTION.meta<auth>):ver($?DISTRIBUTION.meta<version>):api($?DISTRIBUTION.meta<api>);

INIT .fail without NativeLibs::Loader.load: "libgtk-layer-shell.so.{$?DISTRIBUTION.meta<api>}.0";

enum GtkLayerShellLayer is export <
    GTK_LAYER_SHELL_LAYER_BACKGROUND
    GTK_LAYER_SHELL_LAYER_BOTTOM
    GTK_LAYER_SHELL_LAYER_TOP
    GTK_LAYER_SHELL_LAYER_OVERLAY
    GTK_LAYER_SHELL_LAYER_ENTRY_NUMBER
>;

enum GtkLayerShellEdge is export <
     GTK_LAYER_SHELL_EDGE_LEFT
     GTK_LAYER_SHELL_EDGE_RIGHT
     GTK_LAYER_SHELL_EDGE_TOP
     GTK_LAYER_SHELL_EDGE_BOTTOM
     GTK_LAYER_SHELL_EDGE_ENTRY_NUMBER
>;

enum GtkLayerShellKeyboardMode is export <
    GTK_LAYER_SHELL_KEYBOARD_MODE_NONE
    GTK_LAYER_SHELL_KEYBOARD_MODE_EXCLUSIVE
    GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND
    GTK_LAYER_SHELL_KEYBOARD_MODE_ENTRY_NUMBER
>;

class Monitor is repr<CPointer> is export(:monitor) {}
class Window  is repr<CPointer> is export(:window)  {}

#| Returns the major version number of the GTK Layer Shell library
sub gtk_layer_get_major_version returns uint32 is export is native {*}

#| Returns the minor version number of the GTK Layer Shell library
sub gtk_layer_get_minor_version returns uint32 is export is native {*}

#| Returns the micro/patch version number of the GTK Layer Shell library
sub gtk_layer_get_micro_version returns uint32 is export is native {*}

#| Returns C<TRUE> if the platform is Wayland and Wayland compositor supports the zwlr_layer_shell_v1 protocol.
#| May block for a Wayland roundtrip the first time it's called.
sub gtk_layer_is_supported returns int32 is export is native {*}

#| Returns version of the zwlr_layer_shell_v1 protocol supported by the compositor or 0 if the protocol is not supported.
#| May block for a Wayland roundtrip the first time it's called.
sub gtk_layer_get_protocol_version returns uint32 is export is native {*}

#| Sets the C<window> up to be a layer surface once it is mapped.
#| This must be called before the C<window> is realized.
sub gtk_layer_init_for_window (
    Window:D $window #= A C<GtkWindow> to be turned into a layer surface
) is export is native {*}

#| Returns if C<window> has been initialized as a layer surface.
sub gtk_layer_is_layer_window (
    Window:D $window #= A C<GtkWindow> that may or may not have a layer surface.
    --> int32
) is export is native {*}

#| The underlying layer surface Wayland structure
class ZwlrLayerSurfaceV1 is repr<CPointer> is export {}

#| Returns The underlying layer surface Wayland object
sub gtk_layer_get_zwlr_layer_surface_v1 (
    Window:D $window #= A layer surface
    --> ZwlrLayerSurfaceV1
) is export is native {*}

#| Sets the C<namespace> of the surface.
#| No one is quite sure what this is for, but it probably should be something generic
#| ("panel", "osk", etc). The C<name_space> string is copied, and caller maintians
#| ownership of original. If the window is currently mapped, it will get remapped so the change can take effect.
sub gtk_layer_set_namespace (
    Window:D $window,    #= A layer surface
    Str:D    $name_space #= The namespace of this layer surface
) is export is native {*}

#| Returns a reference to the namespace property. If namespace is unset, returns the
#| default namespace ("gtk-layer-shell"). Never returns C<NULL>.
#| NOTE: this function does not return ownership of the string. Do not free the returned string.
#| Future calls into the library may invalidate the returned string.
sub gtk_layer_get_namespace (Window:D $window #=[ A layer surface ] --> Str) is export is native {*}

#| Sets the "layer" on which the surface appears (controls if it is over top of or below other surfaces).
#| The layer may be changed on-the-fly in the current version of the layer shell protocol,
#| but on compositors that only support an older version the C<window> is remapped so the change can take effect.
#| Default is C<GTK_LAYER_SHELL_LAYER_TOP>
sub gtk_layer_set_layer (
    Window:D $window, #= A layer surface
    int32    $layer   #= The layer on which this surface appears
) is export is native {*}

#| Returns the current layer
sub gtk_layer_get_layer (Window:D $window #=[ A layer surface ] --> int32) is export is native {*}

#| Sets the output for the window to be placed on, or C<NULL> to let the compositor choose.
#| If the window is currently mapped, it will get remapped so the change can take effect.
#| Default is C<NULL>
sub gtk_layer_set_monitor (
    Window:D  $window, #= A layer surface
    Monitor   $monitor #= The output this layer surface will be placed on (C<NULL> to let the compositor decide)
) is export is native {*}

#| Returns the monitor this surface will/has requested to be on, can be C<NULL>
#| NOTE: To get which monitor the surface is actually on, use
#| C<gdk_display_get_monitor_at_window>.
sub gtk_layer_get_monitor (Window:D $window #=[ A layer surface ] --> Monitor) is export is native {*}

#| Sets whether C<window> should be anchored to C<edge>.
#| - If two perpendicular edges are anchored, the surface with be anchored to that corner
#| - If two opposite edges are anchored, the window will be stretched across the screen in that direction
#| Default is C<FALSE> for each C<GtkLayerShellEdge>
sub gtk_layer_set_anchor (
    Window:D $window,        #= A layer surface
    int32    $edge,          #= A C<GtkLayerShellEdge> this layer suface may be anchored to
    int32    $anchor_to_edge #= Whether or not to anchor this layer surface to C<edge>
) is export is native {*}

#| Returns if this surface is anchored to the given edge
sub gtk_layer_get_anchor (
    Window:D $window, #= A layer surface
    int32    $edge    #= C<GtkLayerShellEdge>
    --> int32
) is export is native {*}

#| Sets the margin for a specific C<edge> of a C<window>. Effects both surface's distance from
#| the edge and its exclusive zone size (if auto exclusive zone enabled).
#| Default is 0 for each C<GtkLayerShellEdge>
sub gtk_layer_set_margin (
    Window:D $window,     #= A layer surface
    int32    $edge,       #= The C<GtkLayerShellEdge> for which to set the margin
    int32    $margin_size #= The margin for C<edge> to be set
) is export is native {*}

#| Returns the size of the margin for the given edge
sub gtk_layer_get_margin (
    Window:D $window, #= A layer surface
    int32    $edge    #= C<GtkLayerShellEdge>
    --> int32
) is export is native {*}

#| Has no effect unless the surface is anchored to an edge. Requests that the compositor
#| does not place other surfaces within the given exclusive zone of the anchored edge.
#| For example, a panel can request to not be covered by maximized windows. See
#| wlr-layer-shell-unstable-v1.xml for details.
#| Default is 0
sub gtk_layer_set_exclusive_zone (
    Window:D $window,        #= A layer surface
    int32  $exclusive_zone #= The size of the exclusive zone
) is export is native {*}

#| Returns the window's exclusive zone (which may have been set manually or automatically)
sub gtk_layer_get_exclusive_zone (Window:D $window #=[ A layer surface ] --> int32) is export is native {*}

#| When auto exclusive zone is enabled, exclusive zone is automatically set to the
#| size of the C<window> + relevant margin. To disable auto exclusive zone, just set the
#| exclusive zone to 0 or any other fixed value.
#| NOTE: you can control the auto exclusive zone by changing the margin on the non-anchored
#| edge. This behavior is specific to gtk-layer-shell and not part of the underlying protocol
sub gtk_layer_auto_exclusive_zone_enable (Window:D $window #=[ A layer surface ]) is export is native {*}

#| Returns if the surface's exclusive zone is set to change based on the window's size
sub gtk_layer_auto_exclusive_zone_is_enabled (Window:D $window #=[ A layer surface ] --> int32) is export is native {*}

#| Sets if/when C<window> should receive keyboard events from the compositor, see
#| C<GtkLayerShellKeyboardMode> for details.
#| Default is C<GTK_LAYER_SHELL_KEYBOARD_MODE_NONE>
sub gtk_layer_set_keyboard_mode (
    Window:D $window, #= A layer surface
    int32    $mode    #= The type of keyboard interactivity requested.
) is export is native {*}

#| Returns current keyboard interactivity mode for C<window>
sub gtk_layer_get_keyboard_mode (Window:D $window #=[ A layer surface ] --> int32) is export is native {*}

=COPYRIGHT Copyright © 2021 Siavash Askari Nasr

=begin LICENSE
This file is part of GtkLayerShell.

GtkLayerShell is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GtkLayerShell is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with GtkLayerShell.  If not, see <http://www.gnu.org/licenses/>.
=end LICENSE
