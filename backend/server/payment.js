require('dotenv').config({ path: `../.env.${process.env.NODE_ENV}` });

// This is your test secret API key.
const stripe = require('stripe')(process.env.STRIPE_API_KEY);
const endpointSecret = process.env.STRIPE_ENDPOINT_SECRET;
const Org = require('./organizations');
const Courses = require('./courses');
const Auth = require('./auth');
const Db = require('./database');
const Mail = require('./mail');

const CC = require('currency-converter-lt');
let currencyConverter = new CC();

/*
list_all_currencies();
async function list_all_currencies() {

  const countrySpec = await stripe.countrySpecs.retrieve(
    'TH'
  );
  list = "[";
  for (i = 0; i < countrySpec.supported_payment_currencies.length; i++) {
    list = list + '"' + countrySpec.supported_payment_currencies[i] + '"';
    if (i !== countrySpec.supported_payment_currencies.length - 1) {
      list = list + ',';
    }
  }
  list = list + "]";
  console.log(list);
}
*/
var payments = new Db.DatabaseTable("Payments",
    "paymentId",
    [
        {
        name: "stripePaymentIntentId",
        type: "int"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "withdrawalId",
        type: "int"
        },
        {
        name: "paidAmount",
        type: "int"
        },
        {
        name: "paidNet",
        type: "int"
        },
        {
        name: "paidCurrencyCode",
        type: "varchar(4)"
        },
]);
payments.init();

var withdrawals = new Db.DatabaseTable("Withdrawals",
    "withdrawalId",
    [
        {
        name: "dateRequested",
        type: "datetime"
        },
        {
        name: "datePaidOut",
        type: "datetime"
        },
        {
        name: "organizationIdCreditor",
        type: "int"
        },
        {
        name: "data",
        type: "mediumtext"
        },
]);
withdrawals.init();

async function l() {
    /*
    const account = await stripe.accounts.create({
        type: 'standard',
        business_type: 'individual',
        email: 'jenny.rosen@example.com',
      });
      */
      /*
      const accountLink = await stripe.accountLinks.create({
        account: 'acct_1NghNlHGqqE7Xw0g',
        refresh_url: 'https://example.com/reauth',
        return_url: 'https://example.com/return',
        type: 'account_update',
      });
      console.log(accountLink);
    const paymentIntentId = "pi_3NgAOwHO7q6kHiMa1P1tVvLW";
    const data = await payments.select();
    console.log(data);
    */
}

const enumPaymentTiers = Object.freeze({
    basicTier: 0,
    expandTier: 1,
    businessTier: 2,
    enterpriseTier: 3,
    noTier: 4,
});
const enumPaymentTierProductId = Object.freeze({
    basicTier: "prod_ObJ1X8nX2EfIwZ",
    expandTier: "prod_O8gZxHNacIK6H7",
    businessTier: "prod_O8zgaaRBccEZtb",
    enterpriseTier: "prod_O93F5sig77rfAi",
});
const enumPaymentTierPriceId = Object.freeze({
    0: "price_1Nt4NYHO7q6kHiMaFHh06p5l",
    1: "price_1NoL6yHO7q6kHiMaRH7dLUXl",
    2: "price_1No6NQHO7q6kHiMas1k6lzkM",
    3: "price_1NMl9FHO7q6kHiMaTYpK6DeX",
});

module.exports.updateStripeCustomer = updateStripeCustomer;
async function updateStripeCustomer(orgId, organizationOptions) {
    let org = await Org.getOrganization(orgId);
    let stripeCustomerId = org[0].stripeCustomerId;

    // create a customer with Stripe if none exists
    if (stripeCustomerId === undefined || stripeCustomerId === null) {
        return;
    }

    let stripeCustomer = {};
    if (organizationOptions.organizationName !== undefined) {
        stripeCustomer.name = organizationOptions.organizationName;
    }
    if (organizationOptions.email !== undefined) {
        stripeCustomer.email = organizationOptions.email;
    }

    await stripe.customers.update(
        stripeCustomerId,
        stripeCustomer
    );
}

