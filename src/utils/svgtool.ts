import { parse, ElementNode } from "svg-parser";
import { cloneDeep } from "lodash";
import { normalizePath } from "./pathUtils";
import { transforms2matrix, roundMatrix } from "./transformer";
import css from "css";

import {
  Properties,
  PathElement,
  PathData,
  DefsObj,
  TransFormData,
} from "./types";

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

const defObj = {};
const convDefsArray2Obj = (
  obj: ElementNode[],
  defs: { [key: string]: ElementNode[] }
) => {
  obj.map((a) => {
    const myId = String(a.properties?.id || "");
    if (myId) {
      if (!defs[myId]) {
        defs[myId] = [];
      }
      defs[myId].push(a);
    }
    if (a.children && a.children.length > 0) {
      convDefsArray2Obj(a.children as ElementNode[], defs);
    }
  });
  return {};
};

const findPath = (
  obj: ElementNode[],
  _properties: Properties,
  defsObj: DefsObj,
  isBFS: boolean,
  depth: number
) => {
  const ret: {
    ele: ElementNode;
    properties: { transform: string[]; id: string };
  }[] = [];

  const childrenArray: { children: ElementNode[]; properties: Properties }[] =
    [];
  obj.map((element) => {
    const properties = cloneDeep(_properties);
    if (element?.properties?.id) {
      properties.id = String(element?.properties?.id);
    }
    // for <defs>
    if (element?.properties?.transform) {
      properties.transform.push(String(element?.properties?.transform));
    }

    if (element.tagName === "use" && element?.properties?.href) {
      const id = String(element?.properties?.href).replace("#", "");
      if (defsObj[id]) {
        const c = defsObj[id];
        if (isBFS) {
          const children: ElementNode[] = [];
          c.map((chi) => {
            children.push(chi as ElementNode);
          });
          childrenArray.push({ children, properties });
        } else {
          findPath(
            c as ElementNode[],
            { ...properties },
            defsObj,
            isBFS,
            depth + 1
          ).map((childRet) => {
            ret.push(childRet);
          });
        }
      }
    }
    // end of for defs
    if (element.children) {
      if (element.tagName === "clipPath") {
        return;
      }
      if (element.tagName === "defs") {
        convDefsArray2Obj(element.children as ElementNode[], defsObj);
        return;
      }
      if (isBFS) {
        const children: ElementNode[] = [];
        element.children.map((c) => {
          children.push(c as ElementNode);
        });
        childrenArray.push({ children, properties });
      } else {
        findPath(
          element.children as ElementNode[],
          { ...properties },
          defsObj,
          isBFS,
          depth + 1
        ).map((childRet) => {
          ret.push(childRet);
        });
      }
    }
    if (element.tagName === "path") {
      ret.push({ ele: element, properties });
    }
    if (element.tagName === "circle") {
      if (element.properties) {
        element.properties.d = circle2path(element);
      }
      ret.push({ ele: element, properties });
    }
    if (element.tagName === "ellipse") {
      if (element.properties) {
        element.properties.d = ellipse2path(element);
      }
      ret.push({ ele: element, properties });
    }
    if (element.tagName === "line") {
      if (element.properties) {
        element.properties.d = line2path(element);
      }
      ret.push({ ele: element, properties });
    }
    if (element.tagName === "rect") {
      if (element.properties) {
        element.properties.d = rect2path(element);
      }
      ret.push({ ele: element, properties });
    }
    if (element.tagName === "polygon") {
      if (element.properties) {
        element.properties.d = polygon2path(element);
      }
      ret.push({ ele: element, properties });
    }
    if (element.tagName === "polyline") {
      if (element.properties) {
        element.properties.d = polyline2path(element);
      }
      ret.push({ ele: element, properties });
    }
  });
  // for <defs>
  if (isBFS) {
    if (childrenArray.length > 0) {
      childrenArray.map((children) => {
        if (children.children.length > 0) {
          findPath(
            children.children as ElementNode[],
            { ...children.properties },
            defsObj,
            isBFS,
            depth + 1
          ).map((childRet) => {
            ret.push(childRet);
          });
        }
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

export const dumpConvertSVG = (paths: PathData[]) => {
  const ret =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">\n\t<g>\n` +
    paths
      .map((pathData) => {
        const d = pathData["path"];

        // styles
        const fill = pathData["fill"];
        const strokeW = pathData["strokeW"];
        const styles = [];
        if (fill) {
          if (fill === "-") {
            styles.push(`fill:none`);
          } else {
            styles.push(`fill:${fill}`);
          }
        }
        if (strokeW) {
          styles.push(`stroke-linecap:round;stroke-linejoin:round`);
          styles.push(`stroke-width:${strokeW || 3}`);
          styles.push(`stroke:${"#000"}`);
        }
        const style = styles.join(";");

        const opts: string[] = [];
        if (pathData.matrix) {
          opts.push(`transform="matrix(${pathData.matrix})"`);
        }
        if (pathData.opacity) {
          opts.push(`opacity="${pathData.opacity}"`);
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
  return styles.reduce((tmp: { [key: string]: string }, key: string[]) => {
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
const element2opacity = (element: ElementNode) => {
  return getElementProperty(element, "opacity");
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
  matrix?: string
): PathData => {
  const fill = element2fill(element) || style["fill"];
  const stroke = element2stroke(element) || style["stroke"];
  const _strokeWidth = Math.round(
    element2strokeWidth(element, max) || style["stroke-width"] || 0
  );
  const strokeWidth = (() => {
    if (stroke && stroke === 'none') {
      return 0;
    }
    if (_strokeWidth > 0) {
      return _strokeWidth
    }
    if (stroke) {
      return defaultStrokeWidth
    }
    return 0
  })();
  const opacity = element2opacity(element) || style["opacity"];
  
  return {
    path: normalizePath(String(element.properties?.d) || "", Number(max)),
    fill: fill === "none" ? "-" : fill,
    strokeW: strokeWidth,
    matrix: matrix !== "1,0,0,1,0,0" ? matrix : "",
    opacity,
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
        }
      });

      return tmp;
    }, {});
    return rules;
  }
  return {};
};

export const convSVG2Path = (svtText: string, isBFS: boolean) => {
  const obj = parse(svtText);
  const svg = obj.children[0] as ElementNode;

  const { max } = getSvgSize(svg);
  const css = findCSS(svg.children as ElementNode[]);
  const pathElements = findPath(
    svg.children as ElementNode[],
    { transform: [], id: "" },
    {},
    isBFS,
    0
  );

  const path = pathElements.map((element: PathElement) => {
    const className = element?.ele?.properties?.class || "";
    const style = css[className] ? css[className] : {};
    const transformMatrix = transforms2matrix(
      element.properties.transform,
      max
    );
    return elementToData(
      element?.ele,
      max,
      style,
      roundMatrix(transformMatrix).join(",")
    );
  });
  return path;
};

export const svg2imgSrc = (svg: string) => {
  return "data:image/svg+xml;base64," + btoa(unescape(encodeURIComponent(svg)));
};
