// (c) 2023 Isaiah.
module gg

import gx

#include <windows.h>
#include <stdio.h>
#include <wingdi.h>
#flag -lgdi32
#flag -luser32
#flag -I @VEXEROOT/thirdparty/win32
#include "win32_api.c"

// Reference: https://wiki.winehq.org/List_Of_Windows_Messages
const (
	cs_vredraw          = 0x0001
	cs_hredraw          = 0x0002
	wm_create           = 1
	wm_destroy          = 2
	wm_move             = 3
	wm_size             = 5
	wm_activate         = 6
	wm_setfocus         = 7
	wm_killfocus        = 8
	wm_enable           = 10
	wm_setredraw        = 11
	wm_settext          = 12
	wm_gettext          = 13
	wm_gettextlength    = 14
	wm_paint            = 15
	wm_close            = 16
	wm_ncmousemove      = 160
	wm_timer            = 275
	wm_hscroll          = 276
	wm_vscroll          = 277
	wm_mousemove		= 512
	vm_lbuttondown		= 513
	vm_lbuttonup		= 514
	ws_overlappedwindow = 13565952
	gwlp_userdata       = -21
)

struct Win32WndClass {
	cb_size        u32
	style          u32
	lpfn_wnd_proc  voidptr
	cb_cls_extra   int
	cb_wnd_extra   int
	h_instance     C.HINSTANCE
	h_icon         C.HICON
	h_cursor       C.HCURSOR
	hbr_background C.HBRUSH
	lpsz_menu_name &u16 = unsafe { nil }
	// LPCWSTR
	lpsz_class_name &u16 = unsafe { nil }
	h_icon_sm       &u16 = unsafe { nil }
}

// Rectangle (https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect)
struct C.tagRECT {
	left   f32
	top    f32
	right  f32
	bottom f32
}

struct C.tagSIZE {
	cx f32
	cy f32
}

fn C.RegisterClassEx_(class &Win32WndClass) int

fn C.CreateWindowEx(dwExStyle i64, lpClassName &u16, lpWindowName &u16, dwStyle i64, x int, y int, nWidth int, nHeight int, hWndParent i64, hMenu voidptr, h_instance voidptr, lpParam voidptr) &C.HWND

fn C.DefWindowProc(hwnd C.HWND, msg u32, wParam C.WPARAM, lParam C.LPARAM) C.LRESULT

fn C.ShowWindow(hwnd C.HWND, num int)

fn C.UpdateWindow(hwnd C.HWND)

fn C.GetModuleHandle(lc &u16) voidptr

fn C.GetMessage(msg C.LPMSG, hwnd C.HWND, a int, b int) bool

fn C.TranslateMessage(msg C.LPMSG)

fn C.DispatchMessage(msg C.LPMSG)

fn C.PostQuitMessage(code int)

fn C.BeginPaint(hwnd C.HWND, lppaint C.LPPAINTSTRUCT) C.HDC
fn C.EndPaint(hwnd C.HWND, lppaint C.LPPAINTSTRUCT)

fn C.CreateSolidBrush(color C.COLORREF) C.HBRUSH

fn C.RGB(r int, g int, b int) C.COLORREF

fn C.SetTextColor(hdc C.HDC, color C.COLORREF)

fn C.FillRect(hdc C.HDC, rect &C.tagRECT, hbr C.HBRUSH)

fn C.FrameRect(hdc C.HDC, rect &C.tagRECT, hbr C.HBRUSH)

fn C.InvalidateRect(hwnd C.HWND, rect &C.tagRECT, berase bool)

fn C.SetTimer(hwnd C.HWND, id u32, ela u32, C.TIMERPROC)

fn C.DeleteObject(obj C.HBRUSH)

fn C.GetWindowLongPtr(hwnd C.HWND, index int) C.LONG_PTR

fn C.SetWindowLongPtr(hwnd C.HWND, index int, new_long C.LONG_PTR)

fn C.GetClientRect(hwnd C.HWND, lprect &C.tagRECT)

