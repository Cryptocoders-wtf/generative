import { parse, ElementNode } from "svg-parser";

import { normalizePath, transformPath, matrixPath } from "./pathUtils";
import css from "css";

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

const polyline2path = (element: ElementNode) => {
  const points = ((element.properties?.points as string) || "").split(/\s+|,/);
  const x0 = points.shift();
  const y0 = points.shift();
  return "M" + x0 + "," + y0 + "L" + points.join(" ") + "";
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

const line2path = (element: ElementNode) => {
  const x1 = Number(element.properties?.x1);
  const y1 = Number(element.properties?.y1);
  const x2 = Number(element.properties?.x2);
  const y2 = Number(element.properties?.y2);
  return `M ${x1} ${y1} L ${x2} ${y2}`;
};

const getNumber = (item: string | number | undefined) => {
  const match = String(item).match(/^(\d+)%$/);
  if (match) {
    return (Number(match[1]) * 1024) / 100;
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

const findPath = (obj: ElementNode[], transform: any, isBFS: boolean) => {
  const ret: { ele: ElementNode; transform: string }[] = [];

  const children: ElementNode[] = [];
  obj.map((element) => {
    if (element?.properties?.transform) {
      transform = element?.properties?.transform;
    }
    if (element.children) {
      if (element.tagName === "clipPath") {
        return;
      }
      if (element.tagName === "defs") {
        return;
      }
      if (isBFS) {
        element.children.map((c) => {
          children.push(c as ElementNode);
        });
      } else {
        findPath(element.children as ElementNode[], transform, isBFS).map(
          (childRet) => {
            ret.push(childRet);
          }
        );
      }
    }
    if (element.tagName === "path") {
      ret.push({ ele: element, transform });
    }
    if (element.tagName === "circle") {
      if (element.properties) {
        element.properties.d = circle2path(element);
      }
      ret.push({ ele: element, transform });
    }
    if (element.tagName === "ellipse") {
      if (element.properties) {
        element.properties.d = ellipse2path(element);
      }
      ret.push({ ele: element, transform });
    }
    if (element.tagName === "line") {
      if (element.properties) {
        element.properties.d = line2path(element);
      }
      ret.push({ ele: element, transform });
    }
    if (element.tagName === "rect") {
      if (element.properties) {
        element.properties.d = rect2path(element);
      }
      ret.push({ ele: element, transform });
    }
    if (element.tagName === "polygon") {
      if (element.properties) {
        element.properties.d = polygon2path(element);
      }
      ret.push({ ele: element, transform });
    }
    if (element.tagName === "polyline") {
      if (element.properties) {
        element.properties.d = polyline2path(element);
      }
      ret.push({ ele: element, transform });
    }
  });
  if (isBFS) {
    if (children.length > 0) {
      findPath(children as ElementNode[], transform, isBFS).map((childRet) => {
        ret.push(childRet);
      });
    }
  }
  return ret;
};

const getSvgSize = (svg: ElementNode) => {
  const viewBox = ((svg.properties?.viewBox as string) || "").split(" ");

  const originalWidth =
    parseInt(viewBox[2], 10) || parseInt(String(svg?.properties?.width || ""));
  const originalHeight =
    parseInt(viewBox[3], 10) || parseInt(String(svg?.properties?.height || ""));

  const max = Math.max(originalWidth, originalHeight);
  const width = Math.round((originalWidth * 1024) / max);
  const height = Math.round((originalHeight * 1024) / max);
  return { height, width, max };
};

// properties

// end of properties

export const dumpConvertSVG = (paths: any[]) => {
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
        if (strokeW) {
          styles.push(`stroke-linecap:round;stroke-linejoin:round`);
          styles.push(`stroke-width:${strokeW || 3}`);
          styles.push(`stroke:${"#000"}`);
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
const rawStroke = (element: ElementNode, max: number) => {
  if ((element.properties || {})["stroke-width"]) {
    return (element.properties || {})["stroke-width"] || "";
  }
  const styles = style2elem((element.properties?.style as string) || "");
  return styles["stroke-width"] || "";
};
const element2strokeWidth = (element: ElementNode, max: number) => {
  const str = rawStroke(element, max);
  const match = String(str).match(/^\d+/);
  return Math.round(match ? normalizePos(Number(match[0]), max) : 0);
};

const defaultStrokeWidth = 0;

const elementToData = (
  element: ElementNode,
  max: number,
  style: any,
  transform = {},
  matrix = {}
) => {
  const fill = element2fill(element) || style["fill"];
  const stroke = element2stroke(element) || style["stroke"];
  const _strokeWidth = Math.round(
    element2strokeWidth(element, max) || style["stroke-width"] || 0
  );
  const strokeWidth =
    _strokeWidth > 0 ? _strokeWidth : stroke ? defaultStrokeWidth : 0;

  return {
    path: normalizePath(
      matrixPath(
        transformPath(String(element.properties?.d) || "", transform),
        matrix
      ),
      Number(max)
    ),
    fill,
    stroke,
    strokeW: strokeWidth,
  };
};

const findCSS = (children: ElementNode[]) => {
  const cssObj = children.find((child) => {
    return child.tagName === "style";
  });
  if (cssObj) {
    // console.log(css.children[0].value);
    const a = cssObj.children
      .map((c: any) => {
        return c.value;
      })
      .join("");
    const obj = css.parse(a);
    const rules = obj?.stylesheet?.rules.reduce((tmp: any, rule: any) => {
      rule.selectors.map((sele: string) => {
        if (sele.startsWith(".")) {
          const name = sele.replace(/^\./, "");
          if (!tmp[name]) {
            tmp[name] = {};
          }
          rule.declarations.map((dec: any) => {
            tmp[name][dec.property] = dec.value;
          });
          //console.log(rule.declarations)
        }
      });

      return tmp;
    }, {});
    return rules;
  }
  return {};
};

const parseTransform = (tag: string) => {
  const found = tag.match(/translate\(([\d-.]+),([\d-.]+)/);
  if (found && found.length === 3) {
    return {
      w: Number(found[1]),
      h: Number(found[2]),
    };
  }
  return {};
};

const parseMatrix = (tag: string) => {
  const found = tag.match(
    /matrix\(([\d-.]+),([\d-.]+),([\d-.]+),([\d-.]+),([\d-.]+),([\d-.]+)/
  );
  if (found && found.length === 7) {
    return {
      scaleX: Number(found[1]),
      skewY: Number(found[2]),
      skewX: Number(found[3]),
      scaleY: Number(found[4]),
      translateX: Number(found[5]),
      translateY: Number(found[6]),
    };
  }
  return {};
};

export const convSVG2Path = (svtText: string, isBFS: boolean) => {
  const obj = parse(svtText);
  const svg = obj.children[0] as ElementNode;

  const { max } = getSvgSize(svg);
  const css = findCSS(svg.children as ElementNode[]);
  // console.log(css);
  const pathElements = findPath(svg.children as ElementNode[], "", isBFS);
  const path = pathElements.map(
    (element: { ele: ElementNode; transform: any }) => {
      const className = element?.ele?.properties?.class || "";
      const style = css[className] ? css[className] : {};
      const transform = parseTransform(element.transform || "");
      const matrix = parseMatrix(element.transform || "");
      // console.log(matrix);
      return elementToData(element?.ele, max, style, transform);
    }
  );
  // console.log(path);
  return path;
};

export const svg2imgSrc = (svg: string) => {
  return "data:image/svg+xml;base64," + btoa(unescape(encodeURIComponent(svg)));
};
