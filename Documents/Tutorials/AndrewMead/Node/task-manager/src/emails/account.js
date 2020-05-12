const sgMail = require('@sendgrid/mail');

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// sgMail.send({
//   to: 'dqsignup@gmail.com',
//   from: 'dqsignup@gmail.com',
//   subject: 'First email from Node / SendGrid',
//   text: 'I hope this works.',
// });

const sendWelcomeEmail = (email, name) => {
  sgMail.send({
    to: email,
    from: 'dqsignup@gmail.com',
    subject: 'Welcome!',
    text: `Hello ${name}. \n Let me know how you get along with the app.`,
  });
};

const sendCancellationEmail = (email, name) => {
  sgMail.send({
    to: email,
    from: 'dqsignup@gmail.com',
    subject: 'Cancellation Confirmation',
    text: `Goodbye ${name}, we're sorry to see you go. \n We're always here for you in the future.`,
  });
};

module.exports = { sendWelcomeEmail, sendCancellationEmail };
