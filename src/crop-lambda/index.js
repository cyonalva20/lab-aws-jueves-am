const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3");
const { SQSClient, DeleteMessageCommand } = require("@aws-sdk/client-sqs");
const sharp = require("sharp");

const s3 = new S3Client({ region: process.env.AWS_REGION });
const sqs = new SQSClient({ region: process.env.AWS_REGION });

const CIRCLE_MASK = Buffer.from(
    `<svg viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg">
    <circle cx="20" cy="20" r="20"/>
  </svg>`
);

exports.handler = async (event) => {

    const results = await Promise.allSettled(
        event.Records.map((record) => processRecord(record))
    );

    const failures = results
        .map((result, index) => ({ result, record: event.Records[index] }))
        .filter(({ result }) => result.status === "rejected")
        .map(({ record }) => ({ itemIdentifier: record.messageId }));

    return { batchItemFailures: failures };
};

async function processRecord(record) {
    const s3Event = JSON.parse(record.body);
    const s3Record = s3Event.Records[0];
    const sourceKey = decodeURIComponent(
        s3Record.s3.object.key.replace(/\+/g, " ")
    );
    const bucket = s3Record.s3.bucket.name;

    console.log(`Procesando imagen: ${sourceKey}`);

    const getCommand = new GetObjectCommand({ Bucket: bucket, Key: sourceKey });
    const s3Response = await s3.send(getCommand);

    const imageBuffer = await streamToBuffer(s3Response.Body);

    const processedBuffer = await sharp(imageBuffer)
        .resize(40, 40, { fit: "cover" })
        .composite([
            {
                input: CIRCLE_MASK,
                blend: "dest-in",
            },
        ])
        .png()
        .toBuffer();

    const filename = sourceKey.split("/").pop().split(".")[0];
    const destKey = `${process.env.PROCESSED_PREFIX}${filename}_circular.png`;
    await s3.send(
        new PutObjectCommand({
            Bucket: bucket,
            Key: destKey,
            Body: processedBuffer,
            ContentType: "image/png",
        })
    );

    console.log(`Imagen procesada y guardada en: ${destKey}`);
}

function streamToBuffer(stream) {
    return new Promise((resolve, reject) => {
        const chunks = [];
        stream.on("data", (chunk) => chunks.push(chunk));
        stream.on("end", () => resolve(Buffer.concat(chunks)));
        stream.on("error", reject);
    });
}