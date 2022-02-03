use NativeCall;

use GtkLayerShell::Native:auth($?DISTRIBUTION.meta<auth>):ver($?DISTRIBUTION.meta<version>):api($?DISTRIBUTION.meta<api>) :DEFAULT, :window, :monitor;

enum LayerShellLayer is export < LAYER_BACKGROUND LAYER_BOTTOM LAYER_TOP LAYER_OVERLAY LAYER_ENTRY_NUMBER >;

enum LayerShellEdge  is export < EDGE_LEFT EDGE_RIGHT EDGE_TOP EDGE_BOTTOM EDGE_ENTRY_NUMBER >;

enum LayerShellKeyboardMode is export <
    KEYBOARD_MODE_NONE
    KEYBOARD_MODE_EXCLUSIVE
    KEYBOARD_MODE_ON_DEMAND
    KEYBOARD_MODE_ENTRY_NUMBER
>;

sub EXPORT {
    Map.new: 'ZwlrLayerSurfaceV1' => ZwlrLayerSurfaceV1
}

=NAME GtkLayerShell - A L<Raku|https://www.raku-lang.ir/en> module for interfacing with C<Gtk Layer Shell>

=DESCRIPTION
Provides a Raku interface for L<Gtk Layer Shell|https://github.com/wmww/gtk-layer-shell>,
a library for creating panels and other desktop components for Wayland, using the Layer Shell protocol.

=begin SYNOPSIS

=begin code :lang<raku>

use GtkLayerShell:auth<zef:CIAvash>:api<0.7>;

# With C<Gnome::Gtk3> module
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

=end code

=end SYNOPSIS

=begin INSTALLATION

You need to have L<Gtk Layer Shell|https://github.com/wmww/gtk-layer-shell> and a Wayland compositor that works with it, L<Raku|https://www.raku-lang.ir/en> and L<zef|https://github.com/ugexe/zef>, then run:

=begin code :lang<console>

zef install "GtkLayerShell:auth<zef:CIAvash>:api<0.7>"

=end code

or if you have've cloned the repo:

=begin code :lang<console>

zef install .

=end code

=end INSTALLATION

=begin TESTING

=begin code :lang<console>

prove -ve 'raku -I.' --ext rakutest

=end code

=end TESTING

unit class GtkLayerShell:auth($?DISTRIBUTION.meta<auth>):ver($?DISTRIBUTION.meta<version>):api($?DISTRIBUTION.meta<api>);

=ATTRIBUTES

subset DefinedWindow of Mu where { .defined or note 'window must be a defined Pointer' and False }

#| A layer surface. C<Pointer> to C<Gtk.Window>.
has DefinedWindow $.window is repr<CPointer> is required;

#| Whether to initialize layer for C<window> on instantiation
has Bool:D $.init = False;

submethod TWEAK (:$window, :$init, |c) {
    self.init if $!init;

    self.set: |c if c;
}

=METHODS

#| Returns the major version number of the GTK Layer Shell library
method major_version (::?CLASS:U: --> Int:D) {
    gtk_layer_get_major_version;
}

#| Returns the minor version number of the GTK Layer Shell library
method minor_version (::?CLASS:U: --> Int:D) {
    gtk_layer_get_minor_version;
}

#| Returns the micro/patch version number of the GTK Layer Shell library
method micro_version (::?CLASS:U: --> Int:D) {
    gtk_layer_get_micro_version;
}

#| Returns C<True> if the platform is Wayland and Wayland compositor supports the zwlr_layer_shell_v1 protocol.
#| May block for a Wayland roundtrip the first time it's called.
method is_supported (::?CLASS:U: --> Bool:D) {
    so gtk_layer_is_supported;
}

#| Returns version of the zwlr_layer_shell_v1 protocol supported by the compositor or 0 if the protocol is not supported.
#| May block for a Wayland roundtrip the first time it's called.
method protocol_version (::?CLASS:U: --> Int:D) {
    gtk_layer_get_protocol_version;
}

