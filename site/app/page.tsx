"use client";

import { useState, useEffect } from "react";

const ASM_LINES = [
    { label: false, inst: "; boot sequence initiated", color: "text-[#00aa2a]" },
    {
        label: false,
        parts: [
            { text: "mov", color: "text-[#ffbf00]" },
            { text: " rax, ", color: "text-[#ededed]" },
            { text: "SYS_SOCKET", color: "text-[#00ffff]" },
        ],
    },
    {
        label: false,
        parts: [
            { text: "mov", color: "text-[#ffbf00]" },
            { text: " rdi, ", color: "text-[#ededed]" },
            { text: "AF_INET", color: "text-[#00ffff]" },
        ],
    },
    {
        label: false,
        parts: [
            { text: "mov", color: "text-[#ffbf00]" },
            { text: " rsi, ", color: "text-[#ededed]" },
            { text: "SOCK_STREAM", color: "text-[#00ffff]" },
        ],
    },
    {
        label: false,
        parts: [
            { text: "syscall", color: "text-[#ffbf00]" },
            { text: "              ; socket created", color: "text-[#00aa2a]" },
        ],
    },
    { label: false, inst: "", color: "text-[#00aa2a]" },
    {
        label: false,
        parts: [
            { text: "mov", color: "text-[#ffbf00]" },
            { text: " rax, ", color: "text-[#ededed]" },
            { text: "SYS_BIND", color: "text-[#00ffff]" },
        ],
    },
    {
        label: false,
        parts: [
            { text: "syscall", color: "text-[#ffbf00]" },
            { text: "              ; bound to :8080", color: "text-[#00aa2a]" },
        ],
    },
    { label: false, inst: "", color: "text-[#00aa2a]" },
    {
        label: false,
        parts: [
            { text: "mov", color: "text-[#ffbf00]" },
            { text: " rax, ", color: "text-[#ededed]" },
            { text: "SYS_LISTEN", color: "text-[#00ffff]" },
        ],
    },
    {
        label: false,
        parts: [
            { text: "syscall", color: "text-[#ffbf00]" },
            {
                text: "              ; listening...",
                color: "text-[#00aa2a]",
            },
        ],
    },
    { label: false, inst: "", color: "text-[#00aa2a]" },
    { label: true, text: "accept_loop:", color: "text-[#bf40bf]" },
    {
        label: false,
        parts: [
            { text: "    mov", color: "text-[#ffbf00]" },
            { text: " rax, ", color: "text-[#ededed]" },
            { text: "SYS_ACCEPT", color: "text-[#00ffff]" },
        ],
    },
    {
        label: false,
        parts: [
            { text: "    syscall", color: "text-[#ffbf00]" },
        ],
    },
    {
        label: false,
        parts: [
            { text: "    mov", color: "text-[#ffbf00]" },
            { text: " rax, ", color: "text-[#ededed]" },
            { text: "SYS_FORK", color: "text-[#00ffff]" },
        ],
    },
    {
        label: false,
        parts: [
            { text: "    syscall", color: "text-[#ffbf00]" },
            {
                text: "          ; fork child handler",
                color: "text-[#00aa2a]",
            },
        ],
    },
    {
        label: false,
        parts: [
            { text: "    jmp", color: "text-[#ffbf00]" },
            { text: " ", color: "text-[#ededed]" },
            { text: "accept_loop", color: "text-[#bf40bf]" },
        ],
    },
];

function TerminalLine({
    line,
    visible,
}: {
    line: (typeof ASM_LINES)[number];
    visible: boolean;
}) {
    if (!visible) return null;
    if ("label" in line && line.label) {
        return (
            <p className={line.color as string}>
                {"text" in line ? (line.text as string) : ""}
            </p>
        );
    }
    if ("inst" in line) {
        return <p className={line.color as string}>{line.inst as string}</p>;
    }
    if ("parts" in line) {
        return (
            <p>
                {(line.parts as Array<{ text: string; color: string }>).map(
                    (p, i) => (
                        <span key={i} className={p.color}>
                            {p.text}
                        </span>
                    ),
                )}
            </p>
        );
    }
    return null;
}

