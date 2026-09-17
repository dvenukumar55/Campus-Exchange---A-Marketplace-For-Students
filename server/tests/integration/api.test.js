const request = require('supertest');
const app = require('../../src/app');

describe('Integration Test: API Base & Health (T-002, T-030, T-033)', () => {
  test('GET / returns API baseline status', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.service).toBe('Campus Exchange API');
  });

  test('GET /api/v1/health returns health metadata adhering to PRISM-S', async () => {
    const res = await request(app).get('/api/v1/health');
    expect([200, 503]).toContain(res.statusCode);
    expect(res.body).toHaveProperty('service', 'campus-exchange-api');
    expect(res.body).toHaveProperty('targets');
    expect(res.body.targets).toHaveProperty('slaAvailabilityTarget');
    expect(res.body.targets).toHaveProperty('maxResponseTimeTarget');
  });

  test('GET /unknown-route returns structured 404 error adhering to PRISM standard', async () => {
    const res = await request(app).get('/api/v1/non_existent_route');
    expect(res.statusCode).toBe(404);
    expect(res.body).toHaveProperty('error');
    expect(res.body.error).toHaveProperty('code');
    expect(res.body.error).toHaveProperty('message');
    expect(res.body.error).toHaveProperty('requestId');
  });
});
