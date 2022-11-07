import { readdirSync, readFileSync, writeFileSync, existsSync } from "fs";
import { XMLParser } from "fast-xml-parser";

const options = {
  ignoreAttributes: false,
  format: true,
};

const parser = new XMLParser(options);
const folder = "./londrina_solid";

const main = async () => {
  console.log("main");
  let files = readdirSync(folder).filter(file => file !== ".DS_Store");
  // console.log(files);
  const output = files.map((file) => {
    let xml = readFileSync(`${folder}/${file}`, 'utf8');
    //console.log(xml);
    const obj = parser.parse(xml);
    const svg = obj.svg;
    const viewBox = svg['@_viewBox'].split(' ');
    const width = parseInt(viewBox[2], 10);
    return width;
  });
  console.log(output);
};

main();