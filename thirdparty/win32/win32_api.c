// Win32 GDI Helper
// Copyright (c) 2023 Isaiah

#include <windows.h>
#include <stdio.h>
#include <wingdi.h>

HFONT my_create_font(int size) {
	return CreateFont(size, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, 
				OUT_DEFAULT_PRECIS, CLIP_DFA_DISABLE, DEFAULT_QUALITY, DEFAULT_PITCH, TEXT("Arial"));
}

void stf() {
}

SIZE my_text_size(HDC hdc, char* text, int textLength) {
	SIZE size;

	// select a font into the device context
	//HFONT hFont = my_create_font(16);
	//SelectObject(hdc, hFont);

	// get the size of the text
	GetTextExtentPoint32(hdc, text, textLength, &size);
	
	//DeleteObject(hFont);

	// the width and height of the text are in the size structure
	return size;
}

// set the background mode to transparent
void fix_text_background(HDC hdc) {
	SetBkMode(hdc, TRANSPARENT);
}

// set the text color
void set_text_color(HDC hdc, COLORREF color) {
	SetTextColor(hdc, color);
}

void my_scissor_rect(HDC hdc, int x, int y, int w, int h) {
	HRGN hRgn;
	RECT rect;

	// create a region that defines the scissor rectangle
	rect.left = x;
	rect.top = y;
	rect.right = x + w;
	rect.bottom = y + h;
	hRgn = CreateRectRgnIndirect(&rect);

	// set the scissor rectangle for the device context
	SelectClipRgn(hdc, hRgn);

	// release the region and the device context
	DeleteObject(hRgn);
}

int get_mouse_x(LPARAM lParam) {
	int x = LOWORD(lParam);
}

int get_mouse_y(LPARAM lParam) {
	int y = HIWORD(lParam);
}

static HBITMAP hBuffer;
static HDC hBufferDC;
static HDC mhdc;

HDC get_bufferdc() {
	return hBufferDC;
}

void bit_blt(HDC hdcc, PAINTSTRUCT ps, HDC hBufferDC) {
	BitBlt(hdcc, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right - ps.rcPaint.left,
				ps.rcPaint.bottom - ps.rcPaint.top, hBufferDC, ps.rcPaint.left, ps.rcPaint.top, SRCCOPY);
	
}

HDC do_paint(HWND hwnd, HDC hbufferdc) {
	PAINTSTRUCT ps;
	HDC hdcc = BeginPaint(hwnd, &ps);
	mhdc = hdcc;
	//bit_blt(hdcc, ps, hbufferdc);
	EndPaint(hwnd, &ps);
	return hdcc;
}

int RegisterClassEx_(WNDCLASS* claz) {
	return RegisterClassEx(claz);
}

static HBITMAP hBuffer;
static HDC hDC;
static HDC hBufferDC;
static COLORREF background = RGB(255, 255, 255);
static is_win32_ui = false;
static HWND hwnd;

bool is_native_win32_ui() {
	return is_win32_ui;
}

int win32_width() {
	 RECT clientRect;
	 GetClientRect(hwnd, &clientRect);
	 int width = clientRect.right - clientRect.left;
	 int height = clientRect.bottom - clientRect.top;
	 return width;
}

int win32_height() {
	 RECT clientRect;
	 GetClientRect(hwnd, &clientRect);
	 int width = clientRect.right - clientRect.left;
	 int height = clientRect.bottom - clientRect.top;
	 return height;
}


LRESULT CALLBACK WndProc_A(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
	HDC hdc = GetDC(hwnd);
	HDC hdcMem = CreateCompatibleDC(hdc);

	RECT clientRect;
	GetClientRect(hwnd, &clientRect);
	int width = clientRect.right - clientRect.left;
	int height = clientRect.bottom - clientRect.top;

	HBITMAP hbmMem = CreateCompatibleBitmap(hdc, width, height);
	SelectObject(hBufferDC, hbmMem);

	// Draw on the memory DC

	ReleaseDC(hwnd, hdc);
	DeleteDC(hdcMem);
	DeleteObject(hbmMem);

	return 0;
}

void WndProc_create(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
	is_win32_ui = true;
	hwnd = hWnd;
	hDC = GetDC(hWnd);
	hBufferDC = CreateCompatibleDC(hDC);
			hBuffer = CreateCompatibleBitmap(hDC, 640, 480);
			SelectObject(hBufferDC, hBuffer);
			ReleaseDC(hWnd, hDC);
}

void WndProc_pa(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
	RECT rc;
	GetClientRect(hWnd, &rc);
	HBRUSH hBrush = CreateSolidBrush(background);
	FillRect(hBufferDC, &rc, hBrush);
	DeleteObject(hBrush);
}

void WndProc_pb(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
	 // Copy the memory buffer to the screen
	PAINTSTRUCT ps;
	hDC = BeginPaint(hWnd, &ps);

	BitBlt(hDC, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right - ps.rcPaint.left,
		ps.rcPaint.bottom - ps.rcPaint.top, hBufferDC, ps.rcPaint.left, ps.rcPaint.top, SRCCOPY);
	EndPaint(hWnd, &ps);
	return 0;
}

