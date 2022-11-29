import {
  readdirSync,
  readFileSync,
  writeFileSync,
  mkdirSync,
  createWriteStream,
} from "fs";

import { parse, ElementNode, Node } from "svg-parser";

import {
  normalizePath,
  compressPath,
  solidityString,
} from "../../contracts/packages/graphics/pathUtils";

import {
  convSVG2Path,
} from "./svgtool";

const dumpConvertSVG = (svg: ElementNode, paths: any[]) => {
  const vb = "0 0 1024 1024";
  const ret =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}">\n\t<g>\n` +
    paths
      .map((pathData) => {
        const d = pathData["path"];
        const fill = pathData["fill"];
        const stroke = pathData["stroke"];
        const strokeW = pathData["strokeW"];

        const styles = [];
        if (fill) {
          styles.push(`fill:${fill}`);
        }
        if (stroke) {
          styles.push(
            `stroke-linecap:round;stroke-linejoin:round;stroke-width:${strokeW};stroke:${stroke}`
          );
        }
        const style = styles.join(";");
        return `\t\t<path d="${d}" style="${style}" />`;
      })
      .join("\n") +
    "\n\t</g>\n</svg>\n";
  return ret;
};

const main = async (folder: string) => {
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

    const obj = parse(svgData);
    const svg = obj.children[0] as ElementNode;

    const path = convSVG2Path(svgData, false);
    const convertedSVG = dumpConvertSVG(svg, path);

    writeFileSync(outdir + "/svgs/" + fileName, convertedSVG);

    return { fileName, char, name, path };
  });

  writeFileSync(
    outdir + "/svgs/index.html",
    files
      .map((fileName) => {
        return `<img src="${fileName}" width="300px" />\n`;
      })
      .join("")
  );

  const stream = createWriteStream(outdir + "/data/data.txt");
  stream.on("error", (err) => {
    if (err) console.log(err.message);
  });
  const constants = array
    .map((item) => {
      const length = item.path.length;
      const paths: any[] = [];
      const fills: any[] = [];
      const stroke: any[] = [];

      item.path.map((path, k) => {
        paths.push(`          paths[${k}] = "${solidityString(compressPath(path.path as string, 1024))}";`);
        fills.push(`          fill[${k}] = "${path.fill}";`);
        stroke.push(`          stroke[${k}] = ${path.stroke || 0};`);
      });
      const code = [
        `      function parts_${item.name}() internal pure returns(uint16[4] memory sizes, bytes[] memory paths, string[] memory fill, uint8[] memory stroke) {`,
        `          sizes = [${length}, ${1024}, ${1024}, ${1024}];`,
        "          paths = new bytes[](sizes[0]);",
        "          fill = new string[](sizes[0]);",
        "          stroke = new uint8[](sizes[0]);",
        "",
        paths.join("\n"),
        fills.join("\n"),
        stroke.join("\n"),
        "      }",
      ].join("\n");
      // console.log(item);
      
      // const code = `bytes constant ${item.name} = "${item.bytes}"`;
      stream.write(`${code}\n`);

      return code;
    })
    .join("\n");
  console.log(constants);
  
  const calls = array
    .map((item) => {
      const code = `register("${item.char}", ${item.name}, ${1024});`;
      stream.write(`${code}\n`);
      return code;
    })
    .join("\n");
  // console.log(calls);

  const calls2 = array
    .map((item) => {
      const code = `parts["${item.name}"] = parts_${item.name};`
      stream.write(`${code}\n`);
      return code;
    })
    .join("\n");
  // console.log(calls);
  console.log(calls2)
      

};

const folder = process.argv[2];

if (!folder) {
  console.log("npm run convert ./targetFolder/");
  process.exit(-1);
}

main(folder);
