module main

import gg
import gx

struct App {
mut:
	gg     &gg.Context = unsafe { nil }
}

fn main() {
	mut app := &App{
		gg: 0
	}
	app.gg = gg.new_context(
		bg_color: gx.rgb(174, 198, 255)
		width: 300
		height: 220
		window_title: 'Win32 Native Test'
		native_rendering: true
		frame_fn: frame
		user_data: app
	)
	app.gg.run()
}

fn frame(mut app App) {
	
	//dump('frame')
	app.gg.begin()

	app.gg.draw_rect_filled(10, 10, 30, 30, gx.blue)
	// Draw a blue pixel near each corner. (Find your magnifying glass)
	app.gg.draw_pixel(2, 2, gx.blue)
	app.gg.draw_pixel(app.gg.width - 2, 2, gx.blue)
	app.gg.draw_pixel(app.gg.width - 2, app.gg.height - 2, gx.blue)
	app.gg.draw_pixel(2, app.gg.height - 2, gx.blue)

	// Draw pixels in a grid-like pattern.
	// app.gg.draw_pixels(app.pixels, gx.red)
	app.gg.end()
}
