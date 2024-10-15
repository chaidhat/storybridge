require('dotenv').config({ path: `../.env.${process.env.NODE_ENV}` });
const fs = require('fs');
const path = require('path');

const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
const ffmpeg = require('fluent-ffmpeg');
ffmpeg.setFfmpegPath(ffmpegPath);

process.on('message', (msg) => {
    const uncompressedFilePath = msg.filePath;
    const compressedFilePath = `${process.env.CONTENT_DATA_PATH}${path.basename(msg.filePath)}`;

    try { 
        fs.existsSync(uncompressedFilePath);
    } catch (err) {
        //file does not exist
        console.error(err);
        process.send({'status': 500});
        process.exit(1);
    }

    //compress the file
    let totalCompressTime;
    // disabled the ffmpeg compression because our server ain't powerful enough to handle compression :(
    // this does NOT DO COMPRESSION.
    // this essentially copies the uncompressed video to the compressed video dir. 
    fs.copyFile(uncompressedFilePath, compressedFilePath, (err) => {
        if (err) {
            //failed to copy uncompressed video
            console.error(err);
            process.send({'status': 500});
            process.exit(1);
        } 

        // this is copied from the successful exit from the ffmpeg exit
        console.log(`Successfully compressed (but didn't actually) video to ${compressedFilePath}`);
        //delete uncompressed video
        fs.unlink(uncompressedFilePath, (err) => {
            if (err) {
                //failed to delete uncompressed video
                console.error(err);
                process.send({'status': 500});
                process.exit(1);
            }
            
            process.send({'status': 200});
            process.exit(0);
        });
    });
    /*
    // todo: should this be at 60 fps?
    ffmpeg(uncompressedFilePath).fps(60).addOptions(["-preset ultrafast", "-tune fastdecode", "-crf 22", "-c:v libx265", "-b:v 900k", "-c:a aac", "-b:a 96k"])
        .on("start", () => {
            console.log(`Compressing video at ${uncompressedFilePath}...`);
        })
        .on("codecData", codecData => {
            totalCompressTime = parseFloat(codecData.duration.replace(/:/g, ''));
        })
        .on("progress", progress => {
            const compressionStatus = (parseFloat(progress.timemark.replace(/:/g, '')) / totalCompressTime);
            process.send({'compressionStatus': compressionStatus});
        })
        .on("end", () => {
            console.log(`Successfully compressed video to ${compressedFilePath}`);
            //delete uncompressed video
            fs.unlink(uncompressedFilePath, (err) => {
                if (err) {
                    //failed to delete uncompressed video
                    console.error(err);
                    process.send({'status': 500});
                    process.exit(1);
                } else {
                    process.send({'status': 200});
                    process.exit(0);
                }
            });
        })
        .on("error", err => {
            console.log(`Failed to compress video to ${compressedFilePath}`);
            console.error(err);
            process.send({'status': 500});
            process.exit(1);
        })
        .save(compressedFilePath)
        */
    ;
});