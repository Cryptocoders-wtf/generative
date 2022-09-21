import * as functions from "firebase-functions";

import { test } from "../../functions/test";

export default functions
  .region("asia-northeast1")
  .runWith({
    memory: "1GB",
  })
  .https.onCall(async (data, context) => {
    return await test(data, context);
  });
