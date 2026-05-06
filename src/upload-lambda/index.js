const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const Busboy = require("busboy");
const { v4: uuidv4 } = require("uuid");

const s3 = new S3Client({ region: process.env.AWS_REGION });

const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/gif", "image/webp"];
const MAX_SIZE = 10 * 1024 * 1024;

exports.handler = async (event) => {
    try {
        const contentType = event.headers["content-type"] ||
            event.headers["Content-Type"];

        const { fileBuffer, mimeType, originalName } = await parseMultipart(
            event,
            contentType
        );

        if (!ALLOWED_TYPES.includes(mimeType)) {
            return response(400, {
                error: `Tipo de archivo no permitido. Usa: jpg, png, gif, webp`,
            });
        }

        if (fileBuffer.length > MAX_SIZE) {
            return response(400, { error: "El archivo supera los 10MB" });
        }
        const extension = originalName.split(".").pop();
        const key = `${process.env.UPLOAD_PREFIX}${uuidv4()}.${extension}`;

        await s3.send(
            new PutObjectCommand({
                Bucket: process.env.S3_BUCKET,
                Key: key,
                Body: fileBuffer,
                ContentType: mimeType,
            })
        );

        return response(200, {
            message: "Imagen subida exitosamente",
            key: key,
        });
    } catch (err) {
        console.error("Error en upload-lambda:", err);
        return response(500, { error: "Error interno del servidor" });
    }
};

function parseMultipart(event, contentType) {
    return new Promise((resolve, reject) => {
        const busboy = Busboy({ headers: { "content-type": contentType } });

        let fileBuffer = null;
        let mimeType = null;
        let originalName = "file";

        busboy.on("file", (fieldname, file, info) => {
            mimeType = info.mimeType;
            originalName = info.filename || "file";

            const chunks = [];
            file.on("data", (chunk) => chunks.push(chunk));
            file.on("end", () => {
                fileBuffer = Buffer.concat(chunks);
            });
        });

        busboy.on("finish", () => {
            if (!fileBuffer) return reject(new Error("No se encontró archivo"));
            resolve({ fileBuffer, mimeType, originalName });
        });

        busboy.on("error", reject);

        busboy.write(Buffer.from(event.body, "base64"));
        busboy.end();
    });
}
function response(statusCode, body) {
    return {
        statusCode,
        headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify(body),
    };
}