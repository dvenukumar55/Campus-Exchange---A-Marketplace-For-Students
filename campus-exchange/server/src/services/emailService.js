const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API_KEY);

class EmailService {
  async sendVerificationCode(email, otp) {
    const { data, error } = await resend.emails.send({
      from: process.env.EMAIL_FROM || 'onboarding@resend.dev',
      to: [email],
      subject: 'Campus Exchange Verification Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto;">
          <h2>Campus Exchange</h2>
          <p>Your student verification code is:</p>

          <div style="
            font-size: 32px;
            font-weight: bold;
            letter-spacing: 8px;
            padding: 20px;
            text-align: center;
            background: #f1f5f9;
            border-radius: 10px;
          ">
            ${otp}
          </div>

          <p>This code expires in <strong>10 minutes</strong>.</p>

          <p style="color: #64748b;">
            If you did not request this code, you can safely ignore this email.
          </p>
        </div>
      `,
    });

    if (error) {
      throw new Error(`Email delivery failed: ${error.message}`);
    }

    return data;
  }
}

module.exports = new EmailService();