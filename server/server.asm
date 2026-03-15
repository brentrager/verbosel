; ============================================================================
; ASSEMBLY WEB FRAMEWORK (Verbosel) - The Server
; ============================================================================
; A fully functional HTTP/1.1 web server written in pure x86_64 Linux
; assembly. No libc. No frameworks. No dependencies. Just raw syscalls
; and the unshakeable belief that MOV is the only instruction you need.
;
; Syscalls used:
;   socket(2)  - SYS_SOCKET  = 41
;   bind(2)    - SYS_BIND    = 49
;   listen(2)  - SYS_LISTEN  = 50
;   accept(2)  - SYS_ACCEPT  = 43
;   read(2)    - SYS_READ    = 0
;   write(2)   - SYS_WRITE   = 1
;   close(2)   - SYS_CLOSE   = 3
;   fork(2)    - SYS_FORK    = 57
;   exit(2)    - SYS_EXIT    = 60
;   wait4(2)   - SYS_WAIT4   = 61
;
; Architecture: x86_64 Linux (System V AMD64 ABI)
; Assembler: NASM
; ============================================================================

%define SYS_READ      0
%define SYS_WRITE     1
%define SYS_CLOSE     3
%define SYS_FORK      57
%define SYS_EXIT      60
%define SYS_WAIT4     61
%define SYS_SOCKET    41
%define SYS_BIND      49
%define SYS_LISTEN    50
%define SYS_ACCEPT    43
%define SYS_SETSOCKOPT 54

%define AF_INET       2
%define SOCK_STREAM   1
%define SOL_SOCKET    1
%define SO_REUSEADDR  2
%define IPPROTO_TCP   6
%define INADDR_ANY    0

%define PORT          8080
%define BACKLOG       128
%define BUF_SIZE      4096

section .data

; Socket address structure (sockaddr_in)
align 4
sockaddr:
    dw AF_INET              ; sin_family
    dw ((PORT >> 8) & 0xFF) | ((PORT & 0xFF) << 8)  ; sin_port (network byte order)
    dd INADDR_ANY           ; sin_addr
    dq 0                    ; padding
sockaddr_len equ $ - sockaddr

; Socket option value
optval: dd 1

; Startup banner
banner: db ">> Verbosel server starting on port 8080", 10
banner_len equ $ - banner

accept_msg: db ">> connection accepted, forking handler", 10
accept_msg_len equ $ - accept_msg

; HTTP Response Header
http_header:
    db "HTTP/1.1 200 OK", 13, 10
    db "Content-Type: text/html; charset=utf-8", 13, 10
    db "Connection: close", 13, 10
    db "X-Powered-By: raw-x86_64-syscalls", 13, 10
    db "X-Framework: Verbosel", 13, 10
    db "X-No-Dependencies: true", 13, 10
    db "Cache-Control: no-cache", 13, 10
    db 13, 10
http_header_len equ $ - http_header

; HTTP 404 Response
http_404:
    db "HTTP/1.1 404 Not Found", 13, 10
    db "Content-Type: text/html; charset=utf-8", 13, 10
    db "Connection: close", 13, 10
    db "X-Powered-By: raw-x86_64-syscalls", 13, 10
    db 13, 10
    db "<html><body style='background:#0a0a0a;color:#00ff41;font-family:monospace;display:flex;justify-content:center;align-items:center;height:100vh;'>"
    db "<div><h1>404 - SEGFAULT</h1><p>The page you requested caused a General Protection Fault.</p>"
    db "<p style='color:#555'>Actually it just doesn't exist, but that sounds cooler.</p></div>"
    db "</body></html>"
http_404_len equ $ - http_404

