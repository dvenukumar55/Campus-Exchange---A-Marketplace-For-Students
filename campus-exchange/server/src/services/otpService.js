const crypto = require('crypto');

class OtpService {
  generateOtp() {
    return crypto.randomInt(100000, 1000000).toString();
  }

  hashOtp(otp) {
    return crypto
      .createHash('sha256')
      .update(otp)
      .digest('hex');
  }

  getExpiry() {
    return new Date(Date.now() + 10 * 60 * 1000);
  }

  verifyOtp(otp, storedHash, expiresAt) {
    if (!otp || !storedHash || !expiresAt) {
      return false;
    }

    if (new Date(expiresAt).getTime() < Date.now()) {
      return false;
    }

    return this.hashOtp(otp) === storedHash;
  }
}

module.exports = new OtpService();