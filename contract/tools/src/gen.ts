import { readdirSync, readFileSync, writeFileSync, mkdirSync, createWriteStream } from "fs";
import { XMLParser } from "fast-xml-parser";
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

const circle2path = (svgData: SVGData) => {
  const cx = Number(svgData["@_cx"]);
  const cy = Number(svgData["@_cy"]);
  const r = Number(svgData["@_r"]);
  return  `M ${cx} ${cy} m ${-r}, 0 a ${r},${r} 0 1,1 ${r * 2},0 a ${r},${r} 0 1,1 ${-(r * 2)},0`;
}

const polygon2path = (svgData: SVGData) => {
  const points = svgData["@_points"].split(/\s+|,/);
  const x0 = points.shift();
  const y0 = points.shift();
  return "M" + x0 + "," + y0 + "L" + points.join(" ") + "z";
}

const ellipse2path = (svgData: SVGData) => {
  const cx = Number(svgData["@_cx"]);
  const cy = Number(svgData["@_cy"]);
  const rx = Number(svgData["@_rx"]);
  const ry = Number(svgData["@_ry"]);
  return  `M ${cx} ${cy} m ${-rx}, 0 a ${rx},${ry} 0 1,0 ${rx * 2},0 a ${rx},${ry} 0 1,0 ${-(rx * 2)},0`;
}

const rect2path = (svgData: SVGData) => {
  const x = Number(svgData["@_x"] || "0");
  const y = Number(svgData["@_y"] || "0");
  const rx = Number(svgData["@_width"]);
  const ry = Number(svgData["@_height"]);
  return  `M ${x} ${y} H ${rx + x} V ${ry + y} H ${x} Z`;
}


const findPath = (obj: SVGObj) => {
  const ret: SVGData[] = [];

  if (Array.isArray(obj)) {
    obj.map((svgObj) => {
      findPath(svgObj).map((svgData) => {
        ret.push(svgData);
      });
    });
  } else {
    Object.keys(obj).map((key) => {
      if (key === "path") {
        (Array.isArray(obj.path) ? obj.path : [obj.path]).map((svgData: SVGData) => {
          if (svgData["@_style"]) {
            // console.log(svgData["@_style"])
          }
          ret.push(svgData);
        });
      } else if (key === "circle") {
        (Array.isArray(obj.circle) ? obj.circle : [obj.circle]).map((svgData: SVGData) => {
          svgData["@_d"] = circle2path(svgData);
          ret.push(svgData);
        });
      } else if (key === "ellipse") {
        (Array.isArray(obj.ellipse) ? obj.ellipse : [obj.ellipse]).map((svgData: SVGData) => {
          svgData["@_d"] = ellipse2path(svgData);
          ret.push(svgData);
        });
      } else if (key === "rect") {
        (Array.isArray(obj.rect) ? obj.rect : [obj.rect]).map((svgData: SVGData) => {
          svgData["@_d"] = rect2path(svgData);
          ret.push(svgData);
        });
      } else if (key === "polygon") {
        (Array.isArray(obj.polygon) ? obj.polygon : [obj.polygon]).map((svgData: SVGData) => {
          svgData["@_d"] = polygon2path(svgData);
          ret.push(svgData);
        });
      } else if (key === "clipPath") {
        // skip
      } else {
        if (typeof obj[key as keyof SVGData] === "object") {
          findPath(obj[key as keyof SVGData] as SVGObj).map((svgData) => {
            ret.push(svgData);
          });
        }
      }
    });
  }
  return ret;
};
const getSvgSize = (svg: SVGData) => {
  const viewBox = svg["@_viewBox"].split(" ");
  // const originalHeight = parseInt(viewBox[3], 10);
  // const originalWidth = parseInt(viewBox[2], 10)
  const originalHeight = 730;
  const originalWidth = 730;

  // 730;
  const width = Math.round((originalWidth * 1024) / originalHeight);
  console.log({ height: originalHeight, width: width });
  // return { height, width };
  return { height: originalHeight*10, width: width*10 };
};

const dumpConvertSVG = (svg: SVGData, pathElements: SVGData[]) => {
  const vb = svg["@_viewBox"];
  const ret =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}">\n\t<g>\n` +
    pathElements
      .map((svgData) => {
        const d = svgData["@_d"];
        return `\t\t<path d="${d}" style="fill:none;stroke-linecap:round;stroke-linejoin:round;stroke-width:3px;stroke:#000;" />`;
        //        return `\t\t<path d="${d}"  />`;
      })
      .join("\n") +
    "\n\t</g>\n</svg>\n";
  return ret;
};
const dumpConvertSVG2 = (svg: SVGData, paths: any[]) => {
  const vb = svg["@_viewBox"];
  const ret =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}">\n\t<g>\n` +
    paths
      .map((pathData) => {
        const d = pathData["path"];
        const fill = pathData["fill"]
        const stroke = pathData["stroke"];
        const styles = [];
        if (fill) {
          styles.push(`fill:${fill}`)
        }
        if (stroke) {
          styles.push(`stroke-linecap:round;stroke-linejoin:round;stroke-width:${stroke};stroke:#000`);
        };
        const style = styles.join(";");
        return `\t\t<path d="${d}" style="${style}" />`;
      })
      .join("\n") +
    "\n\t</g>\n</svg>\n";
  return ret;
};

const style2elem = (style: string) => {
  const styles = style.split(";").map(a => a.split(":"));
  return styles.reduce((tmp: any, key: string[]) => {
    tmp[key[0]] = key[1];
    return tmp;
  }, {});
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
    if (fileName === "Lu_1.svg")
      console.log(svg.g.g)
    const path = pathElements.map((item: SVGData) => {
      return item["@_d"]
    }).join("");

    const path2 = pathElements.map((item: SVGData) => {
      const styles = (style2elem(item["@_style"]||""));
      const fill = styles["fill"];
      const stroke = styles["stroke-width"];
      return {
        path: item["@_d"],
        fill,
        "stroke": stroke,
      }
    });

    // const convertedSVG = dumpConvertSVG(svg, pathElements);
    const convertedSVG = dumpConvertSVG2(svg, path2);
    name + ".svg";

    writeFileSync(outdir + "/svgs/" + fileName, convertedSVG);

    const bytes = solidityString(compressPath(path, height));

    return { fileName, char, name, width, height, bytes };
  });

  writeFileSync(outdir + "/svgs/index.html", files.map((fileName) => {
    return `<img src="${fileName}" width="300px" />\n`
  }).join(""));

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