module.exports.createStripeSubscription = createStripeSubscription;
async function createStripeSubscription(token, orgId, plan, currency) {
    // check user accessing this has privileges
    let userPrivileges = await Org.getOrgUserPrivilege(token, orgId);
    let userIsAdmin = Db.readBool(userPrivileges.isAdmin);
    if (!userIsAdmin) {
        throw "assigner has insufficient permission to manage billings (must be admin)";
    }

    let org = await Org.getOrganization(orgId);
    let email = org[0].email;
    if (email === undefined || email === null || email === "") {
        //throw new Error("organization must define email!");
        email = "";
    }
    let stripeCustomerId = org[0].stripeCustomerId;

    // create a customer with Stripe if none exists
    if (stripeCustomerId === undefined || stripeCustomerId === null) {
        const customer = await stripe.customers.create({
            name: decodeURI(org[0].organizationName),
            email: email, // TODO: set org email here
        });
        stripeCustomerId = customer.id;
        await Org.setOrganizationStripeCustomerId(orgId, stripeCustomerId);
    }

    let priceId = enumPaymentTierPriceId[parseInt(plan)];
    if (priceId == null) {
        throw new Error(`I don't recognize this payment tier: ${priceId}`)
    }

    if (currency !== "inr" && currency !== "thb" && currency !== "usd") {
        throw new Error(`Invalid currency: ${currency}`)
    }

    // create subscription
    if (parseInt(plan) === 0) {
        // this is a free tier subscription, so no cost
        try {
            const subscription = await stripe.subscriptions.create({
                customer: stripeCustomerId,
                items: [{
                    price: priceId,
                }],
            });

            return {
                subscriptionId: subscription.id,
                clientSecret: null,
            };
        } catch (error) {
            console.log(error);
            throw {status: 403, message: error };
        }
    } else {
        // this is a paid tier subscription, so we want payment details
        try {
            const subscription = await stripe.subscriptions.create({
                customer: stripeCustomerId,
                items: [{
                    price: priceId,
                }],
                payment_behavior: 'default_incomplete',
                payment_settings: { save_default_payment_method: 'on_subscription' },
                trial_period_days: 14,
                currency: currency,
                expand: ['pending_setup_intent'],
            });

            return {
                subscriptionId: subscription.id,
                clientSecret: subscription.pending_setup_intent.client_secret,
            };
        } catch (error) {
            throw {status: 403, message: error };
        }
    }
};

module.exports.getCheckoutSessionUrl = getCheckoutSessionUrl;
async function getCheckoutSessionUrl(token, orgId, plan) {
    // check user accessing this has privileges
    let userPrivileges = await Org.getOrgUserPrivilege(token, orgId);
    let userIsAdmin = Db.readBool(userPrivileges.isAdmin);
    if (!userIsAdmin) {
        throw "assigner has insufficient permission to manage billings (must be admin)";
    }

    let org = await Org.getOrganization(orgId);
    let email = org[0].email;
    if (email === undefined || email === null || email === "") {
        //throw new Error("organization must define email!");
        email = "";
    }
    let stripeCustomerId = org[0].stripeCustomerId;

    // create a customer with Stripe if none exists
    if (stripeCustomerId === undefined || stripeCustomerId === null) {
        const customer = await stripe.customers.create({
            name: decodeURI(org[0].organizationName),
            email: email, // TODO: set org email here
        });
        stripeCustomerId = customer.id;
        await Org.setOrganizationStripeCustomerId(orgId, stripeCustomerId);
    }

    let priceId = enumPaymentTierPriceId[parseInt(plan)];
    if (priceId == null) {
        throw new Error(`I don't recognize this payment tier! ${priceId}`)
    }

    // ensure that organization does NOT already have a subscription
    const subscriptions = await stripe.subscriptions.list({
        customer: stripeCustomerId,
    });
    if (subscriptions.data.length !== 0) {
        return { "isValid": false, "url": "" };
        // this means that org already has a subscription, and should NOT check out a new product until that is gone.
    }

    // create the checkout session
    const session = await stripe.checkout.sessions.create({
        mode: 'subscription',
        customer: stripeCustomerId,
        line_items: [
            {
                price: priceId,
                // For metered billing, do not pass quantity
                quantity: 1,
            },
        ],
        // {CHECKOUT_SESSION_ID} is a string literal; do not change it!
        // the actual Session ID is returned in the query parameter when your customer
        // is redirected to the success page.
        success_url: 'https://www.Storybridge.io/app/#/login',
        cancel_url: 'https://Storybridge.io',

        subscription_data: {
            trial_period_days: 14,
        }
    });
    return { "isValid": true, "url": session.url };

}

