import type { Config } from '@jest/types';

const config: Config.InitialOptions = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    verbose: true,
    collectCoverage: true,
    coverageDirectory: 'coverage',
    coverageProvider: 'v8',
    roots: ['src'],
    testMatch: ['**/tests/unit/**/*.spec.+(ts|tsx)'],
    transform: {
        '^.+\\.(ts|tsx)$': 'ts-jest'
    }
};
export default config;