const FEATURES = [
    {
        icon: "\u2699",
        title: "Zero Abstraction",
        desc: "Why use Express when you can manually pack sockaddr_in structs? Every HTTP response is hand-crafted with MOV instructions.",
        border: "border-[#00ff41]/10 hover:border-[#00ff41]/30",
        bg: "bg-[#00ff41]/[0.02] hover:bg-[#00ff41]/[0.05]",
        titleColor: "text-[#00ff41]",
    },
    {
        icon: "\u26A1",
        title: "Blazingly Fast",
        desc: "No garbage collector. No JIT warmup. Your CPU executes exactly what you wrote. It boots before Node.js finishes parsing package.json.",
        border: "border-[#ffbf00]/10 hover:border-[#ffbf00]/30",
        bg: "bg-[#ffbf00]/[0.02] hover:bg-[#ffbf00]/[0.05]",
        titleColor: "text-[#ffbf00]",
    },
    {
        icon: "\uD83D\uDD12",
        title: "Memory Safe*",
        desc: '*As safe as the programmer writing it. Which is to say: not at all. But at least you can SEE every byte.',
        border: "border-[#00ffff]/10 hover:border-[#00ffff]/30",
        bg: "bg-[#00ffff]/[0.02] hover:bg-[#00ffff]/[0.05]",
        titleColor: "text-[#00ffff]",
        footnote: "*not actually memory safe",
    },
    {
        icon: "\uD83D\uDCE6",
        title: "12KB Binary",
        desc: "Your entire web server fits in L1 cache. Meanwhile, node_modules is downloading the npm registry for hello world.",
        border: "border-[#bf40bf]/10 hover:border-[#bf40bf]/30",
        bg: "bg-[#bf40bf]/[0.02] hover:bg-[#bf40bf]/[0.05]",
        titleColor: "text-[#bf40bf]",
    },
    {
        icon: "\uD83D\uDD25",
        title: "Fork-Per-Request",
        desc: "Process isolation via fork(). Each request gets its own address space. It is 1995 and that is a feature, not a bug.",
        border: "border-[#ff3333]/10 hover:border-[#ff3333]/30",
        bg: "bg-[#ff3333]/[0.02] hover:bg-[#ff3333]/[0.05]",
        titleColor: "text-[#ff3333]",
    },
    {
        icon: "\uD83D\uDE80",
        title: "SST v4 Deployed",
        desc: "Because even assembly deserves infrastructure-as-code. Deployed to AWS ECS via SST. We are civilized barbarians.",
        border: "border-[#00ff41]/10 hover:border-[#00ff41]/30",
        bg: "bg-[#00ff41]/[0.02] hover:bg-[#00ff41]/[0.05]",
        titleColor: "text-[#00ff41]",
    },
];

const BENCHMARKS = [
    { name: "Verbosel", time: "~0.001ms", width: "2%", color: "from-[#00ff41] to-[#33ff66]", glow: true, nameColor: "text-[#00ff41]" },
    { name: "Go net/http", time: "~0.05ms", width: "15%", color: "from-[#00ffff]/60 to-[#00ffff]/60", glow: false, nameColor: "text-[#00aa2a]" },
    { name: "Rust Actix", time: "~0.08ms", width: "20%", color: "from-[#bf40bf]/60 to-[#bf40bf]/60", glow: false, nameColor: "text-[#00aa2a]" },
    { name: "Node.js Express", time: "~2.5ms", width: "60%", color: "from-[#ffbf00]/60 to-[#ffbf00]/60", glow: false, nameColor: "text-[#00aa2a]" },
    { name: "Next.js (cold start)", time: "~150ms", width: "95%", color: "from-[#ff3333]/60 to-[#ff3333]/60", glow: false, nameColor: "text-[#00aa2a]" },
];

