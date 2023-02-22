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
// SetTextColor(hdc, RGB(255, 255, 255));

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