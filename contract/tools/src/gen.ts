import {
  readdirSync,
  readFileSync,
  writeFileSync,
  mkdirSync,
  createWriteStream,
} from "fs";

import { parse, ElementNode, Node } from "svg-parser";

import {
  compressPath,
  solidityString,
} from "../../contracts/packages/graphics/pathUtils";

type SVGObj = SVGData | SVGData[];

interface SVGData {
  path: SVGObj;
  rect: SVGObj;
  circle: SVGObj;
  polygon: SVGObj;
  ellipse: SVGObj;
  "@_d": string;
  "@_r": string;
  "@_x": string;
  "@_y": string;
  "@_rx": string;
  "@_ry": string;
  "@_cy": string;
  "@_cx": string;
  "@_width": string;
  "@_height": string;
  "@_viewBox": string;
  "@_points": string;
  "@_style": string;
  "@_id": string;
}

const circle2path = (element: ElementNode) => {
  const cx = Number(element.properties?.cx);
  const cy = Number(element.properties?.cy);
  const r = Number(element.properties?.r);
  return `M ${cx} ${cy} m ${-r}, 0 a ${r},${r} 0 1,1 ${
    r * 2
  },0 a ${r},${r} 0 1,1 ${-(r * 2)},0`;
};

const polygon2path = (element: ElementNode) => {
  const points = ((element.properties?.points as string) || "").split(/\s+|,/);
  const x0 = points.shift();
  const y0 = points.shift();
  return "M" + x0 + "," + y0 + "L" + points.join(" ") + "z";
};

const ellipse2path = (element: ElementNode) => {
  const cx = Number(element.properties?.cx);
  const cy = Number(element.properties?.cy);
  const rx = Number(element.properties?.rx);
  const ry = Number(element.properties?.ry);
  return `M ${cx} ${cy} m ${-rx}, 0 a ${rx},${ry} 0 1,0 ${
    rx * 2
  },0 a ${rx},${ry} 0 1,0 ${-(rx * 2)},0`;
};

const rect2path = (element: ElementNode) => {
  const x = Number(element.properties?.x || "0");
  const y = Number(element.properties?.y || "0");
  const rx = Number(element.properties?.width);
  const ry = Number(element.properties?.height);
  return `M ${x} ${y} H ${rx + x} V ${ry + y} H ${x} Z`;
};

const findPath = (obj: ElementNode[]) => {
  const ret: ElementNode[] = [];

  obj.map((element) => {
    if (element.children) {
      findPath(element.children as ElementNode[]).map((childRet) => {
        ret.push(childRet);
      });
    }
    if (element.tagName === "path") {
      ret.push(element);
    }
    if (element.tagName === "circle") {
      if (element.properties) {
        element.properties.d = circle2path(element);
      }
      ret.push(element);
    }
    if (element.tagName === "ellipse") {
      if (element.properties) {
        element.properties.d = ellipse2path(element);
      }
      ret.push(element);
    }
    if (element.tagName === "rect") {
      if (element.properties) {
        element.properties.d = rect2path(element);
      }
      ret.push(element);
    }
    if (element.tagName === "polygon") {
      if (element.properties) {
        element.properties.d = polygon2path(element);
      }
      ret.push(element);
    }
  });
  return ret;
};

const getSvgSize = (svg: ElementNode) => {
  const viewBox = ((svg.properties?.viewBox as string) || "").split(" ");
  // const originalHeight = parseInt(viewBox[3], 10);
  // const originalWidth = parseInt(viewBox[2], 10)
  const originalHeight = 730;
  const originalWidth = 730;

  // 730;
  const width = Math.round((originalWidth * 1024) / originalHeight);
  return { height: originalHeight * 10, width: width * 10 };
};

const dumpConvertSVG = (svg: ElementNode, pathElements: ElementNode[]) => {
  const vb = (svg.properties?.viewBox as string) || "";
  const ret =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}">\n\t<g>\n` +
    pathElements
      .map((svgData) => {
        const d = svgData.properties?.d;
        return `\t\t<path d="${d}" style="fill:none;stroke-linecap:round;stroke-linejoin:round;stroke-width:3px;stroke:#000;" />`;
        //        return `\t\t<path d="${d}"  />`;
      })
      .join("\n") +
    "\n\t</g>\n</svg>\n";
  return ret;
};

const dumpConvertSVG2 = (svg: ElementNode, paths: any[]) => {
  const vb = (svg.properties?.viewBox as string) || "";
  const ret =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}">\n\t<g>\n` +
    paths
      .map((pathData) => {
        const d = pathData["path"];
        const fill = pathData["fill"];
        const stroke = pathData["stroke"];
        const styles = [];
        if (fill) {
          styles.push(`fill:${fill}`);
        }
        if (stroke) {
          styles.push(
            `stroke-linecap:round;stroke-linejoin:round;stroke-width:${stroke};stroke:#000`
          );
        }
        const style = styles.join(";");
        return `\t\t<path d="${d}" style="${style}" />`;
      })
      .join("\n") +
    "\n\t</g>\n</svg>\n";
  return ret;
};

const style2elem = (style: string) => {
  const styles = style.split(";").map((a) => a.split(":"));
  return styles.reduce((tmp: any, key: string[]) => {
    tmp[key[0]] = key[1];
    return tmp;
  }, {});
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
    const { height, width } = getSvgSize(svg);

    const pathElements = findPath(svg.children as ElementNode[]);

    const path = pathElements
      .map((item: ElementNode) => {
        return item.properties?.d;
      })
      .join("");
    //console.log(path)

    const path2 = pathElements.map((item: ElementNode) => {
      const styles = style2elem((item.properties?.style as string) || "");
      const fill = styles["fill"];
      const stroke = styles["stroke-width"];
      return {
        path: item.properties?.d || "",
        fill,
        stroke: stroke,
      };
    });
    console.log(path2);

    // const convertedSVG = dumpConvertSVG(svg, pathElements);
    const convertedSVG = dumpConvertSVG2(svg, path2);

    writeFileSync(outdir + "/svgs/" + fileName, convertedSVG);

    const bytes = solidityString(compressPath(path, height));

    return { fileName, char, name, width, height, bytes };
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

main(folder);
