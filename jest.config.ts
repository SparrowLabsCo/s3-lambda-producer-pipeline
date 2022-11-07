import type { Config } from '@jest/types';

const config: Config.InitialOptions = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    verbose: true,
    collectCoverage: true,
    coverageDirectory: 'coverage',
    coverageProvider: 'v8',
    coveragePathIgnorePatterns: [
        "node_modules",
        "test-config",
        "interfaces",
        "jestGlobalMocks.ts",
        ".module.ts",
        "<rootDir>/src/tests",
        ".mock.ts"
    ],
    roots: ['functions'],
    testMatch: ['**/tests/unit/**/*.spec.+(ts|tsx)'],
    transform: {
        '^.+\\.(ts|tsx)$': 'ts-jest'
    }
};
export default config;