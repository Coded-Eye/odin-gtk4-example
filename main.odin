package calc

import "core:fmt"
import glib "odin-gtk/glib"
import gio "odin-gtk/glib/gio"
import gobject "odin-gtk/glib/gobject"
import gtk "odin-gtk/gtk"

hello_world :: proc() {
	fmt.println("Hello, world!")
}

app_activate :: proc(app: ^gtk.Application, user_data: rawptr) {
	builder := gtk.builder_new()
	defer gobject.object_unref(builder)

	cscope := gtk.builder_cscope_new()
	defer gobject.object_unref(cscope)
	gtk.builder_set_scope(builder, cscope)

	gtk.builder_cscope_add_callback_symbol(
		cast(^gtk.BuilderCScope)cscope,
		"hello_world",
		cast(gobject.Callback)hello_world,
	)

	err: ^glib.Error
	ok := gtk.builder_add_from_file(builder, "main.ui", &err)
	if !ok {
		fmt.println(err)
		return
	}

	window := gtk.builder_get_object(builder, "App")
	if window == nil {
		fmt.println("couldn't load window")
		return
	}

	gtk.window_set_application(cast(^gtk.Window)window, app)
	gtk.window_present(cast(^gtk.Window)window)
}

main :: proc() {
	context = glib.create_context()

	app := gtk.application_new("org.calc", gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
	defer gobject.object_unref(app)

	gobject.signal_connect(app, "activate", cast(gobject.Callback)app_activate, nil)

	stat := gio.application_run(
		gobject.type_cast(gio.Application, app, gio.application_get_type()),
		0,
		nil,
	)
}
