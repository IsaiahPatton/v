module gg

import gx

#include <windows.h>
#include <stdio.h>
#include <wingdi.h>
#flag -lgdi32

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
	ws_overlappedwindow = 13565952
	gwlp_userdata       = -21
)

struct WndClassEx {
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

struct C.tagRECT {
	left   f32
	top    f32
	right  f32
	bottom f32
}

fn C.RegisterClassEx(class &WndClassEx) int

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

fn C.FillRect(hdc C.HDC, rect &C.tagRECT, hbr C.HBRUSH)

fn C.InvalidateRect(hwnd C.HWND, rect &C.tagRECT, berase bool)

fn C.SetTimer(hwnd C.HWND, id u32, ela u32, C.TIMERPROC)

fn C.DeleteObject(obj C.HBRUSH)

fn C.GetWindowLongPtr(hwnd C.HWND, index int) C.LONG_PTR

fn C.SetWindowLongPtr(hwnd C.HWND, index int, new_long C.LONG_PTR)

fn main() {
	win32_create_window(600, 300, 500, 400, 'My Program')
	win32_run_message_loop()
}

fn win32_create_window(x int, y int, w int, h int, title string) &C.HWND {
	cw := (C.COLOR_WINDOW + 1)
	wndclass := WndClassEx{
		cb_size: sizeof(WndClassEx)
		lpfn_wnd_proc: my_wnd_proc
		lpsz_class_name: title.to_wide()
		lpsz_menu_name: 0
		h_icon_sm: 0
		style: cs_hredraw + cs_vredraw
		hbr_background: C.HBRUSH(cw)
	}
	if C.RegisterClassEx(&wndclass) == 0 && C.GetLastError() != u32(C.ERROR_CLASS_ALREADY_EXISTS) {
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

// TODO:
fn win32_run_message_loop() {
	mut msg := C.NULL
	for C.GetMessage(&msg, C.NULL, 0, 0) {
		C.TranslateMessage(&msg)
		C.DispatchMessage(&msg)
	}
}

// test:
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

fn my_wnd_proc(hwnd C.HWND, message u32, wParam C.WPARAM, lParam C.LPARAM) C.LRESULT {
	
	mut dat := C.GetWindowLongPtr(hwnd, gwlp_userdata)
	//dump(dat)

	if message == wm_ncmousemove {
		return C.LRESULT(0)
	}

	if message == wm_create {
		target_fps := 1
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
		mut ps := unsafe { nil }
		mut hdc := C.BeginPaint(hwnd, &ps)
		
		if dat != unsafe { nil } {
			mut mydat := unsafe { &Win32Userdata(voidptr(dat)) }
			mydat.hdc = hdc
			gg_frame_fn(mut mydat.ctx)
		} else {
		}

		C.EndPaint(hwnd, &ps)
		return C.LRESULT(0)
	}

	return C.DefWindowProc(hwnd, message, wParam, lParam)
}

// Draw rect filled
fn win32_draw_rect_filled(hdc C.HDC, x f32, y f32, w f32, h f32, c gx.Color) {
	dump('DRAW_RECT')
	hbrush := C.CreateSolidBrush(C.RGB(c.r, c.g, c.b))
	rec := C.tagRECT{x, y, x + w, y + h}
	C.FillRect(hdc, &rec, hbrush)
	C.DeleteObject(hbrush)
}

// Draw rect empty
fn win32_draw_rect_empty(hdc C.HDC, x f32, y f32, w f32, h f32, c gx.Color) {
	dump('DRAW_RECT')
}

// Draw rounded rect empty
fn win32_draw_rounded_rect_empty(hdc C.HDC, x f32, y f32, w f32, h f32, radius f32, c gx.Color) {
	dump('DRAW_RECT')
}

// Draw rounded rect filled
fn win32_draw_rounded_rect_filled(hdc C.HDC, x f32, y f32, w f32, h f32, radius f32, c gx.Color) {
	dump('DRAW_RECT')
}

// Draw pixel
fn win32_draw_pixel(hdc C.HDC, x f32, y f32, c gx.Color) {
	win32_draw_rect_filled(hdc, x, y, 1, 1, c)
}

// Draw pixels
fn win32_draw_pixels(hdc C.HDC, points []f32, c gx.Color) {
	dump('DRAW_RECT')
}