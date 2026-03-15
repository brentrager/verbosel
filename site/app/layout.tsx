import type { Metadata } from "next";
import { JetBrains_Mono } from "next/font/google";
import "./globals.css";

const jetbrains = JetBrains_Mono({
    variable: "--font-jetbrains",
    subsets: ["latin"],
});

export const metadata: Metadata = {
    metadataBase: new URL("https://Verbosel.rager.tech"),
    title: "Verbosel | The Web Framework That Refuses to Abstract",
    description:
        "A web server written in pure x86_64 assembly. 0 dependencies. 0 runtime. 0 compromise. Just syscalls.",
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en" className="scroll-smooth">
            <body className={`${jetbrains.variable} antialiased crt`}>
                {children}
            </body>
        </html>
    );
}
