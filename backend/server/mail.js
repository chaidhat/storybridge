require('dotenv').config({ path: `../.env.${process.env.NODE_ENV}` });

const nodemailer = require('nodemailer')

// set up nodemailer
const transporter = nodemailer.createTransport({
  host: process.env.MAIL_HOST,
  port: process.env.MAIL_PORT, // must be 587 for gmail
  auth: {
    user: process.env.MAIL_USERNAME,
    pass: process.env.MAIL_PASSWORD
  }
})

// transporter.sendEmail is asychronous so let's wrap it in async function
const sendEmail = async (mailOptions) => {
  const { from, to, subject, text, cc } = mailOptions
  
  await transporter.sendMail({
    from,
    to,
    subject,
    text,
    cc,
  })
}

module.exports.sendMail = sendMail;
async function sendMail(to, subject, text) {
    const mailOptions = {
        from: process.env.MAIL_USERNAME,
        cc: process.env.MAIL_USERNAME,
        to: to,
        subject: subject,
        text: text
    };

    sendEmail(mailOptions);
}

module.exports.submitContactForm = submitContactForm;
async function submitContactForm(response, contactFormDataStr) {
    let contactFormData = JSON.parse(contactFormDataStr);
    if (contactFormData.email === "") {
        response.status(403);
        response.json({"message": "Please enter your contact email."});
        return;
    }
    var validRegex = /^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+/;
    if (!contactFormData.email.match(validRegex)) {
        response.status(403);
        response.json({"message": "Please enter a valid email."});
        return;
    }
    if (contactFormData.name === "") {
        response.status(403);
        response.json({"message": "Please enter your name"});
        return;
    }
    if (contactFormData.message === "") {
        response.status(403);
        response.json({"message": "Please enter a message."});
        return;
    }

    // success
    const mailOptions = {
        from: process.env.MAIL_USERNAME,
        cc: process.env.MAIL_USERNAME,
        to: contactFormData.email,
        subject: "Storybridge: Thank you for contacting us",
        text: `Dear ${contactFormData.name},\n\nThank you very much for contacting us. Your input means a lot to us. We will try to get back to you within 1-3 business days.\n\nYour Message:\n${contactFormData.message}`
    };

    sendEmail(mailOptions);
    response.status(200).send();
}