module.exports.getCheckoutSessionUrlCourse = getCheckoutSessionUrlCourse;
async function getCheckoutSessionUrlCourse(token, courseId) {
    let authData = await Auth.getUserFromToken(token);
    if (authData.length == 0) {
        // no user exists
        return { "isValid": false, "url": "" };
    }

    let stripeCustomerId = authData[0].stripeCustomerId;

    // create a customer with Stripe if none exists
    if (stripeCustomerId == null) {
        const customer = await stripe.customers.create({
            name: decodeURI(authData[0].firstName + " " + authData[0].lastName),
            email: authData[0].email,
        });
        stripeCustomerId = customer.id;
        await Auth.setUserStripeCustomerId(token, stripeCustomerId);
    }

    let courseData = await Courses.getCourse(courseId);
    if (courseData[0].stripeProductId == null) {
        // course does not have a productId hence it must be free
        return { "isValid": false, "url": "" };
    } else {
        const product = await stripe.products.retrieve(
            courseData[0].stripeProductId
        );
        try {
            const session = await stripe.checkout.sessions.create({
                mode: "payment",
            customer: stripeCustomerId,
                line_items: [
                    {
                        price: product.default_price,
                        // For metered billing, do not pass quantity
                        quantity: 1,
                    },
                ],
                // {CHECKOUT_SESSION_ID} is a string literal; do not change it!
                // the actual Session ID is returned in the query parameter when your customer
                // is redirected to the success page.
                success_url: 'https://Storybridge.io',
                cancel_url: 'https://Storybridge.io',
            });
            return { "isValid": true, "url": session.url };
        } catch (e) {
            console.log(e);
            return { "isValid": false, "url": "" };
        }
    }
}

module.exports.getPortalSessionUrl = getPortalSessionUrl;
async function getPortalSessionUrl(token, orgId) {
    // check user accessing this has privileges
    let userPrivileges = await Org.getOrgUserPrivilege(token, orgId);
    let userIsAdmin = Db.readBool(userPrivileges.isAdmin);
    if (!userIsAdmin) {
        throw "assigner has insufficient permission to manage billings (must be admin)";
    }

    let org = await Org.getOrganization(orgId);
    let stripeCustomerId = org[0].stripeCustomerId;

    // create a customer with Stripe if none exists
    if (stripeCustomerId === undefined || stripeCustomerId === null) {
        const customer = await stripe.customers.create({
            name: decodeURI(org[0].organizationName),
            email: org[0].email,
        });
        stripeCustomerId = customer.id;
        await Org.setOrganizationStripeCustomerId(orgId, stripeCustomerId);
    }

    const session = await stripe.billingPortal.sessions.create({
        configuration: "bpc_1NMP7THO7q6kHiMaFqWPesro",
        customer: stripeCustomerId,
        return_url: 'https://Storybridge.io/',
    });
    return { "url": session.url };
}

