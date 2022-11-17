import { readdirSync, readFileSync, writeFileSync, existsSync } from "fs";
import { XMLParser } from "fast-xml-parser";
import { compressPath, solidityString } from "../packages/graphics/pathUtils";

const options = {
  ignoreAttributes: false,
  format: true,
};

const parser = new XMLParser(options);
const folder = "./londrina_solid_E2";

const main = async () => {
  console.log("main");
  let files = readdirSync(folder).filter(file => file !== ".DS_Store");
  // console.log(files);
  const array = files.map((file) => {
    let xml = readFileSync(`${folder}/${file}`, 'utf8');
    //console.log(xml);
    const obj = parser.parse(xml);
    const svg = obj.svg;
    const viewBox = svg['@_viewBox'].split(' ');
    const height = parseInt(viewBox[3], 10);
    const width = Math.round(parseInt(viewBox[2], 10) * 1024 / height);
    const element = svg.path;
    let path;
    if (element.length > 0) {
      console.log(element.length);
      path = element.map((item:any) => item["@_d"]).join('');      
    } else {
      path = element["@_d"];      
    }
    const bytes = solidityString(compressPath(path, height));
    const name = file.split('.')[0].slice(10);
    const char = name.slice(5);
    return { file, char, name, width, height, bytes };
  });
  const constants = array.map(item => {
    return `  function ${item.name}() internal pure returns(bytes memory) {\n` +
           `    return "${item.bytes}";\n` +
           `  }`;
  }).join('\n');
  console.log(constants);

  const calls = array.map(item => {
    return `register("${item.char}", ${item.name}, ${item.width});`;
  }).join('\n');
  console.log(calls);
};

main();