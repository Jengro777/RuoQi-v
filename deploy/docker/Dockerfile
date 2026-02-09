# 第一阶段：构建环境
FROM thevlang/vlang:alpine as builder

WORKDIR /app
COPY ./backend .

# 安装依赖并构建（适配 Alpine）
RUN apk add --no-cache \
    libatomic \
    # musl-dev \
    build-base \
    mariadb-connector-c-dev && \
    v -prod -o app ./main && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# 第二阶段：运行时环境
FROM thevlang/vlang:alpine

WORKDIR /app

# 安装运行时依赖（Alpine）
RUN apk add --no-cache \
    libatomic \
    mariadb-connector-c && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# 复制构建产物
COPY --from=builder /app/app .
COPY --from=builder /app/static ./static/
COPY --from=builder /app/etc/config.toml ./etc/
COPY --from=builder /app/etc/locales ./etc/locales


EXPOSE 9009
CMD ["./app", "-f", "etc/config.toml"]
