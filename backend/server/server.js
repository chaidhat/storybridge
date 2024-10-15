// if no node environment is declared, use production
if (process.env.NODE_ENV === undefined) {
  process.env.NODE_ENV = "production";
}

function heartbeat() {
  //console.log("heartbeat");
  fetch('https://hc-ping.com/14069ed9-59b0-4d1c-befb-31af9f9fba24');
}

const fetch = require('node-fetch')
// do a ten minute ping to health check server
setInterval(heartbeat, 60 * 1000);
heartbeat();

require('dotenv').config({ path: `../.env.${process.env.NODE_ENV}` });
main();
async function migrate() {
  const rl = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
  });

  const response = await new Promise(resolve => {
    rl.question(`Press Y/y to migrate the ${process.env.NODE_ENV} database or any other character to cancel`, resolve);
  });
  rl.close();

  if (response == 'Y' || response == 'y') {
    //Database migration code here
    console.log('Migrating database...');
    console.log('No database migration code, please add some and try again');
    console.log('Starting server normally');
    //await require('./db-migration/update-pass-encryption').migratePasswords();
  } else {
    console.log('Aborted database migration, starting up server normally');
  }
}

async function main() {
  try {
    if (Boolean(process.env.MIGRATE) == true) await migrate();

    const express = require('express');
    // for parsing post requests
    const bodyParser = require('body-parser');
    var jsonParser = bodyParser.json();

    // start the application server via Express library
    const app = express();   // setup Express
    const port = process.env.EXPRESS_PORT;

    // override CORS policy of Chrome
    const cors = require('cors');
    app.use(cors());
    app.use(express.static('public')); // for Stripe

    // for payment system
    app.post('/webhook', express.raw({type: 'application/json'}), (request, response) => {
      Payment.handlePaymentWebhook(request, response);
    });

    app.use(express.json({limit: '10gb'}));
    const Route = require('./route');
    const Payment = require('./payment');
    const Analytics = require('./analytics');
    const Mail = require('./mail');
    const VideoData = require("./videoData");

    // for saving camera pictures (since they can't be uplaoded using normal contentServerUpload() methods)
    const multer = require('multer');
    const storage = multer.diskStorage({
        destination: process.env.CONTENT_DATA_PATH,
        filename: (req, file, cb) => {
            console.log(file);
            console.log(process.env.CONTENT_DATA_PATH);
            const contentDataId = file.originalname;
        cb(null,  `${contentDataId}.mp4`);
        }
    })
    const multerUpload = multer({ storage: storage })
    // for saving camera pictures (since they can't be uplaoded using normal contentServerUpload() methods)

    /*
    STATUS CODES used in this project:
    200 - OK
    400 - bad request   client error (e.g., misspelt query/ not enough privilege)
    403 - forbidden     user error (e.g., incorrect password) a message is provided via json
    500 - server error  server error (really bad day)
    */

    // this is called everytime a request is GET'ted at localhost
    app.get('/', function (request, response) { // call a function where request and response are arguments
      const action = request.query.action;
      if (action === undefined) {
        response.status(200);
        response.json({message: "Server is healthy. Define an action in the URL query to make me do stuff! Contact chaidhatchaimongkol@gmail.com for support."})
        return;
      }
      let router = new Route.Router(request, response);
      router.parse(action);
    });

    app.get('/analytics-trigger1', function (request, response) {
      Analytics.triggerAnalyticsEvent(2, 0, request.query.analyticsData);
      response.status(200).send();
    });
    app.get('/analytics-trigger2', function (request, response) {
      Analytics.triggerAnalyticsEvent(3, 0, request.query.analyticsData);
      response.status(200).send();
    });
    app.get('/analytics-trigger3', function (request, response) {
      Analytics.triggerAnalyticsEvent(4, 0, request.query.analyticsData);
      response.status(200).send();
    });
    app.get('/submit-contact-form', function (request, response) {
      Mail.submitContactForm(response, request.query.contactFormData);
    });

    // this is called everytime a request is POST'ed at localhost
    app.post('/',jsonParser, function (request, response) { // call a function where request and response are arguments
      var action = request.body.action;
      // if no action is found in body
      if (action === undefined) {
        // try the queries
        action = request.query.action;

        // if STILL no action
        if (action === undefined) {

          console.log("no action found");
          response.status(200);
          response.json({message: "Server is healthy. Define an action in the URL query to make me do stuff! Contact chaidhatchaimongkol@gmail.com for support."})
          return;
        }
      }
      //console.log(action);
      let router = new Route.Router(request, response);
      router.parse(action);
    });
    
    // for saving camera pictures (since they can't be uplaoded using normal contentServerUpload() methods)
    app.post('/upload', multerUpload.single('file'), (req, res) => {
        try {
            res.status(200).json({ success: "file upload successful" })
        } catch (error) {
            res.status(500).json({ error: error })
        }
    })
    // for saving camera pictures (since they can't be uplaoded using normal contentServerUpload() methods)

    app.listen(port, (error) => {
      if (error) { console.log("server errored: " + error); }
      console.log("server started at " + (new Date()).toLocaleString("en-US", { timeZone: "Asia/Bangkok" }));
    });
  } catch (error) {
      console.log("server errored: " + error);
      console.log(error.stack);
  }
}