// returns the payment tier the customer has
module.exports.getOrgSubscriptionTier = getOrgSubscriptionTier;
async function getOrgSubscriptionTier(orgId) {
    let org = await Org.getOrganization(orgId);
    let stripeCustomerId = org[0].stripeCustomerId;

    // create a customer with Stripe if none exists
    if (stripeCustomerId === undefined || stripeCustomerId === null) {
        return enumPaymentTiers.noTier; // user has no stripe account hence on free tier
    }
    const subscriptions = await stripe.subscriptions.list({
        customer: stripeCustomerId,
    });
    if (subscriptions.data.length === 0) {
        return enumPaymentTiers.noTier; // user has no subscriptions hence on free tier
    }
    // get the product id which the customer is subscribed to
    let productId = subscriptions.data[0].items.data[0].price.product;
    switch (productId) {
        case enumPaymentTierProductId.basicTier:
            return enumPaymentTiers.basicTier;
        case enumPaymentTierProductId.expandTier:
            return enumPaymentTiers.expandTier;
        case enumPaymentTierProductId.businessTier:
            return enumPaymentTiers.businessTier;
        case enumPaymentTierProductId.enterpriseTier:
            return enumPaymentTiers.enterpriseTier;
        default:
            throw new Error(`I don't recognize this stripe product id! ${productId}`);
    }

}

module.exports.handlePaymentWebhook = handlePaymentWebhook;
async function handlePaymentWebhook(req, res) {
    let event = req.body;
    // Only verify the event if you have an endpoint secret defined.
    // Otherwise use the basic event deserialized with JSON.parse
    if (endpointSecret) {
        // Get the signature sent by Stripe
        const signature = req.headers['stripe-signature'];
        try {
            event = stripe.webhooks.constructEvent(
                req.body,
                signature,
                endpointSecret
            );
        } catch (err) {
            console.log(`⚠️  Webhook signature verification failed.`, err.message);
            return res.sendStatus(400);
        }
    }

    let paymentIntent;
    console.log("copy webhook " + event.type);
    // Handle the event
    switch (event.type) {
        case 'payment_intent.succeeded':
            paymentIntent = event.data.object;
            handleSuccessfulCoursePayment(paymentIntent.id);
            console.log(`PaymentIntent for ${paymentIntent.amount} was successful!`);
            // Then define and call a method to handle the successful payment intent.
            // handlePaymentIntentSucceeded(paymentIntent);
            break;
        case 'payment_intent.created':
            console.log("payment created");
            paymentIntent = event.data.object;
            console.log(`PaymentIntent for ${paymentIntent.amount} was created!`);
            // Then define and call a method to handle the successful payment intent.
            // handlePaymentIntentSucceeded(paymentIntent);
            break;
        case 'customer_cash_balance_transaction.created':
            const balanceTransaction = event.data.object;
            console.log(balanceTransaction);
        default:
            // Unexpected event type
            console.log(`Unhandled event type ${event.type}.`);
    }

    // Return a 200 response to acknowledge receipt of the event
    res.send();
}

