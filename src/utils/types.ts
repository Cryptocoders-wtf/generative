import { ElementNode } from "svg-parser";

export interface Properties {
  transform: string[];
  id: string;
}
export interface PathElement {
  ele: ElementNode;
  properties: Properties;
}
export interface PathData {
  path: string;
  fill: string;
  stroke: number;
  strokeW: number;
  matrix?: any;
}
export interface DefsObj {
  [key: string]: ElementNode[];
}
export interface TransFormData {
  scaleX?: number;
  skewY?: number;
  skewX?: number;
  scaleY?: number;
  translateX?: number;
  translateY?: number;
}
