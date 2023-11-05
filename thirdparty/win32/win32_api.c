// Win32 GDI Helper
// Copyright (c) 2023 Isaiah

#include <windows.h>
#include <stdio.h>
#include <wingdi.h>

static HBITMAP hBuffer;
static HDC hBufferDC;
static HDC hDC;
static COLORREF background = RGB(255, 255, 255);
static is_win32_ui = false;
static HWND hwnd;
static PAINTSTRUCT ps;

static int text_size;

HWND get_hwnd() {
	return hwnd;
}

HFONT my_create_font(int size) {
	return CreateFont(size, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, 
				OUT_DEFAULT_PRECIS, CLIP_DFA_DISABLE, DEFAULT_QUALITY, DEFAULT_PITCH, TEXT("Arial"));
}

void win32_set_text_size(int size) {
	text_size = size;
}

SIZE my_text_size(HDC hdc, char* text, int textLength) {
	SIZE size;

	// select a font into the device context
	HFONT hFont = my_create_font(text_size);
	SelectObject(hdc, hFont);

	// get the size of the text
	GetTextExtentPoint32(hdc, text, textLength, &size);
	
	DeleteObject(hFont);

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

// creates a clipping region using the coordinates and dimensions provided by the x, y, w, and h parameters.
void my_scissor_rect(HDC hdc, int x, int y, int w, int h) {
	HRGN hRgn;
	RECT rect = {x, y, x + w, y + h};

	hRgn = CreateRectRgnIndirect(&rect);

	SelectClipRgn(hdc, hRgn);
	DeleteObject(hRgn);
}

int get_mouse_x(LPARAM lParam) {
	int x = LOWORD(lParam);
}

int get_mouse_y(LPARAM lParam) {
	int y = HIWORD(lParam);
}

HDC get_bufferdc() {
	return hBufferDC;
}

bool is_native_win32_ui() {
	return is_win32_ui;
}

int RegisterClassEx_(WNDCLASS* claz) {
	return RegisterClassEx(claz);
}

int win32_width() {
	 RECT clientRect;
	 GetClientRect(hwnd, &clientRect);
	 int width = clientRect.right - clientRect.left;
	 return width;
}

int win32_height() {
	 RECT clientRect;
	 GetClientRect(hwnd, &clientRect);
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
	hDC = BeginPaint(hWnd, &ps);
	RECT rc;
	GetClientRect(hWnd, &rc);
	HBRUSH hBrush = CreateSolidBrush(background);
	FillRect(hBufferDC, &rc, hBrush);
	DeleteObject(hBrush);
}

void WndProc_pb(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
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
	DeleteObject(hPen);
}

// converts image data from the BGR format to the RGB format.
// It creates a copy of the input data, swaps the blue and red components of each pixel, and returns the modified copy.
unsigned char* ConvertBGRToRGB(unsigned char* data, int width, int height, int bytesPerPixel) {
	unsigned char* copyData = malloc(width * height * bytesPerPixel);
	memcpy(copyData, data, width * height * bytesPerPixel);
	for (int i = 0; i < width * height * bytesPerPixel; i += bytesPerPixel) {
		unsigned char temp = copyData[i];
		copyData[i] = copyData[i + 2];
		copyData[i + 2] = temp;
	}
	return copyData;
}

// creates a bitmap in memory from pixel data provided as input. 
// The function first calls the ConvertBGRToRGB function to convert the input pixel data from BGR format to RGB format.
// This is necessary because the CreateDIBitmap function expects pixel data in RGB format.
HBITMAP CreateBitmapFromPixels(HDC hdc,int width,int height,void *pixelss) {
	unsigned char* pixels = ConvertBGRToRGB(pixelss, width, height, 4);

	BITMAPINFO bmi = {
	  .bmiHeader.biSize = sizeof(BITMAPINFOHEADER),
	  .bmiHeader.biWidth = width,
	  .bmiHeader.biHeight = -height,
	  .bmiHeader.biPlanes = 1,
	  .bmiHeader.biBitCount = 32,
	  .bmiHeader.biCompression = BI_RGB
	};

	HBITMAP hbm = CreateDIBitmap(hdc, &bmi.bmiHeader, CBM_INIT, pixels, &bmi, DIB_RGB_COLORS);
	free(pixels);

	return hbm;
}

// The PaintImage function draws a bitmap at a specified location with a specified size.
// The function uses alpha blending to blend the bitmap with the underlying pixels on
// the device context, allowing for transparent or partially transparent images.
// https://learn.microsoft.com/en-us/windows/win32/controls/draw-an-image
void PaintImage(HDC hdc, HBITMAP* hbm, int x, int y, int w, int h, int px, int py, int pw, int ph) {
	HDC hdcMem = CreateCompatibleDC(hdc);
	HGDIOBJ hbmOld = SelectObject(hdcMem,hbm);

	BITMAP bm;
	GetObject(hbm, sizeof(bm), &bm);

	BLENDFUNCTION bf = { AC_SRC_OVER, 0, 255, AC_SRC_ALPHA };

	if (pw != 0) {
		AlphaBlend(hdc, x, y, w, h, hdcMem, px, py, pw, ph, bf);
	} else {
		AlphaBlend(hdc, x, y, w, h, hdcMem, 0, 0, bm.bmWidth, bm.bmHeight, bf);
	}

	SelectObject(hdcMem,hbmOld);
	DeleteDC(hdcMem);
	DeleteObject(hdcMem);
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

// Draws a filled rectangle with a specified color and opacity level using alpha blending
void draw_rect_filled_alpha(HDC hdc, int x, int y, int width, int height, COLORREF rgb, int alpha) {
	HDC hdcMem = CreateCompatibleDC(hdc);
	HBITMAP hBitmap = CreateCompatibleBitmap(hdc, width, height);

	SelectObject(hdcMem, hBitmap);
	HBRUSH hBrush = CreateSolidBrush(rgb);

	RECT rec = {0, 0, width, height};
	FillRect(hdcMem, &rec, hBrush);
	
	DeleteObject(hBrush);

	BLENDFUNCTION blendFunc = { AC_SRC_OVER, 0, alpha, 0 };
	AlphaBlend(hdc, x, y, width, height, hdcMem, 0, 0, width, height, blendFunc);

	DeleteObject(hBitmap);
	DeleteDC(hdcMem);
}

void DrawCell(HDC hdc, const RECT rcTarget, const HBRUSH hbrUpper, int rad) {
	HRGN hRgnUpper = CreateRoundRectRgn(rcTarget.left, rcTarget.top, rcTarget.right, rcTarget.bottom, rad, rad);	  
	FillRgn(hdc, hRgnUpper, hbrUpper);
	DeleteObject(hRgnUpper);
}

void EmptyRoundRect(HDC hdc, const RECT rcTarget, const HBRUSH hbrUpper, int rad) {
	HRGN hRgnUpper = CreateRoundRectRgn(rcTarget.left, rcTarget.top, rcTarget.right, rcTarget.bottom, rad, rad);	  
	FrameRgn(hdc, hRgnUpper, hbrUpper, 1, 1);
	DeleteObject(hRgnUpper);
}

MSG get_msg() {
	MSG msg;
	return msg;
}

int get_msg_msg(MSG msg) {
	return msg.message;
}