FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    nasm \
    binutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY server.asm .

RUN nasm -f elf64 -o server.o server.asm \
    && ld -o server server.o \
    && strip server

# Runtime: scratch-like minimal image
FROM debian:bookworm-slim

WORKDIR /app
COPY --from=builder /build/server .

EXPOSE 8080

CMD ["./server"]