fn C.my_text_size(hdc C.HDC, lpchtext &u16, le int) C.tagSIZE

/*
int DrawTextA(
  [in]      HDC    hdc,
  [in, out] LPCSTR lpchText,
  [in]      int    cchText,
  [in, out] LPRECT lprc,
  [in]      UINT   format
);
*/

fn C.DrawText(hdc C.HDC, lpchtext &u16, cch int, rect &C.tagRECT, format u32)

fn C.my_draw_text(hdc C.HDC, rect &C.tagRECT)

fn C.SelectObject(hdc C.HDC, h C.HGDIOBJ)

fn C.my_scissor_rect(hdc C.HDC, x int, y int, w int, h int)

fn C.fix_text_background(hdc C.HDC)

fn C.draw_background(hwnd C.HWND, wp C.WPARAM)
fn C.set_background(hwnd C.HWND)

fn C.is_native_win32_ui() bool
fn C.win32_width() int
fn C.win32_height() int

fn win32_scissor_rect(hdc C.HDC, x int, y int, w int, h int) {
	C.my_scissor_rect(hdc, x, y, w, h)
}

fn win32_draw_text(hdc C.HDC, text string, x int, y int, c gx.Color) {
	rect := &C.tagRECT{
		top: y
		left: x
		right: x + 200
		bottom: y + 200
	}

	C.fix_text_background(hdc)
	C.SetTextColor(hdc, C.RGB(c.r, c.g, c.b))
	C.DrawText(hdc, text.to_wide(), -1, rect, 0)
	//size := C.my_text_size(hdc, text.to_wide(), text.len)
	//dump(size.cx)
	//win32_draw_rect_empty(hdc, x, y, size.cx, size.cy, gx.blue)
}

fn win32_text_size(hdc C.HDC, text string) (f32, f32) {
	size := C.my_text_size(hdc, text.to_wide(), text.len)
	return size.cx, size.cy
}

fn cstr(the_string string) &char {
	return &char(the_string.str)
}

fn win32_get_window_size(hwnd C.HWND) (int, int) {
	rect := &C.tagRECT{}
	C.GetClientRect(hwnd, rect)
	return int(rect.right - rect.left), int(rect.bottom - rect.top)
}

fn main() {
	win32_create_window(600, 300, 500, 400, 'My Program')
	win32_run_message_loop()
}

fn C.WndProc_A(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM) C.LRESULT
fn C.WndProc_create(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM)
fn C.WndProc_pa(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM)
fn C.WndProc_pb(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM)

//LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)

// Create a new Win32 Window
fn win32_create_window(x int, y int, w int, h int, title string) &C.HWND {
	cw := (C.COLOR_WINDOW + 1)
	wndclass := Win32WndClass{
		cb_size: sizeof(Win32WndClass)
		lpfn_wnd_proc: my_wnd_proc
		lpsz_class_name: title.to_wide()
		lpsz_menu_name: 0
		h_icon_sm: 0
		style: cs_hredraw + cs_vredraw
		hbr_background: C.HBRUSH(cw)
	}
	if C.RegisterClassEx_(&wndclass) == 0 && C.GetLastError() != u32(C.ERROR_CLASS_ALREADY_EXISTS) {
		println('Failed registering class.')
	}

	h_inst := C.GetModuleHandle(C.NULL)
	hwnd := C.CreateWindowEx(0, wndclass.lpsz_class_name, wndclass.lpsz_class_name, ws_overlappedwindow,
		x, y, w, h, C.NULL, C.NULL, h_inst, C.NULL)
	if hwnd == C.NULL {
		println('Error creating window!')
		return hwnd
	}

	C.ShowWindow(hwnd, 10) // 10 = normal
	C.UpdateWindow(hwnd)
	return hwnd
}

// Run the Win32 message loop
// TODO: This needs to be injected at the end of main;
//       or else will crash.
fn win32_run_message_loop() {
	mut msg := C.NULL
	for C.GetMessage(&msg, C.NULL, 0, 0) {
		C.TranslateMessage(&msg)
		C.DispatchMessage(&msg)
	}
}

