import { readdirSync, readFileSync, writeFileSync, existsSync } from "fs";
import { XMLParser } from "fast-xml-parser";
import { compressPath, solidityString } from "../graphics/pathUtils";

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
    const height = parseInt(viewBox[3], 10);
    const width = parseInt(viewBox[2], 10);
    const element = svg.path;
    let path;
    if (element.length > 0) {
      console.log(element.length);
      path = element.map((item:any) => item["@_d"]).join('');      
    } else {
      path = element["@_d"];      
    }
    const bytes = solidityString(compressPath(path, height));
    return { file, width, height, bytes };
  });
  console.log(output);
};

main();