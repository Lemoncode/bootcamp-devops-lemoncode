import js from "@eslint/js";

export default [
    {
        files: ["eslint.config.js"],
        languageOptions: {
            ecmaVersion: 2021,
            sourceType: "module"
        }
    },
    js.configs.recommended,
    {
        files: ["**/*.js"],
        ignores: ["eslint.config.js"],
        languageOptions: {
            ecmaVersion: 2021,
            sourceType: "module",
            globals: {
                "_": "readonly",
                "console": "readonly"
            }
        },
        rules: {
            // "semi": "error",
            // "quotes": ["error", "double"],
            "no-debugger": "error",
            "no-console": "warn"
        }
    }
];