// Stores HDC & HWND of window
[heap]
struct Win32Userdata {
mut:
	ctx &Context
	hdc C.HDC
	hwnd C.HWND
}

fn win32_get_userdata(hwnd C.HWND) &Win32Userdata {
	mut dat := C.GetWindowLongPtr(hwnd, gwlp_userdata)
	mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
	return mydat
}

fn win32_set_userdata(hwnd C.HWND, ctx &Context) &Win32Userdata {
	mut data := &Win32Userdata{
		ctx: ctx
		hwnd: hwnd
	}

	C.SetWindowLongPtr(hwnd, gwlp_userdata, C.LONG_PTR(data))
	return data
}

fn C.get_mouse_x(lp C.LPARAM) int
fn C.get_mouse_y(lp C.LPARAM) int

/**

pub struct Event {
pub mut:
	frame_count        u64
	typ                sapp.EventType
	key_code           KeyCode
	char_code          u32
	key_repeat         bool
	modifiers          u32
	mouse_button       MouseButton
	mouse_x            f32
	mouse_y            f32
	mouse_dx           f32
	mouse_dy           f32
	scroll_x           f32
	scroll_y           f32
	num_touches        int
	touches            [8]TouchPoint
	window_width       int
	window_height      int
	framebuffer_width  int
	framebuffer_height int
}

 */
 
 fn C.GetDC(hwnd C.HWND) C.HDC
 fn C.CreateCompatibleDC(hdc C.HDC) C.HDC
 fn C.CreateCompatibleBitmap(hdc C.HDC, cx int, cy int) C.HBITMAP
 fn C.ReleaseDC(hwnd C.HWND, hdc C.HDC) 
 fn C.BitBlt(hdc C.HDC, x int, y int, cx int, cy int, hdcsrc C.HDC, x1 int, y1 int, rop C.DWORD)
 fn C.bit_blt(hdc C.HDC, ps C.PAINTSTRUCT, hbufferdc C.HDC) 
 
 struct C.PAINTSTRUCT{
 }

fn C.get_ps() C.PAINTSTRUCT
 
 fn C.hdcc() C.HDC
  fn C.set_hdcc(h C.HDC)
 
 
// Win32 Window Events
fn my_wnd_proc(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM) C.LRESULT {

	mut dat := C.GetWindowLongPtr(hwnd, gwlp_userdata)
	//dump(dat)
	
	//static HBITMAP hBuffer;
    //static HDC hDC;

	 if message == 20 {
            // Draw the background using the background brush
    //        C.draw_background(hwnd, wParam)
            return C.LRESULT(1)
        }
	
	if message == wm_size {
		return C.WndProc_A(hwnd, message, wParam, lParam)
	}
	
	if message == wm_mousemove {
		//C.InvalidateRect(hwnd, C.NULL, C.TRUE)
		mx := C.get_mouse_x(lParam)
		my := C.get_mouse_y(lParam)

		mut ev := &Event{
			typ: .mouse_move
			mouse_x: mx
			mouse_y: my
			mouse_button: .left
		}
		
		if dat != unsafe { nil } {
			mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
			gg_event_fn_(ev, mydat.ctx)
		}
		return C.LRESULT(0)
	}
	
	if message == vm_lbuttondown {
		mx := C.get_mouse_x(lParam)
		my := C.get_mouse_y(lParam)

		mut ev := &Event{
			typ: .mouse_down
			mouse_x: mx
			mouse_y: my
			mouse_button: .left
		}
		
		if dat != unsafe { nil } {
			mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
			gg_event_fn_(ev, mydat.ctx)
		}
		return C.LRESULT(0)
	}

	if message == vm_lbuttonup {
		mx := C.get_mouse_x(lParam)
		my := C.get_mouse_y(lParam)

		mut ev := &Event{
			typ: .mouse_up
			mouse_x: mx
			mouse_y: my
			mouse_button: .left
		}
		
		if dat != unsafe { nil } {
			mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
			gg_event_fn_(ev, mydat.ctx)
		}
		return C.LRESULT(0)
	}

	if message == wm_create {
		C.WndProc_create(hwnd, message, wParam, lParam)
		C.set_background(hwnd)
		target_fps := 60
		C.SetTimer(hwnd, 1, (1000 / target_fps), C.NULL)
		return C.LRESULT(0)
	}

	if message == wm_timer {
		timerid := u32(wParam)

		if timerid == 1 {
			C.InvalidateRect(hwnd, C.NULL, C.TRUE)
		}
	}

	if message == wm_destroy {
		// I don't know why but with TCC we get
		// Exception 0xC0000005 without this.
		$if tinyc {
			dump('bye!')
		}
		C.PostQuitMessage(0)
		return C.LRESULT(0)
	}

	if message == wm_paint {
			C.WndProc_pa(hwnd, message, wParam, lParam)

			if dat != unsafe { nil } {
				mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
				mydat.hdc = C.get_bufferdc() //hbufferdc
				gg_frame_fn(mut mydat.ctx)
			} else {
			
			}
			C.WndProc_pb(hwnd, message, wParam, lParam)
		return C.LRESULT(1)
	}

	return C.DefWindowProc(hwnd, message, wParam, lParam)
}