; ============================================================================
; THE HTML - A gorgeous website served from raw assembly
; ============================================================================
html_body:
    db '<!DOCTYPE html>'
    db '<html lang="en" class="scroll-smooth">'
    db '<head>'
    db '<meta charset="UTF-8">'
    db '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
    db '<title>Verbosel | The Web Framework That Refuses to Abstract</title>'
    db '<link rel="icon" type="image/svg+xml" href="data:image/svg+xml,'
    db '%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E'
    db '%3Cdefs%3E%3Cfilter id=%22g%22%3E%3CfeGaussianBlur stdDeviation=%228%22/%3E%3C/filter%3E%3C/defs%3E'
    db '%3Crect width=%22100%22 height=%22100%22 rx=%2220%22 fill=%22%230a0a0a%22/%3E'
    db '%3Ccircle cx=%2250%22 cy=%2250%22 r=%2220%22 fill=%22%2300ff41%22 filter=%22url(%23g)%22 opacity=%220.6%22/%3E'
    db '%3Ccircle cx=%2250%22 cy=%2250%22 r=%2212%22 fill=%22%2300ff41%22/%3E'
    db '%3Ctext x=%2250%22 y=%2258%22 font-size=%2218%22 font-family=%22monospace%22 font-weight=%22bold%22 fill=%22%230a0a0a%22 text-anchor=%22middle%22%3EV%3C/text%3E'
    db '%3C/svg%3E">'
    db '<script src="https://cdn.tailwindcss.com"></script>'
    db '<script>'
    db 'tailwind.config = {'
    db '  theme: {'
    db '    extend: {'
    db '      colors: {'
    db "        terminal: { bg: '#0a0a0a', fg: '#00ff41', dim: '#00aa2a', bright: '#33ff66', amber: '#ffbf00', red: '#ff3333', cyan: '#00ffff', purple: '#bf40bf', gold: '#d4a017' },"
    db '      },'
    db '      fontFamily: {'
    db "        mono: ['JetBrains Mono', 'Fira Code', 'SF Mono', 'monospace'],"
    db '      },'
    db '      animation: {'
    db "        'cursor-blink': 'blink 1s step-end infinite',"
    db "        'glow-pulse': 'glow 2s ease-in-out infinite',"
    db "        'scan': 'scan 8s linear infinite',"
    db "        'flicker': 'flicker 0.15s infinite',"
    db "        'typing': 'typing 3.5s steps(40, end), blink-caret .75s step-end infinite',"
    db "        'fade-in': 'fadeIn 0.6s ease-out forwards',"
    db "        'slide-up': 'slideUp 0.8s ease-out forwards',"
    db "        'matrix': 'matrix 20s linear infinite',"
    db '      },'
    db '      keyframes: {'
    db "        blink: { '0%, 100%': { opacity: '1' }, '50%': { opacity: '0' } },"
    db "        glow: { '0%, 100%': { 'text-shadow': '0 0 5px #00ff41, 0 0 20px #00ff41' }, '50%': { 'text-shadow': '0 0 20px #00ff41, 0 0 60px #00ff41, 0 0 100px #00aa2a' } },"
    db "        scan: { '0%': { top: '-100%' }, '100%': { top: '100%' } },"
    db "        flicker: { '0%': { opacity: '0.97' }, '50%': { opacity: '1' }, '100%': { opacity: '0.98' } },"
    db "        typing: { from: { width: '0' }, to: { width: '100%' } },"
    db "        'blink-caret': { 'from, to': { 'border-color': 'transparent' }, '50%': { 'border-color': '#00ff41' } },"
    db "        fadeIn: { from: { opacity: '0', transform: 'translateY(20px)' }, to: { opacity: '1', transform: 'translateY(0)' } },"
    db "        slideUp: { from: { opacity: '0', transform: 'translateY(40px)' }, to: { opacity: '1', transform: 'translateY(0)' } },"
    db "        matrix: { '0%': { transform: 'translateY(-100%)' }, '100%': { transform: 'translateY(100%)' } },"
    db '      },'
    db '    },'
    db '  },'
    db '}'
    db '</script>'
    db '<link rel="preconnect" href="https://fonts.googleapis.com">'
    db '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
    db '<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">'
    db '<style>'
    db '::selection { background: #00ff41; color: #0a0a0a; }'
    db '::-webkit-scrollbar { width: 8px; }'
    db '::-webkit-scrollbar-track { background: #0a0a0a; }'
    db '::-webkit-scrollbar-thumb { background: #00ff41; border-radius: 4px; }'
    db '::-webkit-scrollbar-thumb:hover { background: #33ff66; }'
    db '.crt::before { content: ""; display: block; position: fixed; top: 0; left: 0; bottom: 0; right: 0; background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.15) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.03), rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.03)); background-size: 100% 2px, 3px 100%; pointer-events: none; z-index: 99; }'
    db '.text-shadow-green { text-shadow: 0 0 10px #00ff41, 0 0 40px rgba(0, 255, 65, 0.3); }'
    db '.text-shadow-amber { text-shadow: 0 0 10px #ffbf00, 0 0 40px rgba(255, 191, 0, 0.3); }'
    db '.border-glow { box-shadow: 0 0 10px rgba(0, 255, 65, 0.3), inset 0 0 10px rgba(0, 255, 65, 0.05); }'
    db '.hex-pattern { background-image: radial-gradient(circle, #00ff41 1px, transparent 1px); background-size: 30px 30px; opacity: 0.03; }'
    db '.gradient-border { background: linear-gradient(#0a0a0a, #0a0a0a) padding-box, linear-gradient(135deg, #00ff41, #00ffff, #bf40bf) border-box; border: 1px solid transparent; }'
    db '@keyframes typechar { from { width: 0; } to { width: 100%; } }'
    db '</style>'
    db '</head>'
    db '<body class="bg-terminal-bg text-terminal-fg font-mono crt animate-flicker overflow-x-hidden">'

    ; Scanline overlay
    db '<div class="fixed inset-0 pointer-events-none z-50">'
    db '<div class="absolute inset-0 hex-pattern"></div>'
    db '<div class="absolute left-0 right-0 h-[200px] bg-gradient-to-b from-terminal-fg/[0.03] to-transparent animate-scan"></div>'
    db '</div>'

    ; Navigation
    db '<nav class="fixed top-0 w-full z-40 bg-terminal-bg/90 backdrop-blur-sm border-b border-terminal-fg/20">'
    db '<div class="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">'
    db '<div class="flex items-center gap-3">'
    db '<div class="w-3 h-3 bg-terminal-fg rounded-full animate-glow-pulse shadow-[0_0_10px_#00ff41]"></div>'
    db '<span class="text-lg font-bold tracking-wider text-shadow-green">Verbosel</span>'
    db '</div>'
    db '<div class="hidden md:flex items-center gap-8 text-sm">'
    db '<a href="#features" class="text-terminal-dim hover:text-terminal-fg transition-colors">.features</a>'
    db '<a href="#code" class="text-terminal-dim hover:text-terminal-fg transition-colors">.source</a>'
    db '<a href="#benchmarks" class="text-terminal-dim hover:text-terminal-fg transition-colors">.benchmarks</a>'
    db '<a href="#deploy" class="text-terminal-dim hover:text-terminal-fg transition-colors">.deploy</a>'
    db '<a href="https://github.com/brentrager/Verbosel" class="px-4 py-2 border border-terminal-fg/30 hover:border-terminal-fg hover:bg-terminal-fg/10 transition-all rounded text-terminal-fg">git clone</a>'
    db '</div>'
    db '</div>'
    db '</nav>'

    ; Hero Section
    db '<section class="min-h-screen flex items-center justify-center relative pt-20">'
    db '<div class="max-w-5xl mx-auto px-6 text-center">'

    ; Terminal window
    db '<div class="mb-12 animate-fade-in">'
    db '<div class="inline-block bg-terminal-bg border border-terminal-fg/20 rounded-lg overflow-hidden text-left max-w-2xl w-full border-glow">'
    db '<div class="flex items-center gap-2 px-4 py-3 bg-terminal-fg/5 border-b border-terminal-fg/10">'
    db '<div class="w-3 h-3 rounded-full bg-terminal-red/80"></div>'
    db '<div class="w-3 h-3 rounded-full bg-terminal-amber/80"></div>'
    db '<div class="w-3 h-3 rounded-full bg-terminal-fg/80"></div>'
    db '<span class="ml-3 text-xs text-terminal-dim">server.asm - Verbosel</span>'
    db '</div>'
    db '<div class="p-6 text-sm leading-relaxed">'
    db '<p class="text-terminal-dim">; boot sequence initiated</p>'
    db '<p><span class="text-terminal-amber">mov</span> rax, <span class="text-terminal-cyan">SYS_SOCKET</span></p>'
    db '<p><span class="text-terminal-amber">mov</span> rdi, <span class="text-terminal-cyan">AF_INET</span></p>'
    db '<p><span class="text-terminal-amber">mov</span> rsi, <span class="text-terminal-cyan">SOCK_STREAM</span></p>'
    db '<p><span class="text-terminal-amber">syscall</span> <span class="text-terminal-dim">; no frameworks were harmed</span></p>'
    db '<p class="mt-2 text-terminal-fg">'
    db '<span class="text-terminal-purple">&gt;&gt;</span> server listening on <span class="text-terminal-amber">:8080</span>'
    db '<span class="inline-block w-2 h-5 bg-terminal-fg ml-1 animate-cursor-blink"></span>'
    db '</p>'
    db '</div>'
    db '</div>'
    db '</div>'

    ; Title
    db '<h1 class="text-5xl md:text-7xl font-extrabold mb-6 animate-glow-pulse text-shadow-green leading-tight">'
    db 'Verbosel'
    db '</h1>'
    db '<p class="text-xl md:text-2xl text-terminal-dim mb-4 animate-fade-in" style="animation-delay:0.2s">'
    db 'The Web Framework That Refuses to Abstract'
    db '</p>'
    db '<p class="text-terminal-amber text-lg mb-10 animate-fade-in" style="animation-delay:0.4s">'
    db '0 dependencies. 0 runtime. 0 compromise. Just syscalls.'
    db '</p>'

    ; Stats bar
    db '<div class="flex flex-wrap justify-center gap-6 mb-12 animate-fade-in" style="animation-delay:0.6s">'
    db '<div class="px-5 py-3 border border-terminal-fg/20 rounded-lg bg-terminal-fg/5">'
    db '<div class="text-2xl font-bold text-terminal-fg text-shadow-green">0</div>'
    db '<div class="text-xs text-terminal-dim uppercase tracking-wider">Dependencies</div>'
    db '</div>'
    db '<div class="px-5 py-3 border border-terminal-amber/20 rounded-lg bg-terminal-amber/5">'
    db '<div class="text-2xl font-bold text-terminal-amber text-shadow-amber">~12KB</div>'
    db '<div class="text-xs text-terminal-dim uppercase tracking-wider">Binary Size</div>'
    db '</div>'
    db '<div class="px-5 py-3 border border-terminal-cyan/20 rounded-lg bg-terminal-cyan/5">'
    db '<div class="text-2xl font-bold text-terminal-cyan">10</div>'
    db '<div class="text-xs text-terminal-dim uppercase tracking-wider">Syscalls Used</div>'
    db '</div>'
    db '<div class="px-5 py-3 border border-terminal-purple/20 rounded-lg bg-terminal-purple/5">'
    db '<div class="text-2xl font-bold text-terminal-purple">0ms</div>'
    db '<div class="text-xs text-terminal-dim uppercase tracking-wider">Cold Start</div>'
    db '</div>'
    db '</div>'

    ; CTA
    db '<div class="flex flex-wrap justify-center gap-4 animate-fade-in" style="animation-delay:0.8s">'
    db '<a href="#code" class="px-8 py-3 bg-terminal-fg text-terminal-bg font-bold rounded-lg hover:bg-terminal-bright transition-colors shadow-[0_0_20px_rgba(0,255,65,0.3)]">'
    db 'View the Source'
    db '</a>'
    db '<a href="https://github.com/brentrager/Verbosel" class="px-8 py-3 border border-terminal-fg/30 text-terminal-fg rounded-lg hover:bg-terminal-fg/10 transition-all">'
    db 'GitHub &rarr;'
    db '</a>'
    db '</div>'

    db '</div>'
    db '</section>'

    ; Features Section
    db '<section id="features" class="py-24 relative">'
    db '<div class="max-w-6xl mx-auto px-6">'
    db '<div class="text-center mb-16">'
    db '<p class="text-terminal-amber text-sm uppercase tracking-widest mb-3">// Why would you do this?</p>'
    db '<h2 class="text-4xl font-bold text-shadow-green mb-4">Features</h2>'
    db '<p class="text-terminal-dim max-w-2xl mx-auto">Everything you never knew you needed from a web framework, implemented at the lowest possible level of abstraction.</p>'
    db '</div>'

    db '<div class="grid md:grid-cols-3 gap-6">'

    ; Feature 1
    db '<div class="p-6 border border-terminal-fg/10 rounded-xl bg-terminal-fg/[0.02] hover:border-terminal-fg/30 hover:bg-terminal-fg/[0.05] transition-all group gradient-border">'
    db '<div class="text-3xl mb-4">&#x2699;</div>'
    db '<h3 class="text-lg font-bold text-terminal-fg mb-2 group-hover:text-shadow-green transition-all">Zero Abstraction</h3>'
    db '<p class="text-terminal-dim text-sm leading-relaxed">Why use Express when you can manually pack sockaddr_in structs? Every HTTP response is hand-crafted with MOV instructions.</p>'
    db '</div>'

    ; Feature 2
    db '<div class="p-6 border border-terminal-amber/10 rounded-xl bg-terminal-amber/[0.02] hover:border-terminal-amber/30 hover:bg-terminal-amber/[0.05] transition-all group">'
    db '<div class="text-3xl mb-4">&#x26A1;</div>'
    db '<h3 class="text-lg font-bold text-terminal-amber mb-2 group-hover:text-shadow-amber transition-all">Blazingly Fast</h3>'
    db '<p class="text-terminal-dim text-sm leading-relaxed">No garbage collector. No JIT warmup. No event loop. Your CPU executes exactly what you wrote. It boots before your Node.js app finishes parsing package.json.</p>'
    db '</div>'

    ; Feature 3
    db '<div class="p-6 border border-terminal-cyan/10 rounded-xl bg-terminal-cyan/[0.02] hover:border-terminal-cyan/30 hover:bg-terminal-cyan/[0.05] transition-all group">'
    db '<div class="text-3xl mb-4">&#x1F512;</div>'
    db '<h3 class="text-lg font-bold text-terminal-cyan mb-2">Memory Safe*</h3>'
    db '<p class="text-terminal-dim text-sm leading-relaxed">*As safe as the programmer writing it. Which is to say: not at all. But at least you can SEE every byte being touched.</p>'
    db '<p class="text-terminal-dim/50 text-xs mt-2">*not actually memory safe</p>'
    db '</div>'

    ; Feature 4
    db '<div class="p-6 border border-terminal-purple/10 rounded-xl bg-terminal-purple/[0.02] hover:border-terminal-purple/30 hover:bg-terminal-purple/[0.05] transition-all group">'
    db '<div class="text-3xl mb-4">&#x1F4E6;</div>'
    db '<h3 class="text-lg font-bold text-terminal-purple mb-2">12KB Binary</h3>'
    db '<p class="text-terminal-dim text-sm leading-relaxed">Your entire web server fits in an L1 cache line. Meanwhile, node_modules just downloaded the entire npm registry for a hello world.</p>'
    db '</div>'

    ; Feature 5
    db '<div class="p-6 border border-terminal-red/10 rounded-xl bg-terminal-red/[0.02] hover:border-terminal-red/30 hover:bg-terminal-red/[0.05] transition-all group">'
    db '<div class="text-3xl mb-4">&#x1F525;</div>'
    db '<h3 class="text-lg font-bold text-terminal-red mb-2">Fork-Per-Request</h3>'
    db '<p class="text-terminal-dim text-sm leading-relaxed">Process isolation via fork(). Each request gets its own address space. It is 1995 and that is a feature, not a bug.</p>'
    db '</div>'

    ; Feature 6
    db '<div class="p-6 border border-terminal-fg/10 rounded-xl bg-terminal-fg/[0.02] hover:border-terminal-fg/30 hover:bg-terminal-fg/[0.05] transition-all group gradient-border">'
    db '<div class="text-3xl mb-4">&#x1F680;</div>'
    db '<h3 class="text-lg font-bold text-terminal-fg mb-2 group-hover:text-shadow-green transition-all">SST v4 Deployed</h3>'
    db '<p class="text-terminal-dim text-sm leading-relaxed">Because even assembly deserves infrastructure-as-code. Deployed to AWS ECS via SST, because we are civilized barbarians.</p>'
    db '</div>'

    db '</div>'
    db '</div>'
    db '</section>'

    ; Source Code Section
    db '<section id="code" class="py-24 bg-terminal-fg/[0.02] border-y border-terminal-fg/10">'
    db '<div class="max-w-5xl mx-auto px-6">'
    db '<div class="text-center mb-16">'
    db '<p class="text-terminal-amber text-sm uppercase tracking-widest mb-3">// The actual code</p>'
    db '<h2 class="text-4xl font-bold text-shadow-green mb-4">Source</h2>'
    db '<p class="text-terminal-dim max-w-2xl mx-auto">The entire HTTP server. No hidden abstractions. No imported modules. Just you, the kernel, and a dream.</p>'
    db '</div>'

    db '<div class="bg-terminal-bg border border-terminal-fg/20 rounded-xl overflow-hidden border-glow">'
    db '<div class="flex items-center gap-2 px-4 py-3 bg-terminal-fg/5 border-b border-terminal-fg/10">'
    db '<div class="w-3 h-3 rounded-full bg-terminal-red/80"></div>'
    db '<div class="w-3 h-3 rounded-full bg-terminal-amber/80"></div>'
    db '<div class="w-3 h-3 rounded-full bg-terminal-fg/80"></div>'
    db '<span class="ml-3 text-xs text-terminal-dim">server.asm (the important bits)</span>'
    db '</div>'
    db '<div class="p-6 text-sm leading-loose overflow-x-auto">'
    db '<pre class="text-terminal-dim">'

    db '<span class="text-terminal-dim">; Create TCP socket</span>',10
    db '<span class="text-terminal-amber">mov</span>     rax, 41          <span class="text-terminal-dim">; SYS_SOCKET</span>',10
    db '<span class="text-terminal-amber">mov</span>     rdi, 2           <span class="text-terminal-dim">; AF_INET</span>',10
    db '<span class="text-terminal-amber">mov</span>     rsi, 1           <span class="text-terminal-dim">; SOCK_STREAM</span>',10
    db '<span class="text-terminal-amber">xor</span>     rdx, rdx',10
    db '<span class="text-terminal-amber">syscall</span>',10
    db 10
    db '<span class="text-terminal-dim">; Bind to 0.0.0.0:8080</span>',10
    db '<span class="text-terminal-amber">mov</span>     rax, 49          <span class="text-terminal-dim">; SYS_BIND</span>',10
    db '<span class="text-terminal-amber">mov</span>     rdi, r12         <span class="text-terminal-dim">; socket fd</span>',10
    db '<span class="text-terminal-amber">lea</span>     rsi, [rel sockaddr]',10
    db '<span class="text-terminal-amber">mov</span>     rdx, 16',10
    db '<span class="text-terminal-amber">syscall</span>',10
    db 10
    db '<span class="text-terminal-dim">; Listen with backlog 128</span>',10
    db '<span class="text-terminal-amber">mov</span>     rax, 50          <span class="text-terminal-dim">; SYS_LISTEN</span>',10
    db '<span class="text-terminal-amber">mov</span>     rdi, r12',10
    db '<span class="text-terminal-amber">mov</span>     rsi, 128',10
    db '<span class="text-terminal-amber">syscall</span>',10
    db 10
    db '<span class="text-terminal-purple">accept_loop:</span>',10
    db '    <span class="text-terminal-amber">mov</span> rax, 43      <span class="text-terminal-dim">; SYS_ACCEPT</span>',10
    db '    <span class="text-terminal-amber">mov</span> rdi, r12',10
    db '    <span class="text-terminal-amber">xor</span> rsi, rsi',10
    db '    <span class="text-terminal-amber">xor</span> rdx, rdx',10
    db '    <span class="text-terminal-amber">syscall</span>          <span class="text-terminal-dim">; blocks until connection</span>',10
    db '    <span class="text-terminal-amber">mov</span> r13, rax     <span class="text-terminal-dim">; save client fd</span>',10
    db 10
    db '    <span class="text-terminal-dim">; Fork to handle request</span>',10
    db '    <span class="text-terminal-amber">mov</span> rax, 57      <span class="text-terminal-dim">; SYS_FORK</span>',10
    db '    <span class="text-terminal-amber">syscall</span>',10
    db '    <span class="text-terminal-amber">test</span> rax, rax',10
    db '    <span class="text-terminal-amber">jz</span>  <span class="text-terminal-purple">handle_request</span>',10
    db '    <span class="text-terminal-amber">jmp</span> <span class="text-terminal-purple">accept_loop</span> <span class="text-terminal-dim">; parent continues listening</span>',10

    db '</pre>'
    db '</div>'
    db '</div>'

    db '</div>'
    db '</section>'

    ; Benchmarks Section
    db '<section id="benchmarks" class="py-24">'
    db '<div class="max-w-5xl mx-auto px-6">'
    db '<div class="text-center mb-16">'
    db '<p class="text-terminal-amber text-sm uppercase tracking-widest mb-3">// Numbers dont lie</p>'
    db '<h2 class="text-4xl font-bold text-shadow-green mb-4">Benchmarks*</h2>'
    db '<p class="text-terminal-dim max-w-2xl mx-auto">Completely real and not at all cherry-picked comparisons.</p>'
    db '<p class="text-terminal-dim/50 text-xs mt-2">*benchmarks performed on the authors laptop at 3am</p>'
    db '</div>'

    db '<div class="space-y-6">'

    ; Benchmark bars
    db '<div class="border border-terminal-fg/10 rounded-xl p-6 bg-terminal-fg/[0.02]">'
    db '<div class="flex justify-between mb-3">'
    db '<span class="font-bold text-terminal-fg">Verbosel</span>'
    db '<span class="text-terminal-amber">~0.001ms</span>'
    db '</div>'
    db '<div class="w-full bg-terminal-fg/10 rounded-full h-4 overflow-hidden">'
    db '<div class="h-full rounded-full bg-gradient-to-r from-terminal-fg to-terminal-bright shadow-[0_0_10px_#00ff41]" style="width: 2%"></div>'
    db '</div>'
    db '</div>'

    db '<div class="border border-terminal-fg/10 rounded-xl p-6 bg-terminal-fg/[0.02]">'
    db '<div class="flex justify-between mb-3">'
    db '<span class="font-bold text-terminal-dim">Go net/http</span>'
    db '<span class="text-terminal-dim">~0.05ms</span>'
    db '</div>'
    db '<div class="w-full bg-terminal-fg/10 rounded-full h-4 overflow-hidden">'
    db '<div class="h-full rounded-full bg-terminal-cyan/60" style="width: 15%"></div>'
    db '</div>'
    db '</div>'

    db '<div class="border border-terminal-fg/10 rounded-xl p-6 bg-terminal-fg/[0.02]">'
    db '<div class="flex justify-between mb-3">'
    db '<span class="font-bold text-terminal-dim">Rust Actix</span>'
    db '<span class="text-terminal-dim">~0.08ms</span>'
    db '</div>'
    db '<div class="w-full bg-terminal-fg/10 rounded-full h-4 overflow-hidden">'
    db '<div class="h-full rounded-full bg-terminal-purple/60" style="width: 20%"></div>'
    db '</div>'
    db '</div>'

    db '<div class="border border-terminal-fg/10 rounded-xl p-6 bg-terminal-fg/[0.02]">'
    db '<div class="flex justify-between mb-3">'
    db '<span class="font-bold text-terminal-dim">Node.js Express</span>'
    db '<span class="text-terminal-dim">~2.5ms</span>'
    db '</div>'
    db '<div class="w-full bg-terminal-fg/10 rounded-full h-4 overflow-hidden">'
    db '<div class="h-full rounded-full bg-terminal-amber/60" style="width: 60%"></div>'
    db '</div>'
    db '</div>'

    db '<div class="border border-terminal-fg/10 rounded-xl p-6 bg-terminal-fg/[0.02]">'
    db '<div class="flex justify-between mb-3">'
    db '<span class="font-bold text-terminal-dim">Next.js (cold start)</span>'
    db '<span class="text-terminal-dim">~150ms</span>'
    db '</div>'
    db '<div class="w-full bg-terminal-fg/10 rounded-full h-4 overflow-hidden">'
    db '<div class="h-full rounded-full bg-terminal-red/60" style="width: 95%"></div>'
    db '</div>'
    db '</div>'

    db '</div>'
    db '</div>'
    db '</section>'

    ; Deploy Section
    db '<section id="deploy" class="py-24 bg-terminal-fg/[0.02] border-y border-terminal-fg/10">'
    db '<div class="max-w-4xl mx-auto px-6 text-center">'
    db '<p class="text-terminal-amber text-sm uppercase tracking-widest mb-3">// Ship it</p>'
    db '<h2 class="text-4xl font-bold text-shadow-green mb-6">Deploy in 3 Instructions</h2>'
    db '<div class="bg-terminal-bg border border-terminal-fg/20 rounded-xl p-6 text-left mb-10 border-glow inline-block w-full max-w-lg mx-auto">'
    db '<p class="text-terminal-dim text-sm">$</p>'
    db '<p class="text-terminal-fg text-sm"><span class="text-terminal-amber">git</span> clone https://github.com/brentrager/Verbosel</p>'
    db '<p class="text-terminal-fg text-sm"><span class="text-terminal-amber">cd</span> Verbosel</p>'
    db '<p class="text-terminal-fg text-sm"><span class="text-terminal-amber">npx</span> sst deploy --stage production</p>'
    db '<p class="mt-3 text-terminal-fg text-sm">'
    db '<span class="text-terminal-purple">&gt;&gt;</span> deployed to <span class="text-terminal-amber">asm.rager.tech</span>'
    db '<span class="inline-block w-2 h-4 bg-terminal-fg ml-1 animate-cursor-blink"></span>'
    db '</p>'
    db '</div>'
    db '</div>'
    db '</section>'

    ; Footer
    db '<footer class="py-16 border-t border-terminal-fg/10">'
    db '<div class="max-w-6xl mx-auto px-6 text-center">'
    db '<div class="text-4xl font-bold text-shadow-green animate-glow-pulse mb-6">Verbosel</div>'
    db '<p class="text-terminal-dim mb-2">Built with nothing but syscalls and questionable life choices.</p>'
    db '<p class="text-terminal-dim/50 text-sm mb-8">This page was served by an x86_64 assembly HTTP server running on AWS ECS.</p>'
    db '<div class="flex justify-center gap-6 text-terminal-dim text-sm">'
    db '<a href="https://github.com/brentrager/Verbosel" class="hover:text-terminal-fg transition-colors">GitHub</a>'
    db '<span class="text-terminal-fg/20">|</span>'
    db '<span>MIT License</span>'
    db '<span class="text-terminal-fg/20">|</span>'
    db '<span>x86_64 Linux</span>'
    db '<span class="text-terminal-fg/20">|</span>'
    db '<span>SST v4</span>'
    db '</div>'
    db '<p class="text-terminal-dim/30 text-xs mt-8">X-Powered-By: raw-x86_64-syscalls</p>'
    db '</div>'
    db '</footer>'

    db '<script>'
    db "document.querySelectorAll(", 22h, "a[href^=", 27h, "#", 27h, "]", 22h, ").forEach(a=>{"
    db 'a.addEventListener("click",e=>{'
    db 'e.preventDefault();'
    db "document.querySelector(a.getAttribute(", 22h, "href", 22h, ")).scrollIntoView({behavior:", 22h, "smooth", 22h, "});"
    db '});});'

    ; Intersection observer for fade-in animations
    db 'const o=new IntersectionObserver((es)=>{'
    db 'es.forEach(e=>{'
    db 'if(e.isIntersecting){'
    db 'e.target.classList.add("opacity-100","translate-y-0");'
    db 'e.target.classList.remove("opacity-0","translate-y-8");'
    db '}});},{threshold:0.1});'
    db 'document.querySelectorAll("section > div").forEach(el=>{o.observe(el);});'
    db '</script>'

    db '</body></html>'
