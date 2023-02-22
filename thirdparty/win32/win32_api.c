// Win32 Text Helper
// Copyright (c) 2023 Isaiah

#include <windows.h>
#include <stdio.h>
#include <wingdi.h>

HFONT my_create_font() {
	return CreateFont(16, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, 
                OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, "Arial");
}

SIZE my_text_size(HDC hdc, char* text, int textLength) {
	SIZE size;

	// select a font into the device context
	// HFONT hFont = my_create_font();
	// SelectObject(hdc, hFont);

	// get the size of the text
	GetTextExtentPoint32(hdc, text, textLength, &size);

	// the width and height of the text are in the size structure
	int width = size.cx;
	int height = size.cy;
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

	// draw some graphics that will be clipped by the scissor rectangle
	// ...

	// release the region and the device context
	// DeleteObject(hRgn);
}

int get_mouse_x(LPARAM lParam) {
	int x = LOWORD(lParam);
}

int get_mouse_y(LPARAM lParam) {
	int y = HIWORD(lParam);
}

void draw_background(HWND hWnd, WPARAM wParam) {
	 /*RECT rc;
     GetClientRect(hWnd, &rc);
     HDC hdc = (HDC)wParam;
     HBRUSH hBrush = CreateSolidBrush(RGB(255, 255, 255));//(HBRUSH)GetClassLongPtr(hWnd, GCLP_HBRBACKGROUND);
     FillRect(hdc, &rc, hBrush);*/
}

void set_background(HWND hWnd) {
	 //HBRUSH hBrush = CreateSolidBrush(RGB(255, 255, 255));
     //SetClassLongPtr(hWnd, GCLP_HBRBACKGROUND, (LONG_PTR)hBrush);
}

static HBITMAP hBuffer;
// static HDC hdcc;
static HDC hBufferDC;

HDC get_bufferdc() {
	return hBufferDC;
}

HDC hdcc() {
	return hdcc;
}

void set_hdcc(HDC h) {
	//hdcc = h;
}

HDC do_paint(HWND hwnd, HDC hbufferdc) {
	PAINTSTRUCT ps;
	HDC hdcc = BeginPaint(hwnd, &ps);
	bit_blt(hdcc, &ps, hbufferdc);
	EndPaint(hwnd, &ps);
	return hdcc;
}

void bit_blt(HDC hdcc, PAINTSTRUCT ps, HDC hBufferDC) {
	BitBlt(hdcc, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right - ps.rcPaint.left,
                ps.rcPaint.bottom - ps.rcPaint.top, hBufferDC, ps.rcPaint.left, ps.rcPaint.top, SRCCOPY);
	
}


static HBITMAP hBuffer;
static HDC hDC;
static HDC hBufferDC;
static COLORREF background = RGB(255, 255, 255);

LRESULT CALLBACK WndProc_A(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{

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