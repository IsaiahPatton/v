// (c) 2023 Isaiah.
module gg

import gx

#include <windows.h>
#include <stdio.h>
#include <wingdi.h>
#flag -lgdi32
#flag -luser32
#flag -lmsimg32
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
	wm_keydown          = 256
	wm_keyup            = 257
	wm_char             = 258
	wm_timer            = 275
	wm_hscroll          = 276
	wm_vscroll          = 277
	wm_mousemove        = 512
	vm_lbuttondown      = 513
	vm_lbuttonup        = 514
	ws_overlappedwindow = 13565952
	gwlp_userdata       = -21
	dt_noclip           = 256
	idc_arrow           = 32512
)

struct Win32WndClass {
	cb_size         u32
	style           u32
	lpfn_wnd_proc   voidptr
	cb_cls_extra    int
	cb_wnd_extra    int
	h_instance      C.HINSTANCE
	h_icon          C.HICON
	h_cursor        C.HCURSOR
	hbr_background  C.HBRUSH
	lpsz_menu_name  &u16 = unsafe { nil }
	lpsz_class_name &u16 = unsafe { nil }
	h_icon_sm       &u16 = unsafe { nil }
}

// Rectangle
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

[typedef]
struct C.HDC {
}

// window c fns
fn C.RegisterClassEx_(class &Win32WndClass) int
fn C.CreateWindowEx(dwExStyle i64, lpClassName &u16, lpWindowName &u16, dwStyle i64, x int, y int, nWidth int, nHeight int, hWndParent i64, hMenu voidptr, h_instance voidptr, lpParam voidptr) C.HWND

fn C.DefWindowProc(hwnd C.HWND, msg u32, wParam C.WPARAM, lParam C.LPARAM) C.LRESULT
fn C.ShowWindow(hwnd C.HWND, num int)
fn C.UpdateWindow(hwnd C.HWND)
fn C.GetWindowLongPtr(hwnd C.HWND, index int) C.LONG_PTR
fn C.SetWindowLongPtr(hwnd C.HWND, index int, new_long C.LONG_PTR)
fn C.WndProc_A(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM) C.LRESULT
fn C.WndProc_create(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM)
fn C.WndProc_pa(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM)
fn C.WndProc_pb(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM)
fn C.GetModuleHandle(lc &u16) voidptr
fn C.GetClientRect(hwnd C.HWND, lprect &C.tagRECT)
fn C.LoadCursor(hin C.HINSTANCE, name C.LPCSTR) C.HCURSOR

// message c fns
fn C.GetMessage(msg C.MSG, hwnd C.HWND, a int, b int) bool
fn C.PeekMessageW(msg C.MSG, hwnd C.HWND, a int, b int, c int) bool
fn C.TranslateMessage(msg C.MSG)
fn C.DispatchMessage(msg C.LPMSG)
fn C.DispatchMessageW(msg C.MSG)
fn C.PostQuitMessage(code int)

fn C.SetTimer(hwnd C.HWND, id u32, ela u32, C.TIMERPROC)

fn C.DeleteObject(obj C.HGDIOBJ)

fn C.SelectObject(hdc C.HDC, h C.HGDIOBJ)

fn C.my_scissor_rect(hdc C.HDC, x int, y int, w int, h int)

fn C.is_native_win32_ui() bool
fn C.win32_width() int
fn C.win32_height() int

fn C.get_mouse_x(lp C.LPARAM) int
fn C.get_mouse_y(lp C.LPARAM) int

fn C.GetDC(hwnd C.HWND) C.HDC
fn C.CreateCompatibleDC(hdc C.HDC) C.HDC
fn C.CreateCompatibleBitmap(hdc C.HDC, cx int, cy int) C.HBITMAP
fn C.ReleaseDC(hwnd C.HWND, hdc C.HDC)

fn C.win32_set_bg(r int, g int, b int)

fn C.get_bufferdc() C.HDC

// Draw C fns
fn C.InvalidateRect(hwnd C.HWND, rect &C.tagRECT, berase bool)
fn C.BeginPaint(hwnd C.HWND, lppaint C.LPPAINTSTRUCT) C.HDC
fn C.EndPaint(hwnd C.HWND, lppaint C.LPPAINTSTRUCT)
fn C.CreateSolidBrush(color C.COLORREF) C.HBRUSH
fn C.RGB(r int, g int, b int) C.COLORREF
fn C.win32_draw_line(hdc C.HDC, a int, b int, c int, d int, rgb C.COLORREF, style int)
fn C.draw_rect_filled_alpha(hdc C.HDC, x int, y int, w int, h int, rgb C.COLORREF, alpha int)
fn C.win32_draw_triangle(hdc C.HDC, x int, y int, x2 int, y2 int, x3 int, y3 int, r int, g int, b int)
fn C.FillRect(hdc C.HDC, rect &C.tagRECT, hbr C.HBRUSH)

