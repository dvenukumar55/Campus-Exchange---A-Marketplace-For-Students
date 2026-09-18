// const nodemailer = require('nodemailer');
// const env = require('../config/env');
// const logger = require('../utils/logger');
// const { EmailDeliveryError } = require('../utils/errors');

// class EmailService {
//   constructor() {
//     this._transporter = null;
//     this._initTransporter();
//   }

//   _initTransporter() {
//     if (env.SMTP_USER && env.SMTP_PASS) {
//       this._transporter = nodemailer.createTransport({
//         host: env.SMTP_HOST || 'smtp.gmail.com',
//         port: env.SMTP_PORT || 465,
//         secure: env.SMTP_SECURE,
//         auth: {
//           user: env.SMTP_USER,
//           pass: env.SMTP_PASS,
//         },
//         family: 4,
//       });
//       logger.info('Gmail SMTP email transport initialized', {
//         host: env.SMTP_HOST || 'smtp.gmail.com',
//         port: env.SMTP_PORT || 465,
//         secure: env.SMTP_SECURE,
//         sender: env.SMTP_USER,
//       });
//     } else {
//       logger.warn('Gmail SMTP credentials (SMTP_USER / SMTP_PASS) not configured. Please set them in server/.env.');
//     }
//   }

//   /**
//    * Sends the 6-digit OTP verification code to the student's institutional email address.
//    * Delivers strictly to the student's entered email. Never logs the raw OTP or credentials.
//    *
//    * @param {string} email - The student's entered email address (recipient)
//    * @param {string} otp - The generated 6-digit OTP
//    */
//   async sendVerificationCode(email, otp) {
//     const cleanEmail = email.trim().toLowerCase();
//     const subject = 'Campus Exchange - Email Verification OTP';

//     const text = `Hello,

// Your Campus Exchange verification OTP is: ${otp}

// This OTP is valid for 5 minutes.

// If you did not request this verification, please ignore this email.

// Regards,
// Campus Exchange Team`;

//     const html = `
//       <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 520px; margin: 0 auto; padding: 24px; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px;">
//         <div style="text-align: center; margin-bottom: 24px;">
//           <h2 style="color: #0f2744; font-size: 22px; font-weight: 800; margin: 0 0 6px 0;">Campus Exchange</h2>
//           <p style="color: #64748b; font-size: 13px; margin: 0;">Institutional Student Verification</p>
//         </div>
//         <p style="color: #334155; font-size: 14px; margin: 0 0 16px 0;">Hello,</p>
//         <p style="color: #334155; font-size: 14px; margin: 0 0 16px 0;">Your Campus Exchange verification OTP is:</p>
//         <div style="background-color: #f8fafc; border: 1px solid #edf2f7; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 20px;">
//           <div style="font-size: 32px; font-weight: 800; letter-spacing: 8px; color: #1e3a8a; font-family: monospace; padding: 12px 20px; background: #ffffff; border: 1px dashed #cbd5e1; border-radius: 8px; display: inline-block;">
//             ${otp}
//           </div>
//           <p style="color: #64748b; font-size: 12px; margin: 12px 0 0 0;">
//             This OTP is valid for <strong>${env.OTP_EXPIRY_MINUTES || 5} minutes</strong>.
//           </p>
//         </div>
//         <p style="color: #64748b; font-size: 13px; line-height: 1.5; margin: 0 0 20px 0;">
//           If you did not request this verification, please ignore this email.
//         </p>
//         <p style="color: #334155; font-size: 13px; line-height: 1.5; margin: 0;">
//           Regards,<br>
//           <strong>Campus Exchange Team</strong>
//         </p>
//       </div>
//     `;

//     // In unit/integration test mode, avoid unmocked external network calls
//     if (process.env.NODE_ENV === 'test') {
//       logger.info('Test environment simulated email dispatch', { recipient: cleanEmail });
//       return { success: true, provider: 'test-mock', recipient: cleanEmail };
//     }

//     // Check if transporter is available
//     if (!this._transporter) {
//       this._initTransporter();
//     }

//     if (!this._transporter) {
//       logger.error('Gmail SMTP is not configured on the server', { recipient: cleanEmail });
//       throw new EmailDeliveryError(
//         'Email service is not configured. Please configure Gmail SMTP credentials (SMTP_USER, SMTP_PASS) in server/.env.'
//       );
//     }

//     const fromAddress = env.SMTP_FROM || `Campus Exchange <${env.SMTP_USER}>`;

//     try {
//       logger.info('OTP email sending started via Gmail SMTP', {
//         recipient: cleanEmail,
//         from: fromAddress,
//       });

//       const info = await this._transporter.sendMail({
//         from: fromAddress,
//         to: cleanEmail,
//         subject,
//         text,
//         html,
//       });

//       logger.info('OTP email sent successfully via Gmail SMTP', {
//         recipient: cleanEmail,
//         messageId: info.messageId,
//       });

//       return {
//         success: true,
//         provider: 'gmail-smtp',
//         messageId: info.messageId,
//       };
//     } catch (smtpErr) {
//       logger.error('Gmail SMTP email delivery failed', {
//         recipient: cleanEmail,
//         error: smtpErr.message,
//       });
//       throw new EmailDeliveryError(`Gmail SMTP email delivery failed: ${smtpErr.message}`);
//     }
//   }
// }

// module.exports = new EmailService();




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
          <p style="color: #64748b; font-size: 13px;">Student Verification</p>
        </div>

        <p style="color: #334155;">Hello,</p>

        <p style="color: #334155;">
          Your Campus Exchange verification OTP is:
        </p>

        <div style="background: #f8fafc; border: 1px solid #edf2f7; border-radius: 12px; padding: 20px; text-align: center;">
          <div style="font-size: 32px; font-weight: 800; letter-spacing: 8px; color: #1e3a8a; font-family: monospace; padding: 12px 20px; background: #ffffff; border: 1px dashed #cbd5e1; border-radius: 8px; display: inline-block;">
            ${otp}
          </div>

          <p style="color: #64748b; font-size: 12px;">
            This OTP is valid for <strong>${env.OTP_EXPIRY_MINUTES || 5} minutes</strong>.
          </p>
        </div>

        <p style="color: #64748b; font-size: 13px; margin-top: 20px;">
          If you did not request this verification, please ignore this email.
        </p>

        <p style="color: #334155; font-size: 13px;">
          Regards,<br>
          <strong>Campus Exchange Team</strong>
        </p>
      </div>
    `;

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

    const apiKey = process.env.RESEND_API_KEY;

    if (!apiKey) {
      logger.error('RESEND_API_KEY is not configured', {
        recipient: cleanEmail,
      });

      throw new EmailDeliveryError(
        'Email service is not configured. Please configure RESEND_API_KEY.'
      );
    }

    try {
      logger.info('OTP email sending started via Resend', {
        recipient: cleanEmail,
      });

      const response = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: 'Campus Exchange <onboarding@resend.dev>',
          to: [cleanEmail],
          subject,
          text,
          html,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || `Resend API error: ${response.status}`);
      }

      logger.info('OTP email sent successfully via Resend', {
        recipient: cleanEmail,
        messageId: data.id,
      });

      return {
        success: true,
        provider: 'resend',
        messageId: data.id,
      };
    } catch (err) {
      logger.error('Resend email delivery failed', {
        recipient: cleanEmail,
        error: err.message,
      });

      throw new EmailDeliveryError(
        `Resend email delivery failed: ${err.message}`
      );
    }
  }
}

module.exports = new EmailService();