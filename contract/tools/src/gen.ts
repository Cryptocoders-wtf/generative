import { readdirSync, readFileSync, writeFileSync, mkdirSync, createWriteStream } from "fs";
import { XMLParser } from "fast-xml-parser";
import {
  compressPath,
  solidityString,
} from "../../contracts/packages/graphics/pathUtils";

const findPath = (obj: any) => {
  const ret: any[] = [];

  if (Array.isArray(obj)) {
    obj.map((a) => {
      findPath(a).map((b) => {
        ret.push(b);
      });
    });
  } else {
    Object.keys(obj).map((key) => {
      if (key === "path") {
        (Array.isArray(obj[key]) ? obj[key] : [obj[key]]).map((a: any) => {
          ret.push(a);
        });
      } else if (key === "circle") {
        (Array.isArray(obj[key]) ? obj[key] : [obj[key]]).map((a: any) => {
          const cx = Number(a["@_cx"]);
          const cy = Number(a["@_cy"]);
          const r = Number(a["@_r"]);
          a["@_d"] = `M ${cx} ${cy} m ${-r}, 0 a ${r},${r} 0 1,1 ${
            r * 2
          },0 a ${r},${r} 0 1,1 ${-(r * 2)},0`;
          ret.push(a);
        });
      } else if (key === "polygon") {
        (Array.isArray(obj[key]) ? obj[key] : [obj[key]]).map((a: any) => {
          const points = a["@_points"].split(/\s+|,/);
          const x0 = points.shift();
          const y0 = points.shift();
          const pathdata = "M" + x0 + "," + y0 + "L" + points.join(" ") + "z";
          a["@_d"] = pathdata;
          ret.push(a);
        });
      } else if (key === "clipPath") {
        // skip
      } else {
        if (typeof obj[key] === "object") {
          findPath(obj[key]).map((b) => {
            ret.push(b);
          });
        }
      }
    });
  }
  return ret;
};
const getSvgSize = (svg: any) => {
  const viewBox = svg["@_viewBox"].split(" ");
  const height = parseInt(viewBox[3], 10);
  const width = Math.round((parseInt(viewBox[2], 10) * 1024) / height);
  return { height, width };
};

const dumpConvertSVG = (svg: any, pathElements: any[]) => {
  const vb = svg["@_viewBox"];
  const ret =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}">\n\t<g>\n` +
    pathElements
      .map((a: any) => {
        const d = a["@_d"];
        return `\t\t<path d="${d}" />`;
      })
      .join("\n") +
    "\n\t</g>\n</svg>\n";
  return ret;
};

const main = async () => {
  const options = {
    ignoreAttributes: false,
    format: true,
  };
  
  const parser = new XMLParser(options);

  const files = readdirSync(folder).filter((fileName) => {
    return fileName.endsWith(".svg");
  });

  const oFolderNname = folder.split("/")[2];
  const outdir = "./outputs/" + oFolderNname;
  mkdirSync(outdir, { recursive: true });
  mkdirSync(outdir + "/svgs/", { recursive: true });
  mkdirSync(outdir + "/data/", { recursive: true });

  const array = files.map((fileName) => {
    const svgData = readFileSync(`${folder}/${fileName}`, "utf8");
    const name = fileName.split(".")[0];
    const char = name;

    const obj = parser.parse(svgData);
    const svg = obj.svg;
    const { height, width } = getSvgSize(svg);

    const pathElements = findPath(svg);
    const path = pathElements.map((item: any) => item["@_d"]).join("");

    const convertedSVG = dumpConvertSVG(svg, pathElements);
    name + ".svg";

    writeFileSync(outdir + "/svgs/" + fileName, convertedSVG);

    const bytes = solidityString(compressPath(path, height));

    return { fileName, char, name, width, height, bytes };
  });

  const stream = createWriteStream(outdir + "/data/data.txt");
  stream.on("error", (err) => {
    if (err) console.log(err.message);
  });
  const constants = array
    .map((item) => {
      const code = `bytes constant ${item.name} = "${item.bytes}"`;
      stream.write(`${code}\n`);
      return code;
    })
    .join("\n");
  // console.log(constants);

  const calls = array
    .map((item) => {
      const code = `register("${item.char}", ${item.name}, ${item.width});`;
      stream.write(`${code}\n`);
      return code;
    })
    .join("\n");
  // console.log(calls);
};

const folder = process.argv[2];

if (!folder) {
  console.log("npm run convert ./targetFolder/");
  process.exit(-1);
}

main();
