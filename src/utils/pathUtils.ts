// SPDX-License-Identifier: MIT

/*
 * This is a part of fully-on-chain.sol, a npm package that allows developers
 * to create fully on-chain generative art.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

import { TransFormData } from "./types";

const regexNum = /[+-]?(\d*\.\d*|\d+)/;
const regexNumG = /[+-]?(\d*\.\d*|\d+)/g;
const regexFloatG = /[+-]?(\d*\.\d*|\d+)e-\d+/g;
const regexDivG = /[,\s]+/g;

// T is number or string
const reduceFun = <T>(
  width: number,
  func1: (val: number) => T,
  func2: (item: string) => T[]
) => {
  return (
    prev: { isArc: boolean; offset: number; numArray: T[] },
    item: string
  ) => {
    if (regexNum.test(item)) {
      let value = Math.round((parseFloat(item) * 1024) / width);
      if (prev.isArc) {
        const off7 = prev.offset % 7;
        if (off7 >= 2 && off7 <= 4) {
          // we don't want to normalize 'angle', and two flags for 'a' or 'A'
          value = Math.round(parseFloat(item));
        }
        prev.offset++;
      }
      prev.numArray.push(func1(value));
    } else {
      const codes = func2(item);
      codes.map((code) => {
        prev.numArray.push(code);
      });
      const ch = item.substring(-1);
      prev.isArc = ch == "a" || ch == "A";
      if (prev.isArc) {
        prev.offset = 0;
      }
    }
    return prev;
  };
};

const prepareBody = (body: string) => {
  let ret = body.replace(regexFloatG, () => {
    return "0";
  });
  ret = ret.replace(regexNumG, (str: string) => {
    return ` ${parseFloat(str)} `;
  });
  const items = ret.split(regexDivG);
  return items;
};

export const normalizePath = (body: string, width: number) => {
  const items = prepareBody(body);
  // console.log(items);
  const func1 = (value: number) => {
    return value.toString();
  };
  const func2 = (item: string) => {
    return [item];
  };
  // console.log(body)
  const { numArray } = items.reduce(reduceFun<string>(width, func1, func2), {
    isArc: false,
    offset: 0,
    numArray: [],
  });
  // console.log(numArray);
  return numArray.join(" ");
};

export const compressNormalizedPath = (body: string, width: number) => {
  const items = prepareBody(body);

  const func1 = (value: number) => {
    return value + 0x100 + 1024;
  };
  const func2 = (item: string) => {
    return item.split("").map((char) => {
      return char.charCodeAt(0);
    });
  };
  const { numArray } = items.reduce(reduceFun<number>(width, func1, func2), {
    isArc: false,
    offset: 0,
    numArray: [],
  });

  // 12-bit middle-endian compression
  const bytes = new Uint8Array((numArray.length * 3 + 1) / 2);
  numArray.map((value: number, index) => {
    const offset = Math.floor(index / 2) * 3;
    if (index % 2 == 0) {
      bytes[offset] = value % 0x100; // low 8 bits in the first byte
      bytes[offset + 1] = (value >> 8) & 0x0f; // hight 4 bits in the low 4 bits of middle byte
    } else {
      bytes[offset + 2] = value % 0x100; // low 8 bits in the third byte
      bytes[offset + 1] |= (value >> 8) * 0x10; // high 4 bits in the high 4 bits of middle byte
    }
  });

  return bytes;
};

export const compressPath = (path: string, height: number) => {
  const normalized = normalizePath(path, height);
  return compressNormalizedPath(normalized, 1024);
};

export const solidityString = (array: Uint8Array) => {
  return Array.from(array)
    .map((value) => {
      return `\\x${value.toString(16).padStart(2, "0")}`;
    })
    .join("");
};


export const decodeCompressData = (bin: string) => {
  const bytes = [];
  for(let i = 0; i < bin.split("").length / 2; i++) {
    bytes.push(parseInt(bin[i * 2] + bin[i*2+1], 16));
  }
  
  const len = bytes.length / 3;
  const numArray = [];
  for(let i = 0; i < len; i++) {
    numArray[i * 2] = bytes[i * 3] + (bytes[i * 3 + 1] & 0x0f) * 256;
    if (bytes[i * 3 + 2] !== undefined) {
      numArray[i * 2 + 1] = bytes[i * 3 + 2] + (bytes[i * 3 + 1] & 0xf0) * 16;
    }
  }
  const pathData = numArray.map(a => {
    // number case;
    if (a > 0x100 ) {
      const c = a - 0x100 - 1024
      return c;
    } else {
      // string case
      return String.fromCharCode(a);
    }
  })
  return pathData.join(" ")
};

export const path2SVG = (path: string) => {
  return `<?xml version="1.0" encoding="UTF-8"?><svg viewBox="0 0 1024 1024"  xmlns="http://www.w3.org/2000/svg"><path d="${path}" /></svg>`
}