html_body_len equ $ - html_body

section .bss
    buf: resb BUF_SIZE

section .text
    global _start

_start:
    ; Print startup banner
    mov     rax, SYS_WRITE
    mov     rdi, 1              ; stdout
    lea     rsi, [rel banner]
    mov     rdx, banner_len
    syscall

    ; === Create socket ===
    mov     rax, SYS_SOCKET
    mov     rdi, AF_INET
    mov     rsi, SOCK_STREAM
    xor     rdx, rdx
    syscall
    test    rax, rax
    js      .error              ; jump if negative (error)
    mov     r12, rax            ; save socket fd in r12

    ; === Set SO_REUSEADDR ===
    mov     rax, SYS_SETSOCKOPT
    mov     rdi, r12
    mov     rsi, SOL_SOCKET
    mov     rdx, SO_REUSEADDR
    lea     r10, [rel optval]
    mov     r8, 4
    syscall

    ; === Bind ===
    mov     rax, SYS_BIND
    mov     rdi, r12
    lea     rsi, [rel sockaddr]
    mov     rdx, sockaddr_len
    syscall
    test    rax, rax
    js      .error

    ; === Listen ===
    mov     rax, SYS_LISTEN
    mov     rdi, r12
    mov     rsi, BACKLOG
    syscall
    test    rax, rax
    js      .error

