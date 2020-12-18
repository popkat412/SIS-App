const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const config = functions.config();
admin.initializeApp(config.firebase);
const db = admin.firestore();

/**
 * Firebase Collection Structure
 *
 * history
 * |---- random document id
 *   |---- dateAdded: Timestamp
 *   |---- userId: String
 *   |---- history (subcollection)
 *     |---- CheckInSession ID
 *       |---- checkedIn: Timestamp
 *       |---- checkedOut: Timestamp
 *       |---- target: String
 *     |---- CheckInSession ID
 *       |---- ...
 *     |---- CheckInSession ID
 *       |---- ...
 * |---- random document id
 *   |---- dateAdded: Timestamp
 *     |---- userId: String
 *     |---- history (subcollection)
 *       |---- CheckInSession ID
 *         |---- ...
 *       |---- CheckInSession ID
 *         |---- ...
 *       |---- CheckInSession ID
 *         |---- ...
 * 
 * otp
 * |---- random document id
 *   |---- dateUsed: Timestamp/nil
 *   |---- isUsed: Bool
 *   |---- otp: String
 * |---- random document id
 *   |---- dateUsed: Timestamp/nil
 *   |---- isUsed: Bool
 *   |---- otp: String
 */


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

/**
 * data for this cloud function should be a string,
 * which is the OTP the user types in
 * 
 * this function should return a bool, which is true if the OTP is valid and false otherwise
 */
/*
exports.checkOTP = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated");
  }

  const snapshot = await db.collection("otp").where("isUsed", "==", false).where("otp", "==", data).get();

  if (snapshot.empty) {
    return false;
  } else if (snapshot.size === 1) {
    return true;
  } else {
    throw new functions.https.HttpsError("internal", "Duplicate OTPs found in database, this is a bug, please contact developers");
  }
})
*/

exports.testFunction = functions.https.onCall((data, context) => {
  console.log("test function");
  return { "status": "ok" };
})