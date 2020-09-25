module.exports = {
  env: {
    browser: true,
    commonjs: true,
    es6: true,
  },
  extends: [
    'airbnb-base',
  ],
  globals: {
    Atomics: 'readonly',
    SharedArrayBuffer: 'readonly',
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  rules: {
    'linebreak-style': 'off',
    indent: ['warn', 2],
    'operator-linebreak': ['error', 'after'],
    'no-plusplus': ['error', { allowForLoopAfterthoughts: true }],
    'no-console': false,
  },
};
