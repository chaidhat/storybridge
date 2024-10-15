require('dotenv').config({ path: `../.env.${process.env.NODE_ENV}` });
const fs = require('fs');

const { fork } = require('child_process');
const multer = require('multer');
const path = require('path');
const formidable = require('formidable');

const CourseElements = require('./courseElements');
const Videos = require("./videos");

let compressionProgress = new Map();

const { readdir } = require('fs/promises');
async function filePathByName(path, fileName) {
    let matches = [];
    for (const file of await readdir(path)) {
        if (file.startsWith(fileName)) matches.push(file);
    }

    if(matches.size > 1) return null;
    return path + matches[0];
}

module.exports.downloadVideo = downloadVideo;
async function downloadVideo(router) {
    // TODO: auth check if ID & token can work  
    let contentDataId = router.request.query.contentDataId;

    try {
        console.log("downloading");
        const path = await filePathByName(process.env.CONTENT_DATA_PATH, contentDataId);
        const stat = fs.statSync(path);
        const fileSize = stat.size;
        const range = router.request.headers.range;
        if (range) {
            const parts = range.replace(/bytes=/, "").split("-")
            const start = parseInt(parts[0], 10);
            const end = parts[1] 
                ? parseInt(parts[1], 10)
                : fileSize-1;
            const chunksize = (end-start)+1;
            const file = fs.createReadStream(path, {start, end});
            const head = {
                'Content-Range': `bytes ${start}-${end}/${fileSize}`,
                'Accept-Ranges': 'bytes',
                'Content-Length': chunksize,
                'Content-Type': 'video/mp4',
            }
            router.response.writeHead(206, head);
            file.pipe(router.response);
        } else {
            const head = {
                'Content-Length': fileSize,
                'Content-Type': 'video/mp4',
            }
            router.response.writeHead(200, head);
            fs.createReadStream(path).pipe(router.response);
        }
    } catch (err) {
        console.log("FATAL: could not find video");
        router.response.json({"message": "error"});
        return;
    }
}

module.exports.downloadImage = downloadImage;
async function downloadImage(router) {
    // TODO: auth check if ID & token can work
    let contentDataId = router.request.query.contentDataId;

    try {
        console.log("downloading");
        const path = await filePathByName(process.env.CONTENT_DATA_PATH, contentDataId);

        // https://www.geeksforgeeks.org/how-to-fetch-images-from-node-js-server/
        // Setting default Content-Type
        const ext = await Videos.getImageExtension(contentDataId);
        switch (ext) {
            case "pdf":
                var contentType = "application/pdf";
                break;
            default:
                var contentType = "text/plain";
                break;
        }
        // Setting the headers
        router.response.writeHead(200, {
            "Content-Type": contentType
        });
        // Reading the file
        fs.readFile(path,
            function (err, content) {
                // Serving the image
                router.response.end(content);
            }
        );
    } catch (err) {
        console.log("FATAL: could not find image");
        console.log(err);
        router.response.json({"message": "error"});
        return;``
    }
}

//NOTE: EVENTUALLY THESE EXTENSIONS SHOULD BE MOVED TO ALSO BE USED IN THE FRONTEND (uploading_widget)
const supported_video_exts = [
    'mp4', 'm4v',
    'mkv', 'flv',
    'ogv', 'mov',
    'qt', 'wmv',
    'mpg', 'mpeg',
    'm2v', 'mpv'
];
const supported_img_exts = [
    'png', 'jpg',
    'jpeg', 'jpe',
    'gif', 'webp',
    'tiff', 'raw',
    'heif', 'heic',
    'jp2',

    'pdf' // this is !
];    
module.exports.uploadContent = uploadContent;
async function uploadContent(router) {
    // TODO: check if ID is valid
    let contentDataId = router.request.query.contentDataId;
    await Videos.updateUploadingVideo(contentDataId, true);

    const fileExt = router.request.query.fileExt;
    let isVideo = false;
    if(supported_video_exts.includes(fileExt)) {
        isVideo = true;
    } else if (!supported_img_exts.includes(fileExt)) {
        // we are accepting all img exts for images
        /*
        console.error('File extension not supported, aborting upload');
        router.response.sendStatus(500);
        return;
        */
    } 

    Videos.setImageExtension(contentDataId, fileExt);

    var form = new formidable.IncomingForm();
    form.parse(router.request, function (err, fields, files) {
        if (err) console.error(err);

        var oldpath = files.file[0].filepath;
        var newpath = ((isVideo) ? process.env.TMP_PATH : process.env.CONTENT_DATA_PATH) 
            + files.file[0].originalFilename;
        // open destination file for appending
        var w = fs.createWriteStream(newpath, {flags: 'a'});
        // open source file for reading
        var r = fs.createReadStream(oldpath);

        w.on('close', function() {
            router.response.write('');
            router.response.end();
        });

        r.pipe(w);
    });
}

module.exports.doneUploadContent =
async router => {
    const contentDataId = router.request.query.contentDataId;
    if (supported_video_exts.includes(router.request.query.fileExt)) {
        //compress the video from the temp folder
        const child = fork('compression.js');
        child.send({
            filePath: await filePathByName(process.env.TMP_PATH, contentDataId)
        });

        child.on("message", msg => {
            if (msg.status == 200) {
                //Sucessfully compressed video
                Videos.updateUploadingVideo(contentDataId, false);  
                router.response.sendStatus(200);
            }
            else if (msg.status == 500) {
                //Failed to compress video
                Videos.updateUploadingVideo(contentDataId, false);
                router.response.sendStatus(500);
            }
            else if (msg.compressionStatus != null) {
                //Still compressing
                compressionProgress.set(contentDataId, msg.compressionStatus.toFixed(2));
                console.log(`Compression status: ${msg.compressionStatus.toFixed(2) * 100}%`);
            }
        });
    } else {
        //Not a video, don't compress
        Videos.updateUploadingVideo(contentDataId, false);  
        router.response.sendStatus(200);
    }
}

module.exports.getCompressionStatus = 
contentDataId => {
    if (!compressionProgress.has(contentDataId))
        return {"compressionStatus": "0"};
    return {"compressionStatus": String(compressionProgress.get(contentDataId))};
}

module.exports.removeVideo = removeVideo;
async function removeVideo(contentDataId) {
    fs.unlinkSync(await filePathByName(process.env.CONTENT_DATA_PATH, contentDataId));
}

module.exports.removeImg = removeImg;
async function removeImg(contentDataId) {
    console.log(`deleting image ${contentDataId}`);
    fs.unlinkSync(await filePathByName(process.env.CONTENT_DATA_PATH, contentDataId));
}

// returns in MB
module.exports.getFileSize = getFileSize;
async function getFileSize(contentDataId) {
    const path = await filePathByName(process.env.CONTENT_DATA_PATH, contentDataId);
    try {
        const stats = fs.statSync(path)
        const fileSizeInBytes = stats.size;
        return fileSizeInBytes / (1024*1024);
    } catch (e) {
        return 0;
    }
}
