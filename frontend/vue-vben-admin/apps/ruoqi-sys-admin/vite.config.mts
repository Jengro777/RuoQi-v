import { defineConfig } from '@vben/vite-config';

export default defineConfig(async () => {
  return {
    application: {},
    vite: {
      server: {
        proxy: {
          '/sys_admin': {
            changeOrigin: true,
            rewrite: (path) => path.replace(/^\/sys_admin/, ''),
            target: 'http://localhost:9009/sys_admin/',
            ws: true,
          },
          // '/fms-api': {
          //   changeOrigin: true,
          //   rewrite: (path) => path.replace(/^\/fms-api/, ''),
          //   target: 'http://localhost:9102/',
          //   ws: true,
          // },
          // '/mms-api': {
          //   changeOrigin: true,
          //   rewrite: (path) => path.replace(/^\/mms-api/, ''),
          //   target: 'http://localhost:9104/',
          //   ws: true,
          // },
          // '/api': {
          //   changeOrigin: true,
          //   rewrite: (path) => path.replace(/^\/api/, ''),
          //   // mock代理目标地址
          //   target: 'http://localhost:5320/api',
          //   ws: true,
          // },
          // '/sys-api': {
          //   changeOrigin: true,
          //   rewrite: (path) => path.replace(/^\/sys-api/, ''),
          //   target: 'http://localhost:9100/',
          //   ws: true,
          // },
        },
      },
    },
  };
});