// 		C.RoundRect(hdc, rect.left, rect.top, rect.right, rect.bottom, f32_to_i32(radius * 2), f32_to_i32(radius * 2));
fn C.RoundRect(hdc C.HDC, x int, y int, right int, bottom int, w int, h int)

fn C.FrameRect(hdc C.HDC, rect &C.tagRECT, hbr C.HBRUSH)
fn C.CreateBitmapFromPixels(hdc C.HDC, width int, height int, pixels voidptr) C.HBITMAP
fn C.PaintImage(hdc C.HDC, hbm C.HBITMAP, x int, y int, w int, h int, px int, py int, pw int, ph int)

fn win_paint_image(hdc C.HDC, hbm C.HBITMAP, x int, y int, w int, h int, px int, py int, pw int, ph int) {
	C.PaintImage(hdc, hbm, x, y, w, h, px, py, pw, ph)
}


// text c fns
fn C.DrawText(hdc C.HDC, lpchtext &u16, cch int, rect &C.tagRECT, format u32)
fn C.my_text_size(hdc C.HDC, lpchtext &u16, le int) C.tagSIZE
fn C.fix_text_background(hdc C.HDC)
fn C.SetTextColor(hdc C.HDC, color C.COLORREF)
fn C.my_create_font(size int) C.HFONT

[typedef]
struct C.PAINTSTRUCT {
}

struct DrawInstruction {
	typ string
}

fn (this DrawInstruction) matches(o DrawInstruction) bool {
	return this.typ == o.typ
}

pub fn do_draw(ctx &Context) int {
	a := ctx.win32.last
	b := ctx.win32.current

	mut dat := C.GetWindowLongPtr(C.get_hwnd(), gg.gwlp_userdata)
	mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }

	mut c := []DrawInstruction{}
	
	for val in b {
		mut doo := true
		for vall in a {
			if vall.matches(val) {
				doo = false
			}
		}
		if doo {
			c << val
		}
	}
	
	
	for y in a {
		mut hass := false
		for z in b {
			if (y.typ == z.typ) {
				hass = true
			}
		}
		if !hass {
			dump(y)
		}
	}
	
	mut a_s := ''
	mut b_s := ''
	
	for aa in a {
		dh := does_have(aa.typ, b)
		if !dh {
			a_s += ' | ' + aa.typ
		}
	}
	for bb in b {
		dh := does_have(bb.typ, a)
		if bb.typ.contains('txt ') && bb.typ.contains('println') {
			dump('${bb.typ} ${dh}')
		}
		if !dh {
			b_s += ' | ' + bb.typ
		}
	}
	//dump('${a.len} | ${b.len}')
	//if a.len != b.len {
	if a_s.len > 0 || b_s.len > 0 {
		dump(a_s)
		dump(b_s)
	}
	//}
	
	if a.len != b.len {
		/*dump(a == b)
		dump(a.len)
		dump(b.len)
		dump(c)*/
		return 1
	}
	
	if a.len == 0 {
		return 1
	}
	
	// dump(c.len)

	return c.len
}

fn does_have(typ string, arr []DrawInstruction) bool {
	for s in arr {
		if s.typ == typ {
			return true
		}
	}
	return false
}

struct FillRectInstruction {
	DrawInstruction
}

fn win32_scissor_rect(hdc C.HDC, x int, y int, w int, h int) {
	C.my_scissor_rect(hdc, x, y, w, h)
}

fn C.get_hwnd() C.HWND 

fn C.win32_set_text_size(size int) 

fn win32_draw_text(hdc C.HDC, text string, x int, y int, cfg gx.TextCfg) {
	rect := &C.tagRECT{
		left: x
		top: y
	}

	//mut dat := C.GetWindowLongPtr(C.get_hwnd(), gg.gwlp_userdata)
	//mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
	//mydat.current << DrawInstruction{
	//	typ: 'txt ${text} ${x} ${y}'
	//}

	hfont := C.my_create_font(cfg.size)
	C.win32_set_text_size(cfg.size)
	C.SelectObject(hdc, C.HGDIOBJ(hfont))
	
	w, h := win32_text_size(hdc, text)

	// win32_draw_rect_empty(hdc, x, y, w, h, gx.red)

	C.fix_text_background(hdc)
	C.SetTextColor(hdc, C.RGB(cfg.color.r, cfg.color.g, cfg.color.b))

	C.DrawText(hdc, text.to_wide(), -1, rect, gg.dt_noclip)
	C.DeleteObject(C.HGDIOBJ(hfont))
}

