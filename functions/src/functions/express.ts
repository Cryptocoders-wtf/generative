import express from "express";
import * as admin from "firebase-admin";
import * as xmlbuilder from "xmlbuilder";
import * as fs from "fs";

import * as Sentry from "@sentry/node";
// set up rate limiter: maximum of five requests per minute
import rateLimit from "express-rate-limit";

export const app = express();
export const router = express.Router();

const LocalConfig = {
  hostName: "nft.fullyonchain.xyz",
  siteName: "p2psea(temporary)",
  title: "TBD",
  siteDescription: "description",
}

var limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minutes
  max: 10, // Limit each IP to 10 requests per `window` 1 min
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// apply rate limiter to all requests
app.use(limiter);

// for test, db is not immutable
if (!admin.apps.length) {
  admin.initializeApp();
}


export const logger = async (req, res, next) => {
  next();
};
export const hello_response = async (req, res) => {
  res.json({ message: "hello" });
};


export const sitemap_response = async (req, res) => {
  try {
    const urlset = xmlbuilder
      .create("urlset")
      .att("xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9");

    const xml = urlset.dec("1.0", "UTF-8").end({ pretty: true });
    res.setHeader("Content-Type", "text/xml");
    res.send(xml);
  } catch (e) {
    console.error(e);
    Sentry.captureException(e);
    return res.status(500).end();
  }
};

const escapeHtml = (str: string): string => {
  if (typeof str !== "string") {
    return "";
  }
  const mapping: any = {
    "&": "&amp;",
    "'": "&#x27;",
    "`": "&#x60;",
    '"': "&quot;",
    "<": "&lt;",
    ">": "&gt;",
  };
  return str.replace(/[&'`"<>]/g, function (match) {
    return mapping[match];
  });
};

const isId = (id: string) => {
  return /^[a-zA-Z0-9-]+$/.test(id);
};

const ogpPage = async (req: any, res: any) => {
  const { contract,token_id } = req.params;
  console.log(contract, token_id);
  const template_data = fs.readFileSync("./templates/index.html", {
    encoding: "utf8",
  });
  try {
    if (!isId(token_id)) {
      console.error(`isId ${token_id} failed`);
      return res.status(404).send(template_data);
    }

    const siteName = LocalConfig.siteName;
    const title =  LocalConfig.title;
    const description = LocalConfig.siteDescription;
    const regexTitle = /<title.*title>/;
    const url = `https://${LocalConfig.hostName}/token/image/${escapeHtml(contract)}/${escapeHtml(token_id)}`;

    const metas = [
      `<title>${escapeHtml(title)}</title>`,
      `<meta data-n-head="1" charset="utf-8">`,
      `<meta data-n-head="1" name="viewport" content="width=device-width,initial-scale=1">`,
      `<meta name="description" content="${escapeHtml(description)}"/>`,
      `<meta property="og:title" content="${escapeHtml(title)}" />`,
      `<meta property="og:site_name" content="${escapeHtml(siteName)}" />`,
      `<meta property="og:type" content="website" />`,
      `<meta property="og:url" content="${url}" />`,
      `<meta property="og:description" content="${escapeHtml(description)}" />`,
      `<meta property="og:image" content="${image}" />`,
      `<meta name="twitter:card" content="summary_large_image" />`,
      `<meta name="twitter:site" content="@nounsmap" />`,
      `<meta name="twitter:creator" content="@nounsmap" />`,
      `<meta name="twitter:description" content="${description}" />`,
      `<meta name="twitter:image" content="${image}" />`,
    ];
    res.set("Cache-Control", "public, max-age=300, s-maxage=600");

    const regexBody = /<div id="__replace_body">/;

    const bodyString = [
      '<div id="__nuxt">',
      '<h1 style="font-size: 50px;">',
      escapeHtml(title),
      "</h1>",
      '<span style="font-size: 30px;">',
      escapeHtml(LocalConfig.siteDescription),
      "</span>",
    ].join("\n");
    res.send(
      template_data
        .replace(/<meta[^>]*>/g, "")
        .replace(regexTitle, metas.join("\n"))
        .replace(regexBody, bodyString)
    );
  } catch (e) {
    console.log(e);
    Sentry.captureException(e);
  }
};

const image = async (req: any, res: any) => {
  const { contract, token_id } = req.params;
  console.log(contract, token_id);
  if (!/^[0-9a-zA-Z]+$/.test(token_id)) {
    return res.status(404).send("not found");
  }
  console.log(image);
  res.setHeader("Content-Type", "image/jpeg");
  res.type("jpg");
  res.send(image);
};

// eslint-disable-next-line
const debugError = async (req: any, res: any) => {
  // eslint-disable-line
  setTimeout(() => {
    throw new Error("sample error");
  }, 10);
};

app.use(express.json());
app.get("/token/ogp/:contract/:token_id", ogpPage);
app.get("/sitemap.xml", sitemap_response);
app.get("/debug/error", debugError);
app.get("/token/image/:contract/:token_id", image);