// this handles creating a subscription from a successful payment id
// step 1: extract what product is being bought & customer who bought it from paymentIntent
// step 2: create a Payment object to store the payment
// step 3: create a CourseSubscription object to grant the user access to the course
async function handleSuccessfulCoursePayment(paymentIntentId) {
    // step 1: extract what product is being bought & customer who bought it from paymentIntent

    // first, get the payment intent object with the latest charge's balance transaction (includes net amount paid)
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId, {expand: ['latest_charge.balance_transaction']});
    let stripeCustomerId = paymentIntent.customer;

    // extract the session object issued to the user from the payment intent 
    const sessions = await stripe.checkout.sessions.list({
        payment_intent: paymentIntentId
      });
    if (sessions.data.length !== 1) { console.log("warning: session.length !== 1"); } // not good
    // extract the line items from the session
    const lineItems = await stripe.checkout.sessions.listLineItems(
        sessions.data[0].id,
        { limit: 2 }
    );
    if (lineItems.data.length !== 1) { console.log("warning: lineItems.length !== 1"); } // not good
    // we can now get the productId from this line item
    let stripeProductId = lineItems.data[0].price.product;

    // get the user linked to the stripe customer id
    let userData = await Auth.getUserFromStripeCustomerId(stripeCustomerId);
    if (userData.length !== 1) { console.log("warning: userData.length !== 1"); } // not good
    let userId = userData[0].userId;
    let userToken = userData[0].token;

    // get the course linked to the stripe product id
    let courseData = await Courses.getCourseFromPayment(stripeProductId, userId);
    if (courseData.length !== 1) { console.log("warning: courseData.length !== 1"); } // not good
    let courseId = courseData[0].courseId;

    // step 2: create a Payment object to store the payment
    let paymentId = await payments.insertInto({
        stripePaymentIntentId: paymentIntentId,
        //datePaidOut: null,
        //userIdCreditor: null,
       dateCreated: Db.getDatetime(),
       paidAmount: paymentIntent.latest_charge.balance_transaction.amount,
       paidNet: paymentIntent.latest_charge.balance_transaction.net,
       paidCurrencyCode: paymentIntent.latest_charge.balance_transaction.currency,
    })

    // step 3: create a CourseSubscription object to grant the user access to the course
    await Courses.subscribeToCourse(userToken, courseId, paymentId);
}

module.exports.getCourseSalesSettings = getCourseSalesSettings;
async function getCourseSalesSettings(token, courseId) {
    // TODO: do authentication
    let courseData = await Courses.getCourse(courseId);
    if (courseData[0].stripeProductId == null) {
        return {
            coursePrice: 0,
            coursePriceCurrencyCode: "",
            courseProductName: decodeURI(courseData[0].courseName),
            courseProductDescription: "",
            checkoutSessionUrl: {isValid: false, url: ""},
        }
    } else {
        const product = await stripe.products.retrieve(
            courseData[0].stripeProductId
        );
        const price = await stripe.prices.retrieve(
            product.default_price
        );
        let checkoutSessionUrl = await getCheckoutSessionUrlCourse(token, courseId);
        return {
            coursePrice: price.unit_amount,
            coursePriceCurrencyCode: price.currency,
            courseProductName: product.name,
            courseProductDescription: product.description != null ? product.description : "",
            checkoutSessionUrl: checkoutSessionUrl,
        }
    }
}

module.exports.changeCourseSalesSettings = changeCourseSalesSettings;
async function changeCourseSalesSettings(token, courseId, courseSalesSettings) {
    // TODO: do authentication
    let courseData = await Courses.getCourse(courseId);
    var productId = courseData[0].stripeProductId;
    if (productId == null) {
        // create a stripe product
        const product = await stripe.products.create({
            name: decodeURI(courseData[0].courseName),
        });
        productId = product.id;
        await Courses.changeCourseOptions(token, courseId, { stripeProductId: productId });
    }

    if (courseSalesSettings.coursePrice != null || courseSalesSettings.coursePriceCurrencyCode != null) {
        console.log("creating new price");

        // enclose in try catch as if there is a failure in exchangeRates API, we don't fail.
        let courseUsdPrice = 0;
        try {
            courseUsdPrice = await currencyConverter.from(courseSalesSettings.coursePriceCurrencyCode.toUpperCase())
                .to("USD")
                .amount(
                    courseSalesSettings.coursePrice / 100
                ).convert();
        } catch (e) {
            console.log(e);
        }

        if (courseUsdPrice < 1 && courseUsdPrice !== 0) {
            throw {status: 403, message: "course price too low"};
        }
        if (courseUsdPrice > 1000) {
            throw {status: 403, message: "course price too high"};
        }

        const price = await stripe.prices.create({
            product: productId,
            unit_amount: courseSalesSettings.coursePrice,
            currency: courseSalesSettings.coursePriceCurrencyCode,
        });
        // TODO: validate price using checkout (if cannot create checkout, then it's bad)
        await stripe.products.update(
            productId,
            { default_price: price.id }
        );
    }
    if (courseSalesSettings.courseProductName != null) {
        await stripe.products.update(
            productId,
            { name : courseSalesSettings.courseProductName }
        );
    }
    if (courseSalesSettings.courseProductDescription != null) {
        await stripe.products.update(
            productId,
            { description : courseSalesSettings.courseProductDescription }
        );
    }
}