fn win32_text_size(hdc C.HDC, text string) (f32, f32) {
	size := C.my_text_size(hdc, text.to_wide(), text.len)
	return size.cx, size.cy
}

fn win32_get_window_size(hwnd C.HWND) (int, int) {
	rect := &C.tagRECT{}
	C.GetClientRect(hwnd, rect)
	C.DeleteObject(C.HGDIOBJ(rect))
	return int(rect.right - rect.left), int(rect.bottom - rect.top)
}

fn to_colorref(c gx.Color) C.COLORREF {
	return C.RGB(c.r, c.g, c.b)
}

// Create a new Win32 Window
fn win32_create_window(x int, y int, w int, h int, title string) C.HWND {
	cw := (C.COLOR_WINDOW + 1)
	wndclass := Win32WndClass{
		cb_size: sizeof(Win32WndClass)
		lpfn_wnd_proc: voidptr(my_wnd_proc)
		lpsz_class_name: title.to_wide()
		lpsz_menu_name: 0
		h_icon_sm: 0
		h_cursor: C.LoadCursor(C.NULL, C.LPCSTR(gg.idc_arrow))
		style: gg.cs_hredraw + gg.cs_vredraw
		hbr_background: C.HBRUSH(cw)
	}
	if C.RegisterClassEx_(&wndclass) == 0 && C.GetLastError() != u32(C.ERROR_CLASS_ALREADY_EXISTS) {
		println('Failed registering class.')
	}

	h_inst := C.GetModuleHandle(C.NULL)
	hwnd := C.CreateWindowEx(0, wndclass.lpsz_class_name, wndclass.lpsz_class_name, gg.ws_overlappedwindow,
		x, y, w, h, C.NULL, C.NULL, h_inst, C.NULL)
	if hwnd == C.NULL {
		println('Error creating window!')
		return hwnd
	}

	C.ShowWindow(hwnd, 10) // 10 = normal
	C.UpdateWindow(hwnd)
	return hwnd
}

fn C.gdi_loop()


fn C.get_msg() C.MSG

fn C.get_msg_msg(C.MSG) int

// Run the Win32 message loop
fn (mut this Win32Userdata) win32_run_message_loop() {
	mut msg := C.get_msg()
	
	
	// C.InvalidateRect(hwnd, C.NULL, C.TRUE)
	
	// PeekMessageW 
	// while (PeekMessageW(&msg, NULL, 0, 0, PM_REMOVE)) {
	
	for C.GetMessage(&msg, C.NULL, 0, 0) {
		C.TranslateMessage(&msg)
		C.DispatchMessageW(&msg)
	}
}

// Stores HDC & HWND of window
[heap]
struct Win32Userdata {
mut:
	ctx    &Context
	hdc    C.HDC
	hwnd   C.HWND
	frames int
	fps    int
	test   int
	mouse_moving bool
	last []DrawInstruction
	current []DrawInstruction
}

fn win32_set_userdata(hwnd C.HWND, ctx &Context) &Win32Userdata {
	mut data := &Win32Userdata{
		ctx: ctx
		hwnd: hwnd
	}

	C.SetWindowLongPtr(hwnd, gg.gwlp_userdata, C.LONG_PTR(data))
	return data
}

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

[manualfree]
struct WImg {
	m C.HBITMAP
}

fn create_wimg(hdc C.HDC, w int, h int, data voidptr) &WImg {
	return &WImg{
		m: C.CreateBitmapFromPixels(hdc, w, h, data)
	}
}

fn update_window(hwnd C.HWND) {
	C.InvalidateRect(hwnd, C.NULL, C.TRUE)
}

