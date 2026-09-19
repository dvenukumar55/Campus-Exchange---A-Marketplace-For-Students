const env = require('../config/env');
const logger = require('../utils/logger');
const { EmailDeliveryError } = require('../utils/errors');

class EmailService {
  async sendVerificationCode(email, otp) {
    const cleanEmail = email.trim().toLowerCase();

    const subject = 'Campus Exchange - Email Verification OTP';

    const text = `Hello,

Your Campus Exchange verification OTP is: ${otp}

This OTP is valid for ${env.OTP_EXPIRY_MINUTES || 5} minutes.

If you did not request this verification, please ignore this email.

Regards,
Campus Exchange Team`;

    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 520px; margin: 0 auto; padding: 24px; background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px;">
        <div style="text-align: center; margin-bottom: 24px;">
          <h2 style="color: #0f2744;">Campus Exchange</h2>
          <p style="color: #64748b;">Student Email Verification</p>
        </div>

        <p style="color: #334155;">Hello,</p>

        <p style="color: #334155;">
          Your Campus Exchange verification OTP is:
        </p>

        <div style="text-align: center; margin: 24px 0;">
          <div style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #1e3a8a; padding: 16px; border: 1px dashed #cbd5e1; border-radius: 8px;">
            ${otp}
          </div>
        </div>

        <p style="color: #64748b;">
          This OTP is valid for <strong>${env.OTP_EXPIRY_MINUTES || 5} minutes</strong>.
        </p>

        <p style="color: #64748b;">
          If you did not request this verification, please ignore this email.
        </p>

        <p style="color: #334155;">
          Regards,<br>
          <strong>Campus Exchange Team</strong>
        </p>
      </div>
    `;

    // Test environment
    if (process.env.NODE_ENV === 'test') {
      logger.info('Test environment simulated email dispatch', {
        recipient: cleanEmail,
      });

      return {
        success: true,
        provider: 'test-mock',
        recipient: cleanEmail,
      };
    }

    // Check Brevo configuration
    if (!env.BREVO_API_KEY || !env.BREVO_FROM_EMAIL) {
      logger.error('Brevo email configuration is missing', {
        recipient: cleanEmail,
      });

      throw new EmailDeliveryError(
        'Email service is not configured. Please configure BREVO_API_KEY and BREVO_FROM_EMAIL.'
      );
    }

    try {
      logger.info('OTP email sending started via Brevo', {
        recipient: cleanEmail,
      });

      const response = await fetch('https://api.brevo.com/v3/smtp/email', {
        method: 'POST',
        headers: {
          accept: 'application/json',
          'api-key': env.BREVO_API_KEY,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          sender: {
            name: env.BREVO_FROM_NAME || 'Campus Exchange',
            email: env.BREVO_FROM_EMAIL,
          },
          to: [
            {
              email: cleanEmail,
            },
          ],
          subject,
          textContent: text,
          htmlContent: html,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(
          data.message || `Brevo API error: ${response.status}`
        );
      }

      logger.info('OTP email sent successfully via Brevo', {
        recipient: cleanEmail,
        messageId: data.messageId,
      });

      return {
        success: true,
        provider: 'brevo',
        messageId: data.messageId,
      };
    } catch (err) {
      logger.error('Brevo email delivery failed', {
        recipient: cleanEmail,
        error: err.message,
      });

      throw new EmailDeliveryError(
        `Brevo email delivery failed: ${err.message}`
      );
    }
  }
}

module.exports = new EmailService();