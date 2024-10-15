const Db = require('./database');
const Auth = require('./auth');
const Token = require('./token');
const Org = require('./organizations');
const { OpenWeatherAPI } = require("openweather-api-node")

let weather = new OpenWeatherAPI({
    key: "e0b2f331d82894aab2c515cbb5d2cb59",
    units: "metric"
})

var fleetFlightplans = new Db.DatabaseTable("FleetFlightplans",
    "fleetFlightplanId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "date",
        type: "datetime"
        },
        {
        name: "organizationId",
        type: "int"
        },
]);
fleetFlightplans.init();

var fleetCars = new Db.DatabaseTable("FleetCars",
    "fleetCarId",
    [
        {
        name: "licensePlate",
        type: "varchar(64)"
        },
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "model",
        type: "varchar(64)"
        },
]);
fleetCars.init();

var fleetDrivers = new Db.DatabaseTable("FleetDrivers",
    "fleetDriverId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "organizationId",
        type: "int"
        },
]);
fleetDrivers.init();

var fleetLocations = new Db.DatabaseTable("FleetLocations",
    "fleetLocationId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "locationName",
        type: "varchar(511)"
        },
        {
        name: "locationAddress",
        type: "varchar(64)"
        },
        {
        name: "longitude",
        type: "double"
        },
        {
        name: "latitude",
        type: "double"
        },
        {
        name: "subdistrict",
        type: "varchar(511)"
        },
        {
        name: "district",
        type: "varchar(511)"
        },
        {
        name: "province",
        type: "varchar(511)"
        },
]);
fleetLocations.init();

var fleetWaypoints = new Db.DatabaseTable("FleetWaypoints",
    "fleetWaypointId",
    [
        {
        name: "fleetCarId",
        type: "int"
        },
        {
        name: "fleetFlightplanId",
        type: "int"
        },
        {
        name: "fleetLocationId",
        type: "int"
        },
        {
        name: "waypointOrder",
        type: "int"
        },
        {
        name: "remark",
        type: "varchar(1023)"
        },
        {
        name: "timeCheckIn",
        type: "datetime"
        },
        {
        name: "timeCheckOut",
        type: "datetime"
        },
        {
        name: "isCheckedIn",
        type: "bit"
        },
        {
        name: "isCheckedOut",
        type: "bit"
        },
]);
fleetWaypoints.init();

async function parseFlightplan(flightplan) {
    let fw = await fleetWaypoints.select({fleetFlightplanId: flightplan.fleetFlightplanId}, "ORDER BY waypointOrder ASC");
    flightplan.waypoints = [];
    for (let i = 0; i < fw.length; i++) {
        const fleetCarId = fw[i].fleetCarId;
        const fc = await fleetCars.select({fleetCarId: fleetCarId});
        fw[i].licensePlate = fc[0].licensePlate;

        const fleetLocationId = fw[i].fleetLocationId;
        const fl = await fleetLocations.select({fleetLocationId: fleetLocationId});
        fw[i].locationName= fl[0].locationName;
        flightplan.waypoints.push(fw[i]);
    }
}

// get only the active flightplans per user
// this assumes data is SORTED date DESC
function getOnlyLatestFlightplans(data, timezone) {

    let notedDates = {};
    for (let i = 0; i < data.length; i++) {
        let doesNotedDatesIncludeDate = false;
        const userId = data[i].userId;
        const localDate = getLocaleDDMMYYYYFromString(data[i].date.toString(), timezone);
        if (notedDates[userId] === undefined) {
            notedDates[userId] = [];
        }
        for (let j = 0; j < notedDates[userId].length; j++) {
            if (notedDates[userId][j] == localDate) {
                doesNotedDatesIncludeDate = true;
            }
        }
        if (!doesNotedDatesIncludeDate) {
            notedDates[userId].push(localDate)
        } else {
            data.splice(i, 1);
            i--;
        }
    }
}

// takes in a dateString and a midnightString (the datetime when the user is midnight)
// it transforms the dateString to a DDMMYYYY based on the timezone of the midnightString
// returns a Datetime object
function getLocaleDDMMYYYYFromString(dateString, timezone) {
    const date = new Date(Date.parse(dateString));
    const midnight = getYesterdayMidnightFromTimezone(timezone);
    date.setHours(date.getHours() - midnight.getUTCHours())

    const d = date.toISOString().substring(0,10)
    const s = d.split("-");
    const o = `${s[2]}/${s[1]}/${s[0]}`
    return o;
}

