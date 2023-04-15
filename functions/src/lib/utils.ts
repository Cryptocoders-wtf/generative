import * as functions from "firebase-functions";
import * as Sentry from "@sentry/node";


export const idRegex = /^[0-9a-zA-Z-]+$/;
export const getRegion = () => {
  const locale = functions.config().locale;
  return (locale && locale.region) || "US";
};

export const validate_auth = (
  context: functions.https.CallableContext 
) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called while authenticated."
    );
  }
  return context.auth.uid;
};

export const validate_admin_auth = (
  context: functions.https.CallableContext 
) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called while authenticated."
    );
  }
  return context.auth?.token?.parentUid || context.auth.uid;
};
export const validate_parent_admin_auth = (
  context: functions.https.CallableContext 
) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called while authenticated."
    );
  }
  if (context.auth?.token?.parentUid) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called parent user."
    );
  }
  return context.auth.uid;
};
export const is_admin_auth = (
  context: functions.https.CallableContext 
) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called while authenticated."
    );
  }
  return !!context.auth?.token?.email;
};

export const validate_params = (params) => {
  const errors = Object.keys(params).filter((key) => {
    return params[key] === undefined;
  });
  if (errors.length > 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing parameters.",
      { params: errors }
    );
  }
};

export const process_error = (error: any) => {
  console.error(error);
  Sentry.captureException(error);
  if (error instanceof functions.https.HttpsError) {
    return error;
  }
  return new functions.https.HttpsError("internal", error.message);
};

export const filterData = (data: { [key: string]: any }) => {
  return Object.keys(data).reduce((tmp: { [key: string]: any }, key) => {
    if (data[key] !== null && data[key] !== undefined) {
      tmp[key] = data[key];
    }
    return tmp;
  }, {});
};

export const isEmpty = (value: any) => {
  return value === null || value === undefined || value === "";
};
