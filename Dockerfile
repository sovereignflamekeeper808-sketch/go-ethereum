# Platinumwrist/go-ethereum  Mainnet Full Node
# Multi-stage build: compile from source, deploy minimal alpine runtime

FROM golang:1.21-alpine AS builder

RUN apk add --no-cache make gcc musl-dev linux-headers git ca-certificates

WORKDIR /build
COPY . .
RUN make geth

FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata curl jq bash
RUN addgroup -S geth && adduser -S -G geth geth

COPY --from=builder /build/build/bin/geth /usr/local/bin/geth

RUN mkdir -p /data/geth && chown -R geth:geth /data
VOLUME /data/geth

USER geth

EXPOSE 8545 8546 8551 30303 30303/udp 6060

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -sf http://localhost:8545 -X POST \
            -H "Content-Type: application/json" \
                    -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' || exit 1

                    ENTRYPOINT ["geth"]