#| Sets the C<window> up to be a layer surface once it is mapped.
#| This must be called before the C<window> is realized.
method init {
    gtk_layer_init_for_window $!window;
}

subset Anchor of Pair where -> (:$key, :$value) { LayerShellEdge::«$key».defined and $value ~~ Bool:D };
subset Margin of Pair where -> (:$key, :$value) { LayerShellEdge::«$key».defined and $value ~~ Int:D  };

#| Sets multiple properties of the layer surface at once
method set (
    LayerShellLayer :$layer,      #= The C<LayerShellLayer> on which this surface appears
    Str             :$name_space, #= The namespace of this layer surface
    #| The output(C<Pointer> to C<Gdk.Monitor>) this layer surface will be placed on (C<Any> to let the compositor decide).
    Monitor :$monitor,
    #| Pairs of C<LayerShellEdge>, C<Int> to set margins of this layer suface's edges
    :@anchors where .all ~~ Anchor,
    #| Pairs of C<LayerShellEdge>, C<Bool> this layer suface may be anchored to
    :@margins  where .all ~~ Margin,
    Int  :$exclusive_zone,      #= The size of the exclusive zone for this layer surface
    Bool :$auto_exclusive_zone, #= Automatically set the size of exclusive zone for this layer surface
    LayerShellKeyboardMode :$keyboard_mode, #= The type of keyboard interactivity requested
) {
    self.set_layer:                 $_ with $layer;
    self.set_namespace:             $_ with $name_space;
    self.set_monitor:               $_ with $monitor;
    self.set_keyboard_mode:         $_ with $keyboard_mode;
    self.set_exclusive_zone:        $_ with $exclusive_zone;
    self.enable_auto_exclusive_zone if $auto_exclusive_zone;
    self.set_anchor: LayerShellEdge::{.key}, .value for @anchors;
    self.set_margin: LayerShellEdge::{.key}, .value for @margins;
}

#| Returns if C<window> has been initialized as a layer surface.
method is_layer_window returns Bool:D {
    so gtk_layer_is_layer_window $!window;
}

#| Returns The underlying layer surface Wayland object
method zwlr_layer_surface_v1 returns ZwlrLayerSurfaceV1 {
    gtk_layer_get_zwlr_layer_surface_v1 $!window;
}

#| Sets the C<namespace> of the surface.
#| No one is quite sure what this is for, but it probably should be something generic
#| ("panel", "osk", etc). If the window is currently mapped, it will get remapped so the change can take effect.
method set_namespace (Str:D $name_space #=[The namespace of this layer surface]) {
    gtk_layer_set_namespace $!window, $name_space;
}

#| Returns the namespace property. If namespace is unset, returns the default namespace ("gtk-layer-shell")
method get_namespace returns Str:D {
    gtk_layer_get_namespace $!window;
}

#| Sets the "layer" on which the surface appears (controls if it is over top of or below other surfaces).
#| The layer may be changed on-the-fly in the current version of the layer shell protocol,
#| but on compositors that only support an older version, the C<window> is remapped so the change can take
#| effect.
#| Default is C<LAYER_TOP>
method set_layer (LayerShellLayer:D $layer #=[ The layer on which this surface appears ]) {
    gtk_layer_set_layer $!window, $layer;
}

#| Returns the current layer
method get_layer returns LayerShellLayer:D {
    LayerShellLayer(gtk_layer_get_layer $!window);
}

#| Sets the output for the window to be placed on, or C<Pointer> type object to let the compositor choose.
#| If the window is currently mapped, it will get remapped so the change can take effect.
#| Default behavior is to let the compositor choose
method set_monitor (Monitor $monitor #=[ The output(C<Pointer> to C<Gdk.Monitor>) this layer surface will be placed on. ]) {
    gtk_layer_set_monitor $!window, $monitor;
}