module.exports.subscribeToCourse = subscribeToCourse;
async function subscribeToCourse(token, courseId) {
    // this is executed from the clientside only if it thinks that the course is free.
    // confirm that this is infact true.
    let courseData = await Courses.getCourse(courseId);
    if (courseData[0].stripeProductId == null) {
        // no stripe product id exists for this course -- this means that the course is FREE
        // this is executed once the user has paid and can DEFINITELY access the course
        await Courses.subscribeToCourse(token, courseId);
    } else {
        // check that the price is zero.
        const product = await stripe.products.retrieve(
            courseData[0].stripeProductId
        );
        const price = await stripe.prices.retrieve(
            product.default_price
        );
        if (price.unit_amount === 0) {
            // this is executed once the user has paid and can DEFINITELY access the course
            await Courses.subscribeToCourse(token, courseId);
        }
    }
}

module.exports.getCourseSalesHistory = getCourseSalesHistory;
async function getCourseSalesHistory(token, courseId) {
    let students = await Courses.getAllStudentsForCourse(token, courseId);
    let output = [];
    for (let i = 0; i < students.length; i++) {
        let paymentId = students[i].paymentId;
        if (paymentId !== null) {
            let payment = (await payments.select({paymentId: paymentId}))[0];
            output.push(
            {
                email: students[i].userData.email,
                dateCreated: payment.dateCreated,
                isWithdrawn: payment.withdrawalId != null,
                paidAmount: payment.paidAmount,
                paidNet: payment.paidNet,
                paidCurrencyCode: payment.paidCurrencyCode,
            });
        }
    }
    return output;
}

module.exports.getOrganizationBalance = getOrganizationBalance;
async function getOrganizationBalance(token, organizationId) {
    let courses = await Courses.getCoursesForOrganization(token, organizationId);

    let output = [];
    let grossRevenue = {}; // map of currency codes to value in that currency
    let netRevenue = {}; // map of currency codes to value in that currency
    let netBalance = {}; // map of currency codes to value in that currency
    for (let i = 0; i < courses.length; i++) {
        let grossRevenuePerCourse = {}; // map of currency codes to value in that currency
        let netRevenuePerCourse = {}; // map of currency codes to value in that currency
        let courseSalesHistory = await getCourseSalesHistory(token, courses[i].courseId);
        for (let j = 0; j < courseSalesHistory.length; j++) {
            let courseSaleHistoryObj = courseSalesHistory[j];
            let currency = courseSaleHistoryObj.paidCurrencyCode;

            // initialize the currency if not already
            if (grossRevenue[currency] == null)  {
                grossRevenue[currency] = 0;
            }
            if (netRevenue[currency] == null)  {
                netRevenue[currency] = 0;
            }
            if (grossRevenuePerCourse[currency] == null)  {
                grossRevenuePerCourse[currency] = 0;
            }
            if (netRevenuePerCourse[currency] == null)  {
                netRevenuePerCourse[currency] = 0;
            }

            grossRevenue[currency] += courseSaleHistoryObj.paidAmount;
            netRevenue[currency] += courseSaleHistoryObj.paidNet;
            grossRevenuePerCourse[currency] += courseSaleHistoryObj.paidAmount;
            netRevenuePerCourse[currency] += courseSaleHistoryObj.paidNet;

            if (!courseSaleHistoryObj.isWithdrawn) {
                if (netBalance[currency] == null)  {
                    netBalance[currency] = 0;
                }
                netBalance[currency] += courseSaleHistoryObj.paidNet;
            }
        }
        output.push({
            courseId: courses[i].courseId,
            courseName: courses[i].courseName,
            grossRevenue: grossRevenuePerCourse,
            netRevenue: netRevenuePerCourse,
        });
    }
    return {
        grossRevenue: grossRevenue,
        netRevenue: netRevenue,
        netBalance: netBalance,
        breakdown: output,
    };
}

