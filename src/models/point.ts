export interface Point {
  x: number;
  y: number;
  c: boolean; // true:line, false:bezier
  r: number; // ratio (0 to 1)
}

export enum LayerType {
  NONE,
  REMIX,
  LAYER,
  OVERLAY,
}

export interface Layer {
  points: Point[];
  color: string;
  path: string;
  svgImage: string;
}

export interface Transform {
  tx: number;
  ty: number;
  scale: number;
  rotate: number;
}

export const identityTransform: Transform = {
  tx: 0,
  ty: 0,
  scale: 1,
  rotate: 0,
};

export const transformString = (xf: Transform) => {
  if (
    xf.tx == identityTransform.tx &&
    xf.ty == identityTransform.ty &&
    xf.scale == identityTransform.scale &&
    xf.rotate == identityTransform.rotate
  ) {
    return "";
  }
  const d = Math.round(512 * (xf.scale - 1));
  return (
    `translate(${xf.tx - d} ${xf.ty - d}) ` +
    `scale(${xf.scale}) rotate(${xf.rotate} 512 512)`
  );
};

export const transformStyle = (xf: Transform, ratio: number) => {
  return (
    `translate(${xf.tx * ratio}px,${xf.ty * ratio}px)` +
    ` scale(${xf.scale}) rotate(${xf.rotate}deg) `
  );
};

export interface Overlay {
  provider: string;
  assetId: number;
  fill: string;
  transform: Transform;
  image: string; // cached svg image (base64)
  svgPart: string; // cached svg part
  svgTag: string; // cached svg tag
}

export interface Remix {
  tokenId: number; // remix tokenId
  color?: string;
  transform: Transform;
  image?: string; // cached svg image
  svgPart?: string; // cached svgPart
  svgTag?: string; // cached svg tag
}

export interface Drawing {
  remix: Remix;
  layers: Layer[];
  overlays: Overlay[];
  stroke: number; // optional stroke width
}

// asset,
// props.remixId, // remixId
// "", // color
// "", // transform
// [] // overlays
/*
  [{
    assetId: 54,
    provider: "asset",
    fill: "blue",
    transform: "scale(0.4, 0.4)"
  }]
*/

export const pathFromPoints = (points: Point[]) => {
  const length = points.length;
  return points.reduce((path, cursor, index) => {
    const prev = points[(index + length - 1) % length];
    const next = points[(index + 1) % length];
    const sx = (cursor.x + prev.x) / 2;
    const sy = (cursor.y + prev.y) / 2;
    const head = index == 0 ? `M${sx},${sy},` : "";
    const ex = (cursor.x + next.x) / 2;
    const ey = (cursor.y + next.y) / 2;
    const last = `${ex},${ey}`;
    if (cursor.c) {
      return path + head + `L${cursor.x},${cursor.y},` + last;
    }
    const c1x = sx + cursor.r * (cursor.x - sx);
    const c1y = sy + cursor.r * (cursor.y - sy);
    const c2x = ex + cursor.r * (cursor.x - ex);
    const c2y = ey + cursor.r * (cursor.y - ey);
    return path + head + `C${c1x},${c1y},${c2x},${c2y},` + last;
  }, "");
};

const svgHead =
  '<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">\n';

export const svgImageFromPath = (path: string, color: string) => {
  const svgTail = "</g></defs>" + `<use href="#asset" fill="${color}" /></svg>`;
  const svg =
    svgHead + '<defs><g id="asset"><path d="' + path + '" />' + svgTail;
  const image =
    "data:image/svg+xml;base64," + Buffer.from(svg).toString("base64");
  return image;
};

export const svgImageFromDrawing = (drawing: Drawing) => {
  const paths = drawing.layers.map((layer) => {
    return `<path d="${layer.path}" fill="${layer.color}" />`;
  });
  const svg = svgHead + "<g>\n" + paths.join("\n") + "</g>\n</svg>\n";
  return "data:image/svg+xml;base64," + Buffer.from(svg).toString("base64");
};

export const togglePointType = (points: Point[], index: number) => {
  return points.map((point, _index) => {
    if (_index == index) {
      return { x: point.x, y: point.y, c: !point.c, r: point.r };
    }
    return point;
  });
};

export const splitPoint = (points: Point[], index: number) => {
  const prev = points[index];
  const next = points[(index + 1) % points.length];
  const newItem = {
    x: (prev.x + next.x) / 2,
    y: (prev.y + next.y) / 2,
    c: false,
    r: prev.r,
  };
  const array = points.map((point) => point);
  array.splice(index + 1, 0, newItem);
  return array;
};
