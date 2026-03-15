```
; ============================================================================
; README.asm - The Documentation
; ============================================================================
; To read this README, load it into RAX and SYSCALL your eyeballs
; ============================================================================

section .data
    readme: db "You are now reading documentation written for REAL programmers."
    db 10, "If you need syntax highlighting to understand this, close your laptop."
    db 10, 0
```

# Verbosel

### The Web Framework That Refuses to Abstract

> *"Any sufficiently advanced assembly is indistinguishable from insanity."*
> -- Arthur C. Clarke, probably, if he'd seen this repo

```nasm
mov  rax, IMPRESSED    ; you will be
xor  rbx, rbx          ; zero dependencies
xor  rcx, rcx          ; zero runtime
xor  rdx, rdx          ; zero regrets (lie)
syscall                 ; deploy it
```

---

## What Is This

**Verbosel** is a web framework where the HTTP server is written in **pure x86_64 Linux assembly**. Not "assembly-like." Not "inline assembly in C." Not "Rust with `unsafe` blocks."

**Actual. Assembly.**

The server uses raw Linux syscalls to:
- `socket()` - Create a TCP socket (syscall 41, because we memorize these)
- `bind()` - Bind to port 8080 (network byte order, manually packed, as God intended)
- `listen()` - Listen with a backlog of 128 (we're optimists)
- `accept()` - Accept connections (blocking, because we live dangerously)
- `fork()` - Fork a child process per request (it's 1995 and we're THRIVING)
- `read()` / `write()` - Handle HTTP (we parse exactly 0 bytes of the request)
- `close()` - Clean up (we have *some* manners)
- `exit()` - Graceful shutdown (SEGFAULT is also an option)

The result is a **gorgeous, Tailwind-styled website** served directly from assembly. The HTML lives in the `.data` section of the ELF binary. Your entire web application is a single statically-linked executable smaller than most favicons.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        THE INTERNET                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ TCP SYN (a mere mortal's request)
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                    AWS ECS (Fargate)                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Verbosel server binary                 │  │
│  │                                                       │  │
│  │  section .text                                        │  │
│  │  ┌─────────────┐     ┌──────────────┐                │  │
│  │  │   _start    │────▶│ accept_loop  │◀──────┐        │  │
│  │  │  (socket,   │     │  (accept,    │       │        │  │
│  │  │   bind,     │     │   fork)      │       │        │  │
│  │  │   listen)   │     └──────┬───────┘       │        │  │
│  │  └─────────────┘            │               │        │  │
│  │                     fork()  │               │        │  │
│  │                 ┌───────────┴────────┐      │        │  │
│  │                 │                    │      │        │  │
│  │          ┌──────▼──────┐    ┌───────▼────┐ │        │  │
│  │          │   child:    │    │  parent:   │ │        │  │
│  │          │  read()     │    │  close()   │ │        │  │
│  │          │  write()    │    │  jmp loop  ├─┘        │  │
│  │          │  close()    │    └────────────┘          │  │
│  │          │  exit()     │                            │  │
│  │          └─────────────┘                            │  │
│  │                                                       │  │
│  │  section .data                                        │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  ~15KB of hand-crafted HTML with Tailwind CDN   │  │  │
│  │  │  (the most beautiful .data section ever written) │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## The Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **CPU** | x86_64 | The only dependency we acknowledge |
| **OS** | Linux | We use 10 of its ~400 syscalls. Efficiency. |
| **Runtime** | None | `_start` IS our runtime |
| **Framework** | None | We ARE the framework |
| **Package Manager** | None | `nasm` + `ld`. That's it. Go home. |
| **HTTP Parser** | None | We read the request and ignore it completely |
| **Template Engine** | `.data` section | String literals are a template engine if you believe hard enough |
| **CSS** | Tailwind CDN | Even we're not crazy enough to implement CSS in assembly |
| **Deployment** | SST v4 on AWS ECS | Infrastructure-as-code for our no-code (it's assembly) server |
| **Container** | Docker | FROM debian:slim, because our binary needs *something* to feel important |

---

## Installation

### Prerequisites

```nasm
; Check if you have what it takes
test  brain, UNDERSTANDING_OF_SYSCALLS
jz    .go_use_express                    ; no shame (some shame)
```

You need:
- **nasm** - The Netwide Assembler (for turning your dreams into machine code)
- **ld** - The GNU linker (for turning machine code into an executable)
- **Docker** - For containerization (we're barbaric, not animals)
- **pnpm** - For SST and the Next.js companion site
- **SST v4** - For deploying to AWS (yes, we use IaC for our assembly server)

### Local Build

```bash
# Clone the repository
git clone https://github.com/brentrager/Verbosel.git
cd Verbosel

# Build the assembly server
cd server
make          # Assembles and links. That's it.
              # No npm install. No cargo build. No pip install -r requirements.txt
              # Just nasm and ld. Two commands. We're done.

# Run it
./server      # Listening on :8080. No configuration. No .env file.
              # No YAML. No TOML. No JSON. Just a binary and a port.
```

### Docker Build

```bash
docker build -t Verbosel ./server
docker run -p 8080:8080 Verbosel

# Your web server is now running.
# Total image size: ~80MB (it's debian:slim's fault, not ours)
# Actual binary size: ~12KB
# The ratio of container overhead to application: embarrassing
```

### Deploy to AWS

```bash
pnpm install
npx sst deploy --stage production

# Deployed. Your assembly HTTP server is now running on AWS ECS.
# Jeff Bezos is serving your hand-crafted syscalls to the world.
# This is the future the founding fathers wanted.
```

---

## Project Structure

```
Verbosel/
├── server/
│   ├── server.asm          # THE server. THE framework. THE everything.
│   │                       # ~500 lines of x86_64 that serve a gorgeous website.
│   │                       # Contains more HTML than most React apps contain logic.
│   ├── Makefile            # nasm + ld. Two lines of actual build commands.
│   │                       # Smaller than your .eslintrc
│   └── Dockerfile          # Multi-stage build. We assemble in the builder,
│                           # then copy the binary. Docker layers have more
│                           # abstraction than our entire server.
│
├── site/                   # Next.js companion site (for the landing page)
│   ├── app/
│   │   ├── layout.tsx      # React. We're not above using it for docs.
│   │   ├── page.tsx        # The React version of what assembly serves natively.
│   │   │                   # Same UI. 10,000x more dependencies.
│   │   └── globals.css     # CRT scanline effects, because AESTHETIC
│   ├── package.json        # 847 transitive dependencies for what assembly
│   │                       # does with 0
│   └── next.config.ts      # output: "standalone" (ironic)
│
├── sst.config.ts           # SST v4 infrastructure. VPC, ECS cluster,
│                           # load balancer. More YAML generated than
│                           # assembly written.
├── package.json            # Root workspace config
└── README.md               # You are here. Congratulations on scrolling
                            # this far. Your reward is more assembly jokes.
```

---

## How It Works

### Step 1: Create a Socket

```nasm
mov     rax, 41          ; SYS_SOCKET - the beginning of everything
mov     rdi, 2           ; AF_INET    - IPv4, because we're not THAT retro
mov     rsi, 1           ; SOCK_STREAM - TCP, because UDP is for quitters
xor     rdx, rdx         ; protocol 0 - let the kernel figure it out
syscall                   ; ASK THE KERNEL NICELY
; rax now contains our socket file descriptor
; or -1 if the kernel rejected us (it happens to everyone)
```

### Step 2: Bind to Port 8080

```nasm
; We manually pack the sockaddr_in struct in the .data section
; because struct packing is a rite of passage
sockaddr:
    dw 2                 ; AF_INET (little-endian, the way x86 likes it)
    dw 0x901F            ; Port 8080 in network byte order
                         ; (0x1F90 byte-swapped, because networks and CPUs
                         ; couldn't agree on endianness in 1981 and we're
                         ; STILL dealing with it)
    dd 0                 ; INADDR_ANY (0.0.0.0 - we accept connections
                         ; from everywhere. security is someone else's job)
```

### Step 3: Fork Like It's 1995

```nasm
.accept_loop:
    mov     rax, 43      ; SYS_ACCEPT
    syscall              ; block until a connection arrives
    mov     r13, rax     ; save the client fd

    mov     rax, 57      ; SYS_FORK
    syscall              ; create a child process
    test    rax, rax
    jz      .child       ; child process handles the request
    jmp     .accept_loop ; parent goes back to accepting

; That's our concurrency model. fork(). Per request.
; Apache did this in 1995 and it was fine.
; (it was not fine, but we're committed to the bit)
```

### Step 4: Serve the HTML

```nasm
; The HTML lives in section .data
; It's a ~15KB string literal containing a full Tailwind-styled website
; with animations, gradients, responsive design, and CRT scanline effects
;
; Is it cursed? Yes.
; Is it beautiful? Also yes.
; Does it work? ABSOLUTELY yes.

mov     rax, 1           ; SYS_WRITE
mov     rdi, r13         ; client socket fd
lea     rsi, [rel html]  ; pointer to our magnificent HTML
mov     rdx, html_len    ; length (every byte accounted for)
syscall                   ; SEND IT
```

---

## Benchmarks

> *All benchmarks performed on the author's laptop at 3am after the third energy drink. Results may vary. Results will not vary.*

| Framework | Response Time | Binary Size | Dependencies | Cold Start |
|-----------|:------------:|:-----------:|:------------:|:----------:|
| **Verbosel** | **~0.001ms** | **~12KB** | **0** | **0ms** |
| Go net/http | ~0.05ms | ~7MB | 0* | ~5ms |
| Rust Actix | ~0.08ms | ~3MB | 147 | ~2ms |
| Node.js Express | ~2.5ms | ~45MB | 847 | ~300ms |
| Next.js | ~150ms | ~200MB | 1,247 | ~3,000ms |

*Go: "0 dependencies" (if you don't count the entire Go runtime)*

### What about `wrk` benchmarks?

```
$ wrk -t4 -c100 -d30s http://localhost:8080

Running 30s test @ http://localhost:8080
  4 threads and 100 connections

  [Results redacted because they would make every other
   framework maintainer mass-unstar their own repos]
```

---

## FAQ

### Is this production-ready?

```nasm
mov  rax, YES
; wait no
mov  rax, TECHNICALLY_YES
; hmm
mov  rax, DEFINE_PRODUCTION
```

It serves HTTP. It handles concurrent connections. It's deployed on AWS. By some definitions, that's production. By other, more reasonable definitions, please don't.

### Why not just use nginx?

nginx is written in C, which is just assembly with training wheels. We removed the training wheels. And the seat. And the handlebars. We're riding the bare frame downhill and we've never felt more alive.

### Is it secure?

```nasm
; Security audit results:
xor  rax, rax    ; vulnerabilities found: [REDACTED]
                  ; buffer overflow potential: yes
                  ; SQL injection: impossible (no SQL)
                  ; XSS: the HTML is hardcoded, so... technically no?
                  ; authentication: what's that?
```

### Can I add routing?

Sure! Just add more `cmp` and `je` instructions to compare the request path byte-by-byte. It's exactly as painful as it sounds. We believe in you.

```nasm
; Example "router"
lea  rsi, [rel buf]
cmp  byte [rsi+4], '/'      ; check first path char after "GET "
je   .serve_index
cmp  byte [rsi+4], 'a'      ; /about maybe?
je   .check_about
jmp  .serve_404              ; everything else is a 404

; This is O(n) where n is your will to live
```

### Can I use this with TypeScript?

You can use this with anything that speaks HTTP. The server doesn't know or care what's talking to it. It reads your request, ignores it completely, and sends back HTML. It's the honey badger of web frameworks.

### How do I add a database?

```nasm
; Option 1: Open a file with SYS_OPEN and read/write bytes
; Option 2: Don't
; We recommend option 2
```

### Does it support WebSockets?

No. And honestly, after implementing HTTP/1.1 in assembly, the thought of implementing the WebSocket handshake (SHA-1 hash of a magic GUID concatenated with the Sec-WebSocket-Key header, base64 encoded) makes us want to `mov rax, 60; xor rdi, rdi; syscall` ourselves.

### Why does the Dockerfile use debian:slim instead of scratch?

Because our binary is statically linked and COULD run on scratch, but we wanted `bash` available for debugging. That's right: the only reason we have an OS in our container is so we can `exec` into it and stare at our binary in confused admiration.

### What's the `X-Powered-By: raw-x86_64-syscalls` header?

A flex. Pure and simple.

---

## Contributing

```nasm
section .data
    contributing_guidelines:
        db "1. Write x86_64 assembly", 10
        db "2. Test it (somehow)", 10
        db "3. Submit a PR", 10
        db "4. Pray the CI can assemble it", 10
        db "5. We will mass merge at 3am", 10, 0
```

### Code Style

- Use NASM syntax (Intel, not AT&T, we're not savages)
- Align your operands (aesthetics matter, even in assembly)
- Comment liberally (future you will thank present you)
- Prefer `xor reg, reg` over `mov reg, 0` (it's one byte shorter and we're OPTIMIZING)
- Never use `rep movsb` when you could write a manual loop (character building)

---

## Deployment with SST v4

This project uses [SST v4](https://sst.dev) because even assembly programmers deserve infrastructure-as-code:

```typescript
// sst.config.ts - More lines of TypeScript than our server has instructions
const asmServer = new sst.aws.Service("AsmServer", {
    cluster,
    image: {
        context: "./server",
        dockerfile: "server/Dockerfile",
    },
    cpu: "0.25 vCPU",    // Our binary barely uses 0.001 vCPU
    memory: "0.5 GB",     // Our binary uses ~12KB. This is like
                           // renting a warehouse for a shoebox.
    loadBalancer: { ... }, // ALB -> our assembly server. Enterprise!
});
```

---

## The Philosophy

```nasm
section .philosophy

; Other frameworks: "Don't reinvent the wheel"
; Verbosel:     "What's a wheel? We're building from quarks."

; Other frameworks: "Convention over configuration"
; Verbosel:     "Syscalls over everything"

; Other frameworks: "Batteries included"
; Verbosel:     "We ARE the battery. We ARE the electrons."

; Other frameworks: "Developer experience"
; Verbosel:     "Character-building experience"
```

We believe that somewhere between "hello world in Express" and "hand-crafting HTTP responses from raw syscalls," there is a sweet spot.

We have not found it. But we've looked *really hard* from the assembly side.

---

## License

MIT - because even this level of chaotic energy deserves to be free.

```nasm
section .license
    db "MIT License", 10
    db "Copyright (c) 2025 Brent Rager", 10
    db 10
    db "Permission is hereby granted, free of charge, to any person", 10
    db "obtaining a copy of this software and associated documentation", 10
    db "files (the 'Software'), to deal in the Software without", 10
    db "restriction, including without limitation the rights to use,", 10
    db "copy, modify, merge, publish, distribute, sublicense, and/or", 10
    db "sell copies of the Software.", 10
    db 10
    db "THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,", 10
    db "EXPRESS OR IMPLIED. If it segfaults, that's on you.", 10, 0
```

---

## Star History

If you've read this far, you legally owe us a star.

```nasm
mov  rax, SYS_STAR
mov  rdi, THIS_REPO
syscall

; Thank you. Your star has been registered in the .bss section
; of our hearts.
```

---

<p align="center">
  <b>Verbosel</b> — because the world needed one more web framework,<br/>
  and this time it needed to be written in assembly.<br/><br/>
  <i>Built with nothing but syscalls and questionable life choices.</i><br/><br/>
  <code>X-Powered-By: raw-x86_64-syscalls</code>
</p>
