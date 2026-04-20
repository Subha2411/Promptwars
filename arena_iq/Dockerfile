# ── Stage 1: Build Flutter Web ──────────────────────────
FROM debian:bullseye-slim AS builder

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa wget \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter stable
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter --depth 1
ENV PATH="/flutter/bin:${PATH}"

# Pre-cache flutter web tools
RUN flutter config --enable-web && flutter precache --web

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# ── Stage 2: Serve with nginx ────────────────────────────
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