fn C.win32_set_bg(r int, g int, b int)

fn C.get_bufferdc() C.HDC

fn C.do_paint(hwnd C.HWND, hbufferdc C.HDC) C.HDC

// Draw rect filled
fn win32_draw_rect_filled(hdc C.HDC, x f32, y f32, w f32, h f32, c gx.Color) {
	hbrush := C.CreateSolidBrush(C.RGB(c.r, c.g, c.b))
	rec := C.tagRECT{x, y, x + w, y + h}
	C.FillRect(hdc, &rec, hbrush)
	C.DeleteObject(hbrush)
}

// Draw rect empty
fn win32_draw_rect_empty(hdc C.HDC, x f32, y f32, w f32, h f32, c gx.Color) {
	hbrush := C.CreateSolidBrush(C.RGB(c.r, c.g, c.b))
	rec := C.tagRECT{x, y, x + w, y + h}
	C.FrameRect(hdc, &rec, hbrush)
	C.DeleteObject(hbrush)
}

// Draw rounded rect empty
fn win32_draw_rounded_rect_empty(hdc C.HDC, x f32, y f32, w f32, h f32, radius f32, c gx.Color) {
	win32_draw_rect_empty(hdc, x, y, w, h, c)
}

// Draw rounded rect filled
fn win32_draw_rounded_rect_filled(hdc C.HDC, x f32, y f32, w f32, h f32, radius f32, c gx.Color) {
	win32_draw_rect_filled(hdc, x, y, w, h, c)
}

// Draw pixel
fn win32_draw_pixel(hdc C.HDC, x f32, y f32, c gx.Color) {
	win32_draw_rect_filled(hdc, x, y, 1, 1, c)
}

// Draw line
fn win32_draw_line(hdc C.HDC, a f32, b f32, c f32, d f32) {
	C.win32_draw_line(hdc, int(a), int(b), int(c), int(d))
}

// Draw pixels
fn win32_draw_pixels(hdc C.HDC, points []f32, c gx.Color) {
	for i in 0 .. (points.len / 2) {
		x, y := points[i * 2], points[i * 2 + 1]
		win32_draw_pixel(hdc, x, y, c)
	}
}

fn C.win32_draw_line(hdc C.HDC, a int, b int, c int, d int)

