const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const config = functions.config();

// TODO: Verify user auth
exports.sendEmail = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated")
  }

  let transporter = nodemailer.createTransport({
    host: 'smtp.office365.com',
    port: 587,
    secure: false,
    auth: {
      user: config.user_info.user,
      pass: config.user_info.password,
    },
    tls: {
      ciphers: 'SSLv3'
    },
    requireTLS: true,
  });

  // send mail with defined transport object
  let info = await transporter.sendMail({
    from: `"Raffles Tracing" <${config.user_info.user}>`, // sender address
    to: "wangyunze412@gmail.com", // list of receivers
    subject: "Testing", // Subject line
    text: `Please confirm that ${context.auth.token.email} should be able to upload their data.`,
    attachments: [
      {
        filename: "user_data.json",
        content: JSON.stringify({
          user: context.auth.token.email,
          data: data,
        }),
        contentType: "text/plain",
      }
    ]
  });

  console.log("Message sent: %s", info.messageId);

})