; ============================================================================
; MAIN ACCEPT LOOP
; ============================================================================
.accept_loop:
    ; Reap zombie children (non-blocking wait)
    mov     rax, SYS_WAIT4
    mov     rdi, -1             ; any child
    xor     rsi, rsi            ; no status
    mov     rdx, 1              ; WNOHANG
    xor     r10, r10
    syscall

    ; Accept new connection
    mov     rax, SYS_ACCEPT
    mov     rdi, r12
    xor     rsi, rsi            ; NULL addr
    xor     rdx, rdx            ; NULL addrlen
    syscall
    test    rax, rax
    js      .accept_loop        ; retry on error (e.g. EINTR)
    mov     r13, rax            ; save client fd

    ; Fork to handle request
    mov     rax, SYS_FORK
    syscall
    test    rax, rax
    js      .accept_loop        ; fork failed, skip
    jnz     .parent             ; parent process

; ============================================================================
; CHILD PROCESS - Handle the HTTP request
; ============================================================================
.child:
    ; Close listening socket in child
    mov     rax, SYS_CLOSE
    mov     rdi, r12
    syscall

    ; Read the HTTP request (we mostly ignore it but need to consume it)
    mov     rax, SYS_READ
    mov     rdi, r13
    lea     rsi, [rel buf]
    mov     rdx, BUF_SIZE
    syscall

    ; Send HTTP header
    mov     rax, SYS_WRITE
    mov     rdi, r13
    lea     rsi, [rel http_header]
    mov     rdx, http_header_len
    syscall

    ; Send HTML body
    lea     rsi, [rel html_body]
    mov     rdx, html_body_len
    xor     rbx, rbx            ; bytes sent so far

.send_loop:
    cmp     rbx, rdx
    jge     .send_done
    mov     rax, SYS_WRITE
    mov     rdi, r13
    lea     rsi, [rel html_body]
    add     rsi, rbx
    mov     rcx, rdx
    sub     rcx, rbx            ; remaining bytes
    ; Send at most 8192 bytes at a time
    cmp     rcx, 8192
    jle     .send_chunk
    mov     rcx, 8192
.send_chunk:
    push    rdx
    mov     rdx, rcx
    syscall
    pop     rdx
    test    rax, rax
    jle     .send_done          ; error or closed
    add     rbx, rax
    jmp     .send_loop

.send_done:
    ; Close client socket
    mov     rax, SYS_CLOSE
    mov     rdi, r13
    syscall

    ; Exit child
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

; ============================================================================
; PARENT PROCESS - Close client fd and continue accepting
; ============================================================================
.parent:
    mov     rax, SYS_CLOSE
    mov     rdi, r13
    syscall
    jmp     .accept_loop

.error:
    mov     rax, SYS_EXIT
    mov     rdi, 1
    syscall
