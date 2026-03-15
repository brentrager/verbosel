# Verbosel

A web server written in pure x86_64 Linux assembly, deployed via SST v4 to AWS ECS, with a Next.js companion landing page.

## Tech Stack

- **Server**: Pure x86_64 NASM assembly (no libc), Linux syscalls only
- **Frontend**: Next.js 16 + React 19 + Tailwind CSS 4
- **Infra**: SST v4 on AWS (ECS for assembly server, Lambda/CloudFront for Next.js site)
- **Build**: NASM + ld for assembly, pnpm for JS

## Tooling

- Use **pnpm** (not npm/yarn)
- Use **oxfmt** and **oxlint** (not prettier/eslint)
- Assembly built with **nasm** and linked with **ld**

## Key Files

- `server/server.asm` — The entire HTTP server in assembly
- `server/Dockerfile` — Multi-stage build: assemble in builder, copy binary to slim
- `site/app/page.tsx` — Next.js landing page (React version of the assembly-served site)
- `sst.config.ts` — SST v4 infrastructure (VPC, ECS, Nextjs)

## Commands

- `pnpm dev:asm` — Build and run the assembly server locally
- `pnpm dev:site` — Run the Next.js site in dev mode
- `pnpm sst:deploy` — Deploy everything to AWS
