; first dive into ASM, let's gooooo

.386
.model flat,stdcall
option casemap:none

include 	\masm32\include\windows.inc 
include 	\masm32\include\user32.inc 
includelib 	\masm32\lib\user32.lib
include 	\masm32\include\kernel32.inc 
includelib 	\masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.DATA
className	db	"justinClass", 0
windowName	db	"Justin's Window", 0

.DATA?
hInstance	HINSTANCE	?
hCursor		HCURSOR		?


.CODE

start:

invoke GetModuleHandle, NULL
mov hInstance, eax

; start main process
invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT

; upon exit of our window we should exit program
invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, prevInst:HINSTANCE, cmdLine:LPSTR, cmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL wHandle:HWND
	
	mov wc.cbSize, SIZEOF WNDCLASSEX
	mov wc.style, NULL
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra, NULL
	mov wc.cbWndExtra, NULL
	
	push hInstance
	pop wc.hInstance
	
	mov wc.hbrBackground, COLOR_WINDOW + 1
	mov wc.lpszMenuName, NULL
	mov wc.lpszClassName, OFFSET className
	
	invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
	
	; register our class
	invoke RegisterClassEx, ADDR wc
	
	invoke CreateWindowEx,
		NULL,
		addr className,
		addr windowName,
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		NULL,
		NULL,
		hInstance,
		NULL
		
	; returns handle to our window, or NULL if fail
	mov wHandle, eax
	
	; show & update window
	invoke ShowWindow, wHandle, cmdShow
	invoke UpdateWindow, wHandle
		
	; core window loop
	.WHILE TRUE
		invoke GetMessage, ADDR msg, NULL, 0, 0
	
		; break if we receive WM_QUIT
		.BREAK .IF (!eax)
		
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.ENDW

	mov		eax,msg.wParam
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	.IF uMsg == WM_DESTROY
		invoke PostQuitMessage, NULL
	.ELSE
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
	.ENDIF
	
	xor eax,eax
	ret
WndProc endp

end start