// based on the timezone, returns a UTC time of the previous midnight of that timezone
function getYesterdayMidnightFromTimezone(timezone) {
    const d = new Date(new Date().toLocaleDateString('en-KR', { timeZone: timezone, timeZoneName: 'short' } ));
    return d;
}

function assertRealDateString(dateString) {
    const d = Date.parse(dateString)
    if (isNaN(d)) {
        throw {status: 403, message: "invalid date"};
    }
    return dateString;
}

module.exports.getFleetFlightplanFromUser = getFleetFlightplanFromUser;
async function getFleetFlightplanFromUser (userId, timezone) {
    let data = await fleetFlightplans.select({userId: userId}, 'ORDER BY date DESC');

    // get ONLY THE LATEST flightplans
    getOnlyLatestFlightplans(data, timezone);
    return data;
}
module.exports.getFleetFlightplanFromUserToday = getFleetFlightplanFromUserToday;
async function getFleetFlightplanFromUserToday (userId, timezone) {
    // get current date

    d = getYesterdayMidnightFromTimezone(timezone);
    dPlusOneDay = getYesterdayMidnightFromTimezone(timezone);
    dPlusOneDay.setHours(dPlusOneDay.getHours() + 24)
    let data = await fleetFlightplans.select({userId: userId}, `AND date BETWEEN '${d.toISOString()}' AND '${dPlusOneDay.toISOString()}' ORDER BY date DESC`);
    for (let i = 0; i < data.length; i++) {

        await parseFlightplan(data[i]);
    }
    return data;
}

module.exports.getFleetFlightplanFromCarToday = getFleetFlightplanFromCarToday;
async function getFleetFlightplanFromCarToday (fleetCarId) {
    // get current date
    const date_time = new Date();
    const date = ("0" + date_time.getDate()).slice(-2);
    const month = ("0" + (date_time.getMonth() + 1)).slice(-2);
    const year = date_time.getFullYear();

    let data = await fleetWaypoints.select({fleetCarId: fleetCarId}, `AND date >= '${year}/${month}/${date}' ORDER BY date DESC`);
    let notedUserIds = [];
    for (let i = 0; i < data.length; i++) {
        // select if it does not appear in notedUserIds
        // if it is, that means the user has filed multiple flightplans, and we want to select only the most recent one.
        if (!notedUserIds.includes(data[i].userId)) {
            notedUserIds.push(data[i].userId);
        } else {
            data.splice(i, 1);
            i--;
        }
    }
    return data;
}

module.exports.getFleetFlightplans = getFleetFlightplans;
async function getFleetFlightplans (organizationId) {
    return await fleetFlightplans.select({organizationId: organizationId});
}

module.exports.createFleetFlightplan = createFleetFlightplan;
async function createFleetFlightplan (
    token,
    userId,
    organizationId,
) {

    // add lecture
    const fleetFlightplanId = await fleetFlightplans.insertInto({
        userId: userId,
        date: Db.getDatetime(),
        organizationId: organizationId,
    });

    return fleetFlightplanId;
}

module.exports.removeFleetFlightplan = removeFleetFlightplan;
async function removeFleetFlightplan (token, fleetFlightplanId) {
    await fleetFlightplans.deleteFrom(
        {
            fleetFlightplanId: fleetFlightplanId,
        }
    );
}

module.exports.getFleetCars = getFleetCars;
async function getFleetCars (organizationId) {
    // also return how many bookings there are per training
    let cars = await fleetCars.select({organizationId: organizationId});
        /*
    for (let i = 0; i < cars.length; i++) {
        const flightplan = await getFleetFlightplanFromCarToday(cars[i].fleetCarId);
        let todaysDrivers = [];
        let todaysLocationNames = [];
        for (let j = 0; j < flightplan.length; j++) {
            const driverName = await Auth.getUserFromUserId(flightplan[j].userId);
            todaysDrivers.push(`${driverName[0].firstName} ${driverName[0].lastName}`)
            todaysLocationNames.push(flightplan[j].locationNames);
        }
        cars[i].todaysDriver = todaysDrivers.join(", ");
        cars[i].todaysLocationNames = todaysLocationNames.join(", ");
    }
        */
    return cars;
}

