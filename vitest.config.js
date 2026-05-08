import { defineConfig } from 'vitest/config';
import preact from '@preact/preset-vite';

export default defineConfig({
  plugins: [preact({ devToolsEnabled: false })],
  test: {
    environment: 'node',
    testTimeout: 15000,
    hookTimeout: 10000,
    fileParallelism: false,
    retry: 1,
  }
});