#| Returns the monitor(C<Pointer> to C<Gdk.Monitor>) this surface will/has requested to be on, can be C<Pointer> type object.
#| NOTE: To get which monitor the surface is actually on, use C<gdk_get_monitor_at_window> from a Gdk module.
method get_monitor returns Monitor {
    gtk_layer_get_monitor $!window;
}

#| Sets whether C<window> should be anchored to C<edge>.
#| - If two perpendicular edges are anchored, the surface with be anchored to that corner
#| - If two opposite edges are anchored, the window will be stretched across the screen in that direction
#| Default is C<False> for each C<LayerShellEdge>
method set_anchor (
    LayerShellEdge:D $edge,          #= A C<LayerShellEdge> this layer suface may be anchored to
    Bool:D           $anchor_to_edge #= Whether or not to anchor this layer surface to C<edge>
) {
    gtk_layer_set_anchor $!window, $edge, $anchor_to_edge;
}

#| Returns if this surface is anchored to the given edge
method get_anchor (LayerShellEdge:D $edge #=[ C<LayerShellEdge> ] --> Bool:D) {
    so gtk_layer_get_anchor $!window, $edge;
}

#| Sets the margin for a specific C<edge> of a C<window>. Effects both surface's distance from
#| the edge and its exclusive zone size (if auto exclusive zone enabled).
#| Default is 0 for each C<LayerShellEdge>
method set_margin (
    LayerShellEdge:D $edge,       #= The C<LayerShellEdge> for which to set the margin
    Int:D            $margin_size #= The margin for C<edge> to be set
) {
    gtk_layer_set_margin $!window, $edge, $margin_size;
}

#| Returns the size of the margin for the given edge
method get_margin (LayerShellEdge:D $edge #=[ C<LayerShellEdge> ] --> Int:D) {
    gtk_layer_get_margin $!window, $edge;
}

#| Has no effect unless the surface is anchored to an edge. Requests that the compositor
#| does not place other surfaces within the given exclusive zone of the anchored edge.
#| For example, a panel can request to not be covered by maximized windows. See
#| wlr-layer-shell-unstable-v1.xml for details.
#| Default is 0
method set_exclusive_zone (Int $exclusive_zone #=[ The size of the exclusive zone ]) {
    gtk_layer_set_exclusive_zone $!window, $exclusive_zone;
}

#| Returns the window's exclusive zone (which may have been set manually or automatically)
method get_exclusive_zone returns Int:D {
    gtk_layer_get_exclusive_zone $!window;
}

#| When auto exclusive zone is enabled, exclusive zone is automatically set to the
#| size of the C<window> + relevant margin. To disable auto exclusive zone, just set the
#| exclusive zone to 0 or any other fixed value.
#| NOTE: you can control the auto exclusive zone by changing the margin on the non-anchored
#| edge. This behavior is specific to gtk-layer-shell and not part of the underlying protocol
method enable_auto_exclusive_zone {
    gtk_layer_auto_exclusive_zone_enable $!window;
}

#| Returns if the surface's exclusive zone is set to change based on the window's size
method is_auto_exclusive_zone_enabled returns Bool:D {
    so gtk_layer_auto_exclusive_zone_is_enabled $!window;
}

#| Sets if/when C<window> should receive keyboard events from the compositor, see
#| C<LayerShellKeyboardMode> for details.
#| Default is C<KEYBOARD_MODE_NONE>
method set_keyboard_mode (LayerShellKeyboardMode:D $mode #=[ The type of keyboard interactivity requested ]) {
    gtk_layer_set_keyboard_mode $!window, $mode;
}

#| Returns current keyboard interactivity mode for C<window>
method get_keyboard_mode returns LayerShellKeyboardMode:D {
    LayerShellKeyboardMode(gtk_layer_get_keyboard_mode $!window);
}

=REPOSITORY L<https://github.com/CIAvash/GtkLayerShell/>

=BUG L<https://github.com/CIAvash/GtkLayerShell/issues>

=AUTHOR Siavash Askari Nasr - L<https://www.ciavash.name>

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