module.exports.getFleetCar = getFleetCar;
async function getFleetCar (fleetCarId) {
    // also return how many bookings there are per training
    const car = await fleetCars.select({fleetCarId: fleetCarId});
    return car;
}

module.exports.createFleetCar = createFleetCar;
async function createFleetCar (
    token, organizationId
) {
    // add lecture
    const fleetCar = await fleetCars.insertInto({
        licensePlate: "",
        organizationId: organizationId,
        model: "",
    });

    return fleetCar;
}

module.exports.changeFleetCar = changeFleetCar;
async function changeFleetCar (
    fleetCarId,
    organizationId,
    licensePlate,
    model
) {
    await fleetCars.update(
        {
            fleetCarId: fleetCarId,
        },
        {
            organizationId: organizationId,
            licensePlate: licensePlate,
            model: model
        }
    );
}

module.exports.removeFleetCar = removeFleetCar;
async function removeFleetCar (fleetCarId) {
    await fleetCars.deleteFrom(
        {
            fleetCarId: fleetCarId,
        }
    );
}

module.exports.isUserFleetDriver = isUserFleetDriver
async function isUserFleetDriver(token, organizationId) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    const fd = await fleetDrivers.select({organizationId: organizationId, userId: userId});
    return fd.length > 0;
}

module.exports.getFleetDrivers = getFleetDrivers;
async function getFleetDrivers (organizationId) {
    let fd = await fleetDrivers.select({organizationId: organizationId});
    for (let i = 0; i < fd.length; i++) {
        const user = await Auth.getUserFromUserId(fd[i].userId);
        fd[i].firstName = user[0].firstName;
        fd[i].lastName = user[0].lastName;
        fd[i].email = user[0].email;
    }
    return fd;
}

module.exports.createFleetDriver = createFleetDriver;
async function createFleetDriver (userId, organizationId) {
    let fd = await fleetDrivers.select({userId: userId, organizationId: organizationId});
    if (fd.length > 0) {
        throw {status: 403, message: "already assigned driver to this organization"};
    }
    const fleetDriverId = await fleetDrivers.insertInto({
        userId: userId,
        organizationId: organizationId,
    });

    return fleetDriverId;
}

module.exports.removeFleetDriver = removeFleetDriver;
async function removeFleetDriver (fleetDriverId) {
    await fleetDrivers.deleteFrom({
        fleetDriverId: fleetDriverId,
    });
}

module.exports.getFleetLocations = getFleetLocations;
async function getFleetLocations (organizationId) {
    // also return how many bookings there are per training
    const locs = await fleetLocations.select({organizationId: organizationId});
    return locs;
}

module.exports.getFleetLocation = getFleetLocation;
async function getFleetLocation (fleetLocationId) {
    // also return how many bookings there are per training
    const locs = await fleetLocations.select({fleetLocationId: fleetLocationId});
    return locs;
}

module.exports.createFleetLocation = createFleetLocation;
async function createFleetLocation (
    token, 
    organizationId,
    locationName,
    locationAddress,
    longitude,
    latitude,
    subdistrict,
    district,
    province,
) {
    const fleetLocationId = await fleetLocations.insertInto({
        organizationId: organizationId,
        locationName: locationName,
        locationAddress: locationAddress,
        longitude: longitude,
        latitude: latitude,
        subdistrict: subdistrict,
        district: district,
        province: province,
    });

    return fleetLocationId;
}

module.exports.changeFleetLocation = changeFleetLocation;
async function changeFleetLocation (
    token,
    fleetLocationId,
    locationName,
    locationAddress,
    longitude,
    latitude,
    subdistrict,
    district,
    province,
) {
    await fleetLocations.update(
        {
            fleetLocationId: fleetLocationId,
        },
        {
            locationName: locationName,
            locationAddress: locationAddress,
            longitude: longitude,
            latitude: latitude,
            subdistrict: subdistrict,
            district: district,
            province: province,
        }
    );
}

module.exports.removeFleetLocation = removeFleetLocation;
async function removeFleetLocation (fleetLocationId) {
    await fleetLocations.deleteFrom(
        {
            fleetLocationId: fleetLocationId,
        }
    );
}
module.exports.removeAllFleetLocation = removeAllFleetLocation;
async function removeAllFleetLocation (organizationId) {
    await fleetLocations.deleteFrom(
        {
            organizationId: organizationId,
        }
    );
}