// Win32 Window Events
fn my_wnd_proc(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM) C.LRESULT {
	mut dat := C.GetWindowLongPtr(hwnd, gg.gwlp_userdata)

	if message == 20 {
		return C.LRESULT(1)
	}

	if message == gg.wm_size {
		dump('SIZE')
		return C.WndProc_A(hwnd, message, wParam, lParam)
	}
	
	if message != gg.wm_paint {
		// C.InvalidateRect(hwnd, C.NULL, C.TRUE)
		//rect := C.tagRECT{0, 0, 100, 100}
		//C.InvalidateRect(hwnd, &rect, C.TRUE)
	}

	if message == gg.wm_mousemove {
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
			mydat.mouse_moving = true
			gg_event_fn_(ev, mydat.ctx)
		}
		return C.LRESULT(1)
	}

	if message == gg.vm_lbuttondown {
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
		return C.LRESULT(1)
	}

	if message == gg.vm_lbuttonup {
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
		return C.LRESULT(1)
	}

	if message == gg.wm_create {
		C.WndProc_create(hwnd, message, wParam, lParam)
		target_fps := 40
		C.SetTimer(hwnd, 1, (1000 / target_fps), C.NULL)
		//C.SetTimer(hwnd, 3, 50, C.NULL)
		C.SetTimer(hwnd, 2, 1000, C.NULL)
		return C.LRESULT(0)
	}

	if message == gg.wm_timer {
		timerid := u32(wParam)

		if timerid == 3 {
			C.InvalidateRect(hwnd, C.NULL, C.TRUE)
		}

		if timerid == 1 {
		
			//mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
			
			// val := do_draw(mydat.ctx)

			//if val > 0 {
			C.InvalidateRect(hwnd, C.NULL, C.TRUE)
			//} else {
			//	mydat.current.clear()
			//	gg_frame_fn(mut mydat.ctx)
			//}
			//mydat.last = mydat.current
				//mydat.current.clear()
			//} else {
				//mydat.current.clear()
				//gg_frame_fn(mut mydat.ctx)
			//}
		}
		if timerid == 2 {
			if dat != unsafe { nil } {
				mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
				mydat.fps = mydat.frames
				dump(mydat.fps)
				mydat.frames = 0
			}
		}
		return C.LRESULT(0)
	}

	if message == gg.wm_keydown {
		pkey := u32(wParam)
		kc := get_key_code(pkey)
		println('${pkey} = ${kc}')

		mut ev := &Event{
			typ: .key_down
			key_code: kc
			char_code: pkey
		}

		if dat != unsafe { nil } {
			mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
			gg_event_fn_(ev, mydat.ctx)
		}
		
		return C.LRESULT(0)
	}

	if message == gg.wm_char {
		pkey := u32(wParam)
		if !is_key_char(pkey) {
			dump(pkey)
			return C.LRESULT(0)
		}

		mut ev := &Event{
			typ: .char
			char_code: pkey
		}

		if dat != unsafe { nil } {
			mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
			gg_event_fn_(ev, mydat.ctx)
		}
		return C.LRESULT(0)
	}

	if message == gg.wm_destroy {
		C.PostQuitMessage(0)
		return C.LRESULT(0)
	}

	if message == gg.wm_paint {
		//dump('PAINT')
		C.WndProc_pa(hwnd, message, wParam, lParam)

		hfont := C.my_create_font(16)
		if dat != unsafe { nil } {
			mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
			mydat.last = mydat.current
			mydat.current.clear()
			if mydat.test == 0 {
				mydat.hdc = C.get_bufferdc() // hbufferdc
				mydat.test = 1
			}
			C.SelectObject(mydat.hdc, C.HGDIOBJ(hfont))
			gg_frame_fn(mut mydat.ctx)
			//mydat.last = mydat.current
			mydat.frames += 1
		}
		C.DeleteObject(C.HGDIOBJ(hfont))
		C.WndProc_pb(hwnd, message, wParam, lParam)

		return C.LRESULT(1)
	}

	return C.DefWindowProc(hwnd, message, wParam, lParam)
}

// TODO: https://boostrobotics.eu/windows-key-codes/
fn get_key_code(c u32) KeyCode {
	//dump(c)
	unsafe {
		if c == 13 {
			return .enter
		}
		if c == 8 {
			return .backspace
		}
		if c == 9 {
			return .tab
		}
		if c == 37 {
			return .left
		}
		if c == 38 {
			return .up
		}
		if c == 39 {
			return .right
		}
		if c == 38 {
			return .down
		}
		if c == 164 {
			return .left_alt 
		}
		kc := KeyCode(c)
		return kc
	}
}

