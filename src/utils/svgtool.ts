import { parse, ElementNode, Node } from "svg-parser";

import { normalizePath, compressPath, solidityString } from "./pathUtils";

// svg to svg
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

const getNumber = (item: string | number | undefined) => {
  const match = String(item).match(/^(\d+)%$/)
  if (match) {
    return Number(match[1]) * 1024 / 100;
  }
  return item;
};
const rect2path = (element: ElementNode) => {
  const x = Number(element.properties?.x || "0");
  const y = Number(element.properties?.y || "0");
  const rx = Number(getNumber(element.properties?.width));
  const ry = Number(getNumber(element.properties?.height));
  return `M ${x} ${y} H ${rx + x} V ${ry + y} H ${x} Z`;
};
// end of svg to svg

const findPath = (obj: ElementNode[], isBFS: boolean) => {
  const ret: ElementNode[] = [];

  const children: ElementNode[] = [];
  obj.map((element) => {
    if (element.children) {
      if (element.tagName === 'clipPath') {
        return ;
      }
      element.children.map((c) => {
        if (isBFS) {
          children.push(c as ElementNode);
        } else {
          findPath(element.children as ElementNode[], isBFS).map((childRet) => {
            ret.push(childRet);
          });
        }
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
  if (isBFS) {
    if (children.length > 0) {
      findPath(children as ElementNode[], isBFS).map((childRet) => {
        ret.push(childRet);
      });
    }
  }
  return ret;
};

const getSvgSize = (svg: ElementNode) => {
  const viewBox = ((svg.properties?.viewBox as string) || "").split(" ");
  const originalWidth = parseInt(viewBox[2], 10);
  const originalHeight = parseInt(viewBox[3], 10);
  const max = Math.max(originalWidth, originalHeight);
  const width = Math.round((originalWidth * 1024) / max);
  const height = Math.round((originalHeight * 1024) / max);

  return { height, width, max };
};

// properties

// end of properties

const dumpConvertSVG = (paths: any[]) => {
  const ret =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">\n\t<g>\n` +
    paths
      .map((pathData) => {
        const d = pathData["path"];

        // styles
        const fill = pathData["fill"];
        const strokeW = pathData["strokeW"];
        const stroke = pathData["stroke"];
        const styles = [];
        if (fill) {
          styles.push(`fill:${fill}`);
        }
        if (strokeW || stroke) {
          styles.push(`stroke-linecap:round;stroke-linejoin:round`);
          styles.push(`stroke-width:${strokeW || 3}`);
          styles.push(`stroke:${stroke || "#000"}`);
        }
        const style = styles.join(";");

        const opts: string[] = [];
        if (pathData["translate"] && pathData["translate"].length == 2) {
          const x = pathData["translate"][0];
          const y = pathData["translate"][1];
          opts.push(`transform="translate(${x},${y})"`);
        }
        const options = opts.join(" ");
        return `\t\t<path d="${d}" style="${style}" ${options} />`;
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

const getElementProperty = (element: ElementNode, name: string) => {
  if ((element.properties || {})[name]) {
    return (element.properties || {})[name];
  }
  const styles = style2elem((element.properties?.style as string) || "");
  const fill = styles[name] || "";
  return fill;
};

const element2fill = (element: ElementNode) => {
  return getElementProperty(element, "fill");
};
const element2stroke = (element: ElementNode) => {
  return getElementProperty(element, "stroke");
};

const normalizePos = (pos: number, max: number) => {
  return (pos * 1024) / max;
};
const element2strokeWidth = (element: ElementNode, max: number) => {
  if ((element.properties || {})["stroke-width"]) {
    return (element.properties || {})["stroke-width"];
  }
  const styles = style2elem((element.properties?.style as string) || "");
  const match = (styles["stroke-width"] || "").match(/^\d+/);
  const stroke = match ? normalizePos(match[0], max) : 0;

  return Math.round(stroke);
};

const element2translate = (element: ElementNode) => {
  const transform = getElementProperty(element, "transform");
  const match = (transform || "").match(/translate\((\d+),(\d+)\)/);
  if (match) {
    return [Number(match[1]), Number(match[2])];
  }
  return [];
};

const elementToData = (element: ElementNode, max: number) => {
  const fill = element2fill(element);
  const stroke = element2stroke(element);
  const strokeWidth = element2strokeWidth(element, max);
  const translate = element2translate(element);

  return {
    path: normalizePath(String(element.properties?.d) || "", Number(max)),
    fill,
    stroke,
    strokeW: strokeWidth,
    translate,
  };
}
export const convSVG2Path = (svtText: string, isBFS: boolean) => {
  const obj = parse(svtText);

  const svg = obj.children[0] as ElementNode;
  const { height, width, max } = getSvgSize(svg);

  const pathElements = findPath(svg.children as ElementNode[], isBFS);
  const path = pathElements.map((element: ElementNode) => {
    return elementToData(element, max);
  });
  return path;
}

export const convSVG2SVG = (svtText: string, isBFS: boolean) => {
  const path = convSVG2Path(svtText, isBFS);
  const convertedSVG = dumpConvertSVG(path);
  return convertedSVG;
};

export const svg2imgSrc = (svg: string) => {
  return "data:image/svg+xml;base64," +
    btoa(unescape(encodeURIComponent(svg)));

};