module.exports.getAllWaypointsForOrganization = getAllWaypointsForOrganization;
async function getAllWaypointsForOrganization (
    token,
    organizationId,
    searchDateBegin,
    searchDateEnd,
    timezone,
) {
    assertRealDateString(searchDateBegin);
    assertRealDateString(searchDateEnd);

    const flightplans = await fleetFlightplans.select({organizationId: organizationId}, `AND date BETWEEN '${searchDateBegin}' AND '${searchDateEnd}' ORDER BY date DESC`);
    getOnlyLatestFlightplans(flightplans, timezone);

    let waypoints = [];
    for (let i = 0; i < flightplans.length; i++) {
        const flightplan = flightplans[i];
        const fw = await fleetWaypoints.select({fleetFlightplanId: flightplan.fleetFlightplanId});
        for (let j = 0; j < fw.length; j++) {
            fw[j].date = flightplan.date;
            fw[j].userId = flightplan.userId;
            const user = await Auth.getUserFromUserId(flightplan.userId);
            fw[j].name = `${user[0].firstName} ${user[0].lastName}`;


            const fleetCarId = fw[j].fleetCarId;
            const fc = await fleetCars.select({fleetCarId: fleetCarId});
            fw[j].licensePlate = fc[0].licensePlate;

            const fleetLocationId = fw[j].fleetLocationId;
            const fl = await fleetLocations.select({fleetLocationId: fleetLocationId});
            fw[j].locationName= fl[0].locationName;
            waypoints.push(fw[j]);
        }
    }
    return waypoints;
}

module.exports.createFleetWaypoint = createFleetWaypoint;
async function createFleetWaypoint (
    token, 
    fleetCarId,
    fleetLocationId,
    fleetFlightplanId,
    remark,
    waypointOrder,
) {
    // add lecture
    const fleetWaypointId = await fleetWaypoints.insertInto({
        fleetCarId: fleetCarId,
        fleetLocationId: fleetLocationId,
        fleetFlightplanId: fleetFlightplanId,
        remark: remark,
        timeCheckIn: null,
        timeCheckOut: null,
        isCheckedIn: false,
        isCheckedOut: false,
        waypointOrder: waypointOrder,
    });

    return fleetWaypointId;
}

module.exports.removeFleetWaypoint = removeFleetWaypoint;
async function removeFleetWaypoint (fleetWaypointId) {
    await fleetWaypoints.deleteFrom(
        {
            fleetWaypointId: fleetWaypointId,
        }
    );
}

module.exports.getTodayDrivers = getTodayDrivers;
async function getTodayDrivers (token, organizationId, timezone) {
    let data = {};
    let userIdToName = {};
    let output = [];
    // driver is the KEY of the data object
    // add all drivers to data object
    const drivers = await fleetDrivers.select({organizationId});
    for (let i = 0; i < drivers.length; i++) {
        const userId = drivers[i].userId;
        const user = await Auth.getUserFromUserId(userId);
        data[userId] = [];
        userIdToName[userId] = `${user[0].firstName} ${user[0].lastName}`;
    }

    // populate the data object
    d = getYesterdayMidnightFromTimezone(timezone);
    dPlusOneDay = getYesterdayMidnightFromTimezone(timezone);
    dPlusOneDay.setHours(dPlusOneDay.getHours() + 24)
    const waypoints = await getAllWaypointsForOrganization(token, organizationId, d.toISOString(), dPlusOneDay.toISOString(), timezone);
    for (let i = 0; i < waypoints.length; i++) {
        const waypoint = waypoints[i];
        if (data[waypoint.userId] !== undefined) {
            data[waypoint.userId].push(`${waypoint.locationName} (${waypoint.licensePlate})`);
        }
    }

    // format the data for a StorybridgeTable
    const keys = Object.keys(data);
    let maxItineraryLength = 0;
    for (let i = 0; i < keys.length; i++) {
        const userId = keys[i];
        let element = {};
        element.userId = userId;
        element.name = userIdToName[userId];
        for (let j = 0; j < data[userId].length; j++) {
            element[j.toString()] = data[userId][j];
        }
        if (data[userId].length > maxItineraryLength) {
            maxItineraryLength = data[userId].length;
        }
        output.push(element);
    }
    return {
       data: output,
       maxItineraryLength: maxItineraryLength,
    };
}

