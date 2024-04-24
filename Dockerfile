FROM golang:1.19.1 as builder

LABEL org.opencontainers.image.description="Dockerized DMGC Stratum Bridge"      
LABEL org.opencontainers.image.authors="dmgcoin"  
LABEL org.opencontainers.image.source="https://github.com/dmgcoin/dmgc-stratum-bridge"
              
WORKDIR /go/src/app
ADD go.mod .
ADD go.sum .
RUN go mod download

ADD . .
RUN go build -o /go/bin/app ./cmd/dmgcbridge


FROM gcr.io/distroless/base:nonroot
COPY --from=builder /go/bin/app /
COPY cmd/dmgcbridge/config.yaml /

WORKDIR /
ENTRYPOINT ["/app"]
