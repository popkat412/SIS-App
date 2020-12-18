import * as functions from 'firebase-functions';
import * as nodemailer from 'nodemailer';
import { Attachment } from 'nodemailer/lib/mailer';

const config = functions.config();

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

async function sendEmail(to: string, subject: string, html: string, attachments: Attachment[]) {
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: config.user_info.user,
      pass: config.user_info.password,
    },
  });


  // send mail with defined transport object
  const info = await transporter.sendMail({
    from: `"RI Tracing" <${config.user_info.user}>`, // sender address
    to: to, // list of receivers
    subject: subject, // Subject line
    html: html,
    attachments: attachments,
  });

  console.log(`Message sent: ${info.messageId}`);

  return info;
}

function formatDate(dateInSeconds: number) {
  const date = new Date(dateInSeconds);
  return date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
}


interface Intersection {
  start: number,
  end: number,
  target: string,
}

export const sendWarningEmail = functions.https.onCall(
  async (data: Intersection[], context) => {
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
      context.auth.token.email!,
      "You have come into contact with somebody who got covid :O",
      formattedBody,
      []
    )
  }
);