module.exports.createWithdrawal = createWithdrawal;
async function createWithdrawal(token, organizationId, withdrawalData) {
    // authentication check
    await Org.getOrgUserPrivilege(token, organizationId);

    // check if there is already a pending withdrawal
    let existingWithdrawals = await withdrawals.select({
        organizationIdCreditor: organizationId,
        datePaidOut: null
    });
    for (let i = 0; i < existingWithdrawals.length; i++) {
        if (existingWithdrawals[i].datePaidOut === null) {
            throw {status: 403, message: "cannot create withdrawal because there is already a pending withdrawal"};
        }
    }

    // create withdrawal
    let withdrawal = await withdrawals.insertInto({
        dateRequested: Db.getDatetime(),
        //datePaidOut: null,
        organizationIdCreditor: organizationId,
        data: withdrawalData, // no data yet
    });

    // email alert about the withdrawal
    let withdrawalDataParsed = JSON.parse(withdrawalData);
    Mail.sendMail(withdrawalDataParsed.contactEmail, "Storybridge Withdrawal Request", 
    `Thank you for submitting a withdrawal request! Our sales team will get back to you as soon as possible to process your request. Please note it may take up to 1-3 business days.\n\nYour requested account type: ${withdrawalDataParsed.accountType}\n\nStorybridge Sales Team`);

    return withdrawal;
}

module.exports.getWithdrawals = getWithdrawals;
async function getWithdrawals(token, organizationId) {
    let data = await withdrawals.select({organizationIdCreditor: organizationId});
    for (let i = 0; i < data.length; i++) {
        let withdrawalId = data[i].withdrawalId;
        let ps = await payments.select({withdrawalId: withdrawalId});
        let netWithdrawn = {}; // map of currency codes to value in that currency
        for (let j = 0; j < ps.length; j++) {
            let currency = ps[j].paidCurrencyCode;
            if (netWithdrawn[currency] == null)  {
                netWithdrawn[currency] = 0;
            }
            netWithdrawn[currency] += ps[j].paidNet;
        }
        data[i].netWithdrawn = netWithdrawn;
    }
    return data;
}

// WARNING: THIS IS AN ADMIN ONLY FUNCTION, SHOULD NOT BE EXECUTED BY USER
async function issueWithdrawal(token, withdrawalId) {
    await withdrawals.update({withdrawalId: withdrawalId}, {
        datePaidOut: Db.getDatetime(),
    });
    let organizationId = (await withdrawals.select({withdrawalId: withdrawalId}))[0].organizationIdCreditor;
    let courses = await Courses.getCoursesForOrganization(token, organizationId);
    for (let i = 0; i < courses.length; i++) {
        let students = await Courses.getAllStudentsForCourse(token, courses[i].courseId);
        for (let i = 0; i < students.length; i++) {
            let paymentId = students[i].paymentId;
            if (paymentId !== null) {
                let payment = (await payments.select({paymentId: paymentId}))[0];
                // withdraw fund which exist only
                if (payment.withdrawalId == null) {
                    payments.update({paymentId: paymentId}, {
                        withdrawalId: withdrawalId,
                    });
                }
            }
        }
    }
}

// WARNING: THIS IS AN ADMIN ONLY FUNCTION, SHOULD NOT BE EXECUTED BY USER
async function undoWithdrawal(token, withdrawalId) {
    await withdrawals.update({withdrawalId: withdrawalId}, {
        datePaidOut: null,
    });
    await payments.update({withdrawalId: withdrawalId}, {
        withdrawalId: null
    });
}