// is_key_char returns true if the given u8 is a valid key character.
[inline]
pub fn is_key_char(c u32) bool {
	return (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || c == 32 || (c >= 48 && c <= 57) || c == 46 // 32 = space, 48-57 = 0-9
}

// Draw rect filled
fn win32_draw_rect_filled(hdc C.HDC, x f32, y f32, w f32, h f32, c gx.Color) {
	color := to_colorref(c)
	
	mut dat := C.GetWindowLongPtr(C.get_hwnd(), gg.gwlp_userdata)
	mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
	mydat.current << DrawInstruction{
		typ: 'filled${x},${y},${w},${h},${c}'
	}

	if c.a == 255 {
		hbrush := C.CreateSolidBrush(color)
		rec := C.tagRECT{x, y, x + w, y + h}
		C.FillRect(hdc, &rec, hbrush)
		C.DeleteObject(C.HGDIOBJ(hbrush))
		return
	}
	C.draw_rect_filled_alpha(hdc, x, y, w, h, color, c.a)
}

// Draw rect filled (using AlphaBlend)
fn win32_draw_rect_filled_alpha(hdc C.HDC, x f32, y f32, w f32, h f32, c gx.Color) {
	C.draw_rect_filled_alpha(hdc, x, y, w, h, to_colorref(c), c.a)
}

// Draw rect empty
fn win32_draw_rect_empty(hdc C.HDC, x f32, y f32, w f32, h f32, c gx.Color) {
	hbrush := C.CreateSolidBrush(C.RGB(c.r, c.g, c.b))
	rec := C.tagRECT{x, y, x + w, y + h}

	mut dat := C.GetWindowLongPtr(C.get_hwnd(), gg.gwlp_userdata)
	mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
	mydat.current << DrawInstruction{
		typ: 'remp${x},${y},${w},${h},${c}'
	}
	
	C.FrameRect(hdc, &rec, hbrush)
	C.DeleteObject(C.HGDIOBJ(hbrush))
}

fn win32_draw_rrect_filled(hdc C.HDC, x f32, y f32, w f32, h f32, radius f32, c gx.Color) {
	color := to_colorref(c)
	
	mut dat := C.GetWindowLongPtr(C.get_hwnd(), gg.gwlp_userdata)
	mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
	mydat.current << DrawInstruction{
		typ: 'filled${x},${y},${w},${h},${c}'
	}

	if c.a == 255 {
		hbrush := C.CreateSolidBrush(color)
		rec := C.tagRECT{x, y, x + w, y + h}

		C.RoundRect(hdc, rec.left, rec.top, rec.right, rec.bottom, (radius * 2), (radius * 2))

		
		C.DeleteObject(C.HGDIOBJ(hbrush))
		return
	}
	C.draw_rect_filled_alpha(hdc, x, y, w, h, color, c.a)
}

// Draw rounded rect empty
fn win32_draw_rounded_rect_empty(hdc C.HDC, x f32, y f32, w f32, h f32, radius f32, c gx.Color) {
	//win32_draw_rect_empty(hdc, x, y, w, h, c)
	
	color := to_colorref(c)
	hbrush := C.CreateSolidBrush(color)
	rec := C.tagRECT{x, y, x + w, y + h}
	C.EmptyRoundRect(hdc, rec, hbrush, radius)
	C.DeleteObject(C.HGDIOBJ(hbrush))
}

// void DrawCell(HDC& hdc, const RECT& rcTarget,const HBRUSH& hbrUpper, const HBRUSH& hbrLower) {
fn C.DrawCell(hdc C.HDC, rec C.tagRECT, b C.HBRUSH, rad int)
fn C.EmptyRoundRect(hdc C.HDC, rec C.tagRECT, b C.HBRUSH, rad int)

// Draw rounded rect filled
fn win32_draw_rounded_rect_filled(hdc C.HDC, x f32, y f32, w f32, h f32, radius f32, c gx.Color) {
	color := to_colorref(c)
	hbrush := C.CreateSolidBrush(color)
	rec := C.tagRECT{x, y, x + w, y + h}
	C.DrawCell(hdc, rec, hbrush, radius)
	C.DeleteObject(C.HGDIOBJ(hbrush))
}

// Draw pixel
fn win32_draw_pixel(hdc C.HDC, x f32, y f32, c gx.Color) {
	win32_draw_rect_filled(hdc, x, y, 1, 1, c)
}

// Draw line
fn win32_draw_line(hdc C.HDC, a f32, b f32, c f32, d f32, rgb C.COLORREF, style int) {
	C.win32_draw_line(hdc, a, b, c, d, rgb, style)
}

// Draw pixels
fn win32_draw_pixels(hdc C.HDC, points []f32, c gx.Color) {
	for i in 0 .. (points.len / 2) {
		x, y := points[i * 2], points[i * 2 + 1]
		win32_draw_pixel(hdc, x, y, c)
	}
}

fn gg_event_fn_(ce voidptr, user_data voidptr) {

	// e := unsafe { &sapp.Event(ce) }
	mut e := unsafe { &Event(ce) }
	mut ctx := unsafe { &Context(user_data) }
	
	mut dat := C.GetWindowLongPtr(C.get_hwnd(), gg.gwlp_userdata)
	mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
	/*mydat.current << DrawInstruction{
		typ: '${e.typ}'
	}*/
	
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
