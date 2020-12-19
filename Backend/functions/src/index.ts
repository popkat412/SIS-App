import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';
import { Attachment } from 'nodemailer/lib/mailer';
import * as randomstring from 'randomstring';

const config = functions.config();
admin.initializeApp();
const db = admin.firestore();

interface SendEmailConfig {
  to: string,
  subject: string,
  body: string,
  attachments?: Attachment[]
}

async function sendEmail(emailConfig: SendEmailConfig) {
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
    to: emailConfig.to, // list of receivers
    subject: emailConfig.subject, // Subject line
    html: emailConfig.body,
    attachments: emailConfig.attachments,
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

    return sendEmail({
      to: context.auth.token.email!,
      subject: "You have come into contact with somebody who got covid :O",
      body: formattedBody,
    });
  }
);

// * NOTE: This doesn't check to see if the same key has already been generated.
// *       We think that it is not necessary because checking is a lot of work
// *       and we are generating so little that the chances of collisions are really low.
function _generateOTPs(count: number): string[] {
  const res: string[] = [];

  for (let i = 0; i < count; i++) {
    res.push(randomstring.generate({
      readable: true,
      length: 10,
      charset: "ABCDEFGHIJKLMNOPQRSTUVTXYZabcdefghijklmnopqrstuvwzyz1234567890!@#$%^&*()",
    }));
  }

  return res;
}

export const generateOTPs = functions.firestore
  .document("otp/{otpId}")
  .onUpdate(async (change, context) => {
    if ((await db.collection("otp").where("isUsed", "==", false).get()).empty) {
      // Generate more OTPs
      const otps = _generateOTPs(20);

      // Write to Firestore
      const batch = db.batch();
      for (const otp of otps) {
        batch.create(db.collection("otp").doc(), {
          "otp": otp,
          "isUsed": false,
          "dateUsed": null,
        });
      }
      await batch.commit();

      // Send email
      let message = `
      <p>Dear Sir/Mdm,</p>

      <p>You are receiving this email either because the OTPs (one time password) for RI Tracing have run out, or this is the first time you're receiving this email.</p>
      
      <p>As a recap, the procedure for RI Tracing is that in the case that somebody contracts Covid-19, the school will contact the student with one of the OTPs for the student to upload their data.</p>

      <p>The new OTPs are as follows. Please keep them private as anybody with a valid OTP can upload their data.</p>

      `;

      message += "<ul>";
      for (const otp of otps) {
        message += `<li>${otp}</li>\n`;
      }
      message += "</ul>";

      await sendEmail({
        to: config.person_in_charge.email,
        subject: "RI Tracing - New one time passwords",
        body: message,
      });
    }
  });