module.exports.getTodayCars = getTodayCars;
async function getTodayCars (token, organizationId, timezone) {
    let data = {};
    let fleetCarIdToLicensePlate = {};
    let output = [];
    // driver is the KEY of the data object
    // add all drivers to data object
    const cars= await fleetCars.select({organizationId});
    for (let i = 0; i <cars.length; i++) {
        const fleetCarId =cars[i].fleetCarId;
        data[fleetCarId] = [];
        fleetCarIdToLicensePlate[fleetCarId] = cars[i].licensePlate;
    }

    // populate the data object
    d = getYesterdayMidnightFromTimezone(timezone);
    dPlusOneDay = getYesterdayMidnightFromTimezone(timezone);
    dPlusOneDay.setHours(dPlusOneDay.getHours() + 24)
    const waypoints = await getAllWaypointsForOrganization(token, organizationId, d.toISOString(), dPlusOneDay.toISOString(), timezone);
    for (let i = 0; i < waypoints.length; i++) {
        const waypoint = waypoints[i];
        if (data[waypoint.fleetCarId] !== undefined) {
            data[waypoint.fleetCarId].push(`${waypoint.locationName} (${waypoint.name})`);
        }
    }

    // format the data for a StorybridgeTable
    const keys = Object.keys(data);
    let maxItineraryLength = 0;
    for (let i = 0; i < keys.length; i++) {
        const fleetCarId = keys[i];
        let element = {};
        element.fleetCarId = fleetCarId;
        element.licensePlate = fleetCarIdToLicensePlate[fleetCarId];
        for (let j = 0; j < data[fleetCarId].length; j++) {
            element[j.toString()] = data[fleetCarId][j];
        }
        if (data[fleetCarId].length > maxItineraryLength) {
            maxItineraryLength = data[fleetCarId].length;
        }
        output.push(element);
    }
    return {
       data: output,
       maxItineraryLength: maxItineraryLength,
    };
}

module.exports.forecastWeather = forecastWeather;
async function forecastWeather (token, lat, lon) {
    weather.setLanguage("th");
    weather.setLocationByCoordinates(parseFloat(lat), parseFloat(lon));
    const weatherCurrent = await weather.getCurrent();
    const weatherForceast = await weather.getForecast(5);
    return {
        weatherCurrent: weatherCurrent,
        weatherForecast: weatherForceast,
    }
}
module.exports.forecastWeatherForFleetLocation = forecastWeatherForFleetLocation;
async function forecastWeatherForFleetLocation (token, fleetLocationId) {
    const loc = await fleetLocations.select({fleetLocationId: fleetLocationId});
    const lat = loc[0].latitude;
    const lon = loc[0].longitude;

    weather.setLanguage("th");
    weather.setLocationByCoordinates(parseFloat(lat), parseFloat(lon));
    const weatherCurrent = await weather.getCurrent();
    const weatherForceast = await weather.getForecast(5);
    return {
        weatherCurrent: weatherCurrent,
        weatherForecast: weatherForceast,
    }
}
module.exports.checkinAtLocation = checkinAtLocation;
async function checkinAtLocation (token,myLat,myLon,fleetWaypointId) {
    const waypoint = await fleetWaypoints.select({fleetWaypointId: fleetWaypointId});
    const fleetLocationId = waypoint[0].fleetLocationId;
    const loc = await fleetLocations.select({fleetLocationId: fleetLocationId});
    const lat1 = loc[0].latitude;
    const lon1 = loc[0].longitude;
    const lat2 = myLat;
    const lon2 = myLon;

    // https://stackoverflow.com/a/11172685
    var R = 6378.137; // Radius of earth in KM
    var dLat = lat2 * Math.PI / 180 - lat1 * Math.PI / 180;
    var dLon = lon2 * Math.PI / 180 - lon1 * Math.PI / 180;
    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    var d = R * c; // d is distance in kilometres

    if (d <= 2) {
        await fleetWaypoints.update({fleetWaypointId: fleetWaypointId}, {isCheckedIn: true, timeCheckIn: Db.getDatetime()});
        return `You have succesfully checked in.`;
    } else {
        throw {status: 403, message: `You are too far. You are ${Math.round(d * 100) / 100} km away (maximum 2 km).`};
    }
}