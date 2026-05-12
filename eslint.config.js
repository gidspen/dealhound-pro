// ESLint v9 flat config (CommonJS — package.json has no "type":"module")
const js = require('@eslint/js');
const globals = require('globals');
const pluginPromise = require('eslint-plugin-promise');

module.exports = [
  // --- Global ignores (includes this config file itself to avoid self-linting issues) ---
  {
    ignores: [
      'eslint.config.js',
      'node_modules/**',
      'dashboard-dist/**',
      'property-research-suite/**',
      'results/**',
      'coverage/**',
      '.vercel/**',
      'dashboard/dist/**',
      '**/*.min.js',
    ],
  },

  // --- Base: eslint:recommended for all JS files ---
  js.configs.recommended,

  // --- Promise plugin flat/recommended ---
  pluginPromise.configs['flat/recommended'],

  // --- Global defaults (ESM, ES2022) ---
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
    },
    rules: {
      // Downgrade to warn — fire-and-forget patterns are common in this codebase
      'promise/always-return': 'warn',
      'promise/catch-or-return': 'warn',
      // Downgrade to warn — `r` shorthand for resolve is idiomatic in test timeouts
      'promise/param-names': 'warn',
      // Downgrade to warn — fires on intentional ANSI escape regex in pty-runner
      'no-control-regex': 'warn',
      // Downgrade to warn — style noise, not a bug (\? inside character class)
      'no-useless-escape': 'warn',

      // Core rules
      'no-unused-vars': ['warn', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
      'no-empty': 'warn',
      'no-undef': 'error',
    },
  },

  // --- CJS Node files: api/ (except filters.js which uses ESM), worker/ ---
  {
    files: [
      'api/*.js',
      'api/_lib/chat-compute.js',
      'api/_lib/deal-files-handler.js',
      'api/_lib/magic-link.js',
      'api/_lib/magic-link-route.js',
      'api/_lib/paywall.js',
      'api/_lib/posthog.js',
      'api/_lib/progress.js',
      'api/_lib/scan-trigger.js',
      'api/_lib/buy-box-limits.js',
      'worker/**/*.js',
      'emails/**/*.js',
    ],
    languageOptions: {
      sourceType: 'commonjs',
      globals: {
        ...globals.node,
        ...globals.es2022,
        require: 'readonly',
        module: 'readonly',
        exports: 'writable',
        __dirname: 'readonly',
        __filename: 'readonly',
        process: 'readonly',
        Buffer: 'readonly',
        setTimeout: 'readonly',
        clearTimeout: 'readonly',
        setInterval: 'readonly',
        clearInterval: 'readonly',
        console: 'readonly',
      },
    },
  },

  // --- ESM Node files: api/_lib/filters.js, tests/, vite/vitest configs ---
  {
    files: ['api/_lib/filters.js', 'tests/**/*.js', 'vite.config.js', 'vitest.config.js'],
    languageOptions: {
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.es2022,
      },
    },
  },

  // --- Playwright e2e specs: Node + browser globals (page.evaluate runs in browser) ---
  {
    files: ['tests/e2e/**/*.{js,ts}', 'playwright.config.ts'],
    languageOptions: {
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.browser,
        ...globals.es2022,
      },
    },
  },

  // --- Browser JS files: chat, free-scan, scan, dashboard lib ---
  {
    files: ['chat/**/*.js', 'free-scan/**/*.js', 'scan/**/*.js', 'dashboard/src/lib/**/*.js'],
    languageOptions: {
      sourceType: 'module',
      globals: {
        ...globals.browser,
        ...globals.es2022,
      },
    },
  },

  // --- Browser JSX files: dashboard/src (Preact components) ---
  {
    files: ['dashboard/src/**/*.jsx', 'dashboard/src/app.jsx', 'dashboard/src/main.jsx'],
    languageOptions: {
      sourceType: 'module',
      parserOptions: {
        ecmaFeatures: { jsx: true },
      },
      globals: {
        ...globals.browser,
        ...globals.es2022,
      },
    },
  },
];
