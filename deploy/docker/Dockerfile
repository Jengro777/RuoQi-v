# 第一阶段：构建环境
FROM thevlang/vlang:alpine as builder

# 可选代理，通过 --build-arg GIT_PROXY=http://proxy:port 传入
ARG GIT_PROXY

WORKDIR /app
COPY ./backend .

# 安装依赖，更新 V 到最新版，然后构建
RUN apk add --no-cache \
    git \
    libatomic \
    build-base \
    gc-dev \
    libpq-dev \
    mariadb-connector-c-dev && \
    (test -n "$GIT_PROXY" && git config --global http.proxy $GIT_PROXY && git config --global http.version HTTP/1.1 || true) && \
    v up && \
    v -prod -o app ./main && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# 第二阶段：运行时环境（轻量 alpine + 必要动态库）
FROM alpine:3.18

WORKDIR /app

# 安装运行时依赖
RUN apk add --no-cache \
    libatomic \
    libpq \
    mariadb-connector-c \
    ca-certificates && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# 复制构建产物
COPY --from=builder /app/app .
COPY --from=builder /app/static ./static/
COPY --from=builder /app/etc/config.toml ./etc/
COPY --from=builder /app/etc/locales ./etc/locales


EXPOSE 9009
CMD ["./app", "-f", "etc/config.toml"]
