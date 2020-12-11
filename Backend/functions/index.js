const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const config = functions.config();


/**
 * 
 * @param {string} to 
 * @param {string} subject 
 * @param {string} text 
 * @param {array} attachments 
 * 
 * @returns {object}
 */
async function sendEmail(to, subject, html, attachments) {
  let transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: config.user_info.user,
      pass: config.user_info.password,
    },
  });


  // send mail with defined transport object
  let info = await transporter.sendMail({
    from: `"RI Tracing" <${config.user_info.user}>`, // sender address
    to: to, // list of receivers
    subject: subject, // Subject line
    html: html,
    attachments: attachments
  });

  console.log(`Message sent: ${info.messageId}`);

  return info;
}

/**
 * 
 * @param {number} dateInSeconds
 * 
 * @returns {string}
 */
function formatDate(dateInSeconds) {
  const date = new Date(dateInSeconds);
  return date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
}

/**
 * data for this cloud function should be a array
 * which contains CheckInSessions of where the user has been to
 */
exports.sendConfirmationEmail = functions.https.onCall(async (data, context) => {
  console.log(`data: ${data}`);
  if (!context.auth) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated");
  }


  await sendEmail(
    "wangyunze412@gmail.com",
    "Somebody got Covid :O",
    `<p>Please confirm that ${context.auth.token.email} should be able to upload their data.<p>`,
    [
      {
        filename: "user_data.json",
        content: JSON.stringify({
          user: context.auth.token.email,
          history: data,
        }),
        contentType: "text/plain",
      }
    ]
  );

  return { "test": "ok" };
})

/**
 * data for this cloud function should be a array of Intersections:
 * 
 * Intersection:
 * |--> start: Date
 * |--> end: Date
 * |--> target: String
 */
exports.sendWarningEmail = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated");
  }

  console.dir(data, { depth: null });

  let formattedBody = "<p>You have come into contact with the infected person at the following locations:</p>";
  formattedBody += "<ul>";
  data.forEach(dateInterval => {
    formattedBody += `<li>${formatDate(dateInterval.start)} - ${formatDate(dateInterval.end)}, at ${dateInterval.target}</li>`;
  });
  formattedBody += "</ul>";

  return sendEmail(
    context.auth.token.email,
    "You have come into contact with somebody who got covid :O",
    formattedBody,
    []
  )
})

exports.testFunction = functions.https.onCall((data, context) => {
  console.log("test function");
  return { "status": "ok" };
})