export default function Home() {
    const [visibleLines, setVisibleLines] = useState(0);

    useEffect(() => {
        const timer = setInterval(() => {
            setVisibleLines((prev) => {
                if (prev >= ASM_LINES.length) {
                    clearInterval(timer);
                    return prev;
                }
                return prev + 1;
            });
        }, 150);
        return () => clearInterval(timer);
    }, []);

    return (
        <main className="bg-[#0a0a0a] text-[#ededed] font-mono overflow-x-hidden">
            {/* Scanline overlay */}
            <div className="fixed inset-0 pointer-events-none z-50">
                <div className="absolute inset-0 opacity-[0.03]" style={{ backgroundImage: "radial-gradient(circle, #00ff41 1px, transparent 1px)", backgroundSize: "30px 30px" }} />
                <div className="absolute left-0 right-0 h-[200px] bg-gradient-to-b from-[#00ff41]/[0.03] to-transparent" style={{ animation: "scan 8s linear infinite" }} />
            </div>

            {/* Nav */}
            <nav className="fixed top-0 w-full z-40 bg-[#0a0a0a]/90 backdrop-blur-sm border-b border-[#00ff41]/20">
                <div className="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-3 h-3 bg-[#00ff41] rounded-full animate-glow" style={{ boxShadow: "0 0 10px #00ff41" }} />
                        <span className="text-lg font-bold tracking-wider text-shadow-green">Verbosel</span>
                    </div>
                    <div className="hidden md:flex items-center gap-8 text-sm">
                        <a href="#features" className="text-[#00aa2a] hover:text-[#00ff41] transition-colors">.features</a>
                        <a href="#code" className="text-[#00aa2a] hover:text-[#00ff41] transition-colors">.source</a>
                        <a href="#benchmarks" className="text-[#00aa2a] hover:text-[#00ff41] transition-colors">.benchmarks</a>
                        <a href="#deploy" className="text-[#00aa2a] hover:text-[#00ff41] transition-colors">.deploy</a>
                        <a href="https://github.com/brentrager/Verbosel" className="px-4 py-2 border border-[#00ff41]/30 hover:border-[#00ff41] hover:bg-[#00ff41]/10 transition-all rounded text-[#00ff41]">
                            git clone
                        </a>
                    </div>
                </div>
            </nav>

            {/* Hero */}
            <section className="min-h-screen flex items-center justify-center relative pt-20">
                <div className="max-w-5xl mx-auto px-6 text-center">
                    {/* Terminal */}
                    <div className="mb-12 animate-fade-in">
                        <div className="inline-block bg-[#0a0a0a] border border-[#00ff41]/20 rounded-lg overflow-hidden text-left max-w-2xl w-full border-glow">
                            <div className="flex items-center gap-2 px-4 py-3 bg-[#00ff41]/5 border-b border-[#00ff41]/10">
                                <div className="w-3 h-3 rounded-full bg-[#ff3333]/80" />
                                <div className="w-3 h-3 rounded-full bg-[#ffbf00]/80" />
                                <div className="w-3 h-3 rounded-full bg-[#00ff41]/80" />
                                <span className="ml-3 text-xs text-[#00aa2a]">server.asm - Verbosel</span>
                            </div>
                            <div className="p-6 text-sm leading-relaxed min-h-[320px]">
                                {ASM_LINES.map((line, i) => (
                                    <TerminalLine key={i} line={line} visible={i < visibleLines} />
                                ))}
                                {visibleLines >= ASM_LINES.length && (
                                    <p className="mt-3 text-[#ededed]">
                                        <span className="text-[#bf40bf]">&gt;&gt;</span> server listening on <span className="text-[#ffbf00]">:8080</span>
                                        <span className="inline-block w-2 h-5 bg-[#00ff41] ml-1 animate-blink" />
                                    </p>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Title */}
                    <h1 className="text-5xl md:text-7xl font-extrabold mb-6 animate-glow text-shadow-green leading-tight">
                        Verbosel
                    </h1>
                    <p className="text-xl md:text-2xl text-[#00aa2a] mb-4">
                        The Web Framework That Refuses to Abstract
                    </p>
                    <p className="text-[#ffbf00] text-lg mb-10">
                        0 dependencies. 0 runtime. 0 compromise. Just syscalls.
                    </p>

                    {/* Stats */}
                    <div className="flex flex-wrap justify-center gap-6 mb-12">
                        {[
                            { val: "0", label: "Dependencies", color: "[#00ff41]" },
                            { val: "~12KB", label: "Binary Size", color: "[#ffbf00]" },
                            { val: "10", label: "Syscalls Used", color: "[#00ffff]" },
                            { val: "0ms", label: "Cold Start", color: "[#bf40bf]" },
                        ].map((s) => (
                            <div key={s.label} className={`px-5 py-3 border border-${s.color}/20 rounded-lg bg-${s.color}/5`}>
                                <div className={`text-2xl font-bold text-${s.color}`}>{s.val}</div>
                                <div className="text-xs text-[#00aa2a] uppercase tracking-wider">{s.label}</div>
                            </div>
                        ))}
                    </div>

                    {/* CTA */}
                    <div className="flex flex-wrap justify-center gap-4">
                        <a href="#code" className="px-8 py-3 bg-[#00ff41] text-[#0a0a0a] font-bold rounded-lg hover:bg-[#33ff66] transition-colors" style={{ boxShadow: "0 0 20px rgba(0,255,65,0.3)" }}>
                            View the Source
                        </a>
                        <a href="https://github.com/brentrager/Verbosel" className="px-8 py-3 border border-[#00ff41]/30 text-[#00ff41] rounded-lg hover:bg-[#00ff41]/10 transition-all">
                            GitHub &rarr;
                        </a>
                    </div>
                </div>
            </section>

            {/* Features */}
            <section id="features" className="py-24 relative">
                <div className="max-w-6xl mx-auto px-6">
                    <div className="text-center mb-16">
                        <p className="text-[#ffbf00] text-sm uppercase tracking-widest mb-3">{"// Why would you do this?"}</p>
                        <h2 className="text-4xl font-bold text-shadow-green mb-4">Features</h2>
                        <p className="text-[#00aa2a] max-w-2xl mx-auto">
                            Everything you never knew you needed, implemented at the lowest possible level of abstraction.
                        </p>
                    </div>
                    <div className="grid md:grid-cols-3 gap-6">
                        {FEATURES.map((f) => (
                            <div key={f.title} className={`p-6 border ${f.border} rounded-xl ${f.bg} transition-all group`}>
                                <div className="text-3xl mb-4">{f.icon}</div>
                                <h3 className={`text-lg font-bold ${f.titleColor} mb-2`}>{f.title}</h3>
                                <p className="text-[#00aa2a] text-sm leading-relaxed">{f.desc}</p>
                                {f.footnote && <p className="text-[#00aa2a]/50 text-xs mt-2">{f.footnote}</p>}
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Source Code */}
            <section id="code" className="py-24 bg-[#00ff41]/[0.02] border-y border-[#00ff41]/10">
                <div className="max-w-5xl mx-auto px-6">
                    <div className="text-center mb-16">
                        <p className="text-[#ffbf00] text-sm uppercase tracking-widest mb-3">{"// The actual code"}</p>
                        <h2 className="text-4xl font-bold text-shadow-green mb-4">Source</h2>
                        <p className="text-[#00aa2a] max-w-2xl mx-auto">
                            The entire HTTP server. No hidden abstractions. No imported modules. Just you, the kernel, and a dream.
                        </p>
                    </div>
                    <div className="bg-[#0a0a0a] border border-[#00ff41]/20 rounded-xl overflow-hidden border-glow">
                        <div className="flex items-center gap-2 px-4 py-3 bg-[#00ff41]/5 border-b border-[#00ff41]/10">
                            <div className="w-3 h-3 rounded-full bg-[#ff3333]/80" />
                            <div className="w-3 h-3 rounded-full bg-[#ffbf00]/80" />
                            <div className="w-3 h-3 rounded-full bg-[#00ff41]/80" />
                            <span className="ml-3 text-xs text-[#00aa2a]">server.asm (the important bits)</span>
                        </div>
                        <div className="p-6 text-sm leading-loose overflow-x-auto">
                            <pre className="text-[#00aa2a]">{`; Create TCP socket
`}<span className="text-[#ffbf00]">mov</span>{`     rax, 41          `}<span className="text-[#00aa2a]">{`; SYS_SOCKET`}</span>{`
`}<span className="text-[#ffbf00]">mov</span>{`     rdi, 2           `}<span className="text-[#00aa2a]">{`; AF_INET`}</span>{`
`}<span className="text-[#ffbf00]">mov</span>{`     rsi, 1           `}<span className="text-[#00aa2a]">{`; SOCK_STREAM`}</span>{`
`}<span className="text-[#ffbf00]">xor</span>{`     rdx, rdx
`}<span className="text-[#ffbf00]">syscall</span>{`

; Bind to 0.0.0.0:8080
`}<span className="text-[#ffbf00]">mov</span>{`     rax, 49          `}<span className="text-[#00aa2a]">{`; SYS_BIND`}</span>{`
`}<span className="text-[#ffbf00]">mov</span>{`     rdi, r12         `}<span className="text-[#00aa2a]">{`; socket fd`}</span>{`
`}<span className="text-[#ffbf00]">lea</span>{`     rsi, [rel sockaddr]
`}<span className="text-[#ffbf00]">mov</span>{`     rdx, 16
`}<span className="text-[#ffbf00]">syscall</span>{`

; Listen with backlog 128
`}<span className="text-[#ffbf00]">mov</span>{`     rax, 50          `}<span className="text-[#00aa2a]">{`; SYS_LISTEN`}</span>{`
`}<span className="text-[#ffbf00]">mov</span>{`     rdi, r12
`}<span className="text-[#ffbf00]">mov</span>{`     rsi, 128
`}<span className="text-[#ffbf00]">syscall</span>{`

`}<span className="text-[#bf40bf]">accept_loop:</span>{`
    `}<span className="text-[#ffbf00]">mov</span>{` rax, 43      `}<span className="text-[#00aa2a]">{`; SYS_ACCEPT`}</span>{`
    `}<span className="text-[#ffbf00]">mov</span>{` rdi, r12
    `}<span className="text-[#ffbf00]">xor</span>{` rsi, rsi
    `}<span className="text-[#ffbf00]">xor</span>{` rdx, rdx
    `}<span className="text-[#ffbf00]">syscall</span>{`          `}<span className="text-[#00aa2a]">{`; blocks until connection`}</span>{`
    `}<span className="text-[#ffbf00]">mov</span>{` r13, rax     `}<span className="text-[#00aa2a]">{`; save client fd`}</span>{`

    `}<span className="text-[#00aa2a]">{`; Fork to handle request`}</span>{`
    `}<span className="text-[#ffbf00]">mov</span>{` rax, 57      `}<span className="text-[#00aa2a]">{`; SYS_FORK`}</span>{`
    `}<span className="text-[#ffbf00]">syscall</span>{`
    `}<span className="text-[#ffbf00]">test</span>{` rax, rax
    `}<span className="text-[#ffbf00]">jz</span>{`  `}<span className="text-[#bf40bf]">handle_request</span>{`
    `}<span className="text-[#ffbf00]">jmp</span>{` `}<span className="text-[#bf40bf]">accept_loop</span>{` `}<span className="text-[#00aa2a]">{`; parent continues`}</span></pre>
                        </div>
                    </div>
                </div>
            </section>

            {/* Benchmarks */}
            <section id="benchmarks" className="py-24">
                <div className="max-w-5xl mx-auto px-6">
                    <div className="text-center mb-16">
                        <p className="text-[#ffbf00] text-sm uppercase tracking-widest mb-3">{"// Numbers don't lie"}</p>
                        <h2 className="text-4xl font-bold text-shadow-green mb-4">Benchmarks*</h2>
                        <p className="text-[#00aa2a] max-w-2xl mx-auto">Completely real and not at all cherry-picked comparisons.</p>
                        <p className="text-[#00aa2a]/50 text-xs mt-2">*benchmarks performed on the author&apos;s laptop at 3am</p>
                    </div>
                    <div className="space-y-6">
                        {BENCHMARKS.map((b) => (
                            <div key={b.name} className="border border-[#00ff41]/10 rounded-xl p-6 bg-[#00ff41]/[0.02]">
                                <div className="flex justify-between mb-3">
                                    <span className={`font-bold ${b.nameColor}`}>{b.name}</span>
                                    <span className={b.glow ? "text-[#ffbf00]" : "text-[#00aa2a]"}>{b.time}</span>
                                </div>
                                <div className="w-full bg-[#00ff41]/10 rounded-full h-4 overflow-hidden">
                                    <div
                                        className={`h-full rounded-full bg-gradient-to-r ${b.color}`}
                                        style={{
                                            width: b.width,
                                            ...(b.glow ? { boxShadow: "0 0 10px #00ff41" } : {}),
                                        }}
                                    />
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Deploy */}
            <section id="deploy" className="py-24 bg-[#00ff41]/[0.02] border-y border-[#00ff41]/10">
                <div className="max-w-4xl mx-auto px-6 text-center">
                    <p className="text-[#ffbf00] text-sm uppercase tracking-widest mb-3">{"// Ship it"}</p>
                    <h2 className="text-4xl font-bold text-shadow-green mb-6">Deploy in 3 Instructions</h2>
                    <div className="bg-[#0a0a0a] border border-[#00ff41]/20 rounded-xl p-6 text-left mb-10 border-glow inline-block w-full max-w-lg mx-auto">
                        <p className="text-[#00aa2a] text-sm">$</p>
                        <p className="text-[#ededed] text-sm"><span className="text-[#ffbf00]">git</span> clone https://github.com/brentrager/Verbosel</p>
                        <p className="text-[#ededed] text-sm"><span className="text-[#ffbf00]">cd</span> Verbosel</p>
                        <p className="text-[#ededed] text-sm"><span className="text-[#ffbf00]">npx</span> sst deploy --stage production</p>
                        <p className="mt-3 text-[#ededed] text-sm">
                            <span className="text-[#bf40bf]">&gt;&gt;</span> deployed to <span className="text-[#ffbf00]">asm.rager.tech</span>
                            <span className="inline-block w-2 h-4 bg-[#00ff41] ml-1 animate-blink" />
                        </p>
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer className="py-16 border-t border-[#00ff41]/10">
                <div className="max-w-6xl mx-auto px-6 text-center">
                    <div className="text-4xl font-bold text-shadow-green animate-glow mb-6">Verbosel</div>
                    <p className="text-[#00aa2a] mb-2">Built with nothing but syscalls and questionable life choices.</p>
                    <p className="text-[#00aa2a]/50 text-sm mb-8">This page is served by an x86_64 assembly HTTP server running on AWS ECS.</p>
                    <div className="flex justify-center gap-6 text-[#00aa2a] text-sm">
                        <a href="https://github.com/brentrager/Verbosel" className="hover:text-[#00ff41] transition-colors">GitHub</a>
                        <span className="text-[#00ff41]/20">|</span>
                        <span>MIT License</span>
                        <span className="text-[#00ff41]/20">|</span>
                        <span>x86_64 Linux</span>
                        <span className="text-[#00ff41]/20">|</span>
                        <span>SST v4</span>
                    </div>
                    <p className="text-[#00aa2a]/30 text-xs mt-8">X-Powered-By: raw-x86_64-syscalls</p>
                </div>
            </footer>
        </main>
    );
}
