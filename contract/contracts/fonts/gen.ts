import * as fs from 'fs';
import { readdirSync, readFileSync, writeFileSync, existsSync } from 'fs';
import { XMLParser } from 'fast-xml-parser';
import { compressPath, solidityString } from '../packages/graphics/pathUtils';

import { fonts, fontsMap } from "./fontData";

const options = {
  ignoreAttributes: false,
  format: true,
};

const parser = new XMLParser(options);

const main = async () => {
  const fileObj: {[key: string]: { file: string, key: string }} = {};
  [
    "./font_lower_case_letters",
    "./font_upper_case_letters",
    "./font_numbers",
    "./font_symbols",
  ].map(folder => {
    readdirSync(folder).map((file) => {
      const key = file.split(".")[0];
      const hit = fontsMap[key];
      if (!!hit) {
        fileObj[key] = {
          file: [folder, file].join("/"),
          key,
        };
      }
    });
  });
  
  const array = fonts.map(fontData => {
    if (fileObj[fontData[0]]) {
      const { file, key } = fileObj[fontData[0]];
      
      const xml = readFileSync(`${file}`, 'utf8');
      //console.log(xml);
      const obj = parser.parse(xml);
      const svg = obj.svg;
      const viewBox = svg['@_viewBox'].split(' ');
      const height = parseInt(viewBox[3], 10);
      const width = Math.round((parseInt(viewBox[2], 10) * 1024) / height);
      const element = svg.path;
      let path;
      if (element.length > 0) {
        path = element.map((item: any) => item['@_d']).join('');
      } else {
        path = element['@_d'];
      }
      const bytes = solidityString(compressPath(path, height));
      const name = "font_" + key;
      
      const char = fontData[1];
      return { file, char, name, width, height, bytes };
    }
    console.log("not hit: ", fontData)
    return {};
  });

  const constants = array
    .map(item => {
      return (
        `  function ${item.name}() internal pure returns(bytes memory) {\n` + `    return "${item.bytes}";\n` + `  }`
      );
    })
    .join('\n');
  // console.log(constants);

  const calls = array
    .map(item => {
      return `    _register("${item.char}", ${item.name}, ${item.width});`;
    })
    .join('\n');
  // console.log(calls);

  const template_data = fs.readFileSync("./template.sol.txt", { encoding: 'utf8' });
  const ret = template_data.replaceAll("___font_func___", constants)
    .replaceAll("___register___", calls)
  fs.writeFileSync("./font.sol", ret, { encoding: 'utf8' });

};

main();
