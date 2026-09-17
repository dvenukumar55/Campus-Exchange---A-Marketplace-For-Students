const request = require('supertest');
const app = require('../../src/app');
const env = require('../../src/config/env');

describe('Performance Validation: Normal User Action Latency Benchmark (T-036)', () => {
  test('Health & Public metadata endpoint responds well under 3-second SLA (target <= 3000ms)', async () => {
    const start = Date.now();
    const res = await request(app).get('/api/v1/health');
    const duration = Date.now() - start;

    expect(duration).toBeLessThanOrEqual(env.TARGET_RESPONSE_TIME_MS);
    expect([200, 503]).toContain(res.statusCode);
  });

  test('Latency tracking headers (X-Request-Id) attached to responses', async () => {
    const res = await request(app).get('/api/v1/health');
    expect(res.headers['x-request-id']).toBeDefined();
  });
});
