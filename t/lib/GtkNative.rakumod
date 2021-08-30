use NativeLibs:auth<github:salortiz>:ver<0.0.9>;

unit module GtkNative;

our $Native_Lib is export = NativeLibs::Loader.load: 'libgtk-3.so';

if $Native_Lib {
    sub gtk_init(CArray[int32] $argc, CArray[CArray[Str]] $argv) is native {*}

    class GtkWidget is repr<CPointer> {};

    sub gtk_window_new(int32 $window_type --> GtkWidget) is native is export {*}
    sub gtk_widget_destroy(GtkWidget $widget) is native is export {*}

    my $argv = CArray[CArray[Str]].new;
    $argv[0] = CArray[Str].new: $*PROGRAM-NAME;
    gtk_init CArray[int32].new(1), $argv;
}
