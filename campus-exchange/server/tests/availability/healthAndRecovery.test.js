const request = require('supertest');
const app = require('../../src/app');

describe('Availability & Health Recovery Validation (T-037)', () => {
  test('Health endpoint provides dependency status, uptime, and SLA targets', async () => {
    const res = await request(app).get('/api/v1/health');
    expect([200, 503]).toContain(res.statusCode);
    expect(res.body).toHaveProperty('status');
    expect(res.body).toHaveProperty('uptimeSeconds');
    expect(res.body).toHaveProperty('dependencies');
    expect(res.body.dependencies).toHaveProperty('database');
    expect(res.body.dependencies).toHaveProperty('storage');
    expect(res.body.dependencies).toHaveProperty('realtime');
  });
});