void win32_set_bg(int r, int g, int b) {
	background = RGB(r, g, b);
}

// PS_SOLID = 0
// PS_DOT = 2
void win32_draw_line(HDC hdc, int a, int b, int c, int d, COLORREF color, int style) {
	HPEN hPen = CreatePen(style, 1, color);
    HPEN hOldPen = SelectObject(hdc, hPen); 
    MoveToEx(hdc, a, b, NULL);
    LineTo(hdc, c, d);
    SelectObject(hdc, hOldPen);
}

unsigned char* ConvertBGRToRGB_(unsigned char* data, int width, int height, int bytesPerPixel) {
	unsigned char* copyData = malloc(width * height * bytesPerPixel);
	memcpy(copyData, data, width * height * bytesPerPixel);
	for (int i = 0; i < width * height * bytesPerPixel; i += bytesPerPixel) {
		unsigned char temp = copyData[i];
		copyData[i] = copyData[i + 2];
		copyData[i + 2] = temp;
	}
	return copyData;
}

void ConvertBGRToRGB(unsigned char* data, int width, int height, int bytesPerPixel) {
	for (int i = 0; i < width * height * bytesPerPixel; i += bytesPerPixel) {
		unsigned char temp = data[i];
		data[i] = data[i + 2];
		data[i + 2] = temp;
	}
}

HBITMAP CreateBitmapFromPixels(HDC hdc,int width,int height,void *pixelss) {
	unsigned char* pixels = ConvertBGRToRGB_(pixelss, width, height, 4);

	BITMAPINFO bmi = {0};
	bmi.bmiHeader.biSize = sizeof(bmi.bmiHeader);
	bmi.bmiHeader.biWidth = width;
	bmi.bmiHeader.biHeight = -height; // top-down
	bmi.bmiHeader.biPlanes = 1;
	bmi.bmiHeader.biBitCount = 32; // 24 = RGB, 32 = RGBA
	bmi.bmiHeader.biCompression = BI_RGB;

	HBITMAP hbm = CreateDIBitmap(hdc,&bmi.bmiHeader,CBM_INIT, pixels,&bmi,DIB_RGB_COLORS);
	free(pixels);

	return hbm;
}

// https://learn.microsoft.com/en-us/windows/win32/controls/draw-an-image
void PaintImage(HDC hdc, HBITMAP hbm, int x, int y, int w, int h, int px, int py, int pw, int ph) {
	HDC hdcMem = CreateCompatibleDC(hdc);
	HGDIOBJ hbmOld = SelectObject(hdcMem,hbm);

	BITMAP bm;
	GetObject(hbm,sizeof(bm),&bm);

	BLENDFUNCTION bf;
	bf.BlendOp = AC_SRC_OVER;
	bf.BlendFlags = 0;
	bf.SourceConstantAlpha = 255; // use per-pixel alpha values
	bf.AlphaFormat = AC_SRC_ALPHA; // bitmap has alpha channel

	if (pw != 0) {
		AlphaBlend(hdc, x, y, w, h, hdcMem, px, py, pw, ph, bf);
	} else {
		AlphaBlend(hdc, x, y, w, h, hdcMem, 0, 0, bm.bmWidth, bm.bmHeight, bf);
	}

	SelectObject(hdcMem,hbmOld);
	DeleteDC(hdcMem);
}


void win32_draw_triangle(HDC hdc, int x1, int y1, int x2, int y2, int x3, int y3, int r, int g, int b) {
	HPEN hPen = CreatePen(PS_SOLID, 1, RGB(r, g, b)); 
	HPEN hOldPen = SelectPen(hdc, hPen);
	HBRUSH hBrush = CreateSolidBrush(RGB(r, g, b)); 
	HBRUSH hOldBrush = SelectBrush(hdc, hBrush); 
	POINT vertices[] = {{x1, y1}, {x2, y2}, {x3, y3}}; // define an array of points
	Polygon(hdc, vertices, 3);
	SelectPen(hdc, hOldPen); 
	SelectBrush(hdc, hOldBrush);
	DeleteObject(hPen);
	DeleteObject(hBrush);
}


void draw_rect_filled_alpha(HDC hdc, int x, int y, int width, int height, COLORREF rgb, int alpha) {
	HDC hdcMem = CreateCompatibleDC(hdc);
	HBITMAP hBitmap = CreateCompatibleBitmap(hdc, width, height);

	SelectObject(hdcMem, hBitmap);

	HBRUSH hBrush = CreateSolidBrush(rgb);
	
	RECT rec = {0, 0, width, height};
	FillRect(hdcMem, &rec, hBrush);
	
	DeleteObject(hBrush);

	// Use the AlphaBlend function to draw the bitmap onto the DC of the window
	BLENDFUNCTION blendFunc = { AC_SRC_OVER, 0, alpha, 0 };
	AlphaBlend(hdc, x, y, width, height, hdcMem, 0, 0, width, height, blendFunc);

	DeleteObject(hBitmap);
	DeleteDC(hdcMem);
}