fn gg_event_fn_(ce voidptr, user_data voidptr) {
	// e := unsafe { &sapp.Event(ce) }
	mut e := unsafe { &Event(ce) }
	mut ctx := unsafe { &Context(user_data) }
	if ctx.ui_mode {
		ctx.refresh_ui()
	}
	if e.typ == .mouse_down {
		bitplace := int(e.mouse_button)
		ctx.mbtn_mask |= u8(1 << bitplace)
		ctx.mouse_buttons = unsafe { MouseButtons(ctx.mbtn_mask) }
	}
	if e.typ == .mouse_up {
		bitplace := int(e.mouse_button)
		ctx.mbtn_mask &= ~(u8(1 << bitplace))
		ctx.mouse_buttons = unsafe { MouseButtons(ctx.mbtn_mask) }
	}
	if e.typ == .mouse_move && e.mouse_button == .invalid {
		if ctx.mbtn_mask & 0x01 > 0 {
			e.mouse_button = .left
		}
		if ctx.mbtn_mask & 0x02 > 0 {
			e.mouse_button = .right
		}
		if ctx.mbtn_mask & 0x04 > 0 {
			e.mouse_button = .middle
		}
	}
	ctx.mouse_pos_x = int(e.mouse_x / ctx.scale)
	ctx.mouse_pos_y = int(e.mouse_y / ctx.scale)
	ctx.mouse_dx = int(e.mouse_dx / ctx.scale)
	ctx.mouse_dy = int(e.mouse_dy / ctx.scale)
	ctx.scroll_x = int(e.scroll_x / ctx.scale)
	ctx.scroll_y = int(e.scroll_y / ctx.scale)
	ctx.key_modifiers = unsafe { Modifier(e.modifiers) }
	ctx.key_repeat = e.key_repeat
	if e.typ in [.key_down, .key_up] {
		key_idx := int(e.key_code) % key_code_max
		prev := ctx.pressed_keys[key_idx]
		next := e.typ == .key_down
		ctx.pressed_keys[key_idx] = next
		ctx.pressed_keys_edge[key_idx] = prev != next
	}
	if ctx.config.event_fn != unsafe { nil } {
		ctx.config.event_fn(e, ctx.config.user_data)
	}
	match e.typ {
		.mouse_move {
			if ctx.config.move_fn != unsafe { nil } {
				ctx.config.move_fn(e.mouse_x / ctx.scale, e.mouse_y / ctx.scale, ctx.config.user_data)
			}
		}
		.mouse_down {
			if ctx.config.click_fn != unsafe { nil } {
				ctx.config.click_fn(e.mouse_x / ctx.scale, e.mouse_y / ctx.scale, e.mouse_button,
					ctx.config.user_data)
			}
		}
		.mouse_up {
			if ctx.config.unclick_fn != unsafe { nil } {
				ctx.config.unclick_fn(e.mouse_x / ctx.scale, e.mouse_y / ctx.scale, e.mouse_button,
					ctx.config.user_data)
			}
		}
		.mouse_leave {
			if ctx.config.leave_fn != unsafe { nil } {
				ctx.config.leave_fn(e, ctx.config.user_data)
			}
		}
		.mouse_enter {
			if ctx.config.enter_fn != unsafe { nil } {
				ctx.config.enter_fn(e, ctx.config.user_data)
			}
		}
		.mouse_scroll {
			if ctx.config.scroll_fn != unsafe { nil } {
				ctx.config.scroll_fn(e, ctx.config.user_data)
			}
		}
		.key_down {
			if ctx.config.keydown_fn != unsafe { nil } {
				ctx.config.keydown_fn(e.key_code, unsafe { Modifier(e.modifiers) }, ctx.config.user_data)
			}
		}
		.key_up {
			if ctx.config.keyup_fn != unsafe { nil } {
				ctx.config.keyup_fn(e.key_code, unsafe { Modifier(e.modifiers) }, ctx.config.user_data)
			}
		}
		.char {
			if ctx.config.char_fn != unsafe { nil } {
				ctx.config.char_fn(e.char_code, ctx.config.user_data)
			}
		}
		.resized {
			if ctx.config.resized_fn != unsafe { nil } {
				ctx.config.resized_fn(e, ctx.config.user_data)
			}
		}
		.quit_requested {
			if ctx.config.quit_fn != unsafe { nil } {
				ctx.config.quit_fn(e, ctx.config.user_data)
			}
		}
		else {
			// dump(e)
		}
	}
}