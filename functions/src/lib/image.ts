import sharp from "sharp";

export const svgToPNG = async (svg:string,size) => {
  try {
    // resize
    console.log(size);
    return await sharp(svg)
      .png()
      .toBuffer();      
  } catch (e) {
    console.log("error", e);
  